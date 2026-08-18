#!/bin/sh
# Copyright (C) 2018 Nick Peng (pymumu@gmail.com)
# Copyright (C) 2019 chongshengB (bkye@vip.qq.com)
# Copyright (C) 2022 TurBoTse (860018505@qq.com)

action="$1"
# 存储路径与程序路径
storage_Path="/etc/storage"
smartdns_Bin="/usr/bin/smartdns"
# 配置文件路径
smartdns_Ini="$storage_Path/smartdns_conf.ini"
smartdns_Conf="$storage_Path/smartdns.conf"
smartdns_tmp_Conf="$storage_Path/smartdns_tmp.conf"
# 规则文件路径
smartdns_address_Conf="$storage_Path/smartdns_address.conf"
smartdns_blacklist_Conf="$storage_Path/smartdns_blacklist-ip.conf"
smartdns_whitelist_Conf="$storage_Path/smartdns_whitelist-ip.conf"
smartdns_custom_Conf="$storage_Path/smartdns_custom.conf"
# 依赖服务配置
dnsmasq_Conf="$storage_Path/dnsmasq/dnsmasq.conf"
chn_Route="$storage_Path/chinadns/chnroute.txt"

# nvram 参数
sdns_enable=$(nvram get sdns_enable)
sdns_name=$(nvram get sdns_name)
sdns_group=$(nvram get sdns_group)
sdns_port=$(nvram get sdns_port)
sdns_tcp_server=$(nvram get sdns_tcp_server)
sdns_ipv6_server=$(nvram get sdns_ipv6_server)
sdns_redirect=$(nvram get sdns_redirect)

# 缓存相关配置
sdns_cache=$(nvram get sdns_cache)
sdns_cache_persist=$(nvram get sdns_cache_persist)
sdns_cache_checkpoint_time=$(nvram get sdns_cache_checkpoint_time)
sdns_tcp_idle_time=$(nvram get sdns_tcp_idle_time)
sdns_rr_ttl=$(nvram get sdns_rr_ttl)
sdns_rr_ttl_min=$(nvram get sdns_rr_ttl_min)
sdns_rr_ttl_max=$(nvram get sdns_rr_ttl_max)
sdns_rr_ttl_reply_max=$(nvram get sdns_rr_ttl_reply_max)

# 解析与优化配置
sdns_max_reply_ip_num=$(nvram get sdns_max_reply_ip_num)
sdns_speed=$(nvram get sdns_speed)
sdns_speed_mode=$(nvram get sdns_speed_mode)
sdns_address=$(nvram get sdns_address)
sdns_ipset=$(nvram get sdns_ipset)
sdns_ipset_timeout=$(nvram get sdns_ipset_timeout)
sdns_as=$(nvram get sdns_as)
sdns_ns=$(nvram get sdns_ns)
sdns_ip_change=$(nvram get sdns_ip_change)
sdns_ip_change_time=$(nvram get sdns_ip_change_time)
sdns_dualstack_ip_allow_force_aaaa=$(nvram get sdns_dualstack_ip_allow_force_aaaa)
sdns_force_aaaa_soa=$(nvram get sdns_force_aaaa_soa)
sdns_force_qtype_soa=$(nvram get sdns_force_qtype_soa)
sdns_prefetch_domain=$(nvram get sdns_prefetch_domain)

# 过期缓存配置
sdns_exp=$(nvram get sdns_exp)
sdns_exp_ttl=$(nvram get sdns_exp_ttl)
sdns_exp_ttl_max=$(nvram get sdns_exp_ttl_max)
sdns_exp_prefetch_time=$(nvram get sdns_exp_prefetch_time)

# 第二服务器配置
sdnse_enable=$(nvram get sdnse_enable)
sdnse_port=$(nvram get sdnse_port)
sdnse_tcp_server=$(nvram get sdnse_tcp_server)
sdnse_speed=$(nvram get sdnse_speed)
sdnse_name=$(nvram get sdnse_name)
sdnse_address=$(nvram get sdnse_address)
sdnse_ns=$(nvram get sdnse_ns)
sdnse_ipset=$(nvram get sdnse_ipset)
sdnse_as=$(nvram get sdnse_as)
sdnse_ipv6_server=$(nvram get sdnse_ipv6_server)
sdnse_ipc=$(nvram get sdnse_ipc)
sdnse_cache=$(nvram get sdnse_cache)

# 附加功能配置
sdns_adblock=$(nvram get sdns_adblock)
sdns_white=$(nvram get sdns_white)
sdns_black=$(nvram get sdns_black)
sdns_coredump=$(nvram get sdns_coredump)
sdns_auto_restart=$(nvram get sdns_auto_restart)

# 运行时状态变量
adbyby_process=$(pidof adbyby | awk '{ print $1 }')
smartdns_process=$(pidof smartdns | awk '{ print $1 }')
IPS4="$(ifconfig br0 | grep "inet addr" | grep -v ":127" | grep "Bcast" | awk '{print $2}' | awk -F : '{print $2}')"
IPS6="$(ifconfig br0 | grep "inet6 addr" | grep -v "fe80::" | grep -v "::1" | grep "Global" | awk '{print $3}')"
dnsmasq_md5=$(md5sum "$dnsmasq_Conf" | awk '{ print $1 }')

