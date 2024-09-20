<h1 align="center">CMCC-XR30-Builder</h1>

<div align="center">

一个用于构建 CMCC-XR30 的 uboot 和 ImmortalWrt 固件的 GitHub Actions 工作流。（主要供个人使用）

<a title="hits" target="_blank" href="https://github.com/iceyear/CMCC-XR30-Builder"><img src="https://hits.b3log.org/iceyear/CMCC-XR30-Builder.svg" ></a> ![GitHub contributors](https://img.shields.io/github/contributors/iceyear/CMCC-XR30-Builder) ![GitHub License](https://img.shields.io/github/license/iceyear/CMCC-XR30-Builder)

English &nbsp;&nbsp;|&nbsp;&nbsp; [简体中文](README_ZH.md)

</div>

## ✨ 特性

- 🤖 （主要供个人使用）构建 CMCC-XR30 的 uboot 和 ImmortalWrt 固件。

## 🔧 使用方法

只需触发 GitHub Actions 工作流，uboot 和固件将自动构建。

## ☑️ 选项

- [ ] 使用 luci-app-mtk 无线配置

1. 使用 luci-app-mtk 无线配置：

该选项默认关闭，即使用 `mtwifi-cfg` 配置工具。要使用旧的 `luci-app-mtk` 无线配置工具，请勾选此框。

- **mtwifi-cfg**：为 `mtwifi` 设计的无线配置工具，兼容 OpenWrt 的原生 `luci` 和 `netifd`。可调整无线驱动的参数较少，配置界面美观友好，由于是新开发的工具，可能存在一些问题。
- **luci-app-mtk**：源自 `mtk-sdk` 提供的配置工具，需要配合 `wifi-profile` 脚本使用，可调整无线驱动的几乎所有参数，配置界面较为简陋。

区别详见 [mtwifi 无线配置工具说明](https://cmi.hanwckf.top/p/immortalwrt-mt798x/#mtwifi%E6%97%A0%E7%BA%BF%E9%85%8D%E7%BD%AE%E5%B7%A5%E5%85%B7%E8%AF%B4%E6%98%8E)。

## 🤝 贡献

项目欢迎新的贡献者！以下是贡献的步骤：

1. Fork 此仓库。
2. 创建一个新分支。
3. 进行更改并提交。
4. 将更改推送到您的分支。
5. 提交一个 Pull Request。

## 🙏 致谢

以下仓库启发了我：

- [`P3TERX/Actions-OpenWrt`](https://github.com/P3TERX/Actions-OpenWrt)
- [`lgs2007m/Actions-OpenWrt`](https://github.com/lgs2007m/Actions-OpenWrt)
- [`217heidai/OpenWrt-Builder`](https://github.com/217heidai/OpenWrt-Builder)

Uboot 和 ImmortalWrt 源码：

- [`hanwckf/bl-mt798x`](https://github.com/hanwckf/bl-mt798x)：CMCC-XR30 的 Uboot。
- [`hanwckf/immortalwrt`](https://github.com/hanwckf/immortalwrt-mt798x)：CMCC-XR30 的 ImmortalWrt。

## 📄 许可证

[MIT](https://github.com/iceyear/CMCC-XR30-Builder/blob/main/LICENSE) 🄯 [**Ice Year**](https://github.com/iceyear)