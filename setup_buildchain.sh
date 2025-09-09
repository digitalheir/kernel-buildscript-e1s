#!/usr/bin/env nix-shell
#!nix-shell -i bash --pure
#!nix-shell -p git git-repo coreutils cacert
#!nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-24.05.tar.gz

# SPDX-License-Identifier: GPL-3.0
#
# Kernel build script for Samsung S24 (Exynos)

BUILDCHAIN="buildchain"
KERNELBUILD="kernelbuild"

TOOLS="${KERNELBUILD}/tools"
SYSTEM="${KERNELBUILD}/system"
BIONIC="${KERNELBUILD}/bionic"
PREBUILTS="${KERNELBUILD}/prebuilts"
EXTERNAL="${KERNELBUILD}/external"
BUILD="${KERNELBUILD}/build"

KERNEL_DIR="${KERNELBUILD}/common"
DEFCONFIG_DIR="${KERNEL_DIR}/arch/arm64/configs/e1s_defconfig"
CURRENT_DIR="$(pwd)"

function getAOSPBuildtools() {
	echo "[💠] Getting the buildchain"
	mkdir $BUILDCHAIN && cd $BUILDCHAIN

	# Only do a shallow pull: we do not need all version history
	repo init --depth=1 -u https://android.googlesource.com/kernel/manifest -b common-android15-6.6

	# Check for updates and apply updates to disk separately with different parallelism

	# -c, --current-branch | fetch only the current branch from the server
  # -j, --jobs           | number of jobs to run in parallel
	repo sync -c -n -j 4  # -n, --network-only   | only fetch data from the network ; don't update the working directory
	repo sync -c -l -j 16 # -l, --local-only     | only update the working directory; don't fetch from the network

	cd ..
	echo "[✅] Done."
}

function getSamsungKernel() {
	echo "[💠] Getting Samsung kernel for S24 (Exynos) from github"
	mkdir $KERNELBUILD && cd $KERNELBUILD
	git clone http://github.com/digitalheir/android-kernel-samsung-e1s.git -b master common
	cd ..
	echo "[✅] Done."
}

function movePrebuilts() {
	echo "[💠] Moving buildchain from AOSP Buildchain to ${KERNELBUILD} folder"
	cp $BUILDCHAIN/tools $TOOLS
	cp $BUILDCHAIN/prebuilts $PREBUILTS
	cp $BUILDCHAIN/external $EXTERNAL
	cp $BUILDCHAIN/build $BUILD
	echo "[✅] Done."
}

function removeAOSPBuildchain() {
	echo "[💠] Remove AOSP Buildchain"
	
	rm -rf $BUILDCHAIN
	
	echo "[✅] Done."
}


if [ ! -d $KERNELBUILD ]; then
	echo getSamsungKernel
fi

#if [ ! -d $PREBUILTS ]; then
	#if [ ! -d $BUILDCHAIN ]; then
		getAOSPBuildtools
	#fi
	
	movePrebuilts
	#removeAOSPBuildchain#(Do not delete checked out AOSP)
#fi
