#!/bin/bash
#
# Thanks for https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
# Enhanced with build optimizations
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

echo "🚀 Enhanced DIY-Part2 with build optimizations"

# ============================================
# Utility Functions
# ============================================

function config_del(){
    yes="CONFIG_$1=y"
    no="# CONFIG_$1 is not set"
    
    # 首先尝试替换已存在的启用配置
    sed -i "s/$yes/$no/" .config
    
    # 如果配置项不存在，直接添加禁用配置
    if ! grep -q "CONFIG_$1" .config; then
        echo "$no" >> .config
    fi
}

function config_add(){
    yes="CONFIG_$1=y"
    no="# CONFIG_$1 is not set"
    sed -i "s/${no}/${yes}/" .config
    if ! grep -q "$yes" .config; then
        echo "$yes" >> .config
    fi
}

function config_package_del(){
    config_del "PACKAGE_$1"
}

function config_package_add(){
    config_add "PACKAGE_$1"
}

function drop_package(){
    if [ "$1" != "golang" ];then
        find package/ -follow -name $1 -not -path "package/custom/*" | xargs -rt rm -rf
        find feeds/ -follow -name $1 -not -path "feeds/base/custom/*" | xargs -rt rm -rf
    fi
}

function clean_packages(){
    path=$1
    dir=$(ls -l ${path} | awk '/^d/ {print $NF}')
    for item in ${dir}; do
        drop_package ${item}
    done
}

function config_device_del(){
    device="TARGET_DEVICE_$1"
    packages="TARGET_DEVICE_PACKAGES_$1"
    packages_list="CONFIG_TARGET_DEVICE_PACKAGES_$1="""    
    deleted_packages_list="# CONFIG_TARGET_DEVICE_PACKAGES_$1 is not set"
    
    config_del $device
    sed -i "s/$packages_list/$deleted_packages_list/" .config
}

