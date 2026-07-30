#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

# ================== 1. 定义 UPDATE_PACKAGE 函数 ==================
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local PKG_LIST=("$PKG_NAME" $5)
	local REPO_NAME=${PKG_REPO#*/}

	echo " "

	# 删除本地可能存在的不同名称的软件包
	for NAME in "${PKG_LIST[@]}"; do
		echo "Search directory: $NAME"
		local FOUND_DIRS=$(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$NAME*" 2>/dev/null)

		if [ -n "$FOUND_DIRS" ]; then
			while read -r DIR; do
				rm -rf "$DIR"
				echo "Delete directory: $DIR"
			done <<< "$FOUND_DIRS"
		else
			echo "Not found directory: $NAME"
		fi
	done

	# 克隆 GitHub 仓库 (浅克隆)
	git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

	# 彻底删除 .git 目录，释放 GitHub Actions 磁盘空间
	rm -rf ./$REPO_NAME/.git

	# 处理克隆的仓库
	if [[ "$PKG_SPECIAL" == "pkg" ]]; then
		find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune -exec cp -rf {} ./ \;
		rm -rf ./$REPO_NAME/
	elif [[ "$PKG_SPECIAL" == "name" ]]; then
		mv -f $REPO_NAME $PKG_NAME
	fi
}

# ================== 2. 使用 UPDATE_PACKAGE 替换/更新核心插件 ==================
# 这些插件通常官方源里有旧版，或者名字冲突，需要用 UPDATE_PACKAGE 来替换
UPDATE_PACKAGE "argon" "sbwml/luci-theme-argon" "openwrt-25.12"
UPDATE_PACKAGE "aurora" "eamonxg/luci-theme-aurora" "master"
UPDATE_PACKAGE "aurora-config" "eamonxg/luci-app-aurora-config" "master"
UPDATE_PACKAGE "kucat" "sirpdboy/luci-theme-kucat" "master"
UPDATE_PACKAGE "kucat-config" "sirpdboy/luci-app-kucat-config" "master"
UPDATE_PACKAGE "noobwrt" "nooblk-98/luci-theme-noobwrt" "master"
UPDATE_PACKAGE "shadcn" "eamonxg/luci-theme-shadcn" "main"
UPDATE_PACKAGE "theme-fluent" "LazuliKao/luci-theme-fluent" "main"

UPDATE_PACKAGE "momo" "nikkinikki-org/OpenWrt-momo" "main"
UPDATE_PACKAGE "nikki" "nikkinikki-org/OpenWrt-nikki" "main"
UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "dev" "pkg"
UPDATE_PACKAGE "passwall" "Openwrt-Passwall/openwrt-passwall" "main" "pkg"
UPDATE_PACKAGE "passwall2" "Openwrt-Passwall/openwrt-passwall2" "main" "pkg"

UPDATE_PACKAGE "luci-app-tailscale" "asvow/luci-app-tailscale" "main"

UPDATE_PACKAGE "ddns-go" "sirpdboy/luci-app-ddns-go" "main"
UPDATE_PACKAGE "diskman" "sbwml/luci-app-diskman" "main"
UPDATE_PACKAGE "easytier" "EasyTier/luci-app-easytier" "main"
UPDATE_PACKAGE "mosdns" "sbwml/luci-app-mosdns" "v5" "" "v2dat"
UPDATE_PACKAGE "netspeedtest" "sirpdboy/netspeedtest" "main" "" "homebox ookla-speedtest"
UPDATE_PACKAGE "netwizard" "sirpdboy/luci-app-netwizard" "main"
UPDATE_PACKAGE "openlist2" "sbwml/luci-app-openlist2" "main"
UPDATE_PACKAGE "partexp" "sirpdboy/luci-app-partexp" "main"
UPDATE_PACKAGE "qbittorrent" "sbwml/luci-app-qbittorrent" "master" "" "qt6base qt6tools rblibtorrent"
UPDATE_PACKAGE "qmodem" "FUjr/QModem" "main"
UPDATE_PACKAGE "quickfile" "sbwml/luci-app-quickfile" "main"
UPDATE_PACKAGE "timecontrol" "sirpdboy/luci-app-timecontrol" "main"
UPDATE_PACKAGE "vnt" "lmq8267/luci-app-vnt" "main"

# ================== 3. 使用 git clone 拉取独立插件 ==================
# 这些插件官方源里没有，直接 git clone 到 package/custom 目录
mkdir -p package/custom

# ================== iStore (软件中心) ==================
# 直接克隆 iStore 核心依赖和主程序
git clone --depth=1 https://github.com/linkease/nas-packages-luci package/custom/nas-packages-luci
git clone --depth=1 https://github.com/linkease/istore package/custom/istore

# 精准提取并移动 iStore 相关文件
if [ -d "package/custom/istore/luci-app-store" ]; then
    mv package/custom/istore/luci-app-store package/custom/luci-app-store
fi
if [ -d "package/custom/nas-packages-luci/luci-lib-taskd" ]; then
    mv package/custom/nas-packages-luci/luci-lib-taskd package/custom/luci-lib-taskd
fi
# 清理不需要的残留目录
rm -rf package/custom/istore package/custom/nas-packages-luci

# ================== DDNSTO (内网穿透) ==================
# 直接克隆 DDNSTO 的独立仓库
git clone --depth=1 https://github.com/linkease/nas-packages package/custom/nas-packages

# 精准提取并移动 DDNSTO 相关文件
if [ -d "package/custom/nas-packages/ddnsto" ]; then
    mv package/custom/nas-packages/ddnsto package/custom/ddnsto
fi
if [ -d "package/custom/nas-packages/luci-app-ddnsto" ]; then
    mv package/custom/nas-packages/luci-app-ddnsto package/custom/luci-app-ddnsto
fi
# 清理残留目录
rm -rf package/custom/nas-packages

# WeChatPush (微信推送)
git clone --depth=1 https://github.com/tty228/luci-app-wechatpush.git package/custom/luci-app-wechatpush

# 集客软AC & Axonhub & Sing-box (Viking 仓库)
git clone --depth=1 https://github.com/VIKINGYFY/packages.git package/custom/viking-packages

git clone --depth=1 https://github.com/ChenLing93/luci-app-cupsd.git package/custom/luci-app-cupsd


# ================== 4. 引入私有扩展脚本 ==================
if [ -f "$GITHUB_WORKSPACE/Scripts/PRIVATE.sh" ]; then
	source "$GITHUB_WORKSPACE/Scripts/PRIVATE.sh"
fi
