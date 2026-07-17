FROM python:3.14.6-slim-bookworm

ARG DEBIAN_FRONTEND=noninteractive

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility \
    SHELL=/bin/bash \
    PATH=/opt/venv/bin:$PATH

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        ca-certificates \
        bash \
        git \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/python -m pip install --upgrade pip setuptools wheel

RUN /opt/venv/bin/python -m pip install \
        torch==2.13.0+cpu \
        --index-url https://download.pytorch.org/whl/cpu

RUN /opt/venv/bin/python -m pip install \
        datajoint[postgres,s3]==2.3.1 \
        graphviz==0.21 \
        jupyterlab==4.6.1 \
        matplotlib==3.11.0 \
        numpy==2.4.6 \
        polars==1.42.1 \
        scikit-learn==1.9.0 \
        scipy==1.17.1 \
        seaborn==0.13.2 \
        statsmodels==0.14.6 \
        umap-learn==0.5.12 \
        xarray==2026.7.0 \
        zarr==3.1.6

RUN mkdir -p /workspace

WORKDIR /workspace

EXPOSE 8888

CMD ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--ServerApp.root_dir=/workspace"]
