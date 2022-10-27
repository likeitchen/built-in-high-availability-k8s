HAProxy配置已拆分成多个文件以及目录便于使用

- example 主要包含master节点以及node节点k8s核心配置
- haproxy.cfg 主要包含haproxy核心配置，按需修改即可
- haproxy.service 主要用于systemd程序管理