# Docker化的Code Server环境

## 一、概述

这个Docker镜像基于 `codercom/code-server:latest`，包括以下集成和配置：

- **Python**: 包含Python 3，支持pip和虚拟环境。
- **Node.js**: 使用NodeSource安装脚本安装Node.js 20.x。
- **npm**: 与Node.js一起安装。
- **pnpm**: 使用npm全局安装。
- **Code-server扩展**: 预装了几个有用的扩展以增强开发能力。
- **工作目录**: 设置为 `/home/coder/project`。
- **监听端口**: code-server监听8080端口。

## 二、已安装的软件和版本

### Python

- **Python版本**: Python的安装版本由基础镜像决定，并在构建过程中验证。
- **Python库**: 使用pip安装 `requirements.txt` 中指定的库。

### Node.js

- **Node.js版本**: 使用NodeSource安装脚本安装Node.js 20.x。

### npm和pnpm

- **npm版本**: 与Node.js一起安装。
- **pnpm版本**: 全局安装的pnpm版本。

### Code-server扩展

已在code-server中安装以下扩展：

- `ms-python.python`
- `ms-vscode.node-debug2`
- `timonwong.shellcheck`
- `Vue.volar`
- `johnsoncodehk.volar`
- `naumovs.color-highlight`
- `MS-CEINTL.vscode-language-pack-zh-hans`
- `Alibaba-Cloud.tongyi-lingma`
- `zaaack.markdown-editor`

## 三、构建Docker镜像

在包含 `Dockerfile` 的目录中运行以下命令来构建Docker镜像：

```sh
docker build -t my-code-server .
```

## 四、生成自签名证书

1. **生成证书和密钥文件**

   首先，在你的工作目录下生成一个`certs`目录，然后使用下面的命令生成自签名证书和密钥文件：

   ```
   mkdir certs
   cd certs
   openssl req -newkey rsa:2048 -nodes -keyout certs.key -x509 -days 365 -out certs.crt
   ```

   该命令会提示你输入一些信息，例如国家、州/省、市等。这些信息可以按提示输入，具体的内容可以根据你的实际情况填写。

2. 执行上述命令后，你会被提示输入一些信息。以下是一个示例输入：

   ```
   Country Name (2 letter code) [AU]: CN
   State or Province Name (full name) [Some-State]: Guangdong
   Locality Name (eg, city) []: Guangzhou
   Organization Name (eg, company) [Internet Widgits Pty Ltd]: MyCompany
   Organizational Unit Name (eg, section) []: IT Department
   Common Name (e.g. server FQDN or YOUR name) []: 192.168.31.186
   Email Address []: admin@mycompany.com
   
   Please enter the following 'extra' attributes
   to be sent with your certificate request
   A challenge password []:
   An optional company name []:
   ```

   解释：

   `Country Name (2 letter code)`: 国家代码，例如中国是`CN`。

   `State or Province Name (full name)`: 省或州的名称，例如广东省。

   `Locality Name (eg, city)`: 城市名称，例如广州。

   `Organization Name (eg, company)`: 公司的名称，例如MyCompany。

   `Organizational Unit Name (eg, section)`: 组织部门的名称，例如IT Department。

   `Common Name (e.g. server FQDN or YOUR name)`: 服务器的域名或IP地址，例如192.168.31.186。

   `Email Address`: 邮箱地址，例如admin@mycompany.com。

   `A challenge password`: 挑战密码，通常留空。

   `An optional company name`: 可选的公司名称，通常留空。

   这些信息填好后，证书和密钥文件将会生成在`certs`目录下。

## 五、部署Docker容器

使用以下 `docker run` 命令来部署Docker容器：

```sh
docker run --name code-server \
  -p 8080:8080 \
  --dns=223.5.5.5 --dns=8.8.8.8 \
  -v /volume1/docker/code-server:/home/coder/project \
  -v /volume1/docker/code-server/certs/certs.crt:/home/coder/cert.crt \
  -v /volume1/docker/code-server/certs/certs.key:/home/coder/cert.key \
  -e TZ=Asia/Shanghai \
  -e PASSWORD=Cors0n@dm1n. \
  --restart=always \
  --privileged=true \
  -d my-code-server \
  --cert /home/coder/cert.crt \
  --cert-key /home/coder/cert.key
```

### Docker Run命令说明

- `--name code-server`: 将运行的容器命名为"code-server"。
- `-p 8080:8080`: 将主机的8080端口映射到容器的8080端口。
- `--dns=223.5.5.5 --dns=8.8.8.8`: 为容器设置自定义DNS服务器。
- `-v /volume1/docker/code-server:/home/coder/project`: 将主机目录挂载到容器的项目目录。
- `-v /volume1/docker/code-server/certs/certs.crt:/home/coder/cert.crt`: 将主机上的SSL证书文件挂载到容器。
- `-v /volume1/docker/code-server/certs/certs.key:/home/coder/cert.key`: 将主机上的SSL证书密钥文件挂载到容器。
- `-e TZ=Asia/Shanghai`: 为容器设置时区环境变量。
- `-e PASSWORD=Cors0n@dm1n.`: 为code-server设置密码环境变量。
- `--restart=always`: 确保容器停止后总是重启。
- `--privileged=true`: 授予容器额外的特权。
- `-d`: 以后台模式运行容器。
- `my-code-server`: 指定用于容器的镜像。
- `--cert /home/coder/cert.crt --cert-key /home/coder/cert.key`: 为code-server指定SSL证书和密钥。

按照这些说明，您将拥有一个功能齐全的code-server环境，其中预装了Python、Node.js和各种扩展，准备好用于开发任务。