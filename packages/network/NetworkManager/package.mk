# SPDX-License-Identifier: LGPL-2.1+-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2021-present Team DockerELEC (https://dockerelec.tv)

PKG_NAME="NetworkManager"
PKG_VERSION="1.32.12"
PKG_SHA256="77a2717c313004baef858a01bfb764cff12cb5984055adf3a15bf8ac5aa337bb"
PKG_LICENSE="LGPL"
PKG_SITE="https://wiki.debian.org/NetworkManager"
PKG_URL="https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/archive/${PKG_VERSION}/NetworkManager-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain glib:host dbus readline iptables libndp nss"
PKG_LONGDESC="A modular network connection manager."
PKG_TOOLCHAIN="meson"

PKG_MESON_OPTS_TARGET="-Dintrospection=false \
					   -Dselinux=false \
					   -Dlibaudit=no \
					   -Dpolkit=false \
					   -Dppp=false \
					   -Dmodem_manager=false \
					   -Dovs=false \
					   -Dlibpsl=false \
					   -Dnmtui=false \
					   -Dnmcli=true \
					   -Dconcheck=false \
					   -Dnm_cloud_setup=false \
					   -Dcrypto=nss \
					   -Dqt=false"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/lib/systemd

  mkdir -p ${PKG_INSTALL}/etc/NetworkManager
    touch ${PKG_INSTALL}/etc/NetworkManager/.empty

  mkdir -p ${PKG_INSTALL}/usr/share/NetworkManager  
     cp ${PKG_DIR}/share/NetworkManager.conf ${PKG_INSTALL}/usr/share/NetworkManager

  mkdir -p ${PKG_INSTALL}/usr/share/NetworkManager/system-connections
     cp ${PKG_DIR}/share/default ${PKG_INSTALL}/usr/share/NetworkManager/system-connections
	 
  cp ${PKG_DIR}/scripts/NetworkManager-setup ${PKG_INSTALL}/usr/bin
}

post_install() {
  enable_service NetworkManager.service  
  enable_service NetworkManager-wait-online.service
  enable_service etc-NetworkManager.mount
}