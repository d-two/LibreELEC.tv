# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2017 Lukas Rusak (lrusak@libreelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="docker-ce"
PKG_VERSION="19.03.15"
PKG_SHA256="f2f31dd4137eaa735a26e590c9718fb06867afff4d8415cc80feb6cdc9e4a8cd"
PKG_REV="133"
PKG_ARCH="any"
PKG_LICENSE="ASL"
PKG_SITE="http://www.docker.com/"
PKG_URL="https://github.com/docker/docker-ce/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain sqlite go:host containerd runc libnetwork tini systemd"
PKG_SECTION="service/system"
PKG_SHORTDESC="Docker is an open-source engine that automates the deployment of any application as a lightweight, portable, self-sufficient container that will run virtually anywhere."
PKG_LONGDESC="Docker containers can encapsulate any payload, and will run consistently on and between virtually any server. The same container that a developer builds and tests on a laptop will run at scale, in production*, on VMs, bare-metal servers, OpenStack clusters, public instances, or combinations of the above."
PKG_TOOLCHAIN="manual"

# Git commit of the matching release https://github.com/docker/docker-ce/releases
export PKG_GIT_COMMIT="99e3ed89195c4e551e87aad1e7453b65456b03ad"

PKG_DOCKER_BUILDTAGS="daemon \
                      autogen \
                      exclude_graphdriver_devicemapper \
                      exclude_graphdriver_aufs \
                      exclude_graphdriver_btrfs \
                      journald"

