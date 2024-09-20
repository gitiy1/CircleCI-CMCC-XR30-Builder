<h1 align="center">CMCC-XR30-Builder</h1>

<div align="center">

A GitHub Actions workflow for building uboot & ImmortalWrt Firmware for CMCC-XR30. (Mainly for personal use)

<a title="hits" target="_blank" href="https://github.com/iceyear/CMCC-XR30-Builder"><img src="https://hits.b3log.org/iceyear/CMCC-XR30-Builder.svg" ></a> ![GitHub contributors](https://img.shields.io/github/contributors/iceyear/CMCC-XR30-Builder) ![GitHub License](https://img.shields.io/github/license/iceyear/CMCC-XR30-Builder)

English &nbsp;&nbsp;|&nbsp;&nbsp; [简体中文](README_ZH.md)

</div>

## ✨ Features

- 🤖 (Mainly for personal use) Build uboot & ImmortalWrt Firmware for CMCC-XR30.

## 🔧 Usage

Just trigger the GitHub Actions workflow, the uboot and firmware will be built automatically.

## ☑️ Options

- [ ] Use luci-app-mtk wifi config

1. Use luci-app-mtk wifi config:

The option is disabled by default, meaning the workflow will use the `mtwifi-cfg` configuration tool. To use the old `luci-app-mtk` wireless configuration tool, please check the box.

- **mtwifi-cfg**: A wireless configuration tool designed for `mtwifi`, compatible with OpenWrt's native `luci` and `netifd`. It allows for fewer adjustments to the wireless driver parameters but offers a more aesthetically pleasing and user-friendly interface. As a newly developed tool, it may have some issues.
- **luci-app-mtk**: A configuration tool derived from the `mtk-sdk`, which needs to be used in conjunction with the `wifi-profile` script. It allows for almost all wireless driver parameters to be adjusted but has a relatively simple interface.

For more details, please refer to [the blog post](https://cmi.hanwckf.top/p/immortalwrt-mt798x/#mtwifi%E6%97%A0%E7%BA%BF%E9%85%8D%E7%BD%AE%E5%B7%A5%E5%85%B7%E8%AF%B4%E6%98%8E).

## 🤝 Contributing

Contributions are welcome! Here are the steps to contribute:

1. Fork this repository.
2. Create a new branch.
3. Make your changes and commit them.
4. Push the changes to your branch.
5. Submit a pull request.


## 🙏 Credit

Repos that inspired me:

- [`P3TERX/Actions-OpenWrt`](https://github.com/P3TERX/Actions-OpenWrt)
- [`lgs2007m/Actions-OpenWrt`](https://github.com/lgs2007m/Actions-OpenWrt)
- [`217heidai/OpenWrt-Builder`](https://github.com/217heidai/OpenWrt-Builder)

Uboot & Firmware Source Code:

- [`hanwckf/bl-mt798x`](https://github.com/hanwckf/bl-mt798x): Uboot for CMCC-XR30.
- [`hanwckf/immortalwrt`](https://github.com/hanwckf/immortalwrt-mt798x): ImmortalWrt for CMCC-XR30.

## 📄 License

[MIT](https://github.com/iceyear/CMCC-XR30-Builder/blob/main/LICENSE) 🄯 [**Ice Year**](https://github.com/iceyear)