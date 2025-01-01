# Molecular Modeling in Docker

This repository contains a Dockerfile for building a molecular dynamics simulation and quantum chemistry base environment with CUDA support. The container includes various tools for molecular modeling, analysis, and visualization and X11 forwarding configured.

## Included Software

- **GROMACS 2023.5**: Molecular dynamics package with CUDA support
- **AutoDock Vina 1.2.5**: Molecular docking program
- **Multiwfn 3.8**: Wavefunction analysis tool by Dr. Tian Lu (Contact: sobereva[at]sina.com. Beijing Kein Research Center for Natural Sciences 北京科音自然科学研究中心)
- **Sobtop**: Molecular topology tool by Dr. Tian Lu (Contact: sobereva[at]sina.com. Beijing Kein Research Center for Natural Sciences 北京科音自然科学研究中心)
- **Avogadro 2**: Advanced molecular editor
- **xTB 6.7.1**: Semi-empirical quantum chemistry package
- **MGLTools 1.5.7**: Molecular graphics tools
- **PyMOL**: Molecular visualization system
- **OpenBabel**: Chemical toolbox
- **Additional Tools**: pdb2pqr, gmx_MMPBSA, DuIvyTools

## System Requirements

- Docker desktop and VcXsrv installed on your system
You can find the download here：https://vcxsrv.com/
- NVIDIA GPU with CUDA support

## Running the Container

```bash
docker build -t cadd:v0 -f .\CADD.dockerfile .
docker run -it --gpus all -e DISPLAY=host.docker.internal:0 -v ${PWD}:/home/cadd/test cadd:v0 /bin/bash # Mount the current location to this address inside the container /home/cadd/test
```

## Container Features

### GPU Acceleration
- CUDA-enabled GROMACS installation
- Optimized FFTW library with AVX2 support
- GPU-specific environment variables pre-configured

### GUI Application Support
- Avogadro 2 for molecular editing
- PyMOL for visualization
- X11 forwarding configured

### Development Environment
- Build tools and compilers included
- Python environment with scientific packages
- Common molecular modeling libraries

## Directory Structure

The main software packages are installed in `/home/cadd/Software/` with the following structure:

```
/home/cadd/Software/
├── ADT/                 # MGLTools
├── GMX-2023.5/         # GROMACS
├── Multiwfn/           # Multiwfn
├── Sobtop/            # Sobtop
├── Vina/              # AutoDock Vina
├── xTB/               # xTB package
└── FFTW/              # FFTW library
```

## Environment Variables

The container comes with pre-configured environment variables for optimal performance:

- `GMX_GPU_DD_COMMS=true`
- `GMX_GPU_PME_PP_COMMS=true`
- `GMX_FORCE_UPDATE_DEFAULT_GPU=true`
- All necessary PATH variables for installed software

## Troubleshooting

1. **GPU Access Issues**
   - Verify NVIDIA drivers are properly installed
   - Check NVIDIA Container Toolkit installation
   - Ensure docker daemon configuration includes NVIDIA runtime

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