# 读取初始化配置
Read_ini () {
    if [ -s "$smartdns_Ini" ] ; then
        hosts_type=$(sed -n '1p' "$smartdns_Ini")
        sdns_redirected=$(sed -n '2p' "$smartdns_Ini")
        sdns_ported=$(sed -n '3p' "$smartdns_Ini")
        sdnse_ported=$(sed -n '4p' "$smartdns_Ini")
    else
        hosts_type=0
        sdns_redirected=0
        sdns_ported="$sdns_port"
        sdnse_ported="$sdnse_port"
    fi
}

# 文件完整性校验
Check_md5 () {
    # 【检测某些文件是否变动】
    echo "smartdns：" "Enter Check_md5"
    
    files="$storage_Path/smartdns_*.sh"
    md5="$storage_Path/smartdns.md5"
    new_md5="/tmp/smartdns.md5"
    status=0
    
    md5sum -b "$files" > $new_md5
    if [ -s "$md5" ] ; then
        diff "$md5" "$new_md5" >/dev/null 2>&1
        [ $? -eq 1 ] && status=1
    else
        status=1
    fi
    [ "$status" = 1 ] && cat "$new_md5" > "$md5" && mtd_storage.sh save >/dev/null 2>&1
    echo "smartdns：Leave Check_md5"
}

# SS冲突检测
Check_ss(){
    if [ -s /etc_ro/ss_ip.sh ] ; then
        if [ $(nvram get ss_enable) = 1 ] && [ $(nvram get ss_run_mode) = "router" ] && [ $(nvram get pdnsd_enable) = 0 ] ; then
            logger -t "SmartDNS" "系统检测到 SS 模式为绕过大陆模式，并且未启用 pdnsd 请先调整 SS 解析使用 SmartDNS +手动配置模式！程序将退出..."
            nvram set sdns_enable=0
            exit 0
        fi
    fi
}

# IP地址格式验证（辅助函数）
Check_ip_addr () {
    echo "$1" | grep "^[0-9]\{1,3\}\.\([0-9]\{1,3\}\.\)\{2\}[0-9]\{1,3\}$" >/dev/null
    if [ $? -ne 0 ] ; then
        return 1
    fi
    ipaddr="$1"
    a=$(echo "$ipaddr" | awk -F . '{ print $1 }')
    b=$(echo "$ipaddr" | awk -F . '{ print $2 }')
    c=$(echo "$ipaddr" | awk -F . '{ print $3 }')
    d=$(echo "$ipaddr" | awk -F . '{ print $4 }')
    for num in "$a" "$b" "$c" "$d"
    do
        if [ "$num" -gt 255 ] || [ "$num" -lt 0 ] ; then
            return 1
        fi
    done
    return 0
}

# 广告过滤规则下载与转换
Start_AD() {
    if [ "$sdns_adblock" -ne 1 ]; then
        if [ -f "/tmp/anti-ad-for-smartdns.conf" ]; then
            :> "/tmp/anti-ad-for-smartdns.conf"
            logger -t "SmartDNS" "广告过滤已关闭：已清空现有规则文件"
        fi
        return
    fi

    ad_url=$(nvram get sdns_adblock_url)
    if [ -z "$ad_url" ]; then
        logger -t "SmartDNS" "广告过滤启用但未配置规则下载地址，无法获取规则"
        return
    fi

    # 下载规则（添加 -f 避免 HTTP 错误时生成空文件）
    curl -s -L -f -o "/tmp/sdnsadnew.conf" --connect-timeout 10 --retry 3 "$ad_url"
    if [ ! -f "/tmp/sdnsadnew.conf" ] || [ ! -s "/tmp/sdnsadnew.conf" ]; then
        logger -t "SmartDNS" "广告过滤规则下载失败（地址无效、网络异常或文件为空）"
        rm -f "/tmp/sdnsadnew.conf"
        return
    fi

    logger -t "SmartDNS" "广告过滤规则下载成功，正在处理..."
    target_conf="/tmp/anti-ad-for-smartdns.conf"
    :> "$target_conf"  # 清空目标文件

    # 1. 提取原生 SmartDNS 规则（仅保留 address /域名/# 或 /IP 格式）
    grep -E '^address /[a-zA-Z0-9.-]+/(#|[0-9.]+)$' "/tmp/sdnsadnew.conf" >> "$target_conf"

    # 2. 处理 AdBlock 格式规则（支持纯域名和 *.子域名格式）
    awk '
        # 排除注释行（! 开头）和空行
        /^!|^$/ { next }
        # 匹配「||域名^」或「||*.子域名^」格式
        /^||(\*\.|)([a-zA-Z0-9.-]+\.[a-zA-Z0-9-]+)\^$/ {
            domain = $0
            sub(/^||/, "address /", domain)  # 替换开头 || 为 address /
            sub(/\^$/, "/#", domain)         # 替换结尾 ^ 为 /#
            print domain
        }
    ' "/tmp/sdnsadnew.conf" >> "$target_conf"

    # 3. 处理 Hosts 格式规则
    awk '
        # 保留注释行（#开头，允许行首空格）
        /^[[:space:]]*#/ { print; next }
        # 保留空行
        /^[[:space:]]*$/ { print; next }
        # 仅匹配「IP 域名」格式（IP 为 0.0.0.0 或自定义 IP，域名不含特殊字符）
        /^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|::1)[[:space:]]+([a-zA-Z0-9.-]+)$/ {
            ip = $1
            domain = $2
            # 本地地址（127.0.0.1、::1）→ 转换为注释掉的SmartDNS规则
            if (ip ~ /^(127\.0\.0\.1|::1)$/) {
                print "#address /" domain "/# （本地地址规则已注释）"
                next
            }
            # 0.0.0.0 → 拦截规则
            if (ip == "0.0.0.0") {
                print "address /" domain "/#"
                next
            }
            # 自定义有效 IP → 定向解析（IP 非 0.0.0.0/127.0.0.1）
            if (ip ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && ip !~ /^(0\.0\.0\.0|127\.0\.0\.1)$/) {
                print "address /" domain "/" ip
            }
        }
    ' "/tmp/sdnsadnew.conf" >> "$target_conf"
    
    # 4. 去重（避免重复规则占用资源）
    sort -u "$target_conf" -o "$target_conf"

    rm -f "/tmp/sdnsadnew.conf"
    logger -t "SmartDNS" "广告过滤规则处理完成：$target_conf"
}

