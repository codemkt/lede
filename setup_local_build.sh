#!/bin/bash
# OpenWrt 本地编译快速设置脚本
# 适用于 Ubuntu 22.04

set -e

echo "=================================="
echo "OpenWrt 本地编译环境设置脚本"
echo "=================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    print_error "此脚本仅适用于Ubuntu系统"
    exit 1
fi

# 检查Ubuntu版本
UBUNTU_VERSION=$(lsb_release -rs)
if [[ "$UBUNTU_VERSION" != "22.04" ]]; then
    print_warning "推荐使用Ubuntu 22.04，当前版本: $UBUNTU_VERSION"
    read -p "是否继续? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 检查可用磁盘空间
AVAILABLE_SPACE=$(df . | tail -1 | awk '{print $4}')
if [[ $AVAILABLE_SPACE -lt 20971520 ]]; then  # 20GB in KB
    print_error "可用磁盘空间不足20GB，当前可用: $((AVAILABLE_SPACE/1048576))GB"
    exit 1
fi

print_info "系统检查通过，开始安装依赖..."

# 更新系统
print_info "更新系统包..."
sudo apt update
sudo apt upgrade -y

# 安装编译依赖
print_info "安装编译依赖包..."
sudo apt install -y \
    ack antlr3 asciidoc autoconf automake autopoint binutils bison \
    build-essential bzip2 ccache clang cmake cpio curl device-tree-compiler \
    flex gawk gcc-multilib g++-multilib gettext genisoimage git gperf \
    haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev \
    libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev \
    libncurses5-dev libncursesw5-dev libpython3-dev libreadline-dev \
    libssl-dev libtool llvm lrzsz msmtp ninja-build p7zip p7zip-full \
    patch pkgconf python3 python3-pyelftools python3-setuptools \
    qemu-utils rsync scons squashfs-tools subversion swig texinfo \
    uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev

print_info "设置时区为Asia/Shanghai..."
sudo timedatectl set-timezone "Asia/Shanghai"

# 配置ccache
print_info "配置ccache..."
ccache -M 10G
ccache -s

# 选择设备类型
echo ""
echo "请选择要编译的设备类型:"
echo "1) MediaTek LinkIt Smart 7688 (32MB存储，推荐)"
echo "2) D-Team PBR-D1 (16MB存储)"
echo "3) Cudy WR1000 (16MB存储)"
echo "4) ALFA Network AWUSFREE1 (8MB存储)"
echo "5) 自定义配置 (使用menuconfig)"

read -p "请输入选择 (1-5): " DEVICE_CHOICE

case $DEVICE_CHOICE in
    1)
        DEVICE_NAME="mediatek_linkit_smart_7688"
        CONFIG_TYPE="linkit-7688"
        ;;
    2)
        DEVICE_NAME="d_team_pbr_d1"
        CONFIG_TYPE="16mb"
        ;;
    3)
        DEVICE_NAME="cudy_wr1000"
        CONFIG_TYPE="16mb"
        ;;
    4)
        DEVICE_NAME="alfa_network_awusfree1"
        CONFIG_TYPE="8mb"
        ;;
    5)
        CONFIG_TYPE="menuconfig"
        ;;
    *)
        print_error "无效选择"
        exit 1
        ;;
esac

# 检查源码目录
if [[ ! -d "feeds" ]]; then
    print_error "请在OpenWrt源码根目录下运行此脚本"
    exit 1
fi

# 更新feeds
print_info "更新feeds..."
sed -i 's/#src-git helloworld/src-git helloworld/g' ./feeds.conf.default
./scripts/feeds update -a
./scripts/feeds install -a

# 生成配置
if [[ "$CONFIG_TYPE" == "menuconfig" ]]; then
    print_info "启动menuconfig界面..."
    make menuconfig
else
    print_info "生成设备配置: $DEVICE_NAME"
    
    # 生成基础配置
    cat > .config << EOF
