IOS_MIN_VERSION="8.0"
DEVELOPER_DIR=`xcode-select --print-path`
IPHONEOS_SDK_VERSION=`xcodebuild -version -sdk | grep -A 1 '^iPhoneOS' | tail -n 1 |  awk '{ print $2 }'`
IPHONEOS_SDK_PATH="$DEVELOPER_DIR/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS$IPHONEOS_SDK_VERSION.sdk"



export CC=`xcrun -find clang`
export CXX=`xcrun -find clang++`

export CGO_ENABLED=1
export GOOS=darwin
export GOARCH=arm64
export CGO_CFLAGS="-isysroot $IPHONEOS_SDK_PATH -arch arm64 -miphoneos-version-min=$IOS_MIN_VERSION"
export CGO_LDFLAGS="-isysroot $IPHONEOS_SDK_PATH -arch arm64 -miphoneos-version-min=$IOS_MIN_VERSION"

go build -buildmode=c-archive