# 生成第二服务器配置（辅助函数）
Get_sdnse_conf () {
    if [ "$sdnse_enable" -ne 1 ]; then
        return
    fi

    ARGS_2=""
    bind_addr=""

    if [ -n "$sdnse_name" ]; then
        ARGS_2="$ARGS_2 -group $sdnse_name"
    fi
    if [ "$sdnse_address" = "1" ]; then
        ARGS_2="$ARGS_2 -no-rule-addr"
    fi
    if [ "$sdnse_ns" = "1" ]; then
        ARGS_2="$ARGS_2 -no-rule-nameserver"
    fi
    if [ "$sdnse_ipset" = "1" ]; then
        ARGS_2="$ARGS_2 -no-rule-ipset"
    fi
    if [ "$sdnse_speed" = "1" ]; then
        ARGS_2="$ARGS_2 -no-speed-check"
    fi
    if [ "$sdnse_as" = "1" ]; then
        ARGS_2="$ARGS_2 -no-rule-soa"
    fi
    if [ "$sdnse_ipc" = "1" ]; then
        ARGS_2="$ARGS_2 -no-dualstack-selection"
    fi
    if [ "$sdnse_cache" = "1" ]; then
        ARGS_2="$ARGS_2 -no-cache"
    fi

    if [ "$sdnse_ipv6_server" = "1" ]; then
        bind_addr="[::]:$sdnse_port"
    else
        bind_addr=":$sdnse_port"
    fi
    echo "bind $bind_addr $ARGS_2" >> "$smartdns_tmp_Conf"
    if [ "$sdnse_tcp_server" = "1" ]; then
        echo "bind-tcp $bind_addr $ARGS_2" >> "$smartdns_tmp_Conf"
    fi
}

