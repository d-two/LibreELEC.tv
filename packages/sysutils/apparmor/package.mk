# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Team DockerELEC (https://dockerelec.tv)

PKG_NAME="apparmor"
PKG_VERSION="3.0.3"
PKG_SHA256="51b1db60e962dd01856a1ec6a9d43b11ed4350dcc5738ef901097c999bcbf50e"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="LGPL"
PKG_SITE="https://apparmor.net/"
PKG_URL="https://gitlab.com/apparmor/apparmor/-/archive/v${PKG_VERSION}/apparmor-v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="service/system"
PKG_SHORTDESC="AppArmor protects systems from insecure or untrusted processes by running them in restricted confinement."
PKG_LONGDESC="AppArmor protects systems from insecure or untrusted processes by running them in restricted confinement, while still allowing processes to share files, exercise privilege and communicate with other processes"

PKG_TOOLCHAIN="manual"

pre_configure_target() {
  cd ${PKG_BUILD}/libraries/libapparmor
  ./autogen.sh
  ./configure --host=armv8a-libreelec-linux-gnueabihf --build=x86_64-linux-gnu --prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc --libdir=/usr/lib --libexecdir=/usr/lib --localstatedir=/var --disable-static --enable-shared --disable-man-pages
}

make_target() {
  cd ${PKG_BUILD}/libraries/libapparmor
  make
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/usr/lib
    cp -P src/.libs/libapparmor.* ${TOOLCHAIN}/usr/lib
  
  mkdir -p ${TOOLCHAIN}/lib/pkgconfig
    cp src/libapparmor.pc ${TOOLCHAIN}/lib/pkgconfig
	
  mkdir -p ${TOOLCHAIN}/include/sys
    cp include/aalogparse.h ${TOOLCHAIN}/include
	cp include/sys/apparmor.h ${TOOLCHAIN}/include/sys
    cp include/sys/apparmor_private.h ${TOOLCHAIN}/include/sys
}

makeinstall_target() {
  cd ${PKG_BUILD}/libraries/libapparmor
    ${STRIP} src/.libs/*.so*
    cp -L src/.libs/*.so* ${SYSROOT_PREFIX}/usr/lib

  mkdir -p ${SYSROOT_PREFIX}/usr/include/sys
    cp include/aalogparse.h ${SYSROOT_PREFIX}/usr/include
	cp include/sys/apparmor.h ${SYSROOT_PREFIX}/usr/include/sys
    cp include/sys/apparmor_private.h ${SYSROOT_PREFIX}/usr/include/sys
    cp -L src/libapparmor.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig

  mkdir -p ${PKG_INSTALL}/usr/lib
    cp -PL src/.libs/*.so* ${PKG_INSTALL}/usr/lib
}