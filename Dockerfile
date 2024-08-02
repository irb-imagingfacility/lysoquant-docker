FROM ubuntu:18.04

LABEL org.opencontainers.image.ref.name=ubuntu
LABEL org.opencontainers.image.version=18.04

ENV NVARCH=x86_64

ENV NV_CUDA_CUDART_VERSION=10.2.89-1
ENV NV_CUDA_COMPAT_PACKAGE=cuda-compat-10-2

RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/${NVARCH}/3bf863cc.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/${NVARCH} /" > /etc/apt/sources.list.d/cuda.list && \
    apt-get purge --autoremove -y curl \
    && rm -rf /var/lib/apt/lists/* # buildkit

ENV CUDA_VERSION=10.2.89

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-10-2=${NV_CUDA_CUDART_VERSION} \
    ${NV_CUDA_COMPAT_PACKAGE} \
    && ln -s cuda-10.2 /usr/local/cuda \
    && rm -rf /var/lib/apt/lists/* # buildkit

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf \
    && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf # buildkit

ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

ENV NV_CUDA_LIB_VERSION=10.2.89-1
ENV NV_NVTX_VERSION=10.2.89-1
ENV NV_LIBNPP_VERSION=10.2.89-1
ENV NV_LIBNPP_PACKAGE=cuda-npp-10-2=10.2.89-1
ENV NV_LIBCUSPARSE_VERSION=10.2.89-1
ENV NV_LIBCUBLAS_PACKAGE_NAME=libcublas10
ENV NV_LIBCUBLAS_VERSION=10.2.2.89-1
ENV NV_LIBCUBLAS_PACKAGE=libcublas10=10.2.2.89-1
ENV NV_LIBNCCL_PACKAGE_NAME=libnccl2
ENV NV_LIBNCCL_PACKAGE_VERSION=2.8.4-1
ENV NCCL_VERSION=2.8.4-1
ENV NV_LIBNCCL_PACKAGE=libnccl2=2.8.4-1+cuda10.2

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-10-2=${NV_CUDA_LIB_VERSION} \
    ${NV_LIBNPP_PACKAGE} \
    cuda-nvtx-10-2=${NV_NVTX_VERSION} \
    cuda-cusparse-10-2=${NV_LIBCUSPARSE_VERSION} \
    ${NV_LIBCUBLAS_PACKAGE} \
    ${NV_LIBNCCL_PACKAGE} \
    && rm -rf /var/lib/apt/lists/* # buildkit

RUN apt-mark hold ${NV_LIBCUBLAS_PACKAGE_NAME} ${NV_LIBNCCL_PACKAGE_NAME} # buildkit

ENV NV_CUDA_LIB_VERSION=10.2.89-1
ENV NV_CUDA_CUDART_DEV_VERSION=10.2.89-1
ENV NV_NVML_DEV_VERSION=10.2.89-1
ENV NV_LIBCUSPARSE_DEV_VERSION=10.2.89-1
ENV NV_LIBNPP_DEV_VERSION=10.2.89-1
ENV NV_LIBNPP_DEV_PACKAGE=cuda-npp-dev-10-2=10.2.89-1
ENV NV_LIBCUBLAS_DEV_VERSION=10.2.2.89-1
ENV NV_LIBCUBLAS_DEV_PACKAGE_NAME=libcublas-dev
ENV NV_LIBCUBLAS_DEV_PACKAGE=libcublas-dev=10.2.2.89-1
ENV NV_CUDA_NSIGHT_COMPUTE_VERSION=10.2.89-1
ENV NV_CUDA_NSIGHT_COMPUTE_DEV_PACKAGE=cuda-nsight-compute-10-2=10.2.89-1
ENV NV_NVPROF_VERSION=10.2.89-1
ENV NV_NVPROF_DEV_PACKAGE=cuda-nvprof-10-2=10.2.89-1
ENV NV_LIBNCCL_DEV_PACKAGE_NAME=libnccl-dev
ENV NV_LIBNCCL_DEV_PACKAGE_VERSION=2.8.4-1
ENV NCCL_VERSION=2.8.4-1
ENV NV_LIBNCCL_DEV_PACKAGE=libnccl-dev=2.8.4-1+cuda10.2

RUN apt-get update && apt-get install -y --no-install-recommends \
    libtinfo5 libncursesw5 \
    cuda-cudart-dev-10-2=${NV_CUDA_CUDART_DEV_VERSION} \
    cuda-command-line-tools-10-2=${NV_CUDA_LIB_VERSION} \
    cuda-minimal-build-10-2=${NV_CUDA_LIB_VERSION} \
    cuda-libraries-dev-10-2=${NV_CUDA_LIB_VERSION} \
    cuda-nvml-dev-10-2=${NV_NVML_DEV_VERSION} \
    ${NV_NVPROF_DEV_PACKAGE} \
    ${NV_LIBNPP_DEV_PACKAGE} \
    cuda-cusparse-dev-10-2=${NV_LIBCUSPARSE_DEV_VERSION} \
    ${NV_LIBCUBLAS_DEV_PACKAGE} \
    ${NV_LIBNCCL_DEV_PACKAGE} \
    ${NV_CUDA_NSIGHT_COMPUTE_DEV_PACKAGE} \
    && rm -rf /var/lib/apt/lists/* # buildkit

RUN apt-mark hold ${NV_LIBCUBLAS_DEV_PACKAGE_NAME} ${NV_LIBNCCL_DEV_PACKAGE_NAME} # buildkit

ENV LIBRARY_PATH=/usr/local/cuda/lib64/stubs

ENV uid=1000
ENV gid=1000
ENV USER=unetuser

# suppress tzdata prompts
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y sudo wget unzip openssh-server git build-essential \
      cmake libxml2 libboost-system-dev libboost-thread-dev libboost-filesystem-dev \
      libprotobuf-dev protobuf-compiler libhdf5-serial-dev libatlas-base-dev \
      libgoogle-glog-dev python3-dev python3-numpy libboost-python-dev \
      software-properties-common libssl-dev openssl && \
    rm -rf /var/lib/apt/lists/*

COPY cudnn-10.2-linux-x64-v7.6.5.32.tgz /
RUN tar xzf /cudnn-10.2-linux-x64-v7.6.5.32.tgz -C /usr/local

# Install recent CMake
RUN git clone --depth 1 --branch v3.23.5 https://github.com/Kitware/CMake.git && \
#RUN git clone https://github.com/Kitware/CMake.git && \
    cd CMake && \
    mkdir x86_64 && \
    cd x86_64 && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j && sudo make install && \
    cd ~ && \
    rm -rf CMake

RUN useradd -m -s /bin/bash ${USER} && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER}

USER ${USER}
ENV HOME=/home/${USER}
WORKDIR ${HOME}

# Setup environment
RUN echo ". ~/.bashrc" > .profile && \
    echo "COL=\"\\\\[\\\\033[0;33m\\\\]\"" > .bashrc && \
    echo "COL2=\"\\\\[\\\\033[1;31m\\\\]\"" >> .bashrc && \
    echo "NOCOL=\"\\\\[\\\\033[m\\\\]\"" >> .bashrc && \
    echo "export PS1=\"\${COL}\\\\u@\\\\h:\\\\w$ \${NOCOL}\"" >> .bashrc && \
    echo "export CUDA_HOME=\"/usr/local/cuda\"" >> .bashrc && \
    git clone https://github.com/BVLC/caffe.git && \
    cd caffe && \
    git checkout 99bd99795dcdf0b1d3086a8d67ab1782a8a08383 && \
    wget -nv --no-check-certificate https://lmb.informatik.uni-freiburg.de/lmbsoft/unet/caffe_unet_99bd99_20190109.patch && \
    git apply caffe_unet_99bd99_20190109.patch && \
    mkdir x86_64 && \
    cd x86_64 && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS_RELEASE="-O2 -DNDEBUG" \
    	  -DCMAKE_C_FLAGS_RELEASE="-O2 -DNDEBUG" -DCPU_ONLY=OFF \
	  -DUSE_OPENMP=ON -DCMAKE_INSTALL_PREFIX=/usr/local \
	  -DBUILD_SHARED_LIBS=ON -DBUILD_docs=OFF \
	  -DBUILD_matlab=OFF -DUSE_OPENCV=OFF -DUSE_LEVELDB=OFF \
	  -DUSE_LMDB=OFF -DUSE_NCCL=OFF -DBUILD_python=OFF \
	  -DCUDA_ARCH_NAME=Manual \
	  -DCUDA_ARCH_BIN="30 35 50 60 61 62" \
	  -DCUDA_ARCH_PTX="30" -DUSE_CUDNN=ON \
          .. && \
    make -j && sudo make install

COPY lysoquant.tgz ${HOME} 

RUN tar xzf lysoquant.tgz

SHELL ["/bin/bash", "-c"]
ENTRYPOINT echo "== Set password for unetuser == " && \
           sudo passwd unetuser && \
	   ssh-keygen -t rsa -b 2048 -q -N "" -f ${HOME}/.ssh/id_rsa -C "lysoquant-server" && \
	   ssh-keygen -t rsa -b 2048 -q -N "" -f ${HOME}/.ssh/lysoquant-client -C "lysoquant-client" && \
           touch ${HOME}/.ssh/authorized_keys && \
	   chmod 600 ${HOME}/.ssh/authorized_keys && \
           cat ${HOME}/.ssh/lysoquant-client.pub >> ${HOME}/.ssh/authorized_keys && \
           sudo service ssh start && \
           sudo rm /etc/sudoers.d/${USER} && \
	   echo "== Copy this to your client and use as Lysoquant RSA KEY ==" && \
           cat ${HOME}/.ssh/lysoquant-client && \ 
	   /bin/bash
