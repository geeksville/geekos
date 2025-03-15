#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
# dnf5 install -y tmux 

# kevinh hack so that missing dependencies for hhd-dev/hhd can install with just the install.sh script
# root cause is that the adjustor python package needs libfuse fuse.h
dnf5 install -y fuse-devel

# kevinh Pull in the kernel headers for whatever kernel this image was built with
dnf install -y kernel-devel

# Get the mesa nightly as a COPR
dnf5 -y copr enable xxmitsu/mesa-git
dnf5 -y update --refresh
dnf5 -y upgrade mesa\* libglvnd\* --allowerasing

# Disable COPRs so they don't end up enabled on the final image:
dnf5 -y copr disable xxmitsu/mesa-git

#### Example for enabling a System Unit File

# systemctl enable podman.socket