function config_device_list(){
    grep -E 'CONFIG_TARGET_DEVICE_|CONFIG_TARGET_DEVICE_PACKAGES_' .config | while read -r line; do
        if [[ $line =~ CONFIG_TARGET_DEVICE_([^=]+)=y ]]; then
            chipset_device=${BASH_REMATCH[1]}
            chipset=${chipset_device%_DEVICE_*}
            device=${chipset_device#*_DEVICE_}
            echo "Chipset: $chipset, Model: $device"
        fi
    done | sort -u
}

function config_device_keep_only(){
    local keep_devices=("$@")
    grep -E 'CONFIG_TARGET_DEVICE_|CONFIG_TARGET_DEVICE_PACKAGES_' .config | while read -r line; do
        if [[ $line =~ CONFIG_TARGET_DEVICE_([^=]+)=y ]]; then
            chipset_device=${BASH_REMATCH[1]}
            device=${chipset_device#*_DEVICE_}
            if [[ ! " ${keep_devices[@]} " =~ " ${device} " ]]; then
                config_device_del $chipset_device
            fi
        fi
    done
}

# ============================================
# Configuration Correction Functions
# ============================================

function fix_target_platform_config() {
    echo "🔧 Checking and fixing target platform configuration..."
    
    # Check if we're using the old mt7981 target platform
    if grep -q "CONFIG_TARGET_mediatek_mt7981=y" .config; then
        echo "⚠️  Detected old mt7981 target platform, fixing to filogic..."
        
        # Update target platform from mt7981 to filogic
        # config_del "CONFIG_TARGET_mediatek_mt7981"
        # config_add "CONFIG_TARGET_mediatek_filogic"
        
        # Update all device configurations from mt7981 to filogic
        # sed -i 's/mediatek_mt7981/mediatek_filogic/g' .config
        
        # echo "✅ Target platform fixed: mt7981 → filogic"
        
        # Verify CMCC XR30 devices are properly enabled
        if grep -q "CONFIG_TARGET_DEVICE_mediatek_mt7981_DEVICE_cmcc_xr30-stock=y" .config; then
            echo "✅ CMCC XR30 (NAND) device is enabled"
        else
            config_add "CONFIG_TARGET_DEVICE_mediatek_mt7981_DEVICE_cmcc_xr30-stock"
            echo "✅ Enabled CMCC XR30 (NAND) device"
        fi
    else
        echo "✅ Target platform configuration is already correct"
    fi
    
    echo "⌚ Device list after replaced..." 
    config_device_list
    echo "🎯 Configuration check completed"
}

# ============================================
# Optimization Functions
# ============================================

function apply_optimizations_by_level() {
    local optimization_level="${OPTIMIZATION_LEVEL:-full}"
    
    echo "🎯 Applying optimizations for level: $optimization_level"
    
    case "$optimization_level" in
        "basic")
            echo "📦 Basic optimizations: LTO + MOLD"
            export ENABLE_LTO="true"
            export ENABLE_MOLD="true"
            # export ENABLE_BPF="false"
            export KERNEL_CLANG_LTO="false"
            export USE_GCC14="false"
            # export ENABLE_LRNG="false"
            # export ENABLE_DPDK="false"
            # export ENABLE_LOCAL_KMOD="false"
            export ENABLE_ADVANCED_OPTIMIZATIONS="false"
            ;;
        "full")
            echo "🚀 Full optimizations: LTO + MOLD + BPF + CLANG LTO + GCC14"
            export ENABLE_LTO="true"
            export ENABLE_MOLD="true"
            # export ENABLE_BPF="true"
            export KERNEL_CLANG_LTO="true"
            export USE_GCC14="true"
            # export ENABLE_LRNG="false"
            # export ENABLE_DPDK="false"
            # export ENABLE_LOCAL_KMOD="false"
            export ENABLE_ADVANCED_OPTIMIZATIONS="true"
            ;;
        "advanced")
            echo "⚡ Advanced optimizations: All features enabled"
            export ENABLE_LTO="true"
            export ENABLE_MOLD="true"
            # export ENABLE_BPF="true"
            export KERNEL_CLANG_LTO="true"
            export USE_GCC14="true"
            # export ENABLE_LRNG="true"
            # export ENABLE_DPDK="true"
            # export ENABLE_LOCAL_KMOD="true"
            export ENABLE_ADVANCED_OPTIMIZATIONS="true"
            ;;
        "custom")
            echo "🔧 Custom optimizations: Using individual settings(useless in 21.02)"
            # Keep current environment variables as set by GitHub Actions
            # if [[ "${ENABLE_ADVANCED_FEATURES}" == "true" ]]; then
            #     export ENABLE_LRNG="true"
            #     export ENABLE_DPDK="true"
            #     export ENABLE_LOCAL_KMOD="true"
            # else
            #     export ENABLE_LRNG="false"
            #     export ENABLE_DPDK="false"
            #     export ENABLE_LOCAL_KMOD="false"
            # fi
            ;;
        *)
            echo "⚠️  Unknown optimization level: $optimization_level, using full"
            export OPTIMIZATION_LEVEL="full"
            apply_optimizations_by_level
            return
            ;;
    esac
    
    echo "✅ Optimization level configuration completed"
}

