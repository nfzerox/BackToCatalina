#include "ZKSwizzle.h"

@interface NSObject (BTC)
@end

@implementation NSObject (BTC)
+ (void)load {
#ifdef DEBUG
    NSLog(@"=== BTC Loaded === ");
#endif
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
        @"NSToolbarItemViewerSupportsSelectionRollover": @NO,
        @"NSToolbarCompatibilityExpansionMetrics": @YES,
        @"NSToolbarItemStandardItemsUseSymbolImages": @NO,
        @"NSToolbarSidebarItemUseSymbolImages": @NO,
        @"NSToolbarCloudSharingItemUseSymbolImages": @NO,
        @"NSAlertMetricsGatheringEnabled": @NO, // Only effective on macOS 11 and 12 - see BTCNSAlert.m for macOS 13 and later
        
#if 0
        // Disabled because it turns Control Center module selection oval and uneven padding between elements
        // Revert some Big Sur-era addons
        @"NSStatusItemSpacing": @4.0,
        @"NSStatusItemSelectionPadding": @0.0,
#endif
        
        @"com.apple.SwiftUI.MacUnbridgedSlider": @NO,
        @"com.apple.SwiftUI.MacUnbridgedButtons": @NO,
        @"com.apple.SwiftUI.MacUnbridgedFormBoxes": @NO,
        @"com.apple.SwiftUI.MacUnbridgedMenuButtons": @NO,
        @"com.apple.SwiftUI.MacUnbridgedBorderedPickerButtons": @NO,
        @"NSAlertGlassSolariumEnabled": @NO,
        @"NSGlassMenusEnabled": @NO,
        @"NSGlassMenuLayoutEnabled": @NO,
        @"NSMenuEnableActionImages": @NO,
        
        // Mitigate later Tahoe updates, plus GoldenGate
        @"NSConvolutionOverride1": @5.0,
        @"NSConvolutionOverride2": @5.0,
    }];
}

@end
