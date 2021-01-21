#!/bin/sh
# https://bgstack15.wordpress.com/2016/06/22/building-an-apt-repository-on-centos/

# working directory
repodir=/www/wwwroot/rpi.kxxt.tech
cd ${repodir}

# create the package index
dpkg-scanpackages -m . > Packages
cat Packages | gzip -9c > Packages.gz

# create the Release file
PKGS=$(wc -c Packages)
PKGS_GZ=$(wc -c Packages.gz)
cat <<EOF > Release
Architectures: all
Date: $(date -Ru)
MD5Sum:
 $(md5sum Packages  | cut -d" " -f1) $PKGS
 $(md5sum Packages.gz  | cut -d" " -f1) $PKGS_GZ
SHA1:
 $(sha1sum Packages  | cut -d" " -f1) $PKGS
 $(sha1sum Packages.gz  | cut -d" " -f1) $PKGS_GZ
SHA256:
 $(sha256sum Packages | cut -d" " -f1) $PKGS
 $(sha256sum Packages.gz | cut -d" " -f1) $PKGS_GZ
EOF
rm -fr Release.gpg
gpg -abs -u 0x5382E35D -o Release.gpg Release
rm -fr InRelease
gpg -u 0x5382E35D --clearsign -o InRelease Release
