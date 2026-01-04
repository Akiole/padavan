#!/bin/sh

# 统一核心配置变量（便于后续修改维护）
ADG_CONF="/etc/storage/AdGuardHome.yaml"
ADG_TMP_WORK="/tmp/AdGuardHome"
ADG_STORAGE="/etc/storage/AdGuardHome"
REDIRECT_PORT="5335"
DNS_PORT="53"

# 1. 配置 dnsmasq 转发（adg_redirect=1 时生效）
change_dns() {
    if [ "$(nvram get adg_redirect)" = 1 ]; then
        # 先清理旧配置，避免重复添加
        sed -i '/no-resolv/d' /etc/storage/dnsmasq/dnsmasq.conf
        sed -i "/server=127.0.0.1#${REDIRECT_PORT}/d" /etc/storage/dnsmasq/dnsmasq.conf
        # 添加新的DNS转发配置
        cat >> /etc/storage/dnsmasq/dnsmasq.conf << EOF
no-resolv
server=127.0.0.1#${REDIRECT_PORT}
EOF
        /sbin/restart_dhcpd
        logger -t "AdGuardHome" "DNS转发已配置：127.0.0.1#${REDIRECT_PORT}"
    fi
}

# 2. 清理 dnsmasq 转发配置
del_dns() {
    sed -i '/no-resolv/d' /etc/storage/dnsmasq/dnsmasq.conf
    sed -i "/server=127.0.0.1#${REDIRECT_PORT}/d" /etc/storage/dnsmasq/dnsmasq.conf
    /sbin/restart_dhcpd
}

# 3. 设置 iptables 端口重定向（adg_redirect=2 时生效）
set_iptable() {
    if [ "$(nvram get adg_redirect)" = 2 ]; then
        # IPv4 地址重定向
        local IPS=$(ifconfig | grep "inet addr" | grep -v ":127" | grep "Bcast" | awk '{print $2}' | awk -F : '{print $2}')
        for IP in $IPS; do
            iptables -t nat -A PREROUTING -p tcp -d $IP --dport $DNS_PORT -j REDIRECT --to-ports $REDIRECT_PORT >/dev/null 2>&1
            iptables -t nat -A PREROUTING -p udp -d $IP --dport $DNS_PORT -j REDIRECT --to-ports $REDIRECT_PORT >/dev/null 2>&1
        done

        # IPv6 地址重定向
        local IPS6=$(ifconfig | grep "inet6 addr" | grep -v " fe80::" | grep -v " ::1" | grep "Global" | awk '{print $3}')
        for IP in $IPS6; do
            ip6tables -t nat -A PREROUTING -p tcp -d $IP --dport $DNS_PORT -j REDIRECT --to-ports $REDIRECT_PORT >/dev/null 2>&1
            ip6tables -t nat -A PREROUTING -p udp -d $IP --dport $DNS_PORT -j REDIRECT --to-ports $REDIRECT_PORT >/dev/null 2>&1
        done

        logger -t "AdGuardHome" "端口重定向已配置：${DNS_PORT} -> ${REDIRECT_PORT}"
    fi
}

# 4. 清理 iptables 端口重定向规则
clear_iptable() {
    # 清理 IPv4 规则
    local IPS=$(ifconfig | grep "inet addr" | grep -v ":127" | grep "Bcast" | awk '{print $2}' | awk -F : '{print $2}')
    for IP in $IPS; do
        iptables -t nat -D PREROUTING -p udp -d $IP --dport $DNS_PORT -j REDIRECT --to-ports $REDIRECT_PORT >/dev/null 2>&1
        iptables -t nat -D PREROUTING -p tcp -d $IP --dport $DNS_PORT -j REDIRECT --to-ports $REDIRECT_PORT >/dev/null 2>&1
    done

    # 清理 IPv6 规则
    local IPS6=$(ifconfig | grep "inet6 addr" | grep -v " fe80::" | grep -v " ::1" | grep "Global" | awk '{print $3}')
    for IP in $IPS6; do
        ip6tables -t nat -D PREROUTING -p udp -d $IP --dport $DNS_PORT -j REDIRECT --to-ports $REDIRECT_PORT >/dev/null 2>&1
        ip6tables -t nat -D PREROUTING -p tcp -d $IP --dport $DNS_PORT -j REDIRECT --to-ports $REDIRECT_PORT >/dev/null 2>&1
    done
}

# 5. 生成 AdGuardHome 默认配置文件（无配置/配置为空时自动生成）
getconfig() {
    if [ ! -f "$ADG_CONF" ] || [ ! -s "$ADG_CONF" ]; then
        cat > "$ADG_CONF" <<-\EEE
http:
  address: 0.0.0.0:3030
  session_ttl: 720h
users:
  - name: AdGuardHome
    password: $2a$10$RV.8NZNelJkpu0yGIQmaOePUc37iTJtkddYGpuHasxqNpyTTodeii
language: zh-cn
theme: dark
dns:
  bind_hosts: [0.0.0.0]
  port: 5335
  refuse_any: true
  upstream_dns: [119.29.29.29, 223.5.5.5]
  bootstrap_dns: [119.29.29.29]
  fallback_dns: [119.29.29.29]
  cache_size: 10000
  cache_ttl_min: 60
  cache_ttl_max: 3600
filtering:
  protection_enabled: true
  filtering_enabled: false
  filters_update_interval: 24
whitelist_filters:
  - enabled: true
    url: https://raw.githubusercontent.com/BlueSkyXN/AdGuardHomeRules/master/ok.txt
    name: ok
    id: 1738938865
user_rules:
  - '@@||ii.gdt.qq.com^$important'
  - '@@||sdkreport.e.qq.com^$important'
  - '@@||oth.bls.mdt.qq.com^$important'
  - '@@||tangram.e.qq.com^$important'
  - '@@||adsmind.gdtimg.com^$important'
  - '@@||pgdt.gtimg.cn^$important'
dhcp:
  enabled: false
log:
  enabled: true
  verbose: false
os:
  rlimit_nofile: 0
schema_version: 29
EEE
        chmod 644 "$ADG_CONF"  # 配置文件无需执行权限，644更安全
    fi
}

# 6. 启动 AdGuardHome
start_adg() {
    # 创建必要目录 + 调整 tmp 分区大小
    mkdir -p $ADG_TMP_WORK $ADG_STORAGE
    mount -o remount,size=16M /tmp >/dev/null 2>&1

    # 初始化配置 + 配置网络规则 + 启动进程
    getconfig
    change_dns
    set_iptable
    AdGuardHome -c $ADG_CONF -w $ADG_TMP_WORK &
    logger -t "AdGuardHome" "AdGuardHome 已启动"
}

# 7. 停止 AdGuardHome
stop_adg() {
    # 停止进程（优先优雅停止，失败则强制终止）
    killall AdGuardHome >/dev/null 2>&1
    [ $? -ne 0 ] && killall -9 AdGuardHome >/dev/null 2>&1

    # 清理资源 + 恢复网络配置
    rm -rf $ADG_TMP_WORK
    del_dns
    clear_iptable
    logger -t "AdGuardHome" "AdGuardHome 已停止"
}

# 主流程：参数判断
case $1 in
    start)
        start_adg
        ;;
    stop)
        stop_adg
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