function apply_build_optimizations() {
    echo "🔧 Applying build optimizations..."
    
    # Link Time Optimization
    if [ "${ENABLE_LTO:-true}" = "true" ]; then
        echo "📦 Enabling Link Time Optimization (LTO)"
        config_add "USE_GC_SECTIONS"
        config_add "USE_LTO"
    fi
    
    # MOLD linker for faster builds
    if [ "${ENABLE_MOLD:-true}" = "true" ]; then
        echo "⚡ Enabling MOLD linker"
        config_add "USE_MOLD"
        config_add "MOLD"
    fi
    
    # # Extended BPF support
    # if [ "${ENABLE_BPF:-true}" = "true" ]; then
    #     echo "🌐 Enabling extended BPF support"
    #     config_add "DEVEL"
    #     config_add "BPF_TOOLCHAIN_HOST"
    #     config_del "BPF_TOOLCHAIN_NONE"
    #     config_add "KERNEL_BPF_EVENTS"
    #     config_add "KERNEL_CGROUP_BPF"
    #     config_add "KERNEL_DEBUG_INFO"
    #     config_del "KERNEL_DEBUG_INFO_REDUCED"
    #     config_add "KERNEL_DEBUG_INFO_BTF"
    #     config_add "KERNEL_DEBUG_INTO_BTF_MODULES"
    #     config_add "KERNEL_MODULE_ALLOW_BTF_MISMATCH"
    #     config_add "KERNEL_XDP_SOCKETS"
    #     config_add "KERNEL_BPF_STREAM_PARSER"
    #     config_add "KERNEL_NETKIT"
        
    #     # BPF packages
    #     config_package_add "kmod-sched-core"
    #     config_package_add "kmod-sched-bpf"
    #     config_package_add "kmod-xdp-sockets-diag"
    #     config_package_add "libbpf"
    # fi
    
    # # Linux Random Number Generator (LRNG)
    # if [ "${ENABLE_LRNG:-false}" = "true" ]; then
    #     echo "🎲 Enabling Linux Random Number Generator (LRNG)"
    #     config_add "KERNEL_LRNG"
    #     config_package_del "urandom-seed"
    #     config_package_del "urngd"
    # fi
    
    # # Data Plane Development Kit (DPDK)
    # if [ "${ENABLE_DPDK:-false}" = "true" ]; then
    #     echo "🚀 Enabling Data Plane Development Kit (DPDK)"
    #     config_package_add "dpdk-tools"
    #     config_package_add "numactl"
    # fi
    
    # # Local kernel module support
    # if [ "${ENABLE_LOCAL_KMOD:-false}" = "true" ]; then
    #     echo "📦 Enabling local kernel module support"
    #     config_add "TARGET_ROOTFS_LOCAL_PACKAGES"
    # fi
    
    # Enable build acceleration tools
    # config_add "CCACHE"
    
    echo "✅ Build optimizations applied"
}

function apply_mt7981_optimizations() {
    echo "🎯 Applying MT7981 specific optimizations"
    
    # Ensure XR30 devices are properly configured
    config_add "TARGET_mediatek_filogic_DEVICE_cmcc_xr30"
    
    # Advanced CPU-specific optimizations
    if [ "${ENABLE_ADVANCED_OPTIMIZATIONS:-true}" = "true" ]; then
        echo "🚀 Enabling advanced Cortex-A53 optimizations (CRC+Crypto)"
        cat >> .config << 'EOF'
# ARM64 Cortex-A53 optimizations with extensions
CONFIG_TARGET_OPTIMIZATION="-O3 -pipe -mcpu=cortex-a53+crc+crypto"
CONFIG_EXTRA_OPTIMIZATION="-ffunction-sections -fdata-sections"
CONFIG_KERNEL_CFLAGS="-march=armv8-a+crc+crypto -mcpu=cortex-a53+crc+crypto -mtune=cortex-a53"
# ZLIB performance optimization
CONFIG_ZLIB_OPTIMIZE_SPEED=y
EOF
    else
        echo "📦 Using basic Cortex-A53 optimizations"
        cat >> .config << 'EOF'
CONFIG_TARGET_OPTIMIZATION="-O3 -pipe -mcpu=cortex-a53"
CONFIG_EXTRA_OPTIMIZATION="-ffunction-sections -fdata-sections"
EOF
    fi
    
    echo "✅ MT7981 optimizations applied"
}

