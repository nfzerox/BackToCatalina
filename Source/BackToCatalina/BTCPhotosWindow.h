#import <AppKit/AppKit.h>
#import "BackToCatalina.h"

static inline BOOL BTCIsPhotosMainWindow(NSWindow *window) {
    return isPhotos && isTahoeOrLater &&
        [window.windowController isKindOfClass:NSClassFromString(@"IPXMainWindowController")];
}
