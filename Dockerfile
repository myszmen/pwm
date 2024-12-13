# Build stage
FROM ubuntu:22.04 AS builder

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
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
        xorg \
        bc \
        xauth \
        locales \
        autotools-dev \
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

# Set the environment variable with the Julia version
ENV JULIA_VERSION=1.10.7
ENV JULIA_VERSION_SHORT=1.10

# Install Julia
RUN wget -q https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION_SHORT}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz \
    && tar -xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz \
    && mv julia-${JULIA_VERSION} /opt/julia \
    && ln -s /opt/julia/bin/julia /usr/local/bin/julia \
    && rm julia-${JULIA_VERSION}-linux-x86_64.tar.gz \
    # Install SWIG
    && wget https://sourceforge.net/projects/swig/files/swig/swig-4.0.1/swig-4.0.1.tar.gz \
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
    && rm -rf /src/*

# Runtime stage
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
	vim \
	git \
	build-essential \
	xvfb \
	evince \
	x11vnc \
	x11-apps \
        python3 \
        python3-pip \
        python3-tk \
        libfftw3-3 \
        libgsl27 \
        libpng16-16 \
        libx11-6 \
        pgplot5 \
        libcfitsio9 \
        libpgplot0 \
        csh \
        expect \
        hwloc \
        libpcre2-8-0 \
        libpcre3 \
        libhdf5-103-1 \
        libxml2 \
        libgomp1 \
        libquadmath0 \
        xorg \
        bc \
        xauth \
        locales \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt/archives/*

# Set up locale information
RUN localedef -i en_AU -c -f UTF-8 -A /usr/share/locale/locale.alias en_AU.UTF-8
ENV LANG=en_AU.utf8 \
    LC_ALL=en_AU.utf8 \
    LANGUAGE=en_AU.utf8

# Install required Python packages
RUN pip install --no-cache-dir numpy==1.23.5 scipy matplotlib ipython -U

# Copy built files from builder stage
COPY --from=builder /usr/local /usr/local
COPY --from=builder /opt/julia /opt/julia

# Create psr user and set up directories
RUN adduser --disabled-password --gecos 'unprivileged user' psr && \
    echo "psr:psr" | chpasswd && \
    mkdir -p /home/psr/.ssh && \
    mkdir -p /work && \
    mkdir -p /home/psr/software && \
    chown -R psr:psr /home/psr/.ssh && \
    chown -R psr:psr /work && \
    chown -R psr:psr /home/psr/software

# Set environment variables
ENV HOME=/home/psr \
    PSRHOME=/home/psr/software \
    OSTYPE=linux \
    TEMPO2=/usr/local/share/tempo2 \
    PGPLOT_DIR=/usr/lib/pgplot5 \
    PGPLOT_FONT=/usr/lib/pgplot5/grfont.dat \
    PGPLOT_BACKGROUND=white \
    PGPLOT_FOREGROUND=black \
    PGPLOT_DEV=/xs \
    LD_LIBRARY_PATH=/usr/local/lib:/usr/lib/pgplot5/lib \
    PATH=/usr/local/pulsar/bin:$PATH

# Environment variables for X11 forwarding and PGPLOT
ENV DISPLAY=:99 \
    QT_X11_NO_MITSHM=1 \
    PGPLOT_DEV=/xwin \
    XAUTHORITY=/tmp/.docker.xauth

# switch to psr user
USER psr

# Clone usefull repositories 
RUN git clone https://github.com/aszary/spa.git /home/psr/software/spa
RUN git clone https://github.com/aszary/spat.git /home/psr/software/spat
RUN git clone https://github.com/aszary/spats.git /home/psr/software/spats

# Add julia libraries
WORKDIR /home/psr/software/spat
RUN Xvfb :99 -screen 0 1024x768x24 & julia -e 'ENV["PYTHON"]="";using Pkg; Pkg.activate("/home/psr/software/spat");Pkg.instantiate();Pkg.add("Conda");using Conda; Conda.add("matplotlib");Pkg.precompile();'
RUN Xvfb :99 -screen 0 1024x768x24 & julia -e 'ENV["PYTHON"]="";using Pkg; Pkg.activate("/home/psr/software/spats");Pkg.instantiate();Pkg.precompile()'


# Set working directory
WORKDIR /home/psr/

USER root
# starting script
COPY scripts/startx.sh /home/psr/startx.sh
RUN mkdir /home/psr/log && chown psr:psr /home/psr/log && chown psr:psr /home/psr/startx.sh && chmod +x /home/psr/startx.sh
#RUN mkdir -p /var/log && chmod 777 /var/log

USER psr

# Default command
CMD ["/bin/bash"]
