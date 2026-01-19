#import "ZKSwizzle.h"

@interface NSObject (BTC)
@end

@implementation NSObject (BTC)
+ (void)load {
    NSLog(@"=== BTC Loaded === ");
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
        @"NSToolbarItemViewerSupportsSelectionRollover": @NO,
        @"NSToolbarCompatibilityExpansionMetrics": @YES,
        @"NSToolbarItemStandardItemsUseSymbolImages": @NO,
        @"NSToolbarSidebarItemUseSymbolImages": @NO,
        @"NSToolbarCloudSharingItemUseSymbolImages": @NO,
        @"NSAlertMetricsGatheringEnabled": @NO, // Only effective on macOS 11 and 12
    }];
}

@end
