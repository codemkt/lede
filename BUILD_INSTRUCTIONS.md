# OpenWrt 编译说明

## 手动触发编译

现在可以手动触发编译流程，支持选择不同的设备和编译配置。

### 如何手动启动编译

1. 进入 GitHub 仓库的 **Actions** 页面
2. 点击左侧的 **OpenWrt-CI** 工作流
3. 点击右上角的 **Run workflow** 按钮
4. 选择编译参数：
   - **设备类型**：选择要编译的目标设备
   - **编译配置**：选择编译时包含的软件包数量

### 支持的MT7628设备

#### 大存储设备 (32MB)
- `mediatek-linkit-smart-7688` - **MediaTek LinkIt Smart 7688** (32MB存储，支持USB和SD卡)

#### 中等存储设备 (16MB)
- `d-team-pbr-d1` - D-Team PBR-D1 (16MB存储)
- `mt7628an-cudy-wr1000` - Cudy WR1000 (16MB存储)
- `mt7628an-hiwifi-hc5611` - HiWiFi HC5611 (16MB存储)
- `mt7628an-hiwifi-hc5861b` - HiWiFi HC5861B (16MB存储)
- `mt7628an-hiwifi-hc5761a` - HiWiFi HC5761A (16MB存储)
- `mt7628an-hiwifi-hc5661a` - HiWiFi HC5661A (16MB存储)

#### 标准存储设备 (8-16MB)
- `mt7628an-gl-mt300n-v2` - GL.iNet GL-MT300N-V2
- `mt7628an-elecom-wrc-1167fs` - Elecom WRC-1167FS
- `mt7628an-buffalo-wcr-1166ds` - Buffalo WCR-1166DS

#### 小存储设备 (8MB以下)
- `alfa-network-awusfree1` - ALFA Network AWUSFREE1 (仅7.6MB存储)

### 镜像文件类型说明

根据设备存储大小和类型，会生成不同的镜像文件：

#### 标准设备（16MB+存储）
- `*-squashfs-sysupgrade.bin` - 用于已安装OpenWrt的设备升级
- `*-squashfs-factory.bin` - 用于从原厂固件刷入OpenWrt

#### 小存储设备（如AWUSFREE1，8MB以下）
- `*-initramfs-kernel.bin` - 内存运行版本，不会保存到flash
- `*-squashfs-factory.bin` - 原厂固件刷入版本（如果支持）

**注意**：AWUSFREE1 等小存储设备由于空间限制，主要生成 initramfs 版本，这意味着：
- 系统运行在内存中，重启后配置会丢失
- 适合临时使用或作为救急固件
- 如需永久安装，需要选择factory版本（如果生成）

### 编译配置选项

- **lean**（默认）：包含常用软件包的精简配置
- **minimal**：最小化配置，仅包含基础功能
- **full**：完整配置，包含大量附加软件包

### 输出文件

编译完成后，会生成以下artifacts：

- `OpenWrt_firmware_[设备]_[配置]` - 固件文件
- `OpenWrt_package_[设备]_[配置]` - 软件包文件
- `OpenWrt_buildinfo_[设备]_[配置]` - 编译信息文件

### 自动编译

工作流仍然保持每天晚上8点的自动编译，默认编译x86_64平台的lean配置。

### 注意事项

1. MT7628设备的编译需要更长时间，请耐心等待
2. full配置可能会因为存储空间不足而失败，建议使用lean配置
3. 如果编译失败，可以查看Actions页面的日志了解详细错误信息

## 本地编译

如果需要本地编译，请参考OpenWrt官方文档。