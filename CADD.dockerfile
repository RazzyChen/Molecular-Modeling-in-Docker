# Use NVIDIA HPC SDK as the base image
FROM nvcr.io/nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04

# Set environment variables for user configuration and software versions
ENV USER_NAME=cadd \
    GROMACS_VERSION=2025.0 \
    MAKEFLAGS="-j 12" \
    FFTW_VERSION=3.3.10

# Set display for GUI applications
ENV DISPLAY=host.docker.internal:0.0

# Configure Ubuntu mirror to use Tsinghua source for better download speed in China
RUN echo \
    "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse\n\
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse\n\
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse" \
    > /etc/apt/sources.list

# Install necessary system packages and development tools
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    vim \
    wget \
    openbabel \
    pdb2pqr \
    primus-libs \
    pymol \
    unzip \
    libmpich-dev \
    libopenmpi-dev \
    python3-pip \
    libmotif-dev \
    gedit \
    && rm -rf /var/lib/apt/lists/*

# Create user and setup working directory
RUN useradd -m -s /bin/bash ${USER_NAME} && \
    mkdir -p /home/${USER_NAME}/Software && \
    chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}

# Install Python packages for molecular dynamics analysis
RUN su - ${USER_NAME} -c "pip install gmx_MMPBSA DuIvyTools" && \
    echo "export PATH=/home/${USER_NAME}/.local/bin:\$PATH" >> /home/${USER_NAME}/.bashrc

# Download and install Sobtop and Multiwfn for molecular analysis
RUN cd /home/${USER_NAME} && \
    wget -c http://sobereva.com/soft/Sobtop/sobtop_1.0\(dev5\).zip && \
    wget -c http://sobereva.com/multiwfn/misc/Multiwfn_3.8_dev_bin_Linux.zip && \
    unzip "sobtop_1.0(dev5).zip" && \
    unzip Multiwfn_3.8_dev_bin_Linux.zip && \
    mv "sobtop_1.0(dev5)" /home/${USER_NAME}/Software/Sobtop && \
    mv Multiwfn_3.8_dev_bin_Linux /home/${USER_NAME}/Software/Multiwfn && \
    rm -f "sobtop_1.0(dev5).zip" Multiwfn_3.8_dev_bin_Linux.zip && \
    echo "# Multiwfn" >> /home/${USER_NAME}/.bashrc && \
    echo "export PATH=/home/${USER_NAME}/Software/Multiwfn:\$PATH" >> /home/${USER_NAME}/.bashrc && \
    echo "export Multiwfnpath=/home/${USER_NAME}/Software/Multiwfn" >> /home/${USER_NAME}/.bashrc && \
    echo "export PATH=/home/${USER_NAME}/Software/Sobtop:\$PATH" >> /home/${USER_NAME}/.bashrc && \
    echo "export Sobtoppath=/home/${USER_NAME}/Software/Sobtop" >> /home/${USER_NAME}/.bashrc && \
    echo "ulimit -s unlimited" >> /home/${USER_NAME}/.bashrc && \
    chmod +x /home/${USER_NAME}/Software/Sobtop/sobtop && \
    chmod +x /home/${USER_NAME}/Software/Sobtop/atomtype && \
    chmod +x /home/${USER_NAME}/Software/Multiwfn/Multiwfn && \
    chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/Software/Sobtop && \
    chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/Software/Multiwfn

# Install Avogadro2
RUN wget -c https://github.com/OpenChemistry/avogadrolibs/releases/download/1.99.0/Avogadro2-x86_64.AppImage -P /home/${USER_NAME}/Software/ && \
    chmod +x /home/${USER_NAME}/Software/Avogadro2-x86_64.AppImage && \
    cd /home/${USER_NAME}/Software/ && \
    ./Avogadro2-x86_64.AppImage --appimage-extract && \
    mv squashfs-root avogadro2-extracted && \
    ln -s /home/${USER_NAME}/Software/avogadro2-extracted/AppRun /usr/local/bin/avo && \
    ln -s /home/${USER_NAME}/Software/avogadro2-extracted/AppRun /usr/local/bin/avogadro2

# Install AutoDock Vina for molecular docking
RUN wget -c https://github.com/ccsb-scripps/AutoDock-Vina/releases/download/v1.2.5/vina_1.2.5_linux_x86_64 -P /home/${USER_NAME}/Software/Vina/bin/ && \
    wget -c https://github.com/ccsb-scripps/AutoDock-Vina/releases/download/v1.2.5/vina_split_1.2.5_linux_x86_64 -P /home/${USER_NAME}/Software/Vina/bin/ &&\
    mv /home/${USER_NAME}/Software/Vina/bin/vina_1.2.5_linux_x86_64 /home/${USER_NAME}/Software/Vina/bin/vina && \
    mv /home/${USER_NAME}/Software/Vina/bin/vina_split_1.2.5_linux_x86_64 /home/${USER_NAME}/Software/Vina/bin/vina_split && \
    chmod +x /home/${USER_NAME}/Software/Vina/bin/vina /home/${USER_NAME}/Software/Vina/bin/vina_split && \
    echo "export PATH=/home/${USER_NAME}/Software/Vina/bin:\$PATH" >> /home/${USER_NAME}/.bashrc

# Install ADT
RUN wget -c https://ccsb.scripps.edu/download/532/mgltools_x86_64Linux2_1.5.7.tar.gz && \
    tar -xvf mgltools_x86_64Linux2_1.5.7.tar.gz &&\
    rm mgltools_x86_64Linux2_1.5.7.tar.gz && \
    cd mgltools_x86_64Linux2_1.5.7/ && \
    sh ./install.sh -d /home/${USER_NAME}/Software/ADT -c 1 && \
    rm /home/${USER_NAME}/Software/ADT/bin/obabel && \
    rm -rf mgltools_x86_64Linux2_1.5.7/ && \
    echo "export PATH=/home/${USER_NAME}/Software/ADT/bin:\$PATH" >> /home/${USER_NAME}/.bashrc

# Install xTB
RUN wget -c https://github.com/grimme-lab/xtb/releases/download/v6.7.1/xtb-6.7.1-linux-x86_64.tar.xz && \
    tar -xvf xtb-6.7.1-linux-x86_64.tar.xz && \
    mv xtb-dist /home/${USER_NAME}/Software/xTB && \
    echo "export PATH=/home/${USER_NAME}/Software/xTB/bin:\$PATH" >> /home/${USER_NAME}/.bashrc && \
    rm xtb-6.7.1-linux-x86_64.tar.xz

# Install FFTW library with optimizations for GROMACS
RUN wget http://www.fftw.org/fftw-${FFTW_VERSION}.tar.gz && \
    tar -xzf fftw-${FFTW_VERSION}.tar.gz && \
    cd fftw-${FFTW_VERSION} && \
    ./configure --enable-shared --enable-float --enable-avx2 --enable-fma --enable-sse2 --enable-avx --prefix=/home/$User_name/Software/FFTW && \
    make && \
    make install && \
    ldconfig && \
    cd .. && \
    rm -rf fftw-${FFTW_VERSION}.tar.gz fftw-${FFTW_VERSION}

# Download GROMACS source code
RUN cd /home/${USER_NAME} && \
    wget -c https://ftp.gromacs.org/gromacs/gromacs-${GROMACS_VERSION}.tar.gz && \
    tar -xvf gromacs-${GROMACS_VERSION}.tar.gz && \
    rm gromacs-${GROMACS_VERSION}.tar.gz

# Compile and install GROMACS with CUDA support
RUN cd /home/${USER_NAME}/gromacs-${GROMACS_VERSION} && \
    mkdir build && \
    cd build && \
    cmake ../ \
        -DGMX_SIMD=avx2_256 \
        -DGMX_GPU=CUDA \
        -DCMAKE_PREFIX_PATH=/home/$User_name/Software/FFTW \
        -DCMAKE_INSTALL_PREFIX=/home/${USER_NAME}/Software/GMX-${GROMACS_VERSION} && \
    make install && \
    chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/Software/GMX-${GROMACS_VERSION}

# Configure GROMACS environment variables
RUN echo '# Gromacs' >> /home/${USER_NAME}/.bashrc && \
    echo 'export GMX_GPU_DD_COMMS=true' >> /home/${USER_NAME}/.bashrc && \
    echo 'export GMX_GPU_PME_PP_COMMS=true' >> /home/${USER_NAME}/.bashrc && \
    echo 'export GMX_FORCE_UPDATE_DEFAULT_GPU=true' >> /home/${USER_NAME}/.bashrc && \
    echo "export PATH=/home/${USER_NAME}/Software/GMX-${GROMACS_VERSION}/bin:\$PATH" >> /home/${USER_NAME}/.bashrc && \
    chown ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.bashrc

# Clean up GROMACS source directory
RUN rm -rf /home/${USER_NAME}/gromacs-${GROMACS_VERSION}

# Set final ownership of user directory
RUN chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}

# Switch to the created user
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# Set default command
CMD ["/bin/bash"]
