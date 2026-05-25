# SatDump

<img src='/icon.png' width='500px' />

A simple generic satellite data processing software.
*Original icon by Crosswalkersam, inverted.*

[SimpleDump Discord Server](https://discord.gg/fSKTq2A2RA)

# Introduction

There is no official documentation yet.

# Build SimpleDump

#### Build SatDump
```
git clone https://github.com/aweeri/SimpleDump.git
cd SimpleDump
mkdir build && cd build
# If you do not want to build the GUI Version, add -DBUILD_GUI=OFF to the command
# If you want to disable some SDRs, you can add -DPLUGIN_HACKRF_SDR_SUPPORT=OFF or similar
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr ..
make -j`nproc`

# To run without installing
ln -s ../pipelines .        # Symlink pipelines so it can run
ln -s ../resources .        # Symlink resources so it can run
ln -s ../satdump_cfg.json . # Symlink settings so it can run

# To install system-wide
sudo make install

# Run (if you want!)
./satdump-ui
```