cmake_minimum_required(VERSION 3.22)
project(purecpp_chunks_clean VERSION 1.0)

 
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CUDA_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON) 
# set(CMAKE_CXX_EXTENSIONS OFF) 
set(CMAKE_BUILD_TYPE "Release")

# ───────────────────────────────────────────────────────────
#------- Path to FAISS -------
# ───────────────────────────────────────────────────────────
#...


# ───────────────────────────────────────────────────────────
#------- Compiler Specific flags -------
# ───────────────────────────────────────────────────────────
if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")# Flags específicas do MSVC
    #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++latest")
    set(CMAKE_TOOLCHAIN_FILE ${CMAKE_BINARY_DIR}/generators/conan_toolchain.cmake)
    #set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Od")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Od /EHsc /MP /openmp /MD")
    #set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /fPIC /EHsc /Ox /DNDEBUG")
else() # Flags para G++/Clang ou G++/GNU em Linux
    # Mantém as flags de otimização e adiciona -std=c++23
    set(CMAKE_TOOLCHAIN_FILE ${CMAKE_BINARY_DIR}/Release/generators/conan_toolchain.cmake)
    # set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC  -Wall -Wextra -Wpedantic") # Debug
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -fopenmp -pthread")
    set(CMAKE_CXX_FLAGS_RELEASE "-O0 -std=c++23") #-flto?
    # set(CMAKE_CXX_FLAGS_RELEASE "-O2 -DNDEBUG")
endif()


# ───────────────────────────────────────────────────────────
#------- Options -------
# ───────────────────────────────────────────────────────────

option(CURL_STATIC_LINKING "Set to ON to build libcurl with static linking." OFF)

if(CURL_STATIC_LINKING)
    message("-DCURL_STATICLIB [added]")
    add_definitions(-DCURL_STATICLIB)
endif()


# ───────────────────────────────────────────────────────────
#------- Find Python  -------
# ───────────────────────────────────────────────────────────
set(Python3_FIND_SHARED OFF)
find_package(Python3 REQUIRED COMPONENTS Interpreter Development.Module)

if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    set(PYTHON_LIB_PATH "C:\\Program Files\\Python312\\libs")
    link_directories(${Python3_LIBRARY_DIRS})
endif()

include_directories(${Python3_INCLUDE_DIRS})


# ───────────────────────────────────────────────────────────
#------- Find Pybind11 -------
# ───────────────────────────────────────────────────────────
message(STATUS "---------------------------------------\n")
if(Python3_VERSION_MAJOR EQUAL 3 AND Python3_VERSION_MINOR EQUAL 8)
    message(STATUS "Python 3.8 detected!!")
    set(pybind11_DIR "/opt/python/cp38-cp38/lib/python3.8/site-packages/pybind11/share/cmake/pybind11")
    # add_definitions(-DPy_LIMITED_API=0x03080000)

elseif(Python3_VERSION_MAJOR EQUAL 3 AND Python3_VERSION_MINOR EQUAL 9)
    message(STATUS "Python 3.9 detected!!")
    set(pybind11_DIR "/opt/python/cp39-cp39/lib/python3.9/site-packages/pybind11/share/cmake/pybind11")
    # add_definitions(-DPy_LIMITED_API=0x03090000)

elseif(Python3_VERSION_MAJOR EQUAL 3 AND Python3_VERSION_MINOR EQUAL 10)
    message(STATUS "Python 3.10 detected!!")
    set(pybind11_DIR "/opt/python/cp310-cp310/lib/python3.10/site-packages/pybind11/share/cmake/pybind11")
    # add_definitions(-DPy_LIMITED_API=0x030A0000)

elseif(Python3_VERSION_MAJOR EQUAL 3 AND Python3_VERSION_MINOR EQUAL 11)
    message(STATUS "Python 3.11 detected!!")
    set(pybind11_DIR "/opt/python/cp311-cp311/lib/python3.11/site-packages/pybind11/share/cmake/pybind11")
    # add_definitions(-DPy_LIMITED_API=0x030B0000)

