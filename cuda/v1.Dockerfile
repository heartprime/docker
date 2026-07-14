FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility \
    PATH=/opt/venv/bin:$PATH

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        ca-certificates \
        git \
        python3 \
        python3-pip \
        python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv \
    && python3 -m pip install --upgrade pip setuptools wheel \
    && python3 -m pip install \
        torch==2.13.0+cu126 \
        --index-url https://download.pytorch.org/whl/cu126 \
    && python3 -m pip install \
        datajoint[postgres]==2.3.0 \
        graphviz==0.21 \
        jupyterlab==4.6.1 \
        matplotlib==3.11.0 \
        numpy==2.5.1 \
        pandas==3.0.3 \
        polars==1.42.1 \
        scikit-learn==1.9.0 \
        seaborn==0.13.2 \
        statsmodels==0.14.6 \
        umap-learn==0.5.12 \
        zarr==3.2.1

RUN mkdir -p /workspace

WORKDIR /workspace

EXPOSE 8888

CMD ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--ServerApp.root_dir=/workspace"]