# 生成主配置文件
Get_sdns_conf () {
    :> "$smartdns_tmp_Conf"

    echo "server-name $sdns_name" >> "$smartdns_tmp_Conf"
    ARGS_1=""
    if [ -n "$sdns_group" ]; then
        ARGS_1="$ARGS_1 -group $sdns_group"
    fi
    if [ "$sdns_address" = "1" ]; then
        ARGS_1="$ARGS_1 -no-rule-addr"
    fi
    if [ "$sdns_ns" = "1" ]; then
        ARGS_1="$ARGS_1 -no-rule-nameserver"
    fi
    if [ "$sdns_ipset" = "1" ]; then
        ARGS_1="$ARGS_1 -no-rule-ipset"
    fi
    if [ "$sdns_speed" = "1" ]; then
        ARGS_1="$ARGS_1 -no-speed-check"
    fi
    if [ "$sdns_as" = "1" ]; then
        ARGS_1="$ARGS_1 -no-rule-soa"
    fi

    bind_addr=""
    if [ "$sdns_ipv6_server" = "1" ]; then
        bind_addr="[::]:$sdns_port"
    else
        bind_addr=":$sdns_port"
    fi
    echo "bind $bind_addr $ARGS_1" >> "$smartdns_tmp_Conf"
    if [ "$sdns_tcp_server" = "1" ]; then
        echo "bind-tcp $bind_addr $ARGS_1" >> "$smartdns_tmp_Conf"
    fi

    Get_sdnse_conf

    # 基础配置写入
    echo "cache-size $sdns_cache" >> "$smartdns_tmp_Conf"
    echo "rr-ttl $sdns_rr_ttl" >> "$smartdns_tmp_Conf"
    echo "rr-ttl-min $sdns_rr_ttl_min" >> "$smartdns_tmp_Conf"
    echo "rr-ttl-max $sdns_rr_ttl_max" >> "$smartdns_tmp_Conf"
    echo "tcp-idle-time $sdns_tcp_idle_time" >> "$smartdns_tmp_Conf"
    echo "rr-ttl-reply-max $sdns_rr_ttl_reply_max" >> "$smartdns_tmp_Conf"
    echo "max-reply-ip-num $sdns_max_reply_ip_num" >> "$smartdns_tmp_Conf"
    # echo "force-qtype-SOA $sdns_force_qtype_soa" >> "$smartdns_tmp_Conf"
    echo "speed-check-mode $sdns_speed_mode" >> "$smartdns_tmp_Conf"

    # 双栈与 AAAA 逻辑优化
    if [ "$sdns_ip_change" -eq 1 ]; then
        # 分支 A：如果开启了双栈模式，只配置双栈
        echo "dualstack-ip-selection yes" >> "$smartdns_tmp_Conf"
        echo "dualstack-ip-selection-threshold $(nvram get sdns_ip_change_time)" >> "$smartdns_tmp_Conf"
    else
        # 分支 B：如果没开启双栈模式，才去考虑 SOA 逻辑
        if [ "$sdns_force_aaaa_soa" -eq 1 ] && [ "$sdns_cache" -gt 0 ]; then
            echo "force-AAAA-SOA yes" >> "$smartdns_tmp_Conf"
        else
            echo "force-AAAA-SOA no" >> "$smartdns_tmp_Conf"
        fi
    fi

    # 强制 AAAA 逻辑
    if [ "$sdns_dualstack_ip_allow_force_aaaa" -eq 1 ] && [ "$sdns_cache" -gt 0 ]; then
        echo "dualstack-ip-allow-force-AAAA yes" >> "$smartdns_tmp_Conf"
    else
        echo "dualstack-ip-allow-force-AAAA no" >> "$smartdns_tmp_Conf"
    fi

    # 缓存持久化
    if [ "$sdns_cache_persist" -eq 1 ] && [ "$sdns_cache" -gt 0 ]; then
        echo "cache-persist yes" >> "$smartdns_tmp_Conf"
        echo "cache-file /tmp/smartdns.cache" >> "$smartdns_tmp_Conf"
        echo "cache-checkpoint-time $sdns_cache_checkpoint_time" >> "$smartdns_tmp_Conf"
    else
        echo "cache-persist no" >> "$smartdns_tmp_Conf"
    fi

    # 其他功能开关处理
    if [ "$sdns_prefetch_domain" -eq 1 ] && [ "$sdns_cache" -gt 0 ]; then
        echo "prefetch-domain yes" >> "$smartdns_tmp_Conf"
    else
        echo "prefetch-domain no" >> "$smartdns_tmp_Conf"
    fi

    if [ "$sdns_ipset_timeout" -eq 1 ] && [ "$sdns_cache" -gt 0 ]; then
        echo "ipset-timeout yes" >> "$smartdns_tmp_Conf"
    else
        echo "ipset-timeout no" >> "$smartdns_tmp_Conf"
    fi

    # 过期解析逻辑 (修复除了重复的判断)
    if [ "$sdns_exp" -eq 1 ] && [ "$sdns_cache" -gt 0 ]; then
        echo "serve-expired yes" >> "$smartdns_tmp_Conf"
        echo "serve-expired-ttl $sdns_exp_ttl" >> "$smartdns_tmp_Conf"
        echo "serve-expired-reply-ttl $sdns_exp_ttl_max" >> "$smartdns_tmp_Conf"
        echo "serve-expired-prefetch-time $sdns_exp_prefetch_time" >> "$smartdns_tmp_Conf"
    else
        echo "serve-expired no" >> "$smartdns_tmp_Conf"
    fi

    if [ "$sdns_adblock" -eq 1 ] && [ "$sdns_cache" -gt 0 ]; then
        echo "conf-file /tmp/anti-ad-for-smartdns.conf" >> "$smartdns_tmp_Conf"
    fi

    echo "log-level error" >> "$smartdns_tmp_Conf"

    # 上游服务器循环
    listnum=$(nvram get sdns_staticnum_x)
    for i in $(seq 1 "$listnum"); do
        j=$(expr "$i" - 1)
        sdnss_enable=$(nvram get sdnss_enable_x"$j")
        if [ "$sdnss_enable" -ne 1 ]; then
            continue
        fi

        sdnss_name=$(nvram get sdnss_name_x"$j")
        sdnss_ip=$(nvram get sdnss_ip_x"$j")
        sdnss_port=$(nvram get sdnss_port_x"$j")
        sdnss_type=$(nvram get sdnss_type_x"$j")
        sdnss_ipc=$(nvram get sdnss_ipc_x"$j")
        sdnss_named=$(nvram get sdnss_named_x"$j")
        sdnss_non=$(nvram get sdnss_non_x"$j")
        sdnss_ipset=$(nvram get sdnss_ipset_x"$j")

        ipc=""
        named=""
        non=""
        if [ "$sdnss_ipc" = "whitelist" ]; then
            ipc="-whitelist-ip"
        elif [ "$sdnss_ipc" = "blacklist" ]; then
            ipc="-blacklist-ip"
        fi
        if [ -n "$sdnss_named" ]; then
            named="-group $sdnss_named"
        fi
        if [ "$sdnss_non" = "1" ]; then
            non="-exclude-default-group"
        fi

        server_port=""
        if [ "$sdnss_port" = "default" ] || [ -z "$sdnss_port" ]; then
            case "$sdnss_type" in
                tcp|udp) server_port="53" ;;
                tls) server_port="853" ;;
                https) server_port="443" ;;
                *) server_port="53" ;;
            esac
        else
            server_port="$sdnss_port"
        fi

        case "$sdnss_type" in
            tcp) echo "server-tcp $sdnss_ip:$server_port $ipc $named $non" >> "$smartdns_tmp_Conf" ;;
            udp) echo "server $sdnss_ip:$server_port $ipc $named $non" >> "$smartdns_tmp_Conf" ;;
            tls) echo "server-tls $sdnss_ip:$server_port $ipc $named $non" >> "$smartdns_tmp_Conf" ;;
            https) echo "server-https $sdnss_ip:$server_port $ipc $named $non" >> "$smartdns_tmp_Conf" ;;
        esac

        if [ -n "$sdnss_ipset" ]; then
            Check_ip_addr "$sdnss_ipset"
            if [ "$?" = "1" ]; then
                echo "ipset /$sdnss_ipset/smartdns" >> "$smartdns_tmp_Conf"
            else
                ipset add smartdns "$sdnss_ipset" 2>/dev/null
            fi
        fi
    done

    # 黑白名单路由文件处理
    if [ "$sdns_white" = "1" ] && [ -f "$chn_Route" ] && [ -s "$chn_Route" ]; then
        logger -t "SmartDNS" "开始处理白名单 IP..."
        whitelist_conf="/tmp/whitelist.conf"
        :> "$whitelist_conf"
        awk '{printf("whitelist-ip %s\n", $1)}' "$chn_Route" >> "$whitelist_conf"
        echo "conf-file $whitelist_conf" >> "$smartdns_tmp_Conf"
    fi

    if [ "$sdns_black" = "1" ] && [ -f "$chn_Route" ] && [ -s "$chn_Route" ]; then
        logger -t "SmartDNS" "开始处理黑名单 IP..."
        blacklist_conf="/tmp/blacklist.conf"
        :> "$blacklist_conf"
        awk '{printf("blacklist-ip %s\n", $1)}' "$chn_Route" >> "$blacklist_conf"
        echo "conf-file $blacklist_conf" >> "$smartdns_tmp_Conf"
    fi

    # 合并所有配置
    grep -v '^#' "$smartdns_address_Conf" | grep -v "^$" >> "$smartdns_tmp_Conf"
    grep -v '^#' "$smartdns_blacklist_Conf" | grep -v "^$" >> "$smartdns_tmp_Conf"
    grep -v '^#' "$smartdns_whitelist_Conf" | grep -v "^$" >> "$smartdns_tmp_Conf"
    grep -v '^#' "$smartdns_custom_Conf" | grep -v "^$" >> "$smartdns_tmp_Conf"

    # 强制路由规则
    sed -i '/my.router/d' "$smartdns_tmp_Conf"
    echo "domain-rules /my.router/ -c none -a $IPS4 -d no" >> "$smartdns_tmp_Conf"

    # 去重并生成最终文件
    awk '!x[$0]++' "$smartdns_tmp_Conf" > "$smartdns_Conf"
    rm -f "$smartdns_tmp_Conf"
}

