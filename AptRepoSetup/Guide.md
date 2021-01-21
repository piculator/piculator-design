# Deb仓库的使用

```bash
wget -q -O piculator.gpg https://rpi.kxxt.tech/KEY.gpg
sudo gpg --import piculator.gpg
sudo apt-key add piculator.gpg
```

运行上面的命令, 显示OK即可

新建`/etc/apt/sources.list.d/piculator.list`

添加类似下面的内容

```sh
deb https://rpi.kxxt.tech/ /
```

# Deb仓库的构建

1. 创建一个子域名, 比如`rpi.kxxt.tech`
2. (推荐)绑定SSL证书（用来支持https）
3. 在宝塔面板新建网站， 并绑定到子域名、
4. (可选)创建ftp,方便上传软件包
5. 修改此网站的nginx配置， 添加`autoindex on;`
6. 上传deb包到网站根目录
7. 在服务器上安装`dpkg-dev`
8. 在服务器上运行`mkdir ~/.gnupg`
   `echo "cert-digest-algo SHA256" >> ~/.gnupg/gpg.conf`
   `echo "digest-algo SHA256" >> ~/.gnupg/gpg.conf`
9. 修改`update-rpi-repo.sh`来适配你的服务器配置情况
10. 上传这个脚本到服务器上并执行
11. 将KEY.gpg(签名公钥)上传到网站根目录
12. 以后每上传新的包都要执行上述脚本

> 出于安全原因考虑, 用于签名的密钥不对外公布.

### 参考资料

- https://www.jianshu.com/p/ee870d63c175

- https://medium.com/sqooba/create-your-own-custom-and-authenticated-apt-repository-1e4a4cf0b864
- https://bgstack15.wordpress.com/2016/06/22/building-an-apt-repository-on-centos/
- https://wiki.debian.org/Teams/Apt/Sha1Removal