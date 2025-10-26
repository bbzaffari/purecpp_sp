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
    # message(STATUS "\n\n\n\n\n\n\n\n\n\n------------------------> MICROSOFT\n\n\n\n\n\n\n\n\n\n")
    #set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Od")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Od /EHsc /MP /openmp /MD")
    #set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /fPIC /EHsc /Ox /DNDEBUG")
else() # Flags para G++/Clang ou G++/GNU em Linux
    # Mantém as flags de otimização e adiciona -std=c++23
    set(CMAKE_TOOLCHAIN_FILE ${CMAKE_BINARY_DIR}/Release/generators/conan_toolchain.cmake)
    # message(STATUS "\n\n\n\n\n\n\n\n\n\n------------------------> variaveis presentes antes do RELEASE: ${CMAKE_CXX_FLAGS}")
    # set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC  -Wall -Wextra -Wpedantic") # Debug
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -fopenmp -pthread")
    set(CMAKE_CXX_FLAGS_RELEASE "-O0 -std=c++23") #-flto?
    # set(CMAKE_CXX_FLAGS_RELEASE "-O2 -DNDEBUG")
    # message(STATUS "\n\n\n\n\n\n\n\n\n\n------------------------> variaveis presentes depois do RELEASE: ${CMAKE_CXX_FLAGS}\n\n\n\n\n\n\n\n\n\n")
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
set(Python3_FIND_SHARED OFF)# Need it?
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
# message(STATUS "---------------------------------------\n")
# message(STATUS "------------------------> Protobuf_FOUND: ${Protobuf_FOUND}")
# message(STATUS "------------------------> Protobuf_VERSION: ${Protobuf_VERSION}")
# message(STATUS "------------------------> Protobuf_INCLUDE_DIRS: ${Protobuf_INCLUDE_DIRS}")
# message(STATUS "------------------------> Protobuf_LIBRARIES: ${Protobuf_LIBRARIES}")
# message(STATUS "------------------------> Protobuf_PROTOC_EXECUTABLE: ${Protobuf_PROTOC_EXECUTABLE}")
# message(STATUS "------------------------> Protobuf_LITE_LIBRARIES: ${Protobuf_LITE_LIBRARIES}")
# message(STATUS "\n --------------------------------------- ")
# include_directories(${Protobuf_INCLUDE_DIRS})#A principio o target Protobuf_INCLUDE_DIRS n existe, mas n sei se é necessario
# message(STATUS "\n\n\n\n\n\n\n\n\n\n\n\n\n\nTargets disponíveis: ")
# get_property(_TARGETS DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY BUILDSYSTEM_TARGETS)
# foreach(target ${_TARGETS})
#     message(STATUS "  - ${target}")
# endforeach()
# message(STATUS "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n--------------------------------------- ")
if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    link_directories(${Protobuf_LIBRARY_DIRS})
    include_directories(C:/vcpkg/packages/protobuf_x64-windows/include)
    if (NOT DEFINED PROTOBUF_PROTOC_EXECUTABLE)
        # include_directories(${Protobuf_INCLUDE_DIRS})#A principio o target Protobuf_INCLUDE_DIRS n existe, mas n sei se é necessario
        set(PROTOBUF_PROTOC_EXECUTABLE "C:/vcpkg/packages/protobuf_x64-windows/tools/protobuf/protoc.exe")
    endif()
endif()

find_package(onnxruntime REQUIRED)     # Pode depender de protobuf (verifique se precisa!)
# message(STATUS "---------------------------------------\n")
# message(STATUS "------------------------> Protobuf_FOUND: ${Protobuf_FOUND}")
# message(STATUS "------------------------> Protobuf_VERSION: ${Protobuf_VERSION}")
# message(STATUS "------------------------> Protobuf_INCLUDE_DIRS: ${Protobuf_INCLUDE_DIRS}")
# message(STATUS "------------------------> Protobuf_LIBRARIES: ${Protobuf_LIBRARIES}")
# message(STATUS "------------------------> Protobuf_PROTOC_EXECUTABLE: ${Protobuf_PROTOC_EXECUTABLE}")
# message(STATUS "------------------------> Protobuf_LITE_LIBRARIES: ${Protobuf_LITE_LIBRARIES}")
# message(STATUS "\n --------------------------------------- ")

