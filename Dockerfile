# Use Ubuntu as the base image
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install all required packages in a single layer and clean up in the same layer to reduce size
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        wget \
        curl \
        ca-certificates \
        autoconf \
        automake \
        libtool \
        pkg-config \
        cmake \
        gfortran \
        python3 \
        python3-pip \
        python3-dev \
        python3-testresources \
        python3-setuptools \
        python3-tk \
        libfftw3-dev \
        libfftw3-bin \
        libgsl-dev \
        libpng-dev \
        libx11-dev \
        pgplot5 \
        libcfitsio-dev \
        libpgplot0 \
        csh \
        expect \
        hwloc \
        perl \
        pcre2-utils \
        libpcre2-dev \
        libpcre3 \
        libpcre3-dev \
        libhdf5-dev \
        libhdf5-serial-dev \
        libxml2 \
        libxml2-dev \
        libltdl-dev \
        libblas-dev \
        liblapack-dev \
        openssh-server \
        latex2html \
        xorg \
        bc \
        xauth \
        locales \
        autotools-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt/archives/*

# Set up locale information
RUN localedef -i en_AU -c -f UTF-8 -A /usr/share/locale/locale.alias en_AU.UTF-8
ENV LANG=en_AU.utf8 \
    LC_ALL=en_AU.utf8 \
    LANGUAGE=en_AU.utf8

# Set up base python packages
RUN pip install --no-cache-dir pip -U && \
    pip install --no-cache-dir numpy==1.23.5 scipy matplotlib ipython -U

# Create working directory for building tools
WORKDIR /src

# Install SWIG, PSRXML, PSRCHIVE, DSPSR, and PSRSALSA in a single layer to reduce image size
RUN wget https://sourceforge.net/projects/swig/files/swig/swig-4.0.1/swig-4.0.1.tar.gz \
    && tar -xf swig-4.0.1.tar.gz \
    && cd swig-4.0.1 \
    && ./configure --prefix=/usr/local \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf swig-4.0.1 swig-4.0.1.tar.gz \
    # Install PSRXML
    && git clone https://github.com/straten/psrxml.git \
    && cd psrxml \
    && autoreconf --install --force \
    && CPPFLAGS="-I/usr/include/libxml2" LDFLAGS="-L/usr/lib -lxml2" ./configure --prefix=/usr/local \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf psrxml \
    # Install PSRCHIVE
    && git clone https://git.code.sf.net/p/psrchive/code psrchive \
    && cd psrchive \
    && ./bootstrap \
    && ./configure --prefix=/usr/local \
        --with-x --x-libraries=/usr/lib/x86_64-linux-gnu \
        --enable-shared --enable-static \
        --with-psrxml-dir=/usr/local \
        F77=gfortran PYTHON=$(which python3) \
        CPPFLAGS="-I/usr/local/include -I/usr/include/libxml2" \
        LDFLAGS="-L/usr/local/lib -L/usr/lib -lxml2" \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf psrchive \
    # Install DSPSR
    && git clone https://git.code.sf.net/p/dspsr/code dspsr \
    && cd dspsr \
    && ./bootstrap \
    && ./configure --enable-shared \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf dspsr \
    # Install PSRSALSA
    && git clone https://github.com/weltevrede/psrsalsa.git \
    && cd psrsalsa \
    && GSL_VERSION=$(gsl-config --version | awk -F. '{print $1*100 + $2}') \
    && make GSLFLAGS="-DGSL_VERSION_NUMBER=$GSL_VERSION" \
    && mkdir -p /usr/local/bin \
    && cp bin/* /usr/local/bin/ \
    && cd .. \
    && rm -rf psrsalsa \
    # Clean up build dependencies
    && apt-get purge -y \
        build-essential \
        git \
        wget \
        autoconf \
        automake \
        libtool \
        pkg-config \
        cmake \
        python3-dev \
    && apt-get autoremove -y \
    && rm -rf /src/*

# Create psr user and set up directories
RUN adduser --disabled-password --gecos 'unprivileged user' psr && \
    echo "psr:psr" | chpasswd && \
    mkdir -p /home/psr/.ssh && \
    mkdir -p /work && \
    mkdir -p /home/psr/software && \
    chown -R psr:psr /home/psr/.ssh && \
    chown -R psr:psr /work && \
    chown -R psr:psr /home/psr/software

# Define environment variables
ENV HOME=/home/psr \
    PSRHOME=/home/psr/software \
    OSTYPE=linux \
    PGPLOT_DIR=/usr/lib/pgplot5 \
    PGPLOT_FONT=/usr/lib/pgplot5/grfont.dat \
    PGPLOT_BACKGROUND=white \
    PGPLOT_FOREGROUND=black \
    PGPLOT_DEV=/xs \
    LD_LIBRARY_PATH=/usr/local/lib:/usr/lib/pgplot5/lib:$LD_LIBRARY_PATH \
    PATH=$PATH:/usr/local/pulsar/bin

# Switch to psr user
USER psr

# Set working directory
WORKDIR /work

# Default command
CMD ["/bin/bash"]
