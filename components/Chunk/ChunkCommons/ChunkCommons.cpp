#include "ChunkCommons.h"
#include "RagException.h"
#include "StringUtils.h"

#include <nlohmann/json.hpp>
#include <onnxruntime/core/session/onnxruntime_cxx_api.h>
#include <onnxruntime/cpu_provider_factory.h>
#include <openai/openai.hpp>
#include <tokenizers_cpp.h>
#include <torch/script.h>

#include <algorithm>
#include <cmath>
#include <numeric>
#include <omp.h>
#include <syncstream>
#include <format>

using namespace Chunk;

//-----------------------------------------------------------------------------------------------------------

/**
 * @brief Parameterized constructor that validates data size.
 */
Chunk::vdb_data::vdb_data(std::vector<float> data, std::string vdr, std::string mdl, size_t d, size_t count)
    : flatVD(std::move(data)), vendor(std::move(vdr)), model(std::move(mdl)), dim(d), n(count)
{
    if (flatVD.size() != dim * n) {
        throw std::invalid_argument("flatVD size mismatch with n * dim");
    }
}

/**
 * @brief Returns (n, dim) as a tuple representing the dataset shape.
 */
std::tuple<size_t, size_t> Chunk::vdb_data::getPar() const noexcept {
    return { n, dim };
}

/**
 * @brief Returns (vendor, model) metadata as a pair of strings.
 */
std::pair<std::string, std::string> Chunk::vdb_data::getEmbPar() const noexcept {
    return { vendor, model };
}

/**
 * @brief Returns a raw pointer to the underlying float buffer.
 * @note Prints a warning message if the buffer is empty.
 */
const float* Chunk::vdb_data::getVDpointer() const {
    if (flatVD.empty()) {
        std::cerr << "[Info] Empty Vector Data Base\n";
        return nullptr;
    }
    return flatVD.data();
}

/**
 * @brief Returns a span view over the embedding buffer.
 * @note Provides a modern, bounds-safe view without copying data.
 */
std::span<const float> Chunk::vdb_data::getView() const {
    if (flatVD.empty()) {
        std::cerr << "[Info] Empty Vector Data Base\n";
        return {};
    }
    return { flatVD.data(), flatVD.size() };
}

/**
 * @brief Checks whether the embedding data is empty.
 */
bool Chunk::vdb_data::empty() const noexcept {
    return flatVD.empty();
}

/**
 * @brief Returns the total number of floats stored in flatVD.
 */
size_t Chunk::vdb_data::totalSize() const noexcept {
    return flatVD.size();
}
//-----------------------------------------------------------------------------------------------------------
std::vector<RAGLibrary::Document> Chunk::Embeddings(const std::vector<RAGLibrary::Document>& list, std::string model)
{     
    std::vector<RAGLibrary::Document> emb;

    std::optional<std::string> vendor_opt = Chunk::resolve_vendor_from_model(model);
    if (!vendor_opt.has_value()) {
        throw std::invalid_argument("Model not supported.");
    }
    std::string vendor = vendor_opt.value();

    if (vendor == "openai") {
        int count = 0;
        Chunk::InitAPIKey();
        do {
            try {
                auto client = std::make_unique<EmbeddingOpenAI::EmbeddingOpenAI>();
                emb = client->GenerateEmbeddings(list, model);
            } catch (const std::exception& e) {
                std::cerr << "[OpenAI::GenerateEmbeddings exception] "
                          << e.what() << " (attempt " << count + 1 << ")\n";
            }
            count++;
        } while (!Chunk::allChunksHaveEmbeddings(emb) && count < 3);

        if (!Chunk::allChunksHaveEmbeddings(emb)) {
            throw std::runtime_error("Failed to generate valid embeddings after 3 attempts.");
        }

        return emb;
    }

    // futuros vendors podem entrar aqui
    //else if (vendor == "huggingface") {
        //auto client = std::make_unique<EmbeddingHF::EmbeddingHF>();
        //emb = client->GenerateEmbeddings(list, m_model);
        //return emb;
    //}

    throw std::runtime_error("Vendor handler for '" + vendor + "' not implemented.");
}

namespace RAGLibrary
{   
    static std::string FileReader(const std::string &filePath)
    {
        std::shared_ptr<std::ifstream> filePtr(new std::ifstream, [](std::ifstream *fil)
                                               { fil->close(); });

        try
        {
            filePtr->exceptions(std::ios::failbit);
            filePtr->open(filePath, std::ios::in);
            return {std::istreambuf_iterator<char>{*filePtr}, std::istreambuf_iterator<char>{}};
        }
        catch (const std::ios::failure &e)
        {
            std::osyncstream(std::cerr) << e.what() << std::endl;
            throw RAGLibrary::RagException(e.what());
        }
        return std::string();
    }

}

