#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

: "${GSPLAT_COMMIT:?GSPLAT_COMMIT must be set}"

if [ ! -d gsplat ]; then
  git clone --filter=blob:none --no-checkout https://github.com/commaai/gsplat.git gsplat
  git -C gsplat checkout --detach "${GSPLAT_COMMIT}"
fi

if [ "$(git -C gsplat rev-parse HEAD)" != "${GSPLAT_COMMIT}" ]; then
  echo "gsplat/ is not at ${GSPLAT_COMMIT}; remove it and retry"
  exit 1
fi
git -C gsplat submodule update --init --depth 1 gsplat/cuda/csrc/third_party/glm
if [ -n "$(git -C gsplat status --porcelain --untracked-files=all --ignored)" ]; then
  echo "gsplat/ is dirty; remove it and retry"
  exit 1
fi
if ! git -C gsplat submodule foreach --quiet --recursive \
  'test -z "$(git status --porcelain --untracked-files=all --ignored)"'; then
  echo "gsplat/ has a dirty submodule; remove it and retry"
  exit 1
fi

docker build -t gsplat-builder .
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -e HOME=/tmp \
  -e MAX_JOBS \
  -e TORCH_CUDA_ARCH_LIST \
  -v "$(pwd)/gsplat:/input:ro" \
  -v "$(pwd):/output" \
  gsplat-builder
