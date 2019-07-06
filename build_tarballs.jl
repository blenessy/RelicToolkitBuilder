# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "RelicToolkit"
version = v"0.4.0-612-gc132de61-1"

# Collection of sources required to build RelicToolkit
sources = [
    "https://github.com/relic-toolkit/relic.git" => "c132de61780cf096ea910bb7abdc22a9c0068c1d",
]

# Bash recipe for building across all platforms
script = raw"""
cmake_build() (
    if [[ ${target} == *-apple-* ]]; then
        seed=udev
        fp_qnres=off
    elif [[ ${target} == *-mingw32 ]]; then
        seed=WCGR
        fp_qnres=on
    fi
    mkdir "$WORKSPACE/srcdir/relic/build-$1"
    cd "$WORKSPACE/srcdir/relic/build-$1"
    cmake -DALLOC=AUTO \
        -DARITH=gmp \
        -DBENCH=0 \
        -DCOLOR=off \
        -DCHECK=off \
        -DCMAKE_BUILD_TYPE=RELEASE \
        -DCMAKE_INSTALL_PREFIX="$prefix" \
        -DCMAKE_POSITION_INDEPENDENT_CODE=on \
        -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain \
        -DCOMP="-O3 -funroll-loops -fomit-frame-pointer" \
        -DDOCUM=off \
        -DSEED="${seed:-dev}" \
        -DEP_PLAIN=off \
        -DEP_SUPER=off \
        -DFP_METHD="INTEG;INTEG;INTEG;MONTY;LOWER;SLIDE" \
        -DFP_PMERS=off \
        -DFP_PRIME=381 \
        -DFP_QNRES="${fp_qnres:-on}" \
        -DFPX_METHD="INTEG;INTEG;LAZYR" \
        -DLABEL="$1" \
        -DMULTI=PTHREAD \
        -DPP_EXT=LAZYR \
        -DPP_METHD="LAZYR;OATEP" \
        -DQUIET=off \
        -DSHLIB=on \
        -DSTBIN=off \
        -DSTLIB=off \
        -DTESTS=0 \
        -DTIMER=CYCLE \
        -DVERBS=off \
        ..
    make
    make install
)
cmake_build gmp_pbc_bls381
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    #Linux(:i686, libc=:glibc),
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
    #Windows(:i686),
    Windows(:x86_64),
]
#platforms = supported_platforms()

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "librelic_gmp_pbc_bls381", :librelic_gmp_pbc_bls381)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaMath/GMPBuilder/releases/download/v6.1.2-2/build_GMP.v6.1.2.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
