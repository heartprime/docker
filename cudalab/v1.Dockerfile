FROM nvidia/cuda:13.2.1-base-ubuntu24.04

ARG DEBIAN_FRONTEND=noninteractive

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
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
        torch==2.13.0+cu132 \
        --index-url https://download.pytorch.org/whl/cu132 \
    && python3 -m pip install \
        datajoint==2.2.4 \
        jupyterlab==4.6.1 \
        matplotlib==3.11.0 \
        numpy==2.4.6 \
        pandas==3.0.3 \
        scikit-learn==1.9.0 \
        seaborn==0.13.2 \
        statsmodels==0.14.6 \
        umap-learn==0.5.12 \
        zarr==3.2.1

RUN mkdir -p /workspace

WORKDIR /workspace

EXPOSE 8888

CMD ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--ServerApp.root_dir=/workspace"]
