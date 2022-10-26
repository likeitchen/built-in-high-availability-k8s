#!/bin/bash
#
#**********************************************************************************************
#Author:        Xinning Chen
#Date:          2022-10-25
#FileName:      install_haproxy.sh
#Description:   The test script
#**********************************************************************************************

set -ex

# HTTPS服务器
export HTTP_SERVER=https://cache.wodcloud.com/kubernetes
# 平台架构
export TARGET_ARCH=amd64
# K8S版本
export HAPROXY_VERSION=2.0.29


if ! [ -e /etc/kubernetes/haproxy/haproxy-$HAPROXY_VERSION.tgz ]; then
mkdir -p /etc/kubernetes/haproxy /opt/haproxy
# 下载文件
curl $HTTP_SERVER/k8s/haproxy/$TARGET_ARCH/haproxy-$HAPROXY_VERSION.tgz > /etc/kubernetes/haproxy/haproxy-$HAPROXY_VERSION.tgz
# 解压文件
tar xzvf /etc/kubernetes/haproxy/haproxy-$HAPROXY_VERSION.tgz -C /opt/haproxy
# 安装Docker
bash /opt/haproxy/install.sh
fi

# 创建haproxy核心目录
mkdir -p /opt/bin /opt/haproxy /etc/haproxy /var/lib/haproxy

rm -rf /etc/kubernetes/haproxy/haproxy-2.0.29.tgz

cp /opt/haproxy/haproxy /opt/bin
cp /opt/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg
cp /opt/haproxy/haproxy.service /etc/systemd/system/haproxy.service

ls -s /opt/haproxy/haproxy /usr/local/bin/haproxy

systemctl daemon-reload
systemctl enable haproxy
