#!/usr/bin/env bash

set -eu

declare -r motomagx_tarball='/tmp/motomagx.tar.gz'
declare -r motomagx_directory='/tmp/motomagx-SDK-toolchain-master'

declare -r sysroot_directory='/tmp/arm-motomagx-linux-gnueabi2.3'
declare -r tarball_filename="${sysroot_directory}.tar.xz"

if ! [ -f "${motomagx_tarball}" ]; then
	curl \
		--url 'https://github.com/fillsa/motomagx-SDK-toolchain/archive/refs/heads/master.tar.gz' \
		--retry '30' \
		--retry-delay '0' \
		--retry-all-errors \
		--retry-max-time '0' \
		--location \
		--silent \
		--output "${motomagx_tarball}"
	
	tar \
		--directory="$(dirname "${motomagx_directory}")" \
		--extract \
		--file="${motomagx_tarball}"
fi

mkdir \
	--parent \
	"${sysroot_directory}/"{include,lib}

mv \
	"${motomagx_directory}/arm-linux-gnueabi/include" \
	"${sysroot_directory}"

mv \
	"${motomagx_directory}/arm-linux-gnueabi/lib" \
	"${sysroot_directory}"

rm \
	--force \
	--recursive \
	"${sysroot_directory}/lib/lib"*'_p.a' \
	"${sysroot_directory}/lib/lib"{affix,affix_,bz2,enca,expat,iberty,jpeg,ncurses,openobex,png,proc,pam,ssmgr,z}* \
	"${sysroot_directory}/lib/lib"{supc++,stdc++,gcc}* \
	"${sysroot_directory}/include/"{c++,faad,x264} \
	"${sysroot_directory}/include/"{bzlib,elcstd,enca,expat_external,expat,jconfig,jerror,jmorecfg,jpeglib,mad,pngconf,png,x264,xvid,zconf,zlib}'.h' \
	"${sysroot_directory}/lib/ldscripts"

echo "- Creating tarball at ${tarball_filename}"

tar --directory="$(dirname "${sysroot_directory}")" --create --file=- "$(basename "${sysroot_directory}")" | xz --compress -9 > "${tarball_filename}"
sha256sum "${tarball_filename}" | sed "s|$(dirname "${sysroot_directory}")/||" > "${tarball_filename}.sha256"

rm \
	--force \
	--recursive \
	"${sysroot_directory}" \
	"${motomagx_directory}" \
	"${motomagx_tarball}"