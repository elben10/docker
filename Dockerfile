FROM jupyter/base-notebook:latest

USER root

ENV GOPATH=$HOME/go
ENV PATH=$PATH:$GOPATH/bin

# Install System dependencies
RUN apt-get update && \
    apt-get -yq dist-upgrade && \
    apt-get install -yq --no-install-recommends \
    fonts-dejavu \
    gcc \
    git \
    gfortran \
    libapparmor1 \
    libedit2 \
    libssl1.0.0 \
    libzmq3-dev \
    lsb-release \
    psmisc \
    tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Rstudio Server
RUN export RSTUDIO_PKG=rstudio-server-$(wget -qO- https://download2.rstudio.org/current.ver)-amd64.deb && \
    wget -q http://download2.rstudio.org/${RSTUDIO_PKG} && \
    dpkg -i ${RSTUDIO_PKG} && \
    rm ${RSTUDIO_PKG} 

USER ${NB_USER}

# The desktop package uses /usr/lib/rstudio/bin
ENV PATH="${PATH}:/usr/lib/rstudio-server/bin"
ENV LD_LIBRARY_PATH="/usr/lib/R/lib:/lib:/usr/lib/x86_64-linux-gnu:/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server:/opt/conda/lib/R/lib"

# Update packages 
RUN conda update --all --yes && \
    conda config --set auto_update_conda False
    
# Conda dependencies
RUN conda install --quiet --yes -c conda-forge -c QuantStack -c krinsman \
    # Python
    # R
    'r-base=3.5.1' \
    'r-irkernel=0.8*' \
    'r-plyr=1.8*' \
    'r-devtools=1.13*' \
    'r-tidyverse=1.2*' \
    'r-shiny=1.2*' \
    'r-rmarkdown=1.11*' \
    'r-forecast=8.2*' \
    'r-rsqlite=2.1*' \
    'r-reshape2=1.4*' \
    'r-nycflights13=1.0*' \
    'r-caret=6.0*' \
    'r-rcurl=1.95*' \
    'r-crayon=1.3*' \
    'r-randomforest=4.6*' \
    'r-htmltools=0.3*' \
    'r-sparklyr=0.9*' \
    'r-htmlwidgets=1.2*' \
    'r-hexbin=1.27*' \
    # Others
    'go' \
    'pkg-config'
    
# Install pip dependencies
RUN pip install \
    bash_kernel \
    jupyterlab-git \
    jupyterlab_github \
    jupyterlab_latex \
    git+https://github.com/elben10/jupyter-rsession-proxy
    
# Install extensions
 RUN jupyter labextension install @jupyterlab/google-drive && \
     jupyter labextension install @jupyterlab/git && \
     jupyter labextension install @jupyterlab/github && \
     jupyter labextension install @jupyterlab/latex && \
     jupyter labextension install @jupyterlab/toc && \
     jupyter labextension install jupyterlab_bokeh && \
     jupyter labextension install jupyterlab-server-proxy
    
# Enable server extensions
RUN jupyter serverextension enable --py jupyterlab_git && \
    jupyter serverextension enable --sys-prefix jupyterlab_github && \
    jupyter serverextension enable --sys-prefix jupyterlab_latex


# Add kernels
RUN python -m bash_kernel.install && \
    go get -u github.com/gopherdata/gophernotes && \
    mkdir -p ~/.local/share/jupyter/kernels/gophernotes && \
    cp $GOPATH/src/github.com/gopherdata/gophernotes/kernel/* ~/.local/share/jupyter/kernels/gophernotes
