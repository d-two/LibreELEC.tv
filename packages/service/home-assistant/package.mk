# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Team DockerELEC (https://dockerelec.tv)

PKG_NAME="home-assistant"
PKG_VERSION="0"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain docker-ce jq NetworkManager apparmor"
PKG_SHORTDESC="Open source home automation."
PKG_LONGDESC="Open source home automation that puts local control and privacy first. Powered by a worldwide community of tinkerers and DIY enthusiasts. Perfect to run on a Raspberry Pi or a local server."
PKG_TOOLCHAIN="manual"

pre_configure_target() {
	mkdir -p ${PKG_INSTALL}/etc
	# Write configuration
	cat > "${PKG_INSTALL}/etc/hassio.json" <<- EOF
	{
		"supervisor": "homeassistant/${TARGET_KERNEL_PATCH_ARCH}-hassio-supervisor",
		"machine": "odroid-c4",
		"data": "/storage/.hassio"
	}
	EOF
	#"machine": "${DEVICE}",
}

make_target() {
  mkdir -p ${PKG_INSTALL}/usr/bin
    cp ${PKG_DIR}/bin/ha ${PKG_INSTALL}/usr/bin
	
  mkdir -p ${PKG_INSTALL}/usr/sbin
    cp ${PKG_DIR}/sbin/* ${PKG_INSTALL}/usr/sbin

  #mkdir -p ${PKG_INSTALL}/etc/network
  #   cp ${PKG_DIR}/etc/interfaces ${PKG_INSTALL}/etc/network
}

post_install() {
  enable_service hassio-apparmor.service
  enable_service hassio-supervisor.service
}
