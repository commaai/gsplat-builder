#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

VERSION=1.5.3+pt213cu130.3dgutrgb.1
: "${MAX_JOBS:=4}"
: "${TORCH_CUDA_ARCH_LIST:=8.6;8.9;12.0}"

rm -rf /tmp/gsplat /tmp/wheel /tmp/unpacked
mkdir -p /tmp/gsplat /tmp/wheel /tmp/unpacked
cp -a /input/. /tmp/gsplat/
cd /tmp/gsplat

sed -i "s/__version__ = \"1.5.3\"/__version__ = \"${VERSION}\"/" gsplat/version.py
grep -q "__version__ = \"${VERSION}\"" gsplat/version.py
sed -i 's/"torch>=2.7"/"torch==2.13.0"/' setup.py
grep -q '"torch==2.13.0"' setup.py

export MAX_JOBS TORCH_CUDA_ARCH_LIST
export BUILD_EXPERIMENTAL=0 BUILD_3DGUT=1 NUM_CHANNELS=3

python setup.py bdist_wheel --dist-dir /tmp/wheel

wheels=(/tmp/wheel/gsplat-"${VERSION}"-*.whl)
test "${#wheels[@]}" -eq 1
python -m zipfile -e "${wheels[0]}" /tmp/unpacked
extension=/tmp/unpacked/gsplat/csrc.so
test -f "${extension}"

python - "${extension}" <<'PY'
import importlib.util
import sys
import torch

spec = importlib.util.spec_from_file_location("gsplat.csrc", sys.argv[1])
module = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = module
spec.loader.exec_module(module)
expected = {
  "2dgs": False,
  "3dgs": False,
  "3dgut": True,
  "adam": False,
  "camera_wrappers": False,
  "losses": False,
  "reloc": False,
}
assert module.build_config() == expected, module.build_config()
PY

expected_arches=$(tr ';' '\n' <<< "${TORCH_CUDA_ARCH_LIST}" | sed 's/+PTX//; s/\.//' | sort -u | tr '\n' ' ')
actual_arches=$(cuobjdump --list-elf "${extension}" | sed -n 's/.*\.sm_\([0-9]*\)\.cubin/\1/p' | sort -u | tr '\n' ' ')
test "${actual_arches}" = "${expected_arches}"

cp "${wheels[0]}" /output/
echo "Built $(basename "${wheels[0]}") for CUDA architectures ${TORCH_CUDA_ARCH_LIST}"