function apply_compiler_optimizations() {
    echo "🔧 Applying compiler optimizations"
    
    # Enable toolchain options
    config_add "TOOLCHAINOPTS"
    config_add "TARGET_OPTIONS"
    
    # Set host tools optimization
    echo "🏗️  Setting host tools optimization to -O3"
    export HOST_CFLAGS="-O3 -pipe"
    export HOST_CXXFLAGS="-O3 -pipe"
    export CFLAGS="-O3 -pipe"
    export CXXFLAGS="-O3 -pipe" 
    export LDFLAGS="-Wl,-O1,--as-needed"
    
    # Add persistent config settings
    cat >> .config << 'EOF'
# Host tools optimization
CONFIG_HOST_CFLAGS="-O3 -pipe"
CONFIG_HOST_CXXFLAGS="-O3 -pipe"
# Global build optimization
CONFIG_CCACHE=n
EOF
    
    # Kernel CLANG LTO if requested (only affects kernel compilation)
    if [ "${KERNEL_CLANG_LTO:-true}" = "true" ]; then
        echo "⚡ Enabling Kernel CLANG LTO (kernel only)"
        cat >> .config << 'EOF'
# Kernel compilation with CLANG
CONFIG_KERNEL_CC="clang"
EOF
        config_package_del "kselftests-bpf"
        
        # Ensure GCC is still used for userspace when USE_GCC14 is enabled
        if [ "${USE_GCC14:-true}" = "true" ]; then
            echo "🛠️ Using GCC14 for userspace compilation"
            cat >> .config << 'EOF'
# Userspace compilation with GCC14
CONFIG_CC_IS_GCC=y
CONFIG_GCC_VERSION_14=y
EOF
        fi
    else
        # Use GCC for both kernel and userspace
        if [ "${USE_GCC14:-true}" = "true" ]; then
            echo "🛠️ Using GCC 14 for kernel and userspace compilation"
        fi
    fi
    
    echo "✅ Compiler optimizations applied"
}

function setup_custom_lan_ip() {
    local custom_ip="${CUSTOM_LAN_IP:-192.168.3.1}"
    
    echo "🌐 Setting up custom LAN IP: $custom_ip"
    
    # Replace ImmortalWrt default IP (192.168.1.1) if different from user input
    if [[ "$custom_ip" != "192.168.1.1" ]]; then
        echo "Replacing ImmortalWrt default IP (192.168.1.1) with $custom_ip"
        
        # Find and update config_generate files
        find . -name "config_generate" -type f | while read -r config_file; do
            echo "Updating ImmortalWrt IP in: $config_file"
            sed -i "s/192.168.1.1/$custom_ip/g" "$config_file"
        done
        
        # # Update other files that might contain the ImmortalWrt IP
        # find . -name "*.sh" -o -name "*.conf" -o -name "*.cfg" | xargs grep -l "192.168.6.1" 2>/dev/null | while read -r file; do
        #     echo "Updating ImmortalWrt IP in: $file"
        #     sed -i "s/192.168.6.1/$custom_ip/g" "$file"
        # done
    else
        echo "Keeping ImmortalWrt default IP (192.168.1.1) as requested"
    fi
    
    # # Replace standard OpenWrt IP (192.168.1.1) if different from user input
    # if [[ "$custom_ip" != "192.168.1.1" ]]; then
    #     echo "Replacing standard OpenWrt IP (192.168.1.1) with $custom_ip"
        
    #     find . -name "config_generate" -type f | while read -r config_file; do
    #         echo "Updating OpenWrt IP in: $config_file"
    #         sed -i "s/192.168.1.1/$custom_ip/g" "$config_file"
    #     done
        
    #     # Update other files that might contain IP addresses
    #     find . -name "*.sh" -o -name "*.conf" -o -name "*.cfg" | xargs grep -l "192.168.1.1" 2>/dev/null | while read -r file; do
    #         echo "Updating OpenWrt IP in: $file"
    #         sed -i "s/192.168.1.1/$custom_ip/g" "$file"
    #     done
    # else
    #     echo "Keeping standard OpenWrt IP (192.168.1.1) as requested"
    # fi
    
    echo "LAN IP setup completed for: $custom_ip"
}

# ============================================
# Specialized Configuration Functions
# ============================================

# function configure_daed_kernel_options() {
#     echo "🔧 Configuring kernel options for Daed eBPF support..."
    
#     # Core BPF support
#     config_add "KERNEL_BPF"
#     config_add "KERNEL_BPF_SYSCALL"
#     config_add "KERNEL_BPF_JIT"
    
