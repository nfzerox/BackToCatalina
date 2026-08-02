#include "BackToCatalina.h"

#include "dobby.h"
#include "ZKSwizzle.h"

NSBundle* carBundle;
BOOL isTahoeOrLater;

// Disable Solarium by fusing it to be disabled..
// ..unless we are ControlCenter or NotificationCenterUI
Boolean (*_os_feature_enabled_impl)(const char* domain, const char* feature);
Boolean BTC_os_feature_enabled_impl(const char* domain, const char* feature) {
    Boolean result = _os_feature_enabled_impl(domain, feature);
    if (domain && feature) {
         if (strcmp(domain, "SwiftUI") == 0 && strcmp(feature, "Solarium") == 0) {
             return ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.notificationcenterui"] || [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.controlcenter"]) ? true : false;
         }
    }
    
    return result;
}

Boolean (*CompatWidgetOld)(void);
Boolean CompatWidgetNew(void) {
    return true;
}

Boolean (*SelectionRolloverOld)(void);
Boolean SelectionRolloverNew(void) {
    return false;
}

NSOperatingSystemVersion tahoeVersion = {
    .majorVersion = 26,
    .minorVersion = 0,
    .patchVersion = 0
};

WEAK_IMPORT_ATTRIBUTE
@interface load : NSObject @end

@implementation load

+(void)load {
    // This loads from a bundle that contains the asset files, but otherwise has been renamed etc so that it isn't wiped during system updates
    carBundle = [NSBundle bundleWithPath:@"/private/var/ammonia/core/tweaks/libBackToCatalina/BTC_VisualStyle.bundle"];
    
    // Check if we are on Tahoe or later
    isTahoeOrLater = [NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:tahoeVersion];
    
    // Disable Solarium by hooking an exported function system-wide, as a fallback and additional layer to ensure it is disabled
    //DobbyHook(DobbySymbolResolver(NULL, "_os_feature_enabled_impl"), BTC_os_feature_enabled_impl, &_os_feature_enabled_impl);
    
    DobbyHook(DobbySymbolResolver("AppKit", "_NSToolbarItemViewerCompatabilitySelectionWidgetDefaultValueFunction"),
              CompatWidgetNew,
              &CompatWidgetOld);
    
    DobbyHook(DobbySymbolResolver("AppKit", "_NSToolbarItemViewerSupportsSelectionRolloverDefaultValueFunction"),
              SelectionRolloverNew,
              &SelectionRolloverOld);
}

@end