# 切换adbyby规则模式
Change_adbyby () {
    adbyby_process=$(pidof adbyby | awk '{ print $1 }')
    if [ -z "$adbyby_process" ] || [ $(nvram get adbyby_enable) -ne 1 ]; then
        return
    fi

    case "$sdns_enable" in
        0)
            if [ $(nvram get adbyby_add) = 1 ] && [ "$hosts_type" != "dnsmasq" ]; then
                nvram set adbyby_add=0
                /usr/bin/adbyby.sh switch
                logger -t "SmartDNS" "去广告规则切换：SmartDNS ⇒ DNSmasq"
                hosts_type="dnsmasq"
            fi
            ;;
        1)
            if [ "$hosts_type" != "SmartDNS" ] && [ "$action" = "start" ]; then
                if [ "$sdns_port" = "53" ] || [ $(nvram get adbyby_add) = 1 ] || [ "$sdns_redirect" = "2" ]; then
                    nvram set adbyby_add=1
                    /usr/bin/adbyby.sh switch
                    logger -t "SmartDNS" "去广告规则切换：DNSmasq ⇒ SmartDNS"
                    hosts_type="SmartDNS"
                fi
            fi
            ;;
    esac
}

# dnsmasq规则检测
dnsmasq_rule_exists() {
    rule="$1"
    # 精准匹配整行，忽略前后空格（兼容不同格式的配置）
    grep -qxF "$(echo "$rule" | xargs)" "$dnsmasq_Conf" 2>/dev/null
    return $?
}

# 修改dnsmasq配置
Change_dnsmasq () {
    # 定义SmartDNS相关的dnsmasq规则
    no_resolv_rule="no-resolv"
    main_server_rule="server=127.0.0.1#$sdns_port"
    second_server_rule="server=127.0.0.1#$sdnse_port"
    port_rule="port=0"

    case "$action" in
        stop)
            logger -t "SmartDNS" "开始删除dnsmasq中SmartDNS相关规则..."
            # 步骤1：删除主服务器规则（精准匹配）
            if dnsmasq_rule_exists "$main_server_rule"; then
                sed -i "/^$(echo "$main_server_rule" | sed 's/\//\\\//g')$/d" "$dnsmasq_Conf"
            fi
            # 步骤2：删除第二服务器规则（若启用）
            if [ "$sdnse_enable" = 1 ] && dnsmasq_rule_exists "$second_server_rule"; then
                sed -i "/^$(echo "$second_server_rule" | sed 's/\//\\\//g')$/d" "$dnsmasq_Conf"
            fi
            # 步骤3：删除no-resolv规则
            if dnsmasq_rule_exists "$no_resolv_rule"; then
                sed -i "/^$(echo "$no_resolv_rule" | sed 's/\//\\\//g')$/d" "$dnsmasq_Conf"
            fi
            # 步骤4：删除port=0规则
            if dnsmasq_rule_exists "$port_rule"; then
                sed -i "/^$(echo "$port_rule" | sed 's/\//\\\//g')$/d" "$dnsmasq_Conf"
            fi

            # 状态日志（移除空行清理步骤）
            if [ "$sdns_enable" = 0 ]; then
                [ "$sdns_ported" = "53" ] && logger -t "SmartDNS" "DNS 功能恢复：已启用 dnsmasq 域名解析"
                [ "$sdns_redirected" = "1" ] && logger -t "SmartDNS" "上游服务器移除完成：已清理 127.0.0.1 相关指向"
            fi
            ;;
        start)
            logger -t "SmartDNS" "开始添加dnsmasq中SmartDNS相关规则..."
            # 移除文件末尾换行符和空行分隔的处理步骤
            
            # 步骤1：添加port=0（避免端口冲突，仅当SmartDNS使用53端口时）
            if [ "$sdns_port" = "53" ] && ! dnsmasq_rule_exists "$port_rule"; then
                echo "$port_rule" >> "$dnsmasq_Conf"
                logger -t "SmartDNS" "已添加dnsmasq规则：$port_rule（关闭dnsmasq 53端口，避免冲突）"
                # 自动禁用重定向（端口冲突时）
                if [ "$sdns_redirect" = "1" ]; then
                    nvram set sdns_redirect=0
                    sdns_redirect=0
                    logger -t "SmartDNS" "重定向自动调整：因端口冲突，已禁用重定向"
                fi
            fi

            # 步骤2：添加no-resolv和server规则（仅当重定向启用时）
            if [ "$sdns_redirect" = "1" ]; then
                # 添加no-resolv（禁用dnsmasq默认上游）
                if ! dnsmasq_rule_exists "$no_resolv_rule"; then
                    echo "$no_resolv_rule" >> "$dnsmasq_Conf"
                    # logger -t "SmartDNS" "已添加dnsmasq规则：$no_resolv_rule（禁用默认上游解析）"
                fi
                # 添加主服务器指向
                if ! dnsmasq_rule_exists "$main_server_rule"; then
                    echo "$main_server_rule" >> "$dnsmasq_Conf"
                    # logger -t "SmartDNS" "已添加dnsmasq规则：$main_server_rule（指向SmartDNS主服务）"
                fi
                # 添加第二服务器指向（若启用）
                if [ "$sdnse_enable" = 1 ] && ! dnsmasq_rule_exists "$second_server_rule"; then
                    # echo "$second_server_rule" >> "$dnsmasq_Conf"
                    # logger -t "SmartDNS" "已添加dnsmasq规则：$second_server_rule（指向SmartDNS第二服务）"
                fi
            fi
            ;;
    esac
}