#     # Control Groups support
#     config_add "KERNEL_CGROUPS"
    
#     # Kernel probes support
#     config_add "KERNEL_KPROBES"
#     config_add "KERNEL_KPROBE_EVENTS"
    
#     # Network traffic control
#     config_add "KERNEL_NET_INGRESS"
#     config_add "KERNEL_NET_EGRESS"
#     config_add "KERNEL_NET_SCH_INGRESS"
#     config_add "KERNEL_NET_CLS_BPF"
#     config_add "KERNEL_NET_CLS_ACT"
    
#     # BPF stream parser and events
#     config_add "KERNEL_BPF_STREAM_PARSER"
#     config_add "KERNEL_BPF_EVENTS"
    
#     # Debug information for BPF
#     config_add "KERNEL_DEBUG_INFO"
#     config_del "KERNEL_DEBUG_INFO_REDUCED"
#     config_add "KERNEL_DEBUG_INFO_BTF"
    
#     echo "✅ Daed kernel configuration completed"
# }

# ============================================
# Custom Package Management Functions
# ============================================

function setup_third_party_packages() {
    echo "📦 Setting up third-party packages..."
    
    # Create custom package directory
    mkdir -p package/custom
    
    # Clone third-party package repository
    if [ ! -d "package/custom/OpenWrt-Packages" ]; then
        echo "🌐 Cloning third-party packages..."
        git clone --depth 1 https://github.com/217heidai/OpenWrt-Packages.git package/custom/OpenWrt-Packages
    fi

    # Remove luci-theme-argon from custom OpenWrt-Packages
    rm -rf package/custom/OpenWrt-Packages/luci-theme-argon 2>/dev/null || true

    # Remove duplicate packages from feeds when present in custom packages
    clean_packages package/custom/OpenWrt-Packages

    # Prefer custom packages over feeds for specific versions
    drop_package "xray-core"
    drop_package "xray-geodata"

    # Pin luci-theme-argon to tag 2.3.2
    drop_package "luci-theme-argon"
    if [ ! -d "package/custom/luci-theme-argon" ]; then
        echo "🎨 Cloning luci-theme-argon (tag 2.3.2)..."
        git clone https://github.com/jerrykuku/luci-theme-argon package/custom/luci-theme-argon
    fi
    git -C package/custom/luci-theme-argon fetch --tags --force
    if ! git -C package/custom/luci-theme-argon checkout -q tags/v2.3.2; then
        git -C package/custom/luci-theme-argon checkout -q tags/2.3.2 || {
            echo "❌ Failed to checkout luci-theme-argon tag v2.3.2"
            exit 1
        }
    fi
    
    # Clean conflicting packages
    # clean_packages package/custom/OpenWrt-Packages
    
    # Update golang to latest version
    if [ -d "package/custom/OpenWrt-Packages/golang" ]; then
        echo "🔄 Updating golang to latest version..."
        rm -rf feeds/packages/lang/golang
        git clone https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
        # mv package/custom/OpenWrt-Packages/golang feeds/packages/lang/
    fi
    
    # Clone specific apps
    echo "📱 Setting up specific applications..."
    
    # MentoHust for campus network authentication
    if [ ! -d "package/mentohust" ]; then
        git clone https://github.com/sbwml/luci-app-mentohust package/mentohust
    fi
    
    # Daed for advanced routing
    # if [ ! -d "package/daed" ]; then
    #     git clone https://github.com/QiuSimons/luci-app-daed package/daed
    # fi
    
    echo "✅ Third-party packages setup completed"
}

