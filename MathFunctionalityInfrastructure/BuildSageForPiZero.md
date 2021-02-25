# Sagemath Build Guide

https://github.com/erinzm/SageMathematics-raspi/wiki/Compilation-Instructions

https://doc.sagemath.org/html/en/installation/source.html#id4

Pi zero/w 内存过小, 会导致编译失败, 需要创建交换文件

注意: 建议至少8GB可用空间

#### 方案一

```
sudo dd if=/dev/zero of=/swapfile bs=1k count=2048000
sudo mkswap /swapfile
sudo swapon /swapfile
```

#### 方案二(最终采用)

```
# 插入U盘
sudo mkswap /dev/sda
sudo swapon /dev/sda
```

## Make之前

```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install imagemagick gcc g++ gfortran texlive-latex-base m4 ffmpeg dvipng cmake coinor-cbc coinor-libcbc-dev libboost-dev libfile-slurp-perl libisl-dev libjson-perl libmongodb-perl libnauty-dev libperl-dev libssl-dev libsvg-perl libterm-readkey-perl libterm-readline-gnu-perl libterm-readline-gnu-perl libxml-libxslt-perl libxml-writer-perl libxml2-dev ninja-build openssl pandoc pari-gp2c libflint-2.5.2
```

```
##BEFORE EVERY BUILD ATTEMPT, ##RUN THESE COMMANDS!
export CFLAGS="-mfloat-abi=hard $CFLAGS"
export CXXFLAGS="-mfloat-abi=hard $CXXFLAGS"
export FC="gfortran-4.7"
export SAGE_INSTALL_GCC=no
```

```
cd sage/sage-9.2
make
```

耐心等上五六天就好啦, 中途出现的问题一般比较容易解决

## viewers

- canvas3d, jmol (recomended, not available on QtWebKit)
- threejs (default,Not available on RPi zero)
- tachyon (not interactive)

## 安装指南

#### 安装依赖

```bash
sudo apt install libflint-2.5.2 libflint-arb2 libmpfi0 libsymmetrica2 imagemagick libiml0 libm4ri-0.0.20140914 libm4rie-0.0.20150908 libbrial-groebner3 libbrial3 libzn-poly-0.9 coinor-libcbc3 librw0 libbraiding0 libcdd0d libcdd-tools libcliquer1 libec4 libecm1 libffi6 libgc1c2 libgd3 liblrcalc1 libgf2x1 libgiac0 libgivaro9 libglpk40 libgmp10 libgsl23 libgslcblas0 libisl19 liblfunction0 liblzma5 libmnl0 libmpc3 libmpfi0 libmpfr6 libnauty2 libncurses5 libntl35 libopenblas-base libpari-gmp-tls6 pari-gp2c libpcre3 libpcre32-3 libplanarity0 libppl14 libppl-c4 libsuitesparse-dev libzmq5 ppl-dev
```

#### 下载sage.tar.xz

树莓派如果没有5GiB可用空间， 建议放在U盘上

#### 解压到主目录

```bash
tar -Jxf sage.tar.xz -C ~
```

耐心等待解压完成

#### 测试运行

```bash
sage/sage-9.2/sage
```

没有错误则安装成功