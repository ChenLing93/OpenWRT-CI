#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

# 确保目标目录存在（根据你的编译环境，路径可能是 package/ 或 package/custom/）
mkdir -p package/custom

echo "开始使用 git clone --depth=1 拉取第三方插件..."

# ================== 主题类 ==================
git clone --depth=1 --single-branch --branch "openwrt-25.12" "https://github.com/sbwml/luci-theme-argon.git" package/custom/luci-theme-argon
git clone --depth=1 --single-branch --branch "master" "https://github.com/eamonxg/luci-theme-aurora.git" package/custom/luci-theme-aurora
git clone --depth=1 --single-branch --branch "master" "https://github.com/eamonxg/luci-app-aurora-config.git" package/custom/luci-app-aurora-config
git clone --depth=1 --single-branch --branch "master" "https://github.com/sirpdboy/luci-theme-kucat.git" package/custom/luci-theme-kucat
git clone --depth=1 --single-branch --branch "master" "https://github.com/sirpdboy/luci-app-kucat-config.git" package/custom/luci-app-kucat-config
git clone --depth=1 --single-branch --branch "master" "https://github.com/nooblk-98/luci-theme-noobwrt.git" package/custom/luci-theme-noobwrt
git clone --depth=1 --single-branch --branch "main" "https://github.com/eamonxg/luci-theme-shadcn.git" package/custom/luci-theme-shadcn
git clone --depth=1 --single-branch --branch "main" "https://github.com/LazuliKao/luci-theme-fluent.git" package/custom/luci-theme-fluent

# ================== 代理与网络工具 ==================
git clone --depth=1 --single-branch --branch "main" "https://github.com/nikkinikki-org/OpenWrt-momo.git" package/custom/OpenWrt-momo
git clone --depth=1 --single-branch --branch "main" "https://github.com/nikkinikki-org/OpenWrt-nikki.git" package/custom/OpenWrt-nikki
git clone --depth=1 --single-branch --branch "dev" "https://github.com/vernesong/OpenClash.git" package/custom/OpenClash
git clone --depth=1 --single-branch --branch "main" "https://github.com/Openwrt-Passwall/openwrt-passwall.git" package/custom/openwrt-passwall
git clone --depth=1 --single-branch --branch "main" "https://github.com/Openwrt-Passwall/openwrt-passwall2.git" package/custom/openwrt-passwall2
git clone --depth=1 --single-branch --branch "main" "https://github.com/asvow/luci-app-tailscale.git" package/custom/luci-app-tailscale

# ================== 实用插件 ==================
# UPDATE_PACKAGE "athena-led" "unraveloop/JDC-AX6600-Athena-LED-Controller" "main"
git clone --depth=1 --single-branch --branch "main" "https://github.com/sirpdboy/luci-app-ddns-go.git" package/custom/luci-app-ddns-go
git clone --depth=1 --single-branch --branch "main" "https://github.com/sbwml/luci-app-diskman.git" package/custom/luci-app-diskman
# 拉取 QModem (5G 模组管理)
git clone --depth=1 https://github.com/ChenLing93/QModem.git package/custom/QModem

# 拉取 DDNSTO (内网穿透)
git clone --depth=1 https://github.com/linkease/ddnsto-openwrt.git package/custom/ddnsto-openwrt

# 拉取 iStore (软件中心)
git clone --depth=1 https://github.com/linkease/istore.git package/custom/istore

git clone --depth=1 https://github.com/tty228/luci-app-wechatpush.git package/custom/luci-app-wechatpush