# 修改iptables规则
Change_iptable () {
    statu=0

    rule_exists() {
        table=$1
        chain=$2
        shift 2
        if [ "$table" = "ip6tables" ]; then
            ip6tables -t nat -C $chain "$@" >/dev/null 2>&1
        else
            iptables -t nat -C $chain "$@" >/dev/null 2>&1
        fi
        return $?
    }

    case "$action" in
        stop)
            if [ "$sdns_redirected" = 2 ]; then
                rule_exists iptables PREROUTING -p tcp -d "$IPS4" --dport 53 -j REDIRECT --to-ports "$sdns_ported" && {
                    iptables -t nat -D PREROUTING -p tcp -d "$IPS4" --dport 53 -j REDIRECT --to-ports "$sdns_ported" >/dev/null 2>&1
                    # logger -t "SmartDNS" "已删除iptables规则：TCP 53 → $sdns_ported"
                }
                rule_exists iptables PREROUTING -p udp -d "$IPS4" --dport 53 -j REDIRECT --to-ports "$sdns_ported" && {
                    iptables -t nat -D PREROUTING -p udp -d "$IPS4" --dport 53 -j REDIRECT --to-ports "$sdns_ported" >/dev/null 2>&1
                    # logger -t "SmartDNS" "已删除iptables规则：UDP 53 → $sdns_ported"
                }
            fi
            if [ "$sdns_redirected" = 2 ] && [ "$sdns_ipv6_server" = 1 ]; then
                rule_exists ip6tables PREROUTING -p tcp -d "$IPS6" --dport 53 -j REDIRECT --to-ports "$sdns_ported" && {
                    ip6tables -t nat -D PREROUTING -p tcp -d "$IPS6" --dport 53 -j REDIRECT --to-ports "$sdns_ported" >/dev/null 2>&1
                    # logger -t "SmartDNS" "已删除ip6tables规则：TCP 53 → $sdns_ported"
                }
                rule_exists ip6tables PREROUTING -p udp -d "$IPS6" --dport 53 -j REDIRECT --to-ports "$sdns_ported" && {
                    ip6tables -t nat -D PREROUTING -p udp -d "$IPS6" --dport 53 -j REDIRECT --to-ports "$sdns_ported" >/dev/null 2>&1
                    # logger -t "SmartDNS" "已删除ip6tables规则：UDP 53 → $sdns_ported"
                }
            fi
            [ "$sdns_enable" = 0 ] && true # logger -t "SmartDNS" "重定向已清除：恢复默认 DNS 解析"


            if [ "$sdns_redirected" = 1 ]; then
                rule_exists iptables PREROUTING -p udp -d "$IPS4" --dport 53 -j REDIRECT --to-ports 53 && {
                    iptables -t nat -D PREROUTING -p udp -d "$IPS4" --dport 53 -j REDIRECT --to-ports 53 >/dev/null 2>&1
                    # logger -t "SmartDNS" "已删除iptables规则：UDP 53 → 53"
                }
            fi
            ;;

        start)
            if [ "$sdns_redirected" != 2 ] && [ "$sdns_redirect" = 2 ]; then
                statu=1
                logger -t "SmartDNS" "重定向启用：开始添加iptables规则"
                if [ "$sdnse_enable" = 1 ]; then
                    # logger -t "SmartDNS" "重定向规则：DNS 请求将分发至 $IPS4:$sdns_port（主）和 $IPS4:$sdnse_port（第二）"
                else
                    # logger -t "SmartDNS" "重定向规则：DNS 请求将定向至 $IPS4:$sdns_port"
                fi
            fi
            ;;

        reset)
            $0 stop >/dev/null 2>&1
            logger -t "SmartDNS" "重置iptables规则：先停止现有重定向"

            if [ "$sdns_redirect" = 1 ]; then
                if ! rule_exists iptables PREROUTING -p udp -d "$IPS4" --dport 53 -j REDIRECT --to-ports 53; then
                    iptables -t nat -A PREROUTING -p udp -d "$IPS4" --dport 53 -j REDIRECT --to-ports 53 >/dev/null 2>&1
                    # logger -t "SmartDNS" "已重置iptables规则：UDP 53 → 53"
                fi
            fi

            if [ "$sdns_redirect" = 2 ]; then
                statu=1
            fi
            ;;
    esac

    if [ "$statu" = 1 ]; then
        # 添加IPv4 UDP规则
        if ! rule_exists iptables PREROUTING -p udp -d "$IPS4" --dport 53 -j REDIRECT --to-ports "$sdns_port"; then
            iptables -t nat -A PREROUTING -p udp -d "$IPS4" --dport 53 -j REDIRECT --to-ports "$sdns_port" >/dev/null 2>&1
            # logger -t "SmartDNS" "已添加iptables规则：UDP 53 → $sdns_port"
        fi
        # 添加IPv4 TCP规则（若启用TCP服务）
        if [ "$sdns_tcp_server" = 1 ] && ! rule_exists iptables PREROUTING -p tcp -d "$IPS4" --dport 53 -j REDIRECT --to-ports "$sdns_port"; then
            iptables -t nat -A PREROUTING -p tcp -d "$IPS4" --dport 53 -j REDIRECT --to-ports "$sdns_port" >/dev/null 2>&1
            # logger -t "SmartDNS" "已添加iptables规则：TCP 53 → $sdns_port"
        fi

        # 添加IPv6规则（若启用IPv6）
        if [ "$sdns_ipv6_server" = 1 ]; then
            if ! rule_exists ip6tables PREROUTING -p udp -d "$IPS6" --dport 53 -j REDIRECT --to-ports "$sdns_port"; then
                ip6tables -t nat -A PREROUTING -p udp -d "$IPS6" --dport 53 -j REDIRECT --to-ports "$sdns_port" >/dev/null 2>&1
                # logger -t "SmartDNS" "已添加ip6tables规则：UDP 53 → $sdns_port"
            fi
            if [ "$sdns_tcp_server" = 1 ] && ! rule_exists ip6tables PREROUTING -p tcp -d "$IPS6" --dport 53 -j REDIRECT --to-ports "$sdns_port"; then
                ip6tables -t nat -A PREROUTING -p tcp -d "$IPS6" --dport 53 -j REDIRECT --to-ports "$sdns_port" >/dev/null 2>&1
                # logger -t "SmartDNS" "已添加ip6tables规则：TCP 53 → $sdns_port"
            fi
        fi
    fi
}