# ───────────────────────────────────────────────────────────────────────
#------- Discover the directory Current Python site-packages -------
# ────────────────────────────────────────────────────────────
# We will use sysconfig to be more robust across multiple Python versions.

execute_process(
    COMMAND "${Python3_EXECUTABLE}" -c
        "import sysconfig; import pathlib; site_packages = sysconfig.get_paths()['purelib']; print(str(pathlib.Path(site_packages).resolve()))"
    OUTPUT_VARIABLE PYTHON_SITE_PACKAGES
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

 
# message(STATUS "------------------------> Encontrado site-packages do Python em: ${PYTHON_SITE_PACKAGES}")

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
    "\$ORIGIN/../purecpp_libs.libs"
    "\$ORIGIN/purecpp_libs.libs"
    "\$ORIGIN/../purecpp_libs.libs"
    "\$ORIGIN/purecpp_libs.libs"
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
    "\$ORIGIN/../purecpp_libs.libs"
    "\$ORIGIN/../purecpp_libs.libs"
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
#------- OpenAI C++ bindings -------
# ───────────────────────────────────────────────────────────
#...


# ───────────────────────────────────────────────────────────
# ----- Project sources -----
# ───────────────────────────────────────────────────────────

set(RagPUREAI_BINDING_SRCS  "binding_libs.cpp")
set(RagPUREAI_IMPL_SRCS
    "${CMAKE_SOURCE_DIR}/../../libs/StringUtils/StringUtils.cpp"
)

# ───────────────────────────────────────────────────────────
#------- RagPUREAI Library -------
# ───────────────────────────────────────────────────────────

add_library(RagPUREAILib STATIC ${RagPUREAI_IMPL_SRCS})

target_include_directories(RagPUREAILib PUBLIC
    # ${CURL_INCLUDE_DIRS}   
    "${CMAKE_SOURCE_DIR}/../../libs/RagException"
    "${CMAKE_SOURCE_DIR}/../../libs/ThreadSafeQueue"
    "${CMAKE_SOURCE_DIR}/../../libs/CommonStructs"
    "${CMAKE_SOURCE_DIR}/../../libs/StringUtils"
    "${CMAKE_SOURCE_DIR}/../../libs/FileUtils"  
    "${CMAKE_SOURCE_DIR}/../../libs/MemoryUtils"
    ${CURL_INCLUDE_DIRS}   
)


# ───────────────────────────────────────────────────────────
# Link libraries with RagPUREAILib
# ───────────────────────────────────────────────────────────

target_link_libraries(RagPUREAILib PUBLIC
        # 🔹 Core Libraries
        pdfium::pdfium
        icu::icu
        miniz::miniz
        rapidxml::rapidxml
        beauty::beauty
        lexbor::lexbor_static
        # 🔹 Math and Optimization Libraries
        OpenMP::OpenMP_CXX
        Threads::Threads
        # 🔹 Auxiliary and Utility Libraries
        #fmt::fmt
        re2::re2
        protobuf::libprotobuf # ONNX and tokenizers may need this
        nlohmann_json::nlohmann_json
        # 🔹 Important External Libraries
        onnxruntime::onnxruntime
        # 🔹 Networking and IO Libraries
        CURL::libcurl
        # 🔹 Dynamic Libraries and Python
        ${Python3_LIBRARIES} # Python must come at the end to avoid symbol conflicts
)


# ───────────────────────────────────────────────────────────
# Link libraries with RagPUREAILib
# ───────────────────────────────────────────────────────────

pybind11_add_module(purecpp_libs ${RagPUREAI_BINDING_SRCS})

target_link_libraries(purecpp_libs PUBLIC RagPUREAILib)


# ───────────────────────────────────────────────────────────
#---------------- DEBUG MESSAGES
# ───────────────────────────────────────────────────────────
