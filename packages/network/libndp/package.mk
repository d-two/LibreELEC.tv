# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libndp"
PKG_VERSION="1.8"
PKG_SHA256="c3ea76e253def89869651686a827da75b56896fe94fabd87d8c14b1d4588fd05"
PKG_LICENSE="LGPL"
PKG_SITE="https://github.com/jpirko/libndp"
PKG_URL="https://github.com/jpirko/libndp/archive/refs/tags/v${PKG_VERSION}.tar.gz"

PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Library for Neighbor Discovery Protocol."

PKG_TOOLCHAIN="autotools"

#PKG_CONFIGURE_OPTS_TARGET="--enable-static \
#                           --disable-shared \
#                           --disable-cli"
