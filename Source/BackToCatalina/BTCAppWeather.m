#import <AppKit/AppKit.h>
#import "ZKSwizzle.h"

static BOOL BTCWeatherMainWindow(NSWindow *window) {
    return [window isKindOfClass:NSClassFromString(@"UINSWindow")] &&
           (window.styleMask & NSWindowStyleMaskFullSizeContentView) &&
           !(window.styleMask & NSWindowStyleMaskNonactivatingPanel);
}

ZKSwizzleInterfaceGroup(BTCWeatherWindowAppearance, NSWindow, NSObject, BTCWeather)
@implementation BTCWeatherWindowAppearance
- (void)setTitlebarAppearsTransparent:(BOOL)transparent {
    if (BTCWeatherMainWindow((id)self)) transparent = YES;
    _orig(void, transparent);
}
- (void)setToolbar:(NSToolbar *)toolbar {
    _orig(void, toolbar);
    if (toolbar && BTCWeatherMainWindow((id)self))
        [(NSWindow *)self setTitlebarAppearsTransparent:YES];
}
endhook
