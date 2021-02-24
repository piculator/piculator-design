# JupyterHub with sagemath Setup

## 目标

### 已完成

- 部署 jupyterhub 到云端
- 设置 jupyterhub 使用 DockerSpawner
- 接入 sagemath
- 存储可持久化

### 未完成

- 写一个 OAuthenticator 来支持 Piculator 统一身份认证登录

## 环境信息

- CentOS 7
- python 3.6.8
- node 12.21.0
- npm 6.14.1
- docker 20.10.3
- 在继续之前, 请确保你的环境信息与以上环境信息兼容

## SSL

手动配置好子域名,网站,SSL,不再赘述

## 依赖配置

```bash
sudo npm install -g configurable-http-proxy
sudo python3 -m venv /opt/jupyterhub/
sudo /opt/jupyterhub/bin/python3 -m pip install -U pip
sudo /opt/jupyterhub/bin/python3 -m pip install wheel
sudo /opt/jupyterhub/bin/python3 -m pip install jupyterhub jupyterlab
sudo /opt/jupyterhub/bin/python3 -m pip install ipywidgets
sudo /opt/jupyterhub/bin/python3 -m pip install dockerspawner
```

## 设置

### 生成默认设置

```bash
sudo mkdir -p /opt/jupyterhub/etc/jupyterhub/
cd /opt/jupyterhub/etc/jupyterhub/
sudo /opt/jupyterhub/bin/jupyterhub --generate-config
```

### 注册 Systemd Service

> 以下内容来自 https://jupyterhub.readthedocs.io/en/latest/installation-guide-hard.html#setup-systemd-service

We will setup JupyterHub to run as a system service using Systemd (which is responsible for managing all services and servers that run on startup in Ubuntu). We will create a service file in a suitable location in the virtualenv folder and then link it to the system services. First create the folder for the service file:

```
sudo mkdir -p /opt/jupyterhub/etc/systemd
```

Then create the following text file using your [favourite editor](https://micro-editor.github.io/) at

```
/opt/jupyterhub/etc/systemd/jupyterhub.service
```


Paste the following service unit definition into the file:

```
[Unit]
Description=JupyterHub
After=syslog.target network.target

[Service]
User=root
Environment="PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/jupyterhub/bin"
ExecStart=/opt/jupyterhub/bin/jupyterhub -f  --port 11111 /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py

[Install]
WantedBy=multi-user.target
```


This sets up the environment to use the virtual environment we created, tells Systemd how to start jupyterhub using the configuration file we created, specifies that jupyterhub will be started as the `root` user (needed so that it can start jupyter on behalf of other logged in users), and specifies that jupyterhub should start on boot after the network is enabled.

Finally, we need to make systemd aware of our service file. First we symlink our file into systemd’s directory:

```
sudo ln -s /opt/jupyterhub/etc/systemd/jupyterhub.service /etc/systemd/system/jupyterhub.service
```


Then tell systemd to reload its configuration files

```
sudo systemctl daemon-reload
```


And finally enable the service

```
sudo systemctl enable jupyterhub.service
```


The service will start on reboot, but we can start it straight away using:

```
sudo systemctl start jupyterhub.service
```


…and check that it’s running using:

```
sudo systemctl status jupyterhub.service
```


You should now be already be able to access jupyterhub using `<your servers ip>:8000` (assuming you haven’t already set up a firewall or something). 

### 设置 docker spawner

Tell JupyterHub to use DockerSpawner by adding the following line to your `jupyterhub_config.py`:

```
c.JupyterHub.spawner_class = 'dockerspawner.DockerSpawner'
c.DockerSpawner.image = 'rsworktech/sagemath-jupyterhub-docker:latest'
c.Spawner.mem_limit = '500M'
```

查看 docker0 ip:`ifconfig` : 得到 ip 地址 `a.b.c.d`, 填入设置中

(为了让 docker 镜像可以连接到 hub)

```
c.JupyterHub.hub_connect_ip = 'a.b.c.d'
```

### 下载 docker image

拉取我的 sagemath 版镜像用于 DockerSpawn

```bash
docker pull rsworktech/sagemath-jupyterhub-docker
```

### Nginx 反向代理

编辑 Nginx 配置文件, 最后大概像下面那样:

```nginx
map $http_upgrade $connection_upgrade {
        default upgrade;
        '' close;
    }

server
{
    # 强制 HTTPS
    if ($scheme = http) {
      return 301 https://$server_name$request_uri;
    }
    ......
    OTHER CONFIGURATIONS (For example: SSL)
    ......
    location / {
    	proxy_pass http://127.0.0.1:11111;

    	proxy_redirect   off;
    	proxy_set_header X-Real-IP $remote_addr;
    	proxy_set_header Host $host;
    	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    	proxy_set_header X-Forwarded-Proto $scheme;

    	# websocket headers
    	proxy_set_header Upgrade $http_upgrade;
    	proxy_set_header Connection $connection_upgrade;
        
  	}
	......
}
```

### (临时) PAMAuthenticator 设置管理员

```
c.Authenticator.admin_users = {'YOUR_USER_NAME'}
```

### 可持久化

```
c.DockerSpawner.notebook_dir = '/home/sage/notebooks'
c.DockerSpawner.volumes = { 'jupyterhub-user-{username}': '/home/sage/notebooks' }
```

## 参考文档

[Install JupyterHub and JupyterLab from the ground up — JupyterHub 1.4.0.dev documentation](https://jupyterhub.readthedocs.io/en/latest/installation-guide-hard.html)

[DockerSpawner — JupyterHub Federated Documentation v0.1 (jhubdocs.readthedocs.io)](https://jhubdocs.readthedocs.io/en/latest/dockerspawner/README.html#building-the-docker-images)

[dockerspawner/examples/oauth at master · jupyterhub/dockerspawner (github.com)](https://github.com/jupyterhub/dockerspawner/tree/master/examples/oauth)

[Picking or building a Docker image (jupyterhub-dockerspawner.readthedocs.io)](https://jupyterhub-dockerspawner.readthedocs.io/en/latest/docker-image.html)

[Failed to connect to Hub API at 'http://127.0.0.1:8081/hub/api'. · Issue #198 · jupyterhub/dockerspawner (github.com)](https://github.com/jupyterhub/dockerspawner/issues/198)