# 启动SmartDNS服务
Start_smartdns () {
    :> "$smartdns_Ini"
    [ "$sdns_enable" -eq 0 ] && nvram set sdns_enable=1 && sdns_enable=1
    [ -n "$smartdns_process" ] && killall -9 smartdns >/dev/null 2>&1 && logger -t "SmartDNS" "已停止现有SmartDNS进程（PID=$smartdns_process）"

    # 步骤1：配置dnsmasq规则
    Change_dnsmasq
    # 步骤2：切换adbyby规则
    Change_adbyby
    echo "$hosts_type" >> "$smartdns_Ini"

    # 端口信息日志
    if [ "$sdns_redirect" = 0 ]; then
        logger -t "SmartDNS" "端口信息：主服务使用 $sdns_port 端口"
        if [ "$sdnse_enable" = 1 ]; then
            logger -t "SmartDNS" "端口信息：第二服务使用 $sdnse_port 端口"
        fi
    fi

    # 步骤3：配置iptables重定向
    Change_iptable
    sdns_redirected="$sdns_redirect"
    echo "$sdns_redirected" >> "$smartdns_Ini"
    echo "$sdns_port" >> "$smartdns_Ini"
    echo "$sdnse_port" >> "$smartdns_Ini"

    args=""
    logger -t "SmartDNS" "配置生成：开始创建 SmartDNS 配置文件..."
    ipset -N smartdns hash:net >/dev/null 2>&1

    # 步骤4：生成SmartDNS核心配置
    Get_sdns_conf

    # 附加启动参数
    if [ "$sdns_auto_restart" = "1" ]; then
        args="$args -R"
    fi
    if [ "$sdns_coredump" = "1" ]; then
        args="$args -S"
    fi

    # 重启dnsmasq（若配置变动）
    if [ "$dnsmasq_md5" != $(md5sum "$dnsmasq_Conf" | awk '{ print $1 }') ]; then
        # logger -t "SmartDNS" "依赖服务重启：dnsmasq 配置已变动，正在重启..."
        /sbin/restart_dhcpd >/dev/null 2>&1
        logger -t "SmartDNS" "依赖服务重启：dnsmasq 已重启"
    fi

    # 启动SmartDNS
    "$smartdns_Bin" -f -c "$smartdns_Conf" $args &>/dev/null &
    sleep 1
    smartdns_process=$(pidof smartdns | awk '{ print $1 }')

    # 容错处理：启动失败重试（移除广告规则）
    if [ -z "$smartdns_process" ]; then
        if [ "$hosts_type" = "SmartDNS" ]; then
            logger -t "SmartDNS" "启动失败：首次启动未成功，尝试移除广告规则..."
            logger -t "SmartDNS" "启动失败：若重试成功，可能是广告规则格式不兼容"
            sed -i '/conf-file \/tmp\/anti-ad-for-smartdns.conf/d' "$smartdns_Conf"
            "$smartdns_Bin" -f -c "$smartdns_Conf" $args &>/dev/null &
        fi
    fi

    # 最终状态检查
    sleep 1
    smartdns_process=$(pidof smartdns | awk '{ print $1 }')
    if [ -z "$smartdns_process" ]; then
        logger -t "SmartDNS" "启动失败：重试后仍未启动，将停用 SmartDNS"
        logger -t "SmartDNS" "启动失败：请检查端口占用或配置文件格式"
        logger -t "SmartDNS" "恢复操作：将恢复 dnsmasq 提供 DNS 解析"
        nvram set sdns_enable=0
        sdns_enable=0
        action="stop"
        Stop_smartdns
        if [ "$dnsmasq_md5" != $(md5sum "$dnsmasq_Conf" | awk '{ print $1 }') ]; then
            # logger -t "SmartDNS" "依赖服务重启：dnsmasq 配置已变动，正在重启..."
            /sbin/restart_dhcpd >/dev/null 2>&1
            logger -t "SmartDNS" "依赖服务重启：dnsmasq 已重启"
        fi
        exit
    else
        logger -t "SmartDNS" "启动成功：SmartDNS 进程已运行（PID=$smartdns_process）"
    fi
}

