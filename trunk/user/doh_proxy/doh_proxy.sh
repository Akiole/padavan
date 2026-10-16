#!/bin/sh
# DoH Proxy Manager - Minimal Modular Version

BIN="/usr/sbin/https_dns_proxy"
PID_DIR="/var/run/doh-proxy"
CERT="/etc/ssl/certs/ca-certificates.crt"

# 1. 基础检查
[ -x "$BIN" ] && [ -r "$CERT" ] || { echo "Error: Missing binary or cert"; exit 1; }
mkdir -p "$PID_DIR"

# 2. 配置加载
PORT=$(nvram get doh_listen_port); PORT=${PORT:-53}
MODE=$(nvram get doh_listen_mode); MODE=${MODE:-0}
BOOT=$(nvram get doh_bootstrap_dns)
QUIC=$(nvram get doh_quic)

# 确定监听地址
case "$MODE" in
    1) ADDR=$(nvram get lan_ipaddr_t); : ${ADDR:=192.168.1.1} ;;
    2) ADDR="0.0.0.0" ;;
    ) ADDR="127.0.0.1" ;;
esac

# 3. 核心函数：启动单个实例
start_one() {
    local i=$1
    local URL=$(nvram get doh_server$i)
    [ -z "$URL" ] && return 0 # 未配置则跳过

    local PFILE="$PID_DIR/${i}.pid"
    
    # 如果已运行且PID有效，不重复启动
    if [ -f "$PFILE" ] && kill -0 "$(cat $PFILE)" 2>/dev/null; then
        return 0
    fi

    # 构建参数
    local ARGS="-a $ADDR -p $((PORT + i)) -r $URL -C $CERT -u nobody -g nogroup -4"
    [ -n "$BOOT" ] && ARGS="$ARGS -b $BOOT"
    [ "$QUIC" = "1" ] && ARGS="$ARGS -q"

    # 启动并记录PID
    $BIN $ARGS &
    echo $! > "$PFILE"
}

# 4. 核心函数：停止单个实例
stop_one() {
    local i=$1
    local PFILE="$PID_DIR/${i}.pid"
    if [ -f "$PFILE" ]; then
        kill "$(cat $PFILE)" 2>/dev/null
        rm -f "$PFILE"
    fi
}

# 5. 主流程处理
case "${1:-start}" in
    start)
        for i in 0 1 2 3; do start_one $i; done
        ;;
    stop)
        for i in 0 1 2 3; do stop_one $i; done
        # 清理可能残留的孤儿进程
        pkill -f "$BIN" 2>/dev/null || true
        ;;
    restart)
        sh "$0" stop
        sleep 1
        sh "$0" start
        ;;
    )
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac

exit 0
