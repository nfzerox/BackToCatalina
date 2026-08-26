#!/bin/bash

set -euo pipefail

PACKAGE_NAME="BackToCatalina.pkg"
INSTALL_LOCATION="/var/ammonia/core/tweaks"
STAGING_DIR="${TMPDIR:?}/BackToCatalina-staging"
SCRIPTS_DIR="${TMPDIR:?}/BackToCatalina-scripts"
MARKETING_VERSION="1.0"

MAIN_DYLIB="$BUILT_PRODUCTS_DIR/libBackToCatalina.dylib"
DOCK_DYLIB="$BUILT_PRODUCTS_DIR/libBackToCatalinaDock.dylib"
MAIN_DENYLIST="$SRCROOT/libBackToCatalina.dylib.blacklist"
DOCK_ALLOWLIST="$SRCROOT/libBackToCatalinaDock.dylib.whitelist"
BUNDLE_FILE="$SRCROOT/BTC_VisualStyle.bundle"

required_files=(
  "$MAIN_DYLIB"
  "$DOCK_DYLIB"
  "$MAIN_DENYLIST"
  "$DOCK_ALLOWLIST"
)

for required_file in "${required_files[@]}"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Error: required file not found at $required_file" >&2
    exit 1
  fi
done

if [[ ! -d "$BUNDLE_FILE" ]]; then
  echo "Error: bundle not found at $BUNDLE_FILE" >&2
  exit 1
fi

if [[ "$CONFIGURATION" == "Debug" ]]; then
  echo "Running Debug install..."
  echo "If this fails, run: sudo chmod -R a+rwx /private/var/ammonia/core/tweaks"

  for dylib in "$MAIN_DYLIB" "$DOCK_DYLIB"; do
    destination="$INSTALL_LOCATION/$(basename "$dylib")"
    rm -f "$destination"
    cp "$dylib" "$destination"
    codesign -f -s - "$destination"
  done

  cp "$MAIN_DENYLIST" "$DOCK_ALLOWLIST" "$INSTALL_LOCATION/"
  exit 0
fi

echo "Preparing package staging directories..."
rm -rf "$STAGING_DIR" "$SCRIPTS_DIR"
mkdir -p "$STAGING_DIR" "$SCRIPTS_DIR"

cat > "$SCRIPTS_DIR/preinstall" <<'EOF'
#!/bin/bash
rm -f /private/var/ammonia/core/tweaks/libCatalinaUI.dylib
rm -f /private/var/ammonia/core/tweaks/libCatalinaUI.dylib.blacklist
rm -f /private/var/ammonia/core/tweaks/libBackToCatalina/SystemAppearance.bundle
rm -f /private/var/ammonia/core/tweaks/libBackToCatalinaDock.dylib
rm -f /private/var/ammonia/core/tweaks/libBackToCatalinaDock.dylib.whitelist
exit 0
EOF
chmod +x "$SCRIPTS_DIR/preinstall"

cat > "$SCRIPTS_DIR/postinstall" <<'EOF'
#!/bin/bash

launchctl setenv FEATUREFLAGS_DISABLED SwiftUI/Solarium

mkdir -p /Library/Preferences/FeatureFlags/Domain
defaults write /Library/Preferences/FeatureFlags/Domain/SwiftUI.plist Solarium -dict Enabled -bool false

CURRENT_ARGS=$(nvram boot-args 2>/dev/null | sed 's/boot-args[[:space:]]*//')
if [[ "$CURRENT_ARGS" != *"-arm64e_preview_abi"* ]]; then
  if [[ -z "$CURRENT_ARGS" ]]; then
    nvram boot-args="-arm64e_preview_abi"
  else
    nvram boot-args="$CURRENT_ARGS -arm64e_preview_abi"
  fi
fi

exit 0
EOF
chmod +x "$SCRIPTS_DIR/postinstall"

echo "Copying and signing dylibs..."
for dylib in "$MAIN_DYLIB" "$DOCK_DYLIB"; do
  cp "$dylib" "$STAGING_DIR/"
  codesign -f -s - "$STAGING_DIR/$(basename "$dylib")"
done

cp "$MAIN_DENYLIST" "$DOCK_ALLOWLIST" "$STAGING_DIR/"

mkdir -p "$STAGING_DIR/libBackToCatalina"
COPYFILE_DISABLE=1 cp -R "$BUNDLE_FILE" "$STAGING_DIR/libBackToCatalina/"

echo "Generating package at $SRCROOT/../$PACKAGE_NAME..."
pkgbuild --root "$STAGING_DIR" \
         --scripts "$SCRIPTS_DIR" \
         --identifier "com.nfzerox.backtocatalina.style" \
         --version "$MARKETING_VERSION" \
         --install-location "$INSTALL_LOCATION" \
         "$SRCROOT/../$PACKAGE_NAME"

echo "Package generated successfully."
