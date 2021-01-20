# Deb仓库的使用

新建`/etc/apt/sources.list.d/piculator.list`

添加类似下面的内容

```sh
deb https://rpi.kxxt.tech/
```

# Deb仓库的构建

1. 创建一个子域名, 比如`rpi.kxxt.tech`
2. (可选) 绑定SSL证书（用来支持https）
3. 在宝塔面板新建网站， 并绑定到子域名、
4. (可选)创建ftp,方便上传软件包
5. 修改此网站的nginx配置， 添加`autoindex on;`
6. 上传deb包到网站根目录
7. 在服务器上安装`dpkg-dev`
8. 修改`update-rpi-repo.sh`来适配你的服务器配置情况
9. 上传这个脚本到服务器上并执行
10. 以后每上传新的包都要执行上述脚本
11. （可选）设置定时任务，自动执行脚本

## 新的deb上传后自动更新Repo

1. 安装`inotify-tools`
2. 根据自己的服务器的情况，修改`start-update-rpi-repo-daemon.sh`
3. 将`start-update-rpi-repo-daemon.sh`上传到服务器上
4. 将脚本设置为开机自启动（设置自启动建议使用systemd方式，可以参考`updrpirepo.service`，请根据服务器情况做出修改）

### 参考资料

- https://www.jianshu.com/p/ee870d63c175

- https://medium.com/sqooba/create-your-own-custom-and-authenticated-apt-repository-1e4a4cf0b864
- https://bgstack15.wordpress.com/2016/06/22/building-an-apt-repository-on-centos/