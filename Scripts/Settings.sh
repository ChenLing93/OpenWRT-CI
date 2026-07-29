#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

#移除luci-app-attendedsysupgrade
sed -i "/attendedsysupgrade/d" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_MARK-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")

WIFI_SH=$(find ./target/linux/{mediatek/filogic,qualcommax}/base-files/etc/uci-defaults/ -type f -name "*set-wireless.sh" 2>/dev/null)
WIFI_UC="./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"
if [ -f "$WIFI_SH" ]; then
	#修改WIFI名称
	sed -i "s/BASE_SSID='.*'/BASE_SSID='$WRT_SSID'/g" $WIFI_SH
	#修改WIFI密码
	sed -i "s/BASE_WORD='.*'/BASE_WORD='$WRT_WORD'/g" $WIFI_SH
elif [ -f "$WIFI_UC" ]; then
	#修改WIFI名称
	sed -i "s/ssid='.*'/ssid='$WRT_SSID'/g" $WIFI_UC
	#修改WIFI密码
	sed -i "s/key='.*'/key='$WRT_WORD'/g" $WIFI_UC
fi

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#引入私有扩展配置
if [ -f "$GITHUB_WORKSPACE/Config/PRIVATE.txt" ]; then
	echo "Applying private configurations from PRIVATE.txt..."
	cat $GITHUB_WORKSPACE/Config/PRIVATE.txt >> ./.config
fi

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo -e "$WRT_PACKAGE" >> ./.config
fi

#无WIFI配置标志
if [[ "${WRT_CONFIG,,}" == *"wifi"* && "${WRT_CONFIG,,}" == *"no"* ]]; then
	echo "WRT_WIFI=wifi-no" >> $GITHUB_ENV
fi

# ================== 修复 luci-app-cupsd 索引与 ACL 缺失 ==================
CUPSD_DIR="package/custom/luci-app-cupsd"
if [ -d "$CUPSD_DIR" ]; then
    echo "=== Fixing luci-app-cupsd ACL and Index ==="
    
    # 1. 强制创建 ACL 权限目录并写入权限文件
    mkdir -p "$CUPSD_DIR/root/usr/share/rpcd/acl.d"
    cat > "$CUPSD_DIR/root/usr/share/rpcd/acl.d/luci-app-cupsd.json" << 'EOF'
{
	"luci-app-cupsd": {
		"description": "Grant UCI access for luci-app-cupsd",
		"read": {
			"uci": [ "cupsd" ]
		},
		"write": {
			"uci": [ "cupsd" ]
		}
	}
}
EOF

    # 2. 修复 Makefile 的安装逻辑（确保 ACL 文件被正确安装到固件中）
    if [ -f "$CUPSD_DIR/Makefile" ]; then
        # 检查 Makefile 里是否已经包含 acl 安装命令，如果没有则追加
        if ! grep -q "acl.d" "$CUPSD_DIR/Makefile"; then
            sed -i '/define Package\/luci-app-cupsd\/install/i \
define Package/luci-app-cupsd/install/acl\
\t$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d\
\t$(INSTALL_DATA) ./root/usr/share/rpcd/acl.d/luci-app-cupsd.json $(1)/usr/share/rpcd/acl.d/\
endef\n' "$CUPSD_DIR/Makefile"
        fi
    fi
    
    echo "luci-app-cupsd ACL and Index fix completed!"
fi

#高通平台调整
DTS_PATH="./target/linux/qualcommax/dts/"
if [[ "${WRT_TARGET^^}" == *"QUALCOMMAX"* ]]; then
	#无WIFI配置调整Q6大小
	if [[ "${WRT_CONFIG,,}" == *"wifi"* && "${WRT_CONFIG,,}" == *"no"* ]]; then
		find $DTS_PATH -type f ! -iname '*nowifi*' -exec sed -i 's/ipq\(6018\|8074\).dtsi/ipq\1-nowifi.dtsi/g' {} +
		echo "qualcommax set up nowifi successfully!"
	fi
fi