configure_target() {
  go_configure

  PKG_GOPATH_ENGINE=${GOPATH}
  PKG_GOPATH_CLI=${GOPATH}_cli
  export GOPATH=${PKG_GOPATH_CLI}:${PKG_GOPATH_ENGINE}
  export GO111MODULE=off

  export LDFLAGS="-w -linkmode external -extldflags -Wl,--unresolved-symbols=ignore-in-shared-libs -extld ${CC}"

  mkdir -p ${PKG_GOPATH_ENGINE}
  mkdir -p ${PKG_GOPATH_CLI}

  PKG_ENGINE_PATH=${PKG_BUILD}/components/engine
  PKG_CLI_PATH=${PKG_BUILD}/components/cli

  if [ -d ${PKG_ENGINE_PATH}/vendor ]; then
    mv ${PKG_ENGINE_PATH}/vendor ${PKG_GOPATH_ENGINE}/src
  fi

  if [ -d ${PKG_CLI_PATH}/vendor ]; then
    mv ${PKG_CLI_PATH}/vendor ${PKG_GOPATH_CLI}/src
  fi

  # Fix missing/incompatible .go files
  cp -rf ${PKG_GOPATH_ENGINE}/src/github.com/moby/buildkit/frontend/*               ${PKG_GOPATH_CLI}/src/github.com/moby/buildkit/frontend
  cp -rf ${PKG_GOPATH_ENGINE}/src/github.com/moby/buildkit/frontend/gateway/*       ${PKG_GOPATH_CLI}/src/github.com/moby/buildkit/frontend/gateway
  cp -rf ${PKG_GOPATH_ENGINE}/src/github.com/moby/buildkit/solver/*                 ${PKG_GOPATH_CLI}/src/github.com/moby/buildkit/solver
  cp -rf ${PKG_GOPATH_ENGINE}/src/github.com/moby/buildkit/util/progress/*          ${PKG_GOPATH_CLI}/src/github.com/moby/buildkit/util/progress
  cp -rf ${PKG_GOPATH_ENGINE}/src/github.com/docker/swarmkit/manager/*              ${PKG_GOPATH_CLI}/src/github.com/docker/swarmkit/manager
  cp -rf ${PKG_GOPATH_ENGINE}/src/github.com/coreos/etcd/raft/*                     ${PKG_GOPATH_CLI}/src/github.com/coreos/etcd/raft
  cp -rf ${PKG_GOPATH_ENGINE}/src/golang.org/x/crypto/*                             ${PKG_GOPATH_CLI}/src/golang.org/x/crypto
  cp -rf ${PKG_GOPATH_ENGINE}/src/github.com/opencontainers/runtime-spec/specs-go/* ${PKG_GOPATH_CLI}/src/github.com/opencontainers/runtime-spec/specs-go

  rm -rf   ${PKG_GOPATH_CLI}/src/github.com/containerd/containerd
  mkdir -p ${PKG_GOPATH_CLI}/src/github.com/containerd/containerd
  cp -rf   ${PKG_GOPATH_ENGINE}/src/github.com/containerd/containerd/* ${PKG_GOPATH_CLI}/src/github.com/containerd/containerd

  rm -rf   ${PKG_GOPATH_CLI}/src/github.com/containerd/continuity
  mkdir -p ${PKG_GOPATH_CLI}/src/github.com/containerd/continuity
  cp -rf   ${PKG_GOPATH_ENGINE}/src/github.com/containerd/continuity/* ${PKG_GOPATH_CLI}/src/github.com/containerd/continuity

  mkdir -p ${PKG_GOPATH_CLI}/src/github.com/docker/docker/builder
  cp -rf   ${PKG_ENGINE_PATH}/builder/* ${PKG_GOPATH_CLI}/src/github.com/docker/docker/builder

  mkdir -p ${PKG_GOPATH_CLI}/src/github.com/docker/docker/pkg/idtools
  cp -rf   ${PKG_ENGINE_PATH}/pkg/idtools/* ${PKG_GOPATH_CLI}/src/github.com/docker/docker/pkg/idtools

  if [ ! -L ${PKG_GOPATH_ENGINE}/src/github.com/docker/docker ]; then
    ln -fs  ${PKG_ENGINE_PATH} ${PKG_GOPATH_ENGINE}/src/github.com/docker/docker
  fi

  if [ ! -L ${PKG_GOPATH_CLI}/src/github.com/docker/cli ]; then
    ln -fs ${PKG_CLI_PATH} ${PKG_GOPATH_CLI}/src/github.com/docker/cli
  fi

  # used for docker version
  export GITCOMMIT=${PKG_GIT_COMMIT}
  export VERSION=${PKG_VERSION}
  export BUILDTIME="$(date --utc)"

  cd ${PKG_ENGINE_PATH}
  bash hack/make/.go-autogen
  cd ${PKG_BUILD}
}

make_target() {
  mkdir -p bin
  PKG_CLI_FLAGS="-X 'github.com/docker/cli/cli/version.Version=${VERSION}'"
  PKG_CLI_FLAGS+=" -X 'github.com/docker/cli/cli/version.GitCommit=${GITCOMMIT}'"
  PKG_CLI_FLAGS+=" -X 'github.com/docker/cli/cli/version.BuildTime=${BUILDTIME}'"
  ${GOLANG} build -v -o bin/docker -a -tags "${PKG_DOCKER_BUILDTAGS}" -ldflags "${LDFLAGS} ${PKG_CLI_FLAGS}" ./components/cli/cmd/docker
  ${GOLANG} build -v -o bin/dockerd -a -tags "${PKG_DOCKER_BUILDTAGS}" -ldflags "${LDFLAGS}" ./components/engine/cmd/dockerd
}

makeinstall_target() {
	mkdir -p ${INSTALL}/etc
	cp -P ${PKG_DIR}/config/docker.conf.sample ${INSTALL}/etc
	
    mkdir -p ${INSTALL}/usr/bin
	cp -P ${PKG_DIR}/bin/docker-config ${INSTALL}/usr/bin
	cp -P ${PKG_DIR}/bin/docker-compose ${INSTALL}/usr/bin
    cp -P ${PKG_BUILD}/bin/docker ${INSTALL}/usr/bin
    cp -P ${PKG_BUILD}/bin/dockerd ${INSTALL}/usr/bin

    # containerd
    cp -P $(get_build_dir containerd)/bin/containerd ${INSTALL}/usr/bin/containerd
    cp -P $(get_build_dir containerd)/bin/containerd-shim ${INSTALL}/usr/bin/containerd-shim

    # libnetwork
    cp -P $(get_build_dir libnetwork)/bin/docker-proxy ${INSTALL}/usr/bin/docker-proxy

    # runc
    cp -P $(get_build_dir runc)/bin/runc ${INSTALL}/usr/bin/runc

    # tini
    cp -P $(get_build_dir tini)/.${TARGET_NAME}/tini-static ${INSTALL}/usr/bin/docker-init
}

post_install() {
    enable_service docker-ce.service
}