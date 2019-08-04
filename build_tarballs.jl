# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "RelicToolkit"
version = v"0.4.0-613-g613795f7-3"

# Collection of sources required to build RelicToolkit
sources = [
    "https://github.com/blenessy/relic.git" => "613795f7481bf7806ba09bf248ab36aec599f4ab",
]

# Bash recipe for building across all platforms
script = raw"""
if [ "${target#*-apple-}" != "$target" ]; then
    opsys=MACOSX
elif [ "${target%-mingw32}" != "$target" ]; then
    opsys=WINDOWS
else
    opsys=LINUX
fi
cd "$WORKSPACE/srcdir/relic"

cat >>src/relic_core.c <<EOF1
#include "relic_bn.h"
#include "relic_md.h"
#include "relic_fp.h"
#include "relic_pc.h"
const size_t JL_RLC_BN_SIZE = RLC_BN_SIZE;
const size_t JL_RLC_MD_LEN = RLC_MD_LEN;
const size_t JL_BN_ST_SIZE  = sizeof(bn_st);
const size_t JL_DIG_T_SIZE  = sizeof(dig_t);
const size_t JL_FP_ST_SIZE  = sizeof(fp_st);
const size_t JL_FP2_ST_SIZE = sizeof(fp2_st);
const size_t JL_FP3_ST_SIZE = sizeof(fp3_st);
const size_t JL_G1_ST_SIZE  = sizeof(g1_st);
const size_t JL_G2_ST_SIZE  = sizeof(g2_st);
EOF1

cat >build.sh <<EOF2
set -exo pipefail
mkdir "build_\$1"
cd "build_\$1"
cmake -DCMAKE_INSTALL_PREFIX="$prefix" -DCMAKE_TOOLCHAIN_FILE="/opt/$target/${target}_gcc.toolchain" \
  -DALLOC=AUTO \
  -DARITH=\$2 \
  -DBENCH=0 \
  -DCOLOR=off \
  -DCHECK=off \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_POSITION_INDEPENDENT_CODE=on \
  -DCOMP="-O3 -funroll-loops -fomit-frame-pointer" \
  -DDOCUM=off \
  -DSEED=udev \
  -DEP_PLAIN=off \
  -DEP_SUPER=off \
  -DFP_METHD="BASIC;COMBA;COMBA;MONTY;LOWER;SLIDE" \
  -DFP_PMERS=off \
  -DFP_PRIME=\$3 \
  -DFP_QNRES=on \
  -DAMALG=on \
  -DFPX_METHD="INTEG;INTEG;LAZYR" \
  -DMD_METHD=SH256 \
  -DMULTI=PTHREAD \
  -DOPSYS="${opsys:-MACOSX}" \
  -DPP_EXT=LAZYR \
  -DPP_METHD="LAZYR;OATEP" \
  -DQUIET=off \
  -DSHLIB=on \
  -DSTBIN=off \
  -DSTLIB=off \
  -DTESTS=0 \
  -DTIMER=CYCLE \
  -DVERBS=off \
  -DWITH="BN;DV;FP;FPX;EP;EPX;EC;PP;PC;MD" \
  -DWSIZE="${nbits:-64}" \
  ..
make
make install
# workaround mingw install bug
if [ "${target%-mingw32}" != "$target" ]; then
    rm -f "$prefix/lib/librelic.$dlext.a"
    cp ./lib/librelic.$dlext "$prefix/lib/"
fi
mv "$prefix/lib/librelic.$dlext" "$prefix/lib/librelic_\$1.$dlext"
EOF2
sh build.sh gmp_pbc_bls381 gmp 381
sh build.sh gmp_pbc_bn254 gmp 254
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    #Linux(:aarch64, libc=:glibc),
    #Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
    #Linux(:powerpc64le, libc=:glibc),
    #Linux(:i686, libc=:musl),
    #Linux(:x86_64, libc=:musl),
    #Linux(:aarch64, libc=:musl),
    #Linux(:armv7l, libc=:musl, call_abi=:eabihf),
    MacOS(:x86_64),
    #FreeBSD(:x86_64),
    # The resulting lib is called librelic_*.dll.a need to investigate the problem
    Windows(:i686),
    Windows(:x86_64),
]
#platforms = supported_platforms()

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "librelic_gmp_pbc_bls381", :librelic_gmp_pbc_bls381),
    LibraryProduct(prefix, "librelic_gmp_pbc_bn254", :librelic_gmp_pbc_bn254),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaMath/GMPBuilder/releases/download/v6.1.2-2/build_GMP.v6.1.2.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