elseif(Python3_VERSION_MAJOR EQUAL 3 AND Python3_VERSION_MINOR EQUAL 12)
    message(STATUS "Python 3.12 detected!!")
    set(pybind11_DIR "/opt/python/cp312-cp312/lib/python3.12/site-packages/pybind11/share/cmake/pybind11")
    # add_definitions(-DPy_LIMITED_API=0x030C0000)

elseif(Python3_VERSION_MAJOR EQUAL 3 AND Python3_VERSION_MINOR EQUAL 13)
    message(STATUS "Python 3.13 detected!")
    set(pybind11_DIR "/opt/python/cp313-cp313/lib/python3.13/site-packages/pybind11/share/cmake/pybind11")
    # add_definitions(-DPy_LIMITED_API=0x030D0000)

else()
    message(STATUS "Python version not specified in previous if's!")
    # Default setting or other action
    
endif()

find_package(pybind11 REQUIRED)

# ───────────────────────────────────────────────────────────
#------- Find other dependencies -------
# ───────────────────────────────────────────────────────────
find_package(pdfium REQUIRED)         
find_package(OpenMP REQUIRED)         
find_package(ICU REQUIRED)            
find_package(miniz REQUIRED)           
find_package(rapidxml REQUIRED)       
find_package(beauty REQUIRED)          
find_package(lexbor REQUIRED)         
find_package(re2 REQUIRED)            
find_package(nlohmann_json REQUIRED)  
#find_package(fmt REQUIRED)            
find_package(CURL REQUIRED)            
find_package(Threads REQUIRED)          

# ───────────────────────────────────────────────────────────
#------- Protobuf -------
# ───────────────────────────────────────────────────────────

find_package(Protobuf REQUIRED)

if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    link_directories(${Protobuf_LIBRARY_DIRS})
    include_directories(C:/vcpkg/packages/protobuf_x64-windows/include)
    if (NOT DEFINED PROTOBUF_PROTOC_EXECUTABLE)
        set(PROTOBUF_PROTOC_EXECUTABLE "C:/vcpkg/packages/protobuf_x64-windows/tools/protobuf/protoc.exe")
    endif()
endif()

find_package(onnxruntime REQUIRED) 

# ───────────────────────────────────────────────────────────
#------- Torch -------
# ───────────────────────────────────────────────────────────
#...


# ───────────────────────────────────────────────────────────
#------- RPATH -------
# ───────────────────────────────────────────────────────────
#------- RPATH/RUNPATH/LIBRARY_PATH Configuration -------

set(CMAKE_BUILD_RPATH
    "${PYTHON_SITE_PACKAGES}/*/d_libs/libtorch/cpu/lib"
    "\$ORIGIN/../purecpp_extract.libs"
    "\$ORIGIN/purecpp_extract.libs"
    "\$ORIGIN/../purecpp_extract.libs"
    "\$ORIGIN/purecpp_extract.libs"
    "\$ORIGIN/d_libs/libtorch/cpu/lib"

    "${CMAKE_SOURCE_DIR}/../../libs/libtorch/cpu/lib"
    "${CMAKE_SOURCE_DIR}/../libs/libtorch/cpu/lib"
    "${CMAKE_SOURCE_DIR}/libs/libtorch/cpu/lib"

    "\$ORIGIN/../../libs/libtorch/cpu/lib"
    "\$ORIGIN/../libs/libtorch/cpu/lib"
    "\$ORIGIN/libs/libtorch/cpu/lib"

    "\$ORIGIN:/usr/bin/protoc"
    "/usr/lib/x86_64-linux-gnu"
    "/usr/lib64"

    "\$ORIGIN/"
    "\$ORIGIN/../purecpp_chunks_clean/d_libs/libtorch/cpu/lib"
)

