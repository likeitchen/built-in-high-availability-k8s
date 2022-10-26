# K8s built-in high availability architecture
## 简介

* 快速搭建一个不需要vip，即可高可用的K8S集群
* 搭建过程支持在线以及离线，离线情况避免访问外网无法在线安装问题
* 两三行命令即可完成集群环境适配

### 限制条件

* Linux Kernel >= 4.0 , 推荐 Ubuntu 22.04

### 核心组件

* haproxy v2.0+

## 在线一键安装HAProxy组件

- Ubuntu

```bash
curl -sfL https://cache.wodcloud.com/kubernetes/k8s/haproxy/install-offline.sh | sh -
```

## 安装离线HAProxy核心组件

```bash
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
```

## 验证安装

```bash
root@k8s-node-001:~# systemctl status haproxy.service 
● haproxy.service - HAProxy Load Balancer
     Loaded: loaded (/etc/systemd/system/haproxy.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2022-10-26 19:10:04 CST; 3min 7s ago
    Process: 6352 ExecStartPre=/usr/local/bin/haproxy -f /etc/haproxy/haproxy.cfg -c -q (code=exited, status=0/SUCCESS)
   Main PID: 6355 (haproxy)
      Tasks: 3 (limit: 2187)
     Memory: 2.3M
     CGroup: /system.slice/haproxy.service
             ├─6355 /usr/local/bin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -p /var/lib/haproxy/haproxy.pid
             └─6363 /usr/local/bin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -p /var/lib/haproxy/haproxy.pid

Oct 26 19:10:04 k8s-node-001 systemd[1]: Starting HAProxy Load Balancer...
Oct 26 19:10:04 k8s-node-001 systemd[1]: Started HAProxy Load Balancer.
```

## 其他Work节点配置

```bash
 cat  /etc/kubernetes/config/kubelet.conf | head -n 8
---
apiVersion: v1
kind: Config
clusters:
- name: local
  cluster:
    server: https://127.0.0.1:6443
    certificate-authority: /etc/kubernetes/ssl/ca.crt
```
