# Newer version of micromamba with lots of features
FROM mambaorg/micromamba:1.4.1
# Add MAGMA directory to env
ENV PATH="/magma:${PATH}"
# Copy env file. must be chowned to the micromamba user
COPY --chown=micromamba:micromamba R.yaml /tmp/env.yaml
# Install the environment. This is done as the micromamba user so superuser commands will not work
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes

# Install MAGMA
# Change user to root to make root directory and chown it to mamba user. Mamba env is not active here
USER root
RUN mkdir /magma && \
    cd /magma && \
    curl https://vu.data.surfsara.nl/index.php/s/lxDgt2dNdNr6DYt/download > magma.zip && \
    unzip magma.zip && \
    rm magma.zip && \
    chmod +x magma && \
    chown -R mambauser:mambauser /magma

# below is necessary for the env to work with shell sessions
# ENV PATH "$MAMBA_ROOT_PREFIX/bin:/magma:$PATH"
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "/magma/magma"]
