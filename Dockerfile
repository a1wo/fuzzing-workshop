FROM ubuntu:24.04 AS aflplusplus-builder
USER root
# Set build arguments
ARG AFLPLUSPLUS_COMMIT=4f53803dfeca8f9da66aedbabeb25939031b8a57 # 4.30c version

RUN rm -rf /var/lib/apt/lists/*
RUN apt-get update -o Acquire::CompressionTypes::Order::=gz
RUN apt-get update -y && apt-get upgrade -y
RUN apt update
# RUN echo "=== BEFORE sed ===" && cat /etc/apt/sources.list.d/ubuntu.sources
RUN sed -i 's|http://ports.ubuntu.com/ubuntu-ports|http://archive.ubuntu.com/ubuntu|g' /etc/apt/sources.list.d/ubuntu.sources
# RUN echo "=== AFTER sed ===" && cat /etc/apt/sources.list.d/ubuntu.sources


# Install build dependencies with better error handling

RUN apt-get clean && rm -rf /var/lib/apt/lists/* && \
    apt-get update -qq
    
RUN apt-get -y --no-install-recommends --fix-missing --allow-unauthenticated install \
  autoconf \
  automake \
  build-essential \
  cmake \
  git-core \
  git \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update -qq && apt-get -y --no-install-recommends --fix-missing install \
  llvm \
  llvm-dev \
  clang \
  clang-tools \
  lld \
  llvm-runtime \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update -qq && apt-get -y --no-install-recommends --fix-missing install \
  wget \
  gnupg \
  software-properties-common \
  python3 \
  python3-pip \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install LLVM 16 from official repository
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    echo "deb http://apt.llvm.org/noble/ llvm-toolchain-noble-16 main" >> /etc/apt/sources.list && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    apt-get update -qq
    
RUN apt-get -y --no-install-recommends --fix-missing install \
    llvm-16 \
    llvm-16-dev \
    llvm-16-tools \
    clang-16 \
    clang-16-doc \
    libclang-common-16-dev \
    libclang-16-dev \
    libclang1-16 \
    clang-format-16 \
    clangd-16 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set LLVM 16 as default
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-16 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-16 100 && \
    update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-16 100

# Install updated GDB and debugging tools
RUN apt-get update -qq && apt-get -y --no-install-recommends --fix-missing install \
    gdb \
    gdb-multiarch \
    valgrind \
    strace \
    ltrace \
    binutils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install meson and ninja using system packages
RUN apt-get update -qq && apt-get -y --no-install-recommends --fix-missing install \
    meson \
    ninja-build \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Utils for working in the docker
RUN apt-get update -qq && apt-get -y --no-install-recommends --fix-missing install \
    curl \
    vim \
    apt \
    htop \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install utilities for a lot of libraries
RUN apt-get update -qq && apt-get -y --no-install-recommends --fix-missing install \
    build-essential \
    libtool \
    autoconf \
    automake \
    libglib2.0-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Install and build AFL++
WORKDIR /afl
RUN mkdir $HOME/afl/ && \
    cd $HOME/afl/ && \
    git clone https://github.com/AFLplusplus/AFLplusplus.git . && \
    git reset --hard ${AFLPLUSPLUS_COMMIT} && \
    make source-only -j$(nproc) && \
    make install -j$(nproc)  && \
    cd .. && rm -rf /AFLplusplus

# Set environment variables for fuzzing
ENV CC=clang-16
ENV CXX=clang++-16
ENV AFL_SKIP_CPUFREQ=1
ENV AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
