
```bash
git clone https://github.com/PoutineSyropErable/install_cross_gcc ~/cross-gcc/ --depth=1
cd ~/cross-gdb
./install.sh

yay -S gcc-ia16
```



Then, the binutils-2.45 and gcc-15.2.0 are downloaded, compiled and installed to the local dir here. 
Then, it's symlinked to /usr/local/bin for syswide availability

can't quite get an ia16-elf-gcc that uses this old version of gcc

