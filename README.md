# BackToCatalina

This work-in-progress project restores macOS Catalina UI on newer versions of macOS. Requires Mac with Apple silicon. Tested on macOS Sequoia.

![](Source/Screenshot.png)

## Installing BackToCatalina

1. [Disable System Integrity Protection](https://developer.apple.com/documentation/security/disabling-and-enabling-system-integrity-protection) by running `csrutil disable` in macOS Recovery.
1. In Terminal, enable arm64e preview ABI with `sudo nvram boot-args=-arm64e_preview_abi`
1. Install [ammonia](https://github.com/CoreBedtime/ammonia?tab=readme-ov-file#quick-install)
1. Install [BackToCatalina.pkg](https://raw.githubusercontent.com/nfzerox/BackToCatalina/refs/heads/main/BackToCatalina.pkg)
1. Only if you're on macOS Tahoe, disable Liquid Glass in Terminal with:
```
sudo mkdir -p /Library/Preferences/FeatureFlags/Domain
sudo defaults write /Library/Preferences/FeatureFlags/Domain/SwiftUI.plist Solarium -dict Enabled -bool false
```

## Uninstalling BackToCatalina
1. In Terminal, run:
```
sudo rm -rf /private/var/ammonia/core/tweaks/SystemAppearance.bundle /private/var/ammonia/core/tweaks/libBackToCatalina.dylib /private/var/ammonia/core/tweaks/libBackToCatalina.dylib.blacklist
```
2. Only if you're on macOS Tahoe, re-enable Liquid Glass in Terminal with:
```
sudo defaults delete /Library/Preferences/FeatureFlags/Domain/SwiftUI.plist
```
