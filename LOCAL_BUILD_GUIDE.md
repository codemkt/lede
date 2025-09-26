# 本地Ubuntu编译OpenWrt指南

## 系统要求
- Ubuntu 22.04 LTS (推荐)
- 至少20GB可用磁盘空间
- 4GB以上内存 (推荐8GB+)

## 1. 安装依赖包

首先安装编译所需的依赖包：

```bash
# 更新系统
sudo apt update
sudo apt upgrade -y

# 安装编译依赖
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

# 设置时区（可选）
sudo timedatectl set-timezone "Asia/Shanghai"
```

## 2. 克隆源码

```bash
# 克隆你的仓库
git clone https://github.com/codemkt/lede.git
cd lede

# 或者如果已经克隆，更新代码
git pull origin master
```

## 3. 更新feeds

```bash
# 启用helloworld feed
sed -i 's/#src-git helloworld/src-git helloworld/g' ./feeds.conf.default

# 更新和安装feeds
./scripts/feeds update -a
./scripts/feeds install -a
```

## 4. 生成配置文件

你可以选择以下两种方式之一：

### 方式一：使用预设配置（推荐）

根据你的设备创建配置文件：

```bash
# MediaTek LinkIt Smart 7688 配置
cat > .config << 'EOF'
CONFIG_TARGET_ramips=y
CONFIG_TARGET_ramips_mt76x8=y
CONFIG_TARGET_ramips_mt76x8_DEVICE_mediatek_linkit_smart_7688=y
CONFIG_DEVEL=y
CONFIG_TOOLCHAINOPTS=y
CONFIG_BUSYBOX_CUSTOM=y
# 文件系统配置
CONFIG_TARGET_ROOTFS_SQUASHFS=y
CONFIG_TARGET_SQUASHFS_BLOCK_SIZE=64
# 禁用initramfs（除非特别需要）
# CONFIG_TARGET_ROOTFS_INITRAMFS is not set
# 启用sysupgrade镜像
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
# MT7628特定配置
CONFIG_PACKAGE_kmod-mt76x2=y
CONFIG_PACKAGE_kmod-mt7628=y
CONFIG_PACKAGE_wpad-basic=y
CONFIG_PACKAGE_hostapd-common=y
CONFIG_PACKAGE_wpa-supplicant=y
CONFIG_PACKAGE_kmod-mt76x8=y
CONFIG_PACKAGE_kmod-mt7603=y
# LinkIt Smart 7688 特定配置(32MB)
CONFIG_TARGET_ROOTFS_PARTSIZE=28
CONFIG_TARGET_KERNEL_PARTSIZE=4
CONFIG_TARGET_IMAGES_PAD=y
CONFIG_TARGET_IMAGES_GZIP=y
CONFIG_PACKAGE_kmod-usb2=y
CONFIG_PACKAGE_kmod-usb-ohci=y
CONFIG_PACKAGE_kmod-sdhci-mt7620=y
CONFIG_PACKAGE_uboot-envtools=y
EOF

# 生成完整配置
make defconfig
```

### 方式二：使用menuconfig界面配置

```bash
# 启动配置界面
make menuconfig
```

在menuconfig中进行以下配置：
1. **Target System** → `MediaTek Ralink MIPS`
2. **Subtarget** → `MT76x8 based boards`
3. **Target Profile** → `MediaTek LinkIt Smart 7688`
4. **LuCI** → `Collections` → `luci`
5. **LuCI** → `Themes` → `luci-theme-bootstrap`
6. **LuCI** → `Translations` → `Chinese Simplified (zh-cn)`

## 5. 下载源码包

```bash
# 下载所需的源码包
make download -j16
```

## 6. 开始编译

```bash
# 首次编译（单线程，便于查看错误）
make -j1 V=s

# 后续编译可以使用多线程加速
# make -j$(nproc)
```

## 7. 编译选项说明

- `make -j1 V=s`: 单线程编译，显示详细信息，便于调试
- `make -j$(nproc)`: 多线程编译，速度更快
- `make -j4`: 使用4个线程编译
- `V=s`: 显示详细的编译信息
- `V=sc`: 显示编译命令但不显示警告

## 8. 查看编译结果

编译完成后，固件文件位于：
```bash
# 查看生成的固件
ls -la ./bin/targets/ramips/mt76x8/

# 查看所有.bin文件
find ./bin/targets/ -name "*.bin" -exec ls -lh {} \;
```

## 9. 常见问题处理

### 编译失败时的处理：
```bash
# 清理编译缓存
make clean

# 完全清理（删除所有编译文件）
make distclean

# 重新配置
make menuconfig
make defconfig
```

### 增量编译：
```bash
# 只重新编译内核
make target/linux/compile V=s

# 只重新编译某个软件包
make package/软件包名/compile V=s
```

## 10. 优化建议

### 启用ccache加速：
```bash
# 在.config中确保有这一行
echo "CONFIG_CCACHE=y" >> .config
```

### 设置ccache缓存大小：
```bash
ccache -M 10G  # 设置10GB缓存
```

### 使用RAM磁盘加速（可选）：
```bash
# 创建RAM磁盘用于编译（需要足够内存）
sudo mkdir /tmp/openwrt-build
sudo mount -t tmpfs -o size=8G tmpfs /tmp/openwrt-build
```

## 编译时间估计

- **首次编译**: 1-3小时（取决于硬件配置）
- **增量编译**: 5-30分钟
- **仅内核编译**: 2-10分钟

使用这个配置，你就能在本地Ubuntu系统中编译出与GitHub Actions相同的固件了！