template <typename T>
inline Ort::Value CreateTensorOrt(Ort::AllocatorWithDefaultOptions &allocator,
                                  std::vector<T> &data, std::vector<int64_t> &shape)
{
    return Ort::Value::CreateTensor<T>(allocator.GetInfo(), data.data(), data.size(), shape.data(), shape.size());
}


//=================================================================================================================================================


std::vector<float> Chunk::MeanPooling(const std::vector<float> &token_embeddings, const std::vector<int64_t> &attention_mask, size_t embedding_size)
{
    size_t num_tokens = token_embeddings.size() / embedding_size;
    std::vector<float> pooled_embeddings(embedding_size, 0.0f);

    for (int i = 0; i < num_tokens; ++i)
    {
        if (attention_mask[i] == 1)
        {
            for (int j = 0; j < embedding_size; ++j)
            {
                pooled_embeddings[j] += token_embeddings[i * embedding_size + j];
            }
        }
    }

    int valid_tokens = std::accumulate(attention_mask.begin(), attention_mask.end(), 0);
    for (int j = 0; j < embedding_size; ++j)
    {
        pooled_embeddings[j] /= std::max(valid_tokens, 1);
    }

    return pooled_embeddings;
}

void Chunk::NormalizeEmbeddings(std::vector<float>& e)
{
    // Usa double para precisão numérica
    const double norm = std::sqrt(std::inner_product(
        e.begin(), e.end(), e.begin(), 0.0, std::plus<>(),
        [](float x, float y) { return static_cast<double>(x) * y; }
    ));

    if (norm <= 1e-12)
        return; // Evita divisão por zero

    const float inv = 1.0f / static_cast<float>(norm);
    for (auto& v : e) v *= inv;
}

std::vector<std::vector<float>> Chunk::EmbeddingModelBatch(const std::vector<std::string> &chunks, const std::string &model, const int batch_size)
{
    const auto model_c = model.c_str();
    const std::string modelPath = std::format("models/{}/model.onnx", model_c);
    const std::string tokenizerPath = std::format("models/{}/tokenizer.json", model_c);

    auto env = std::make_shared<Ort::Env>(ORT_LOGGING_LEVEL_WARNING, "NER");
    Ort::SessionOptions sessionOptions;
    sessionOptions.SetInterOpNumThreads(1);

    auto session = std::make_shared<Ort::Session>(*env, modelPath.c_str(), sessionOptions);
    auto blob = RAGLibrary::FileReader(tokenizerPath);
    auto tokenizer = tokenizers::Tokenizer::FromBlobJSON(blob);

    Ort::AllocatorWithDefaultOptions allocator;

    std::vector<std::vector<float>> results;
    for (int start_idx = 0; start_idx < chunks.size(); start_idx += batch_size)
    {
        size_t end_idx = std::min<ptrdiff_t>(start_idx + batch_size, chunks.size());
        std::vector<std::string> texts(chunks.begin() + start_idx, chunks.begin() + end_idx);
        auto encode_batch = tokenizer->EncodeBatch(chunks);

        size_t total_size = std::accumulate(encode_batch.begin(), encode_batch.end(), std::size_t(0),
                                            [](std::size_t sum, const std::vector<int32_t> &encode)
                                            {
                                                return sum + encode.size();
                                            });

        std::vector<int64_t> inputIds(total_size, 0);
        std::vector<int64_t> attentionMask(total_size, 0);
        size_t ii = 0;
        for (int i = 0; i < encode_batch.size(); ++i)
        {
            for (auto index = 0; index < encode_batch[i].size(); ++index)
            {
                inputIds[ii + index] = encode_batch[i][index];
                inputIds[ii + index] > 0 ? attentionMask[ii + index] = 1 : attentionMask[ii + index] = 0;
            }
            ii += encode_batch[i].size();
        }
        std::vector<int64_t> tokenTypeIds(total_size, 0);
        std::vector<int64_t> inputShape{int64_t(encode_batch.size()), int64_t(encode_batch.front().size())};

        auto attentionTensor = CreateTensorOrt<int64_t>(allocator, attentionMask, inputShape);
        auto inputTensor = CreateTensorOrt<int64_t>(allocator, inputIds, inputShape);
        auto tokenTypeTensor = CreateTensorOrt<int64_t>(allocator, tokenTypeIds, inputShape);

        std::vector<Ort::Value> inputTensors;
        inputTensors.emplace_back(std::move(inputTensor));
        inputTensors.emplace_back(std::move(attentionTensor));
        inputTensors.emplace_back(std::move(tokenTypeTensor));

        const char *inputNames[] = {"input_ids", "attention_mask", "token_type_ids"};
        const char *outputNames[] = {"logits"};
        std::vector<Ort::Value> outputTensors = session->Run(Ort::RunOptions(nullptr), inputNames, inputTensors.data(), 3, outputNames, 1);

        float *logits = outputTensors.front().GetTensorMutableData<float>();
        size_t outputSize = outputTensors.front().GetTensorTypeAndShapeInfo().GetElementCount();

        results.reserve(results.size() + encode_batch.size());
        ii = 0;
        size_t numLabels = outputSize / total_size;
        for (int i = 0; i < encode_batch.size(); i++)
        {
            std::vector<float> tokenLogits(logits + ii * numLabels, logits + (ii + encode_batch[i].size()) * numLabels);
            results.push_back(std::move(tokenLogits));
            ii += encode_batch[i].size();
        }
    }

    return results;
}