function configure_unwanted_packages() {
    echo "🗑️  Removing unwanted packages..."
    
    # Remove SSR Plus related packages
    local ssr_packages=(
        "luci-app-ssr-plus_INCLUDE_NONE_V2RAY"
        "luci-app-ssr-plus_INCLUDE_Shadowsocks_NONE_Client"
        "luci-app-ssr-plus_INCLUDE_Shadowsocks_NONE_Server"
        "luci-app-ssr-plus_INCLUDE_ShadowsocksR_NONE_Server"
        "luci-app-ssr-plus_INCLUDE_ShadowsocksR_Rust_Client"
        "luci-app-ssr-plus_INCLUDE_ShadowsocksR_Rust_Server"
        "luci-app-passwall2_INCLUDE_ShadowsocksR_Libev_Client"
        "luci-app-passwall2_INCLUDE_Shadowsocks_Libev_Client"
        "luci-app-passwall2_INCLUDE_Haproxy"
        "luci-app-passwall2_INCLUDE_Simple_Obfs"
        
    )
    
    for package in "${ssr_packages[@]}"; do
        config_package_del "$package"
    done
    
    # Remove theme packages
    # config_package_del "luci-theme-bootstrap-mod"
    config_package_add "luci-theme-argon"
    
    # Clean shadowsocks packages from custom directory
    if [ -d "package/custom/OpenWrt-Packages" ]; then
        rm -rf package/custom/OpenWrt-Packages/shadowsocks-rust 2>/dev/null || true
        rm -rf package/custom/OpenWrt-Packages/simple-obfs 2>/dev/null || true
    fi
    
    echo "✅ Unwanted packages removed"
}

function configure_network_packages() {
    echo "🌐 Configuring network packages..."
    
    # Core network utilities
    config_package_add "curl"                    # HTTP client
    config_package_add "socat"                   # Network relay tool
    config_package_add "kmod-tcp-bbr"           # BBR congestion control
    # config_package_add "kmod-xdp-sockets-diag"
    # config_package_add "kmod-sched-core"
    # config_package_add "kmod-sched-bpf"
    # config_package_add "kmod-nft-bridge"

    
    # Multi-WAN support
    # config_package_add "kmod-macvlan"           # MACVLAN support
    # config_package_add "mwan3"                  # Multi-WAN management
    # config_package_add "luci-app-mwan3"        # Multi-WAN WebUI
    
    # USB network adapters
    local usb_network_packages=(
        "kmod-usb-net-ipheth"              # iPhone tethering
    )
    
    for package in "${usb_network_packages[@]}"; do
        config_package_add "$package"
    done
    
    echo "✅ Network packages configured"
}

function configure_system_packages() {
    echo "🖥️  Configuring system packages..."
    
    # System management
    config_package_add "luci-app-ttyd"          # Web Terminal
    config_package_add "luci-app-autoreboot"    # Auto reboot scheduler
    config_package_add "luci-app-autotimeset"   # Scheduled tasks
    config_package_add "luci-lib-ipkg"          # Package manager library
    
    # Network tools and binding
    config_package_add "luci-app-arpbind"       # IP-MAC binding
    config_package_add "luci-app-wol"           # Wake on LAN
    config_package_add "qrencode"               # QR code generator
    
    # USB support
    config_package_add "usbutils"
    config_package_add "kmod-usb-net"
    config_package_add "kmod-usb-net-rndis"
    config_package_add "kmod-usb-net-cdc-ether"
    config_package_add "luci-app-usb3disable"   # USB3.0 disable control
    config_package_add "kmod-usb-storage"       # USB storage support
    config_package_add "kmod-usb-ohci"          # OHCI USB support
    config_package_add "kmod-usb-uhci"          # UHCI USB support
    config_package_add "usb-modeswitch"         # USB modem mode switching
    config_package_add "sendat"                 # AT command tool
    
    # Disk utilities
    config_package_add "fdisk"                  # GPT disk utility
    #config_package_add "sgdisk"                 # Script-friendly GPT utility
    
    # Performance and monitoring
    config_package_add "iperf"                  # Network performance testing
    # config_package_add "coremark"             # CPU benchmark (commented out for size)
    # config_package_add "autocore"             # System info (commented out)
    # config_package_add "lm-sensors-detect"    # Hardware monitoring (commented out)
    
    echo "✅ System packages configured"
}