set(CMAKE_INSTALL_RPATH 
    "${PYTHON_SITE_PACKAGES}/*/d_libs/libtorch/cpu/lib"
    "\$ORIGIN/../purecpp_extract.libs"
    "\$ORIGIN/purecpp_extract.libs"
    "\$ORIGIN/../purecpp_extract.libs"
    "\$ORIGIN/purecpp_extract.libs"
    "\$ORIGIN/d_libs/libtorch/cpu/lib"
    "${CMAKE_SOURCE_DIR}/../../libs/libtorch/cpu/lib"
    "${CMAKE_SOURCE_DIR}/../libs/libtorch/cpu/lib"
    "${CMAKE_SOURCE_DIR}/libs/libtorch/cpu/lib"

    "\$ORIGIN/../../libs/libtorch/cpu/lib"
    "\$ORIGIN/../libs/libtorch/cpu/lib"
    "\$ORIGIN/libs/libtorch/cpu/lib"

    "\$ORIGIN:/usr/bin/protoc"
    "/usr/lib/x86_64-linux-gnu"
    "/usr/lib64"

    "\$ORIGIN/"
    "\$ORIGIN/../purecpp_chunks_clean/d_libs/libtorch/cpu/lib"
)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--enable-new-dtags")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
#------- RPATH/RUNPATH/LIBRARY_PATH Configuration -------

# ───────────────────────────────────────────────────────────
#------- Tokenizers -------
# ───────────────────────────────────────────────────────────
#...


# ───────────────────────────────────────────────────────────
# ----- Project sources -----
# ───────────────────────────────────────────────────────────

# set(RagPUREAI_BINDING_SRCS  ${CMAKE_SOURCE_DIR}/../src/binding_extract.cpp) # Para compilar o binding.cpp
set(RagPUREAI_BINDING_SRCS  binding_extract.cpp)

set(RagPUREAI_IMPL_SRCS
    ${CMAKE_SOURCE_DIR}/../../libs/StringUtils/StringUtils.cpp
    ${CMAKE_SOURCE_DIR}/../../components/DataLoader/BaseLoader.cpp
    ${CMAKE_SOURCE_DIR}/../../components/DataLoader/PDFLoader/PDFLoader.cpp
    ${CMAKE_SOURCE_DIR}/../../components/DataLoader/DOCXLoader/DOCXLoader.cpp
    ${CMAKE_SOURCE_DIR}/../../components/DataLoader/WebLoader/WebLoader.cpp
    ${CMAKE_SOURCE_DIR}/../../components/DataLoader/TXTLoader/TXTLoader.cpp
)

# ───────────────────────────────────────────────────────────
#------- RagPUREAI Library -------
# ───────────────────────────────────────────────────────────

add_library(RagPUREAILib STATIC ${RagPUREAI_IMPL_SRCS})

target_include_directories(RagPUREAILib PUBLIC #.h
    ${CMAKE_SOURCE_DIR}/../../libs/RagException
    ${CMAKE_SOURCE_DIR}/../../libs/ThreadSafeQueue
    ${CMAKE_SOURCE_DIR}/../../libs/CommonStructs
    ${CMAKE_SOURCE_DIR}/../../libs/StringUtils
    ${CMAKE_SOURCE_DIR}/../../libs/FileUtils
    ${CMAKE_SOURCE_DIR}/../../libs/MemoryUtils
    #C:/vcpkg/packages/protobuf_x64-windows/include
    ${CURL_INCLUDE_DIRS}

    ${CMAKE_SOURCE_DIR}/../../components/DataLoader
)


# ───────────────────────────────────────────────────────────
# Link libraries with RagPUREAILib
# ───────────────────────────────────────────────────────────

target_link_libraries(RagPUREAILib PUBLIC
    pdfium::pdfium
    icu::icu
    miniz::miniz
    rapidxml::rapidxml
    beauty::beauty
    #fmt::fmt
    lexbor::lexbor_static       
    re2::re2
    protobuf::libprotobuf      
    onnxruntime::onnxruntime    
    OpenMP::OpenMP_CXX         
    Threads::Threads 
    CURL::libcurl
    nlohmann_json::nlohmann_json
    ${Python3_LIBRARIES}
    # ${TORCH_LIBRARIES}        
    # tokenizers_cpp
)

# ───────────────────────────────────────────────────────────
#---------------- Pybind11 Module
# ───────────────────────────────────────────────────────────

pybind11_add_module(purecpp_extract ${RagPUREAI_BINDING_SRCS})

target_link_libraries(purecpp_extract PRIVATE RagPUREAILib)

# ───────────────────────────────────────────────────────────
#---------------- DEBUG MESSAGES
# ───────────────────────────────────────────────────────────

# message(STATUS "-------------Caminho previsto para Torch_L: ${TORCH_LIBRARIES}")
# 