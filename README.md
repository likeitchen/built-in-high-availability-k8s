# K8s built-in high availability architecture
## 简介

* 快速搭建一个不需要vip，即可高可用的K8S集群
* 搭建过程支持在线以及离线，离线情况避免访问外网无法在线安装问题
* 两三行命令即可完成集群环境适配

## 概述

每个work节点部署一个haproxy（负载均衡），所有master的核心组件连接本地kube-apiserver，所有工作节点通过haproxy代理到多个master的kube-apiserver，如果当前集群或者部署环境无法提供外部负载或者vip，可以采用此种方法进行集群高可用部署

## 架构图



![k8s-haproxy](https://github.com/likeitchen/built-in-high-availability-k8s/blob/dev-test/artwork/PNG/K8S-HAProxy.png)

### 限制条件

* Linux Kernel >= 4.0 , 推荐 Ubuntu 22.04
* K8S集群

### 核心组件

* haproxy v2.0+
* docker 20.10+
* kubernetes 1.20+

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

### HAProxy验证安装

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

root@k8s-node-001:~# haproxy -v
HA-Proxy version 2.0.29-5e15b0f 2022/05/13 - https://haproxy.org/
```

## K8S集群检查

### master节点配置

- cat /etc/kubernetes/config/kubelet.conf

```yaml
apiVersion: v1
kind: Config
clusters:
- name: local
  cluster:
    server: https://127.0.0.1:6443
    certificate-authority: /etc/kubernetes/ssl/ca.crt
users:
- name: kubelet
  user:
    client-certificate: /etc/kubernetes/ssl/kubelet.crt
    client-key: /etc/kubernetes/ssl/kubelet.key
contexts:
- context:
    cluster: local
    user: kubelet
  name: kubelet-context
current-context: kubelet-context
```

- cat /root/.kube/config

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /etc/kubernetes/ssl/ca.crt
    server: https://127.0.0.1:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: default
  name: kubernetes
current-context: kubernetes
kind: Config
preferences: {}
users:
- name: default
  user:
    client-certificate: /etc/kubernetes/ssl/admin.crt
    client-key: /etc/kubernetes/ssl/admin.key
```

### work节点配置

- /etc/haproxy/haproxy.cfg

```bash
global
  maxconn  2000
  log  127.0.0.1 local0 err

defaults
  log global
  mode  http
  option  httplog
  timeout connect 5000
  timeout client  50000
  timeout server  50000
  timeout http-request 15s
  timeout http-keep-alive 15s
  retries 3
  maxconn  2000

listen  stats
        bind    0.0.0.0:8888
        stats   refresh 30s
        stats   uri /
        stats   realm   baison-test-Haproxy
        stats   auth    beagle:beagle
        bind-process    1

frontend k8s-master
  bind 0.0.0.0:8080
  bind 127.0.0.1:8080
  mode tcp
  option tcplog
  tcp-request inspect-delay 5s
  default_backend k8s-master

backend k8s-master
  mode tcp
  option tcplog
  option tcp-check
  balance roundrobin
  default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
  server k8s-master01    192.168.192.100:6443  check
  server k8s-master02    192.168.192.101:6443  check
  server k8s-master03    192.168.192.102:6443  check
```

- cat /etc/kubernetes/config/kubelet.conf 

```yaml
apiVersion: v1
kind: Config
clusters:
- name: local
  cluster:
    server: https://127.0.0.1:8080
    certificate-authority: /etc/kubernetes/ssl/ca.crt
users:
- name: kubelet
  user:
    client-certificate: /etc/kubernetes/ssl/kubelet.crt
    client-key: /etc/kubernetes/ssl/kubelet.key
contexts:
- context:
    cluster: local
    user: kubelet
  name: kubelet-context
current-context: kubelet-context
```

### 最终结果

* 此时，整个集群仅有一个master节点kube-apiserver正常，但是丝毫不影响work节点正常运行。

```bash
root@k8s-master-003:~# kubectl get nodes
NAME              STATUS     ROLES    AGE   VERSION
192.168.192.100   NotReady   master   22m   v1.20.9-beagle
192.168.192.101   NotReady   master   22m   v1.20.9-beagle
192.168.192.102   Ready      master   22m   v1.20.9-beagle
192.168.192.103   Ready      <none>   20m   v1.20.9-beagle
192.168.192.104   Ready      <none>   20m   v1.20.9-beagle
```

