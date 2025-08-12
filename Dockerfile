# 使用 codercom/code-server:latest 作为基础镜像
FROM codercom/code-server:latest

# 其余内容保持不变...

# 更新包列表，并安装必要的软件包和 Python
RUN sudo apt-get update && \
    sudo apt-get install -y \
    curl \
    software-properties-common \
    build-essential \
    git \
    wget \
    iputils-ping \
    net-tools \
    python3 \
    python3-pip \
    python3-venv \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

# 创建一个虚拟环境并激活它，拷贝 requirements.txt 文件到容器中并安装 Python 包
COPY requirements.txt /home/coder/requirements.txt
RUN python3 -m venv /home/coder/venv && \
    /home/coder/venv/bin/pip install --upgrade pip && \
    /home/coder/venv/bin/pip install -r /home/coder/requirements.txt  
    #-i https://pypi.tuna.tsinghua.edu.cn/simple

# 将虚拟环境的路径添加到 PATH
ENV PATH="/home/coder/venv/bin:$PATH"

# 安装 Node.js (使用 NodeSource 提供的安装脚本)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && \
    sudo apt-get install -y nodejs && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# 设置全局 npm 安装路径
ENV NPM_CONFIG_PREFIX=/home/coder/.npm-global
ENV PATH=/home/coder/.npm-global/bin:$PATH

# 设置全局 npm 安装路径，并安装 pnpm
RUN mkdir -p /home/coder/.npm-global && \
    npm install -g pnpm && \
    pnpm -v
    
ENV PATH=/home/coder/.npm-global/bin:$PATH

# 安装常用插件
RUN code-server --install-extension ms-python.python \
    && code-server --install-extension ms-vscode.node-debug2 \
    && code-server --install-extension timonwong.shellcheck \
    && code-server --install-extension Vue.volar \
    && code-server --install-extension johnsoncodehk.volar \
    && code-server --install-extension naumovs.color-highlight \
    && code-server --install-extension MS-CEINTL.vscode-language-pack-zh-hans \
    && code-server --install-extension Alibaba-Cloud.tongyi-lingma \
    && code-server --install-extension zaaack.markdown-editor \
    && code-server --install-extension oderwat.indent-rainbow

# 设置工作目录
WORKDIR /home/coder/project

# 暴露 code-server 的默认端口
EXPOSE 8080

# 启动 code-server
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "."]
