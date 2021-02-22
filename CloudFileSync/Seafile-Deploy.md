# Seafile Server Deployment

> This guide was modified from [Deploy with MySQL - Seafile admin manual](https://manual.seafile.com/deploy/using_mysql/)

Download the server src from [Download - Seafile](https://www.seafile.com/en/download/)

Supposed you have downloaded `seafile-server_*` into `/opt/seafile/`. We suggest you to use the following layout for your deployment:

```sh
mkdir /opt/seafile
mv seafile-server_* /opt/seafile
cd /opt/seafile
# after moving seafile-server_* to this directory
tar -xzf seafile-server_*
mkdir installed
mv seafile-server_* installed
```

Now you should have the following directory layout

```
#tree seafile -L 2
seafile
├── installed
│   └── seafile-server_7.0.0_x86-64.tar.gz
└── seafile-server-7.0.0
    ├── reset-admin.sh
    ├── runtime
    ├── seafile
    ├── seafile.sh
    ├── seahub
    ├── seahub.sh
    ├── setup-seafile-mysql.sh
    └── upgrade
```

## Prepare MySQL Databases

Three components of Seafile Server need their own databases:

- ccnet server
- seafile server
- seahub

See [Seafile Server Components Overview](https://manual.seafile.com/overview/components/) if you want to know more about the Seafile server components.

let the `setup-seafile-mysql.sh` script create the databases for you.

Get the database root password: BT Panel > Database > root password

Configure the subdomain and SSL by yourself.

Configure port (for example: 8051) , open the port in BT Panel by yourself.

```
# install requirements
# in seahub folder
yum install python3-devel
pip3 install -r requirements.txt
```

## Running Seafile Server

### Starting Seafile Server and Seahub Website

Under seafile-server-latest directory, run the following commands

```
./seafile.sh start # Start Seafile service
./seahub.sh start  # Start seahub website, port defaults to 127.0.0.1:8000
```

The first time you start Seahub, the script would prompt you to create an admin account for your Seafile Server.

**Note:** The Seahub service listens on `127.0.0.1:8000` by default. So we recommend that you deploy a reverse proxy service so that other users can access the Seahub service.

### Deploy reverse proxy with BT Panel

Modify the site's nginx configuration.

If you've set up ssl, you'll end up having the file like this:

```nginx
log_format seafileformat '$http_x_forwarded_for $remote_addr [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" $upstream_response_time';
server
{
    listen 80;
	listen 443 ssl http2;
    server_name sync.kxxt.tech;
   
    proxy_set_header X-Forwarded-For $remote_addr;
    
    location / {
         proxy_pass         http://127.0.0.1:8000;
         proxy_set_header   Host $host;
         proxy_set_header   X-Real-IP $remote_addr;
         proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
         proxy_set_header   X-Forwarded-Host $server_name;
         proxy_read_timeout  1200s;

         # used for view/edit office file via Office Online Server
         client_max_body_size 0;

         access_log      /www/wwwlogs/seahub.access.log seafileformat;
         error_log       /www/wwwlogs/seahub.error.log;
    }
    
# If you are using [FastCGI](http://en.wikipedia.org/wiki/FastCGI),
# which is not recommended, you should use the following config for location `/`.
#
#    location / {
#         fastcgi_pass    127.0.0.1:8000;
#         fastcgi_param   SCRIPT_FILENAME     $document_root$fastcgi_script_name;
#         fastcgi_param   PATH_INFO           $fastcgi_script_name;
#
#         fastcgi_param  SERVER_PROTOCOL     $server_protocol;
#         fastcgi_param   QUERY_STRING        $query_string;
#         fastcgi_param   REQUEST_METHOD      $request_method;
#         fastcgi_param   CONTENT_TYPE        $content_type;
#         fastcgi_param   CONTENT_LENGTH      $content_length;
#         fastcgi_param  SERVER_ADDR         $server_addr;
#         fastcgi_param  SERVER_PORT         $server_port;
#         fastcgi_param  SERVER_NAME         $server_name;
#         fastcgi_param   REMOTE_ADDR         $remote_addr;
#        fastcgi_read_timeout 36000;
#
#         client_max_body_size 0;
#
#         access_log      /www/wwwlogs/seahub.access.log;
#        error_log        /www/wwwlogs/seahub.error.log;
#    }
    
    #SSL-START SSL相关配置，请勿删除或修改下一行带注释的404规则
    #error_page 404/404.html;
    ssl_certificate    /www/server/panel/vhost/cert/sync.kxxt.tech/fullchain.pem;
    ssl_certificate_key    /www/server/panel/vhost/cert/sync.kxxt.tech/privkey.pem;
    ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    add_header Strict-Transport-Security "max-age=31536000";
    error_page 497  https://$host$request_uri;

    #SSL-END
    
    #ERROR-PAGE-START  错误页配置，可以注释、删除或修改
    #error_page 404 /404.html;
    #error_page 502 /502.html;
    #ERROR-PAGE-END
    
    #PHP-INFO-START  PHP引用配置，可以注释或修改
    include enable-php-00.conf;
    #PHP-INFO-END
    
    #REWRITE-START URL重写规则引用,修改后将导致面板设置的伪静态规则失效
    include /www/server/panel/vhost/rewrite/sync.kxxt.tech.conf;
    #REWRITE-END
    
    #一键申请SSL证书验证目录相关设置
    location ~ \.well-known{
        allow all;
    }
    
    location /seafhttp {
        rewrite ^/seafhttp(.*)$ $1 break;
        proxy_pass http://127.0.0.1:8051;
        client_max_body_size 0;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_connect_timeout  36000s;
        proxy_read_timeout  36000s;
        proxy_send_timeout  36000s;

        send_timeout  36000s;

        access_log      /www/wwwlogs/seafhttp.access.log seafileformat;
        error_log       /www/wwwlogs/seafhttp.error.log;
    }
    
    location /media {
        root /opt/seafile/seafile-server-latest/seahub;
    }
    
}
```

Nginx settings `client_max_body_size` is by default 1M. Uploading a file bigger than this limit will give you an error message HTTP error code 413 ("Request Entity Too Large").

You should use 0 to disable this feature or write the same value than for the parameter `max_upload_size` in section `[fileserver]` of [seafile.conf](https://manual.seafile.com/config/seafile-conf/). Client uploads are only partly effected by this limit. With a limit of 100 MiB they can safely upload files of any size.

Tip for uploading very large files (> 4GB): By default Nginx will buffer large request bodies in temp files. After the body is completely received, Nginx will send the body to the upstream server (seaf-server in our case). But it seems when the file size is very large, the buffering mechanism dosen't work well. It may stop proxying the body in the middle. So if you want to support file uploads larger than 4GB, we suggest to install Nginx version >= 1.8.0 and add the following options to Nginx config file:

```
    location /seafhttp {
        ... ...
        proxy_request_buffering off;
    }
```

## Config

[seafile.conf - Seafile admin manual](https://manual.seafile.com/config/seafile-conf/)

[seahub_settings.py - Seafile admin manual](https://manual.seafile.com/config/seahub_settings_py/)

# Seafile Client Deploy

```sh
sudo apt install seafile-cli
mkdir ~/.seaf-cli
seaf-cli init -d ~/.seaf-cli
```

