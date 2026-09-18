#include "BackToCatalina.h"

#include "dobby.h"
#include "ZKSwizzle.h"

NSBundle* carBundle;
BOOL isTahoeOrLater;
BOOL isGoldenGateOrLater;
BOOL isSafari27OrLater;
BOOL isPhotos;
BOOL isMessages;
BOOL isReminders;
BOOL isWeather;
BOOL isFinder;
BOOL isShortcuts;
BOOL isCalendar;

void BTCInstallToolbarAnimationHooks(void);
void BTCInstallSidebarFontHook(void);

__attribute__((constructor)) static void BTCInstallAppHooks(void) {
    ZKSwizzleGroup(BTCSwiftUIToolbarButtons);
    ZKSwizzleGroup(BTCWindowSidebarActions);

    if (isShortcuts) ZKSwizzleGroup(BTCShortcuts);
    if (isTahoeOrLater) ZKSwizzleGroup(BTCWindowAnimation);
    if (isTahoeOrLater) BTCInstallToolbarAnimationHooks();
    if (isTahoeOrLater && isReminders) ZKSwizzleGroup(BTCReminders);
    if (isTahoeOrLater && isCalendar) ZKSwizzleGroup(BTCCalendar);
    if (isTahoeOrLater && isPhotos) {
        ZKSwizzleGroup(BTCPhotos);
    } else {
        ZKSwizzleGroup(BTCDefaultWindowToolbarStyle);
    }
    if (isTahoeOrLater && isMessages) {
        ZKSwizzleGroup(BTCMessages);
    } else {
        ZKSwizzleGroup(BTCDisableSectionTracking);
    }

    if (isGoldenGateOrLater && isFinder) ZKSwizzleGroup(BTCFinderTableSpacing);
    if (isGoldenGateOrLater) ZKSwizzleGroup(BTCGoldenGateToolbarContextMenu);
    if (isGoldenGateOrLater) {
        BTCInstallSidebarFontHook();
        ZKSwizzleGroup(BTCGoldenGateSidebarFont);
    }
    if (isWeather && isGoldenGateOrLater) ZKSwizzleGroup(BTCWeather);
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

NSOperatingSystemVersion goldenGateVersion = {
    .majorVersion = 27,
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
    isGoldenGateOrLater = [NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:goldenGateVersion];
    isPhotos = [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.Photos"];
    isFinder = [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.finder"];
    isShortcuts = [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.shortcuts"];
    isMessages = [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.MobileSMS"];
    isReminders = [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.reminders"];
    isWeather = [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.weather"];
    isCalendar = [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.iCal"];
    
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (versionString) {
        NSComparisonResult result = [versionString compare:@"27.0" options:NSNumericSearch];
        if (result != NSOrderedAscending) {
            isSafari27OrLater = YES;
        }
    }
    
    DobbyHook(DobbySymbolResolver("AppKit", "_NSToolbarItemViewerCompatabilitySelectionWidgetDefaultValueFunction"),
              CompatWidgetNew,
              &CompatWidgetOld);
    
    DobbyHook(DobbySymbolResolver("AppKit", "_NSToolbarItemViewerSupportsSelectionRolloverDefaultValueFunction"),
              SelectionRolloverNew,
              &SelectionRolloverOld);
}

@end

