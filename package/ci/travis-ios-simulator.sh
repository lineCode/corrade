#!/bin/bash
set -ev

git submodule update --init

# Build native corrade-rc
mkdir build && cd build
cmake .. \
    -DCMAKE_INSTALL_PREFIX=$HOME/deps \
    -DCMAKE_INSTALL_RPATH=$HOME/deps/lib \
    -DCMAKE_BUILD_TYPE=Release
make -j install
cd ..

# Crosscompile
mkdir build-ios && cd build-ios
cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=../toolchains/generic/iOS.cmake \
    -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk \
    -DCMAKE_OSX_ARCHITECTURES="x86_64" \
    -DCORRADE_RC_EXECUTABLE=$HOME/deps/bin/corrade-rc \
    -DCMAKE_INSTALL_PREFIX=$HOME/ios-deps \
    -DBUILD_STATIC=ON \
    -DBUILD_TESTS=ON \
    -DTESTSUITE_TARGET_XCTEST=ON \
    -G Xcode
cmake --build . --config Release | xcpretty
cmake --build . --config Release --target install | xcpretty
CORRADE_TEST_COLOR=ON ctest -V -C Release