function configure_shell_packages() {
    echo "🐚 Configuring shell and terminal packages..."
    
    # Advanced shell environment
    config_package_add "zsh"                   # Fish shell
    config_package_add "vim-full"               # Full-featured Vim
    config_package_add "byobu"                  # Terminal multiplexer wrapper
    config_package_add "tmux"                   # Terminal multiplexer
    
    echo "✅ Shell packages configured"
}

function configure_custom_applications() {
    echo "📱 Configuring custom applications..."
    
    # Campus network authentication
    config_package_add "luci-app-mentohust"     # MentoHust WebUI
    
    # Advanced routing and proxy
    # config_package_add "luci-app-daed"          # Daed WebUI
    
    # Configure kernel options for Daed (eBPF support)
    # configure_daed_kernel_options
    
    # Optional packages (commented out by default)
    # config_package_add "luci-app-frpc"        # FRP client
    # config_package_add "luci-app-mosdns"      # MosDNS
    
    # Passwall2 configuration (commented out by default)
    echo "🔐 Enabling Passwall2..."
    config_package_add "luci-app-passwall2"
    config_package_add "iptables-mod-socket"
    config_package_add "luci-app-passwall2_Iptables_Transparent_Proxy"
    config_package_add "luci-app-passwall2_INCLUDE_Hysteria"
    # config_package_add "luci-app-passwall2_Nftables_Transparent_Proxy"
    # config_package_add "kmod-nft-socket"
    # config_package_add "kmod-nft-tproxy"
    
    # Upnp
    config_package_add "luci-app-upnp"
    config_package_add "miniupnpd"

    echo "✅ Custom applications configured"
}

# ============================================
# Main Configuration
# ============================================

# Device configuration
echo "⌚ Device list before fixed..." 
config_device_list
config_device_keep_only "cmcc_xr30"

echo "✅ Configured for XR30 (H layout) only"
echo "⌚ Device list after fixed..." 

# Theme modification
# sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' $(find ./feeds/luci/collections/ -type f -name "Makefile")
cat feeds/luci/collections/luci/Makefile

# Package management - organized approach
setup_third_party_packages
configure_unwanted_packages
configure_network_packages
configure_system_packages
configure_shell_packages
configure_custom_applications

# ============================================
# Apply All Optimizations
# ============================================

echo "🚀 Starting optimization process..."

# First, fix target platform configuration if needed
# fix_target_platform_config

# Apply optimizations based on level
apply_optimizations_by_level

# Apply specific optimizations
apply_build_optimizations
apply_mt7981_optimizations  
apply_compiler_optimizations

# Setup custom LAN IP
setup_custom_lan_ip

echo "🎉 All optimizations and configurations completed successfully"

# ============================================
# Configuration Verification
# ============================================

echo "📋 验证构建配置..."

# Show all enabled devices
echo "📋 启用的设备列表："
grep "CONFIG_TARGET_DEVICE.*=y" .config | sed 's/CONFIG_TARGET_DEVICE_/  - /' | sed 's/=y//'

# Show enabled optimizations
echo "📋 启用的优化功能："
echo "  - LTO: ${ENABLE_LTO:-true}"
echo "  - MOLD: ${ENABLE_MOLD:-true}"
# echo "  - BPF: ${ENABLE_BPF:-true}"
echo "  - KERNEL_CLANG_LTO: ${KERNEL_CLANG_LTO:-true}"
echo "  - USE_GCC14: ${USE_GCC14:-true}"
echo "  - ADVANCED_OPTIMIZATIONS: ${ENABLE_ADVANCED_OPTIMIZATIONS:-true}"

# Show package statistics
echo "📦 软件包统计："
total_packages=$(grep "CONFIG_PACKAGE.*=y" .config | wc -l)
luci_apps=$(grep "CONFIG_PACKAGE_luci-app.*=y" .config | wc -l)
kernel_modules=$(grep "CONFIG_PACKAGE_kmod.*=y" .config | wc -l)
echo "  - 总软件包: $total_packages"
echo "  - LuCI 应用: $luci_apps" 
echo "  - 内核模块: $kernel_modules"

cat .config
echo "🎯 配置验证完成"