std::vector<std::vector<float>> Chunk::EmbeddingOpeanAI(const std::vector<std::string> &chunks, const std::string &openai_api_key)
{
    std::vector<std::vector<float>> results;
    openai::start(openai_api_key);
    results.reserve(chunks.size());
    for (int i = 0; i < chunks.size(); i++)
    {
        auto &chunk = chunks[i];
        auto startTime = std::chrono::high_resolution_clock::now();
        auto values = openai::embedding().create(openai::_detail::Json{
            {"input", std::vector<std::string>{chunk}},
            {"model", "text-embedding-ada-002"},
        })["data"][0]["embedding"];
        if (values.is_array())
        {
            results.push_back(values.get<std::vector<float>>());
        }
    }
    return results;
}

at::Tensor Chunk::toTensor(std::vector<std::vector<float>> &vect)
{
    int64_t n = vect.size();
    int64_t m = vect.front().size();
    auto options = torch::TensorOptions().dtype(torch::kFloat32);
    auto tensor = torch::zeros({n, m}, options);
    for (int64_t i = 0; i < n; ++i)
    {
        tensor.slice(0, i, i + 1) = torch::from_blob(vect[i].data(), {m}, options);
    }
    return tensor;
}


std::vector<std::string>
Chunk::SplitText(std::string inputs, int overlap, int chunk_size)
{
    // if (chunk_size <= 0) throw std::invalid_argument("chunk_size <= 0");
    // if (overlap < 0)     throw std::invalid_argument("overlap < 0");
    // if (overlap >= chunk_size)
    //     throw std::invalid_argument("overlap must be < chunk_size");

    const size_t step = size_t(chunk_size - overlap);
    const size_t n_chunks = (inputs.empty() ? 0 :
        (inputs.size() + step - 1) / step);

    std::vector<std::string> chunks;
    chunks.reserve(n_chunks);

    for (size_t i = 0; i < n_chunks; ++i) {
        size_t start = i * step;
        size_t end   = std::min(start + size_t(chunk_size), inputs.size());
        chunks.emplace_back(inputs.substr(start, end - start));
    }
    return chunks;
}



std::vector<std::string>
Chunk::SplitTextByCount(const std::string& input, int overlap,
                        int count_threshold, const std::shared_ptr<re2::RE2> regex)
{
    // Sanity checks to ensure parameters are valid
    // if (!regex) throw std::invalid_argument("regex null");
    // if (count_threshold <= 0) throw std::invalid_argument("count_threshold <= 0");
    // if (overlap < 0) throw std::invalid_argument("overlap < 0");

    // Vector to store regex matches as StringPiece views over the original input
    std::vector<re2::StringPiece> matches;

    // Copy of input used by RE2 to consume matches
    re2::StringPiece text(input), m;

    // Extract all regex matches from the input and store them
    while (re2::RE2::FindAndConsume(&text, *regex, &m)) {
        matches.push_back(m);
    }

    std::vector<std::string> chunks;
    size_t start_idx = 0;

    // Process matches in groups of 'count_threshold'
    for (int i = 0; i < (int)matches.size(); i += count_threshold) {
        const int j = std::min(i + count_threshold, (int)matches.size());

        // Compute the end index of the current chunk
        size_t end_idx = input.size();
        if (j > 0) {
            const auto& last = matches[j - 1];
            // Calculate offset using pointer arithmetic relative to input base
            end_idx = (size_t)(last.data() - input.data()) + last.size();
        }

        // Defensive check: ensure end is never before start
        if (end_idx < start_idx) end_idx = start_idx;

        // Extract substring chunk and add it to the result
        chunks.emplace_back(input.substr(start_idx, end_idx - start_idx));

        // Move start index forward, with optional overlap between chunks
        start_idx = (end_idx > (size_t)overlap) ? (end_idx - (size_t)overlap) : 0;
    }

    // Fallback: if no regex matches found, return the whole input as one chunk
    if (chunks.empty()) chunks.emplace_back(input);

    return chunks;
}
