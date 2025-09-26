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

- `mt7628an-gl-mt300n-v2` - GL.iNet GL-MT300N-V2
- `mt7628an-hiwifi-hc5611` - HiWiFi HC5611
- `mt7628an-hiwifi-hc5861b` - HiWiFi HC5861B
- `mt7628an-hiwifi-hc5761a` - HiWiFi HC5761A
- `mt7628an-hiwifi-hc5661a` - HiWiFi HC5661A
- `mt7628an-cudy-wr1000` - Cudy WR1000
- `mt7628an-d-team-pbr-d1` - D-Team PBR-D1
- `mt7628an-elecom-wrc-1167fs` - Elecom WRC-1167FS
- `mt7628an-buffalo-wcr-1166ds` - Buffalo WCR-1166DS

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