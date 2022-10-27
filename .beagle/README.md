# K8S-HAProxy

# tgz

## amd64

```bash
#!/bin/bash

# HTTPS服务器
export HTTP_SERVER=https://cache.wodcloud.com/kubernetes
# 平台架构
export TARGET_ARCH=amd64
# HAProxy版本
export HAPROXY_VERSION=2.0.29


if ! [ -e /etc/kubernetes/haproxy/haproxy-$HAPROXY_VERSION.tgz ]; then
mkdir -p /etc/kubernetes/haproxy /opt/haproxy
# 下载文件
curl $HTTP_SERVER/k8s/haproxy/$TARGET_ARCH/haproxy-$HAPROXY_VERSION.tgz > /etc/kubernetes/haproxy/haproxy-$HAPROXY_VERSION.tgz
# 解压文件
tar xzvf /etc/kubernetes/haproxy/haproxy-$HAPROXY_VERSION.tgz -C /opt/haproxy
# 安装HAProxy
bash /opt/haproxy/install.sh
fi

# 创建HAProxy核心目录
mkdir -p /opt/bin /opt/haproxy /etc/haproxy /var/lib/haproxy

ENV_OPT="/opt/bin:$PATH"
if ! (grep -q /opt/bin /etc/environment) ; then
  cat > /etc/environment <<-EOF
PATH="${ENV_OPT}"
EOF
fi
source /etc/environment

rm -rf /etc/kubernetes/haproxy/haproxy-2.0.29.tgz

cp /opt/haproxy/haproxy /opt/bin
cp /opt/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg
cp /opt/haproxy/haproxy.service /etc/systemd/system/haproxy.service
 
ln -s /opt/haproxy/haproxy /usr/local/bin/haproxy

systemctl daemon-reload
systemctl enable haproxy && systemctl restart haproxy
```

## arm64

```bash
#!/bin/bash

# HTTPS服务器
export HTTP_SERVER=https://cache.wodcloud.com/kubernetes
# 平台架构
export TARGET_ARCH=arm64
# HAProxy版本
export HAPROXY_VERSION=2.0.29


if ! [ -e /etc/kubernetes/haproxy/haproxy-$HAPROXY_VERSION.tgz ]; then
mkdir -p /etc/kubernetes/haproxy /opt/haproxy
# 下载文件
curl $HTTP_SERVER/k8s/haproxy/$TARGET_ARCH/haproxy-$HAPROXY_VERSION.tgz > /etc/kubernetes/haproxy/haproxy-$HAPROXY_VERSION.tgz
# 解压文件
tar xzvf /etc/kubernetes/haproxy/haproxy-$HAPROXY_VERSION.tgz -C /opt/haproxy
# 安装HAProxy
bash /opt/haproxy/install.sh
fi

# 创建HAProxy核心目录
mkdir -p /opt/bin /opt/haproxy /etc/haproxy /var/lib/haproxy

ENV_OPT="/opt/bin:$PATH"
if ! (grep -q /opt/bin /etc/environment) ; then
  cat > /etc/environment <<-EOF
PATH="${ENV_OPT}"
EOF
fi
source /etc/environment

rm -rf /etc/kubernetes/haproxy/haproxy-2.0.29.tgz

cp /opt/haproxy/haproxy /opt/bin
cp /opt/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg
cp /opt/haproxy/haproxy.service /etc/systemd/system/haproxy.service
 
ln -s /opt/haproxy/haproxy /usr/local/bin/haproxy

systemctl daemon-reload
systemctl enable haproxy && systemctl restart haproxy
```