CONFIG_TARGET_ramips=y
CONFIG_TARGET_ramips_mt76x8=y
CONFIG_TARGET_ramips_mt76x8_DEVICE_$DEVICE_NAME=y
CONFIG_DEVEL=y
CONFIG_TOOLCHAINOPTS=y
CONFIG_BUSYBOX_CUSTOM=y
CONFIG_TARGET_ROOTFS_SQUASHFS=y
CONFIG_TARGET_SQUASHFS_BLOCK_SIZE=64
# CONFIG_TARGET_ROOTFS_INITRAMFS is not set
CONFIG_TARGET_IMAGES_GZIP=y
CONFIG_BUSYBOX_CONFIG_FEATURE_EDITING_SAVEHISTORY=y
CONFIG_BUSYBOX_CONFIG_FEATURE_EDITING_VI=y
CONFIG_BUSYBOX_CONFIG_FEATURE_LESS_FLAGS=y
CONFIG_BUSYBOX_CONFIG_FEATURE_LESS_REGEXP=y
CONFIG_BUSYBOX_CONFIG_FEATURE_LESS_WINCH=y
CONFIG_KERNEL_BUILD_USER="OpenWrt-Local"
CONFIG_KERNEL_BUILD_DOMAIN="Ubuntu"
CONFIG_CCACHE=y
CONFIG_PACKAGE_luci=y
CONFIG_LUCI_LANG_zh_Hans=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_nano=y
CONFIG_PACKAGE_tree=y
CONFIG_PACKAGE_vim-fuller=y
CONFIG_PACKAGE_wget-ssl=y
CONFIG_PACKAGE_kmod-tun=y
CONFIG_PACKAGE_luci-app-upnp=y
CONFIG_PACKAGE_luci-app-wol=y
CONFIG_PACKAGE_luci-app-ramfree=y
CONFIG_PACKAGE_luci-app-filetransfer=y
CONFIG_PACKAGE_luci-app-autoreboot=y
CONFIG_PACKAGE_luci-app-ssr-plus=y
CONFIG_PACKAGE_kmod-mt76x2=y
CONFIG_PACKAGE_kmod-mt7628=y
CONFIG_PACKAGE_wpad-basic=y
CONFIG_PACKAGE_hostapd-common=y
CONFIG_PACKAGE_wpa-supplicant=y
CONFIG_PACKAGE_kmod-mt76x8=y
CONFIG_PACKAGE_kmod-mt7603=y
EOF

    # 根据设备类型添加特定配置
    case $CONFIG_TYPE in
        "linkit-7688")
            cat >> .config << EOF
CONFIG_TARGET_ROOTFS_PARTSIZE=28
CONFIG_TARGET_KERNEL_PARTSIZE=4
CONFIG_TARGET_IMAGES_PAD=y
CONFIG_PACKAGE_kmod-usb2=y
CONFIG_PACKAGE_kmod-usb-ohci=y
CONFIG_PACKAGE_kmod-sdhci-mt7620=y
CONFIG_PACKAGE_uboot-envtools=y
EOF
            ;;
        "16mb")
            cat >> .config << EOF
CONFIG_TARGET_ROOTFS_PARTSIZE=12
CONFIG_TARGET_KERNEL_PARTSIZE=4
CONFIG_TARGET_IMAGES_PAD=y
EOF
            ;;
        "8mb")
            cat >> .config << EOF
CONFIG_TARGET_ROOTFS_PARTSIZE=6
CONFIG_TARGET_KERNEL_PARTSIZE=2
EOF
            ;;
    esac

    make defconfig
fi

print_info "配置完成，开始下载源码包..."
make download -j16

echo ""
print_info "环境设置完成！"
echo ""
echo "接下来的编译命令:"
echo "  首次编译: make -j1 V=s"
echo "  后续编译: make -j\$(nproc)"
echo "  清理编译: make clean"
echo ""
echo "固件输出目录: ./bin/targets/ramips/mt76x8/"
echo ""

read -p "是否现在开始编译? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "开始编译，这可能需要1-3小时..."
    make -j1 V=s
    
    if [[ $? -eq 0 ]]; then
        print_info "编译成功！"
        echo "固件文件:"
        find ./bin/targets/ -name "*.bin" -exec ls -lh {} \;
    else
        print_error "编译失败，请检查错误信息"
    fi
fi

print_info "脚本执行完成"