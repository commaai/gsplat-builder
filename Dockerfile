FROM nvidia/cuda:13.0.2-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    python3-dev \
    python3-venv \
  && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"
RUN pip install --no-cache-dir torch==2.14.1 --index-url https://download.pytorch.org/whl/cu130 \
  && pip install --no-cache-dir ninja==1.13.0 setuptools==81.0.0 wheel==0.45.1

COPY build.sh /usr/local/bin/build-gsplat
CMD ["build-gsplat"]
