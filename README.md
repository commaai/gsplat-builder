# gsplat-builder

Builds gsplat 3DGUT CUDA extension for xx's Python 3.12, PyTorch 2.13, and CUDA 13 runtime.

```bash
GSPLAT_COMMIT=2b902ff1891fc7f73f0f9b8c8bfc932cef2b198c ./docker-build.sh
```

The wheel contains only gsplat's RGB 3DGUT backend for `sm_86`, `sm_89`, and `sm_120`.
