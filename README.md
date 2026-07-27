# gsplat-builder

Builds gsplat 3DGUT CUDA extension for xx's Python 3.12, PyTorch 2.13, and CUDA 13 runtime.

```bash
GSPLAT_COMMIT=b36d71c42cf7311ed3659cb2b8fb6c5c3e51b0a7 ./docker-build.sh
```

The default build contains only gsplat's RGB 3DGUT backend for `sm_86`, `sm_89`, and `sm_120`.
