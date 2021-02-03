## Sage安装指南

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