#!/bin/bash
set -Eeo pipefail
if [[ -z "$GITHUB_WORKSPACE" ]]
then
    GITHUB_WORKSPACE=".."
    cd $( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../build
fi

if [[ -n "$MACOS_CERTIFICATE" && -n "$MACOS_CERTIFICATE_PWD" ]]
then
    echo "Extracting signing certificate..."
    echo $MACOS_CERTIFICATE | base64 --decode > certificate.p12
    security create-keychain -p $MACOS_CERTIFICATE_PWD build.keychain
    security default-keychain -s build.keychain
    security unlock-keychain -p $MACOS_CERTIFICATE_PWD build.keychain
    security import certificate.p12 -k build.keychain -P $MACOS_CERTIFICATE_PWD -T /usr/bin/codesign
    security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k $MACOS_CERTIFICATE_PWD build.keychain
fi

rm -rf MacApp
rm -rf SimpleDump-macOS-$1.dmg

echo "Making app shell..." 
mkdir -p MacApp/SimpleDump.app/Contents/MacOS
mkdir -p MacApp/SimpleDump.app/Contents/Resources/plugins
cp -r $GITHUB_WORKSPACE/resources MacApp/SimpleDump.app/Contents/Resources/resources
cp -r $GITHUB_WORKSPACE/pipelines MacApp/SimpleDump.app/Contents/Resources/pipelines
cp $GITHUB_WORKSPACE/simpledump_cfg.json MacApp/SimpleDump.app/Contents/Resources
cp $GITHUB_WORKSPACE/macOS/Info.plist MacApp/SimpleDump.app/Contents
cp $GITHUB_WORKSPACE/macOS/Readme.rtf MacApp/Readme.rtf

echo "Creating app icon..." 
mkdir macOSIcon.iconset
sips -z 16 16     $GITHUB_WORKSPACE/icon.png --out macOSIcon.iconset/icon_16x16.png
sips -z 32 32     $GITHUB_WORKSPACE/icon.png --out macOSIcon.iconset/icon_16x16@2x.png
sips -z 32 32     $GITHUB_WORKSPACE/icon.png --out macOSIcon.iconset/icon_32x32.png
sips -z 64 64     $GITHUB_WORKSPACE/icon.png --out macOSIcon.iconset/icon_32x32@2x.png
sips -z 128 128   $GITHUB_WORKSPACE/icon.png --out macOSIcon.iconset/icon_128x128.png
sips -z 256 256   $GITHUB_WORKSPACE/icon.png --out macOSIcon.iconset/icon_128x128@2x.png
sips -z 256 256   $GITHUB_WORKSPACE/icon.png --out macOSIcon.iconset/icon_256x256.png
sips -z 512 512   $GITHUB_WORKSPACE/icon.png --out macOSIcon.iconset/icon_256x256@2x.png
sips -z 512 512   $GITHUB_WORKSPACE/icon.png --out macOSIcon.iconset/icon_512x512.png
sips -z 1024 1024 $GITHUB_WORKSPACE/icon.png --out macOSIcon.iconset/icon_512x512@2x.png
iconutil -c icns -o MacApp/SimpleDump.app/Contents/Resources/icon.icns macOSIcon.iconset
rm -rf macOSIcon.iconset

echo "Copying binaries..."
cp simpledump-ui MacApp/SimpleDump.app/Contents/MacOS
cp simpledump MacApp/SimpleDump.app/Contents/MacOS
cp simpledump_sdr_server MacApp/SimpleDump.app/Contents/MacOS
cp plugins/*.dylib MacApp/SimpleDump.app/Contents/Resources/plugins

if [[ -n "$MACOS_SIGNING_SIGNATURE" ]]
then
    SIGN_FLAG="-ns"
fi

echo "Re-linking binaries"
plugin_args=$(ls MacApp/SimpleDump.app/Contents/Resources/plugins | xargs printf -- '-x MacApp/SimpleDump.app/Contents/Resources/plugins/%s ')
dylibbundler $SIGN_FLAG -cd -s $GITHUB_WORKSPACE/vcpkg/installed/osx-simpledump/lib/ -s . -d MacApp/SimpleDump.app/Contents/libs -b -x MacApp/SimpleDump.app/Contents/MacOS/simpledump-ui -x MacApp/SimpleDump.app/Contents/MacOS/simpledump_sdr_server -x MacApp/SimpleDump.app/Contents/MacOS/simpledump $plugin_args

if [[ -n "$MACOS_SIGNING_SIGNATURE" ]]
then
    echo "Code signing..."
    for dylib in MacApp/SimpleDump.app/Contents/libs/*.dylib
    do
	    codesign -v --force --timestamp --sign "$MACOS_SIGNING_SIGNATURE" $dylib
    done

    for dylib in MacApp/SimpleDump.app/Contents/Resources/plugins/*.dylib
    do
	    codesign -v --force --timestamp --sign "$MACOS_SIGNING_SIGNATURE" $dylib
    done

    codesign -v --force --options runtime --entitlements $GITHUB_WORKSPACE/macOS/Entitlements.plist --timestamp --sign "$MACOS_SIGNING_SIGNATURE" MacApp/SimpleDump.app/Contents/MacOS/simpledump
    codesign -v --force --options runtime --entitlements $GITHUB_WORKSPACE/macOS/Entitlements.plist --timestamp --sign "$MACOS_SIGNING_SIGNATURE" MacApp/SimpleDump.app/Contents/MacOS/simpledump_sdr_server
    codesign -v --force --options runtime --entitlements $GITHUB_WORKSPACE/macOS/Entitlements.plist --timestamp --sign "$MACOS_SIGNING_SIGNATURE" MacApp/SimpleDump.app/Contents/MacOS/simpledump-ui

fi

echo "Creating SimpleDump.dmg..."
hdiutil create -srcfolder MacApp/ -volname SimpleDump SimpleDump-macOS-$1.dmg

if [[ -n "$MACOS_SIGNING_SIGNATURE" ]]
then
    codesign -v --force --timestamp --sign "$MACOS_SIGNING_SIGNATURE" SimpleDump-macOS-$1.dmg

    if [[ -n "$MACOS_NOTARIZATION_UN" && -n "$MACOS_NOTARIZATION_PWD" && -n "$MACOS_TEAM" ]]
    then
        echo "Notarizing DMG..."
        xcrun notarytool submit SimpleDump-macOS-$1.dmg --apple-id $MACOS_NOTARIZATION_UN --password $MACOS_NOTARIZATION_PWD --team-id $MACOS_TEAM --wait
        xcrun stapler staple SimpleDump-macOS-$1.dmg
    fi
fi

echo "Done!"


