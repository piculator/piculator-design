# 本地静态文件服务

因本项目可能在网络极差甚至没有网络的地方运行, 我打算将大部分静态文件保存到本地,然后在本地运行一个静态HTTP服务.

初步计划将此服务运行在 http://localhost:11111/

### 目录组织结构

- /usr/share/piculator/static
  - package-name
    - folder
      - files
    - files

#### 举例

- /static
  - gamma
    - js
    - css
    - images
      - logo.png
  - local
  - frontend