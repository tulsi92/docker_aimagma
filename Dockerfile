# Newer version of micromamba with lots of features
FROM mambaorg/micromamba:1.4.1
# copy env file. must be chowned to the micromamba user
COPY --chown=micromamba:micromamba R.yaml /tmp/env.yaml
# Install the environment. This is done as the micromamba user so superuser commands will not work
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes

# Install MAGMA
USER micromamba
RUN wget https://ctg.cncr.nl/software/MAGMA/prog/magma_v1.10.zip && \
    unzip magma_v1.10.zip -d /opt && \
    rm magma_v1.10.zip && \
    chmod +x /opt/magma

# Change user to root to make root directory and chown it to mamba user. Mamba env is not active here
USER root
RUN mkdir /evaladmix && \
    chown mambauser:mambauser /evaladmix
# switch user back to mambauser
USER mambauser
# you must include the below arg to activate the env within the dockerfile
ARG MAMBA_DOCKERFILE_ACTIVATE=1
ARG CPLUS_INCLUDE_PATH=/opt/conda/include
ARG C_INCLUDE_PATH=/opt/conda/include
RUN git clone https://github.com/GenisGE/evalAdmix.git /evaladmix && \
    cd /evaladmix && \
    git checkout 89ba805 && \
    make clean && \
    make
# below is necessary for the env to work with shell sessions
ENV PATH "$MAMBA_ROOT_PREFIX/bin:/evaladmix:$PATH"
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "/evaladmix/evalAdmix"]
