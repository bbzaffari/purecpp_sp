

---
**This repository is my development scratchpad, where all structural changes are designed and documented before being pushed to the official ecosystem.**
> **Note**:
> Please disregard the commit history in this branch.
> 
> Normally, I clean it up using `git reset --soft HEAD~X` to maintain a more concise and readable history—just like I did in the forked version. This is especially useful because I tend to iterate multiple times on documentation files like the README.
>
> This disorganized repository also serves as a sandbox to test commits from the remote repository while verifying dates—something the regular `.git` metadata doesn't always make straightforward.
>
> And since there aren't many people involved, I'm testing and refactoring the build process myself.  That means, occasionally I end up running into a few issues—some related to testing, which I only catch later, and others related to compilation.

---
 
[![Status](https://img.shields.io/badge/status-stable-brightgreen?style=flat-square)](https://github.com/bbzaffari/purecpp) 👉  🔗  [Stable purecpp](https://github.com/bbzaffari/purecpp) 

---
---
---

# PureCPP framework

[![***Status this***](https://img.shields.io/badge/Status-%20Refactoring%20in%20progress-orange.svg)]()
## Overview 
**PureCPP is a powerful C++ backend architecture for RAG systems.**\
Designed for maximum performance and scalability, it integrates vector search, ONNX models, and CPU/CUDA acceleration into a seamless, python integrated framework.

*This repository provides detailed guidance on how to set up the environment, configure dependencies and build.*

## Table of Contents
* **1.** [Environment Setup](#environment-setup)
   - [Docker](#docker)
   - [Local](#local)
* **2.** [Build Instructions](#how-to-build)
* **3.** [Testing Locally](#testing-locally)

🔍 Explore [all of Bruno Bavaresco Zaffari’s contributions (explained)](https://github.com/bbzaffari/Open-Source-RAG-Engine-System-with-Modular-Vector-Processing)
 related to this framework.
 
---

# Environment Setup


## Docker

* **1. Clone the repository along with all its submodules (recursively)**

```bash
git clone --recursive https://github.com/bbzaffari/purecpp_sp
```

* **2. Navigate into the cloned repository folder**

```bash
cd purecpp_sp
```

* **3. Build a Docker image from the current directory and tag it as 'pure_faiss'**

```bash
docker build -t pure_faiss .
```

* **4. Start a Docker container named 'env' from the 'pure_faiss' image, mounting current dir to /home**

```bash
docker run -it --name env -v "$PWD":/home pure_faiss
```

> [!IMPORTANT]
> 
> Once you've created the container using `docker run`, ***you don't need to recreate it again.***
> Instead, follow these two simple commands to ***reuse*** the container:
> ```bash
> docker start env
> ```
> **This command **starts an existing container** that has already been created earlier using `docker run`.**
> ```bash
> docker exec -it env bash
> ```
> **This command **attaches a terminal to the running container**, allowing you to interact with it just like you would with a regular Linux shell.**


* **5. Execute the `env_config.sh`** **(to install FAISS, PyTorch, and configure Conan)**

```bash
chmod +x installers/*.sh
./installers/env_config.sh
```

* **6. [How to Build](#how-to-build)**

---

## Local

> Requirements
> 
> - ***GCC/G++** >= 13.1*
> - ***CMake**   >= 3.22*
> - ***Python** >= 3.8*

### 1. Clone the Repository
   
```bash
git clone --recursive https://github.com/bbzaffari/purecpp_sp
cd purecpp_sp
````

> [!NOTE]
> If you forgot to use `--recursive` when cloning the repository,  
> make sure to run:
>
> ```bash
> git submodule update --init --recursive
> ```
>
> This will initialize and update all required Git submodules.

### 2. Installing dependencies

- **Ubuntu/Debian**
```bash
sudo apt update && \
sudo apt upgrade -y && \
sudo apt install -y \
  build-essential wget curl \
  ninja-build cmake libopenblas-dev \
  libgflags-dev python3-dev libprotobuf-dev \
  protobuf-compiler unzip libssl-dev zlib1g-dev
````
- **RedHat**
```bash
yum update && 
yum install -y \
      gcc gcc-c++ make git curl wget \
      ninja-build libffi-devel openssl-devel \
      protobuf-devel gflags-devel zlib-devel \
      openblas-devel unzip \
````

### 3. Install python essential packages

*In case you do not have a Docker environment available*, we strongly recommend that you use a Python `venv` (virtual environment) to ensure proper isolation of dependencies and reproducibility of results. This practice minimizes conflicts between global packages and project-specific requirements, fostering a cleaner and more maintainable development setup. 

Steps below to create and activate the virtual environment:

  - Create the virtual environment (replace 'venv' with your preferred name)
    ```bash
    python3 -m venv venv
    ````
  - Activate the virtual environment on Linux or macOS
    ```bash
    source venv/bin/activate
    ````

```bash
pip install build conan cmake requests pybind11
````

### 4. Install Rust via rustup

*Run rustup installer non-interactively (-y). This places cargo and rustc in /root/.cargo & activate Rust Environment:*
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env
````

### 5. Execute the `env_config.sh` **(to install FAISS, PyTorch, and configure Conan)**

```bash
chmod +x ./installers/*.sh
./installers/env_config.sh
````

### **6. [How to Build](#how-to-build)**


---

## How to Build

The `build.sh` is a development version pipline, otimizing the process, making it easy to compile and test all five modules.

Before running the provided shell scripts, ensure they have the appropriate execution permissions.
```bash
chmod -R +x ./CMAKE/*/sub_mod_build.sh
chmod +x ./build.sh
````

### Compile all at once
```bash
./build.sh all
````

### Compile one at a time
```bash
./build.sh MODULE-NUMBER
````

Each module (CMAKE_LIBS, CMAKE_META, CMAKE_EMBED, CMAKE_EXTRACT, CMAKE_CHUNKS_CLEAN) has its own **`sub_mod_build.sh`** script, which:
- Cleans the build/ folder
- Installs Conan dependencies if missing
- Compiles the code
- Sends the .so output to the central Sandbox/ directory
  
---

## Testing Locally

The build.sh script will **place** the resulting libraries inside [`Sandbox/`](/Sandbox)

```SourceTree
Sandbox/
    ├── Resources/
    ├── RagPUREAI.cpython-312-x86_64-linux-gnu.so
    └── YOUR-TEST.py
```

## Notebook Playground

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/bbzaffari/purecpp_sp/blob/main/Sandbox/demo_chunk_VDB.ipynb)


---
---
---
