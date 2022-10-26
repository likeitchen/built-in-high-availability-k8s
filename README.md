# K8s built-in high availability architecture
## 简介

* 快速搭建一个不需要vip，即可高可用的K8S集群
* 搭建过程支持在线以及离线，离线情况避免访问外网无法在线安装问题
* 两三行命令即可完成集群环境适配

### 限制条件

* Linux Kernel >= 4.0 , 推荐 Ubuntu 22.04 或者 Centos 7.9

### 核心组件

* haproxy v2.0+

## 准备主机配置清单

```bash
mkdir -p /etc/kubernetes/ansible && \
cat > /etc/kubernetes/ansible/hosts.ini <<\EOF
[master]
beagle-01 ansible_ssh_host=192.168.192.100 ansible_ssh_port=22 ansible_ssh_user=root
beagle-02 ansible_ssh_host=192.168.192.101 ansible_ssh_port=22 ansible_ssh_user=root
beagle-03 ansible_ssh_host=192.168.192.102 ansible_ssh_port=22 ansible_ssh_user=root

[node]
beagle-04 ansible_ssh_host=192.168.192.103 ansible_ssh_port=22 ansible_ssh_user=root
beagle-05 ansible_ssh_host=192.168.192.104 ansible_ssh_port=22 ansible_ssh_user=root
EOF
```

## 在线一键安装HAProxy组件

- Centos

```bash
yum install -y haproxy 
```

- Ubuntu

```bash
apt install -y haproxy
```

## 安装离线HAProxy核心组件