# 停止SmartDNS服务
Stop_smartdns () {
    # 停止SmartDNS进程
    killall -9 smartdns >/dev/null 2>&1
    # logger -t "SmartDNS" "停止操作：正在结束 SmartDNS 进程..."

    # 步骤1：切换adbyby规则回退
    Change_adbyby
    # 步骤2：删除dnsmasq中SmartDNS相关规则
    Change_dnsmasq
    # 步骤3：删除iptables重定向规则
    Change_iptable

    # 关闭广告过滤时清空规则文件
    if [ "$sdns_adblock" -ne 1 ] && [ -f "/tmp/anti-ad-for-smartdns.conf" ]; then
        :> "/tmp/anti-ad-for-smartdns.conf"
        logger -t "SmartDNS" "停止操作：广告过滤已关闭，清空规则文件"
    fi

    # 重启dnsmasq（若配置变动且永久停用）
    if [ "$dnsmasq_md5" != $(md5sum "$dnsmasq_Conf" | awk '{ print $1 }') ] && [ "$sdns_enable" = 0 ]; then
        # logger -t "SmartDNS" "依赖服务重启：dnsmasq 配置已变动，正在重启..."
        /sbin/restart_dhcpd >/dev/null 2>&1
        logger -t "SmartDNS" "依赖服务重启：dnsmasq 已重启"
    fi

    # 最终状态检查
    smartdns_process=$(pidof smartdns | awk '{ print $1 }')
    if [ -z "$smartdns_process" ] && [ "$sdns_enable" = 0 ]; then
        rm -f "$smartdns_Ini"
        logger -t "SmartDNS" "停止完成：SmartDNS 服务器已停用，所有相关规则已清理"
    fi
}

# 主函数（分发命令）
Main () {
    case "$action" in
        start)
            if [ ! -s "$smartdns_Ini" ]; then
                logger -t "SmartDNS" "启动流程：SmartDNS 开始启动..."
            fi
            Check_ss
            # 无论是否开启广告过滤，都调用Start_AD处理（内部会判断开关状态）
            Start_AD
            Start_smartdns
            logger -t "SmartDNS" "启动流程：SmartDNS 服务器已启动完成"
            sleep 2
            echo 3 > /proc/sys/vm/drop_caches
            ;;
        stop)
            smartdns_process=$(pidof smartdns | awk '{ print $1 }')
            if [ -n "$smartdns_process" ]; then
                case "$sdns_enable" in
                    0) logger -t "SmartDNS" "停止流程：开始停用 SmartDNS 服务器..." ;;
                    1) logger -t "SmartDNS" "重启流程：先停止当前 SmartDNS 进程..." ;;
                esac
            fi
            Stop_smartdns
            sleep 2
            echo 3 > /proc/sys/vm/drop_caches
            ;;
        restart)
            if [ $(nvram get adbyby_enable) = 1 ]; then
                [ $(nvram get adbyby_add) = 1 ] && hosts_type="SmartDNS"
                [ $(nvram get adbyby_add) = 0 ] && hosts_type="dnsmasq"
            else
                hosts_type="0"
            fi
            Check_ss
            # 重启时也处理广告规则状态
            Start_AD
            Start_smartdns
            logger -t "SmartDNS" "重启流程：SmartDNS 服务器已重启完成"
            sleep 2
            echo 3 > /proc/sys/vm/drop_caches
            ;;
        reset)
            [ "$sdns_enable" = "1" ] && Change_iptable
            logger -t "SmartDNS" "重置完成：已重新配置 DNS 重定向规则"
            ;;
        *)
            echo "用法：$0 start|stop|restart|reset"
            echo "  start   - 启动 SmartDNS 服务"
            echo "  stop    - 停止 SmartDNS 服务（清理所有相关规则）"
            echo "  restart - 重启 SmartDNS 服务"
            echo "  reset   - 重置 DNS 重定向规则"
            ;;
    esac
}

Read_ini
Main
