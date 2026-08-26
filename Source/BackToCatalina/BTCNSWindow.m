#include <AppKit/AppKit.h>
#include "ZKSwizzle.h"

@interface NSWindow ()
- (BOOL)_isUtilityWindow;
@end

@interface NSSheetMoveHelper : NSObject
@end

hook(NSWindow)
- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {
    NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    if ([bundleIdentifier isEqualToString:@"com.apple.iCal"] || [bundleIdentifier isEqualToString:@"com.apple.freeform"]) {
        style &= ~NSWindowStyleMaskFullSizeContentView;
    }
    return _orig(id, contentRect, style, backingStoreType, flag);
}

- (NSUInteger)sheetBehavior {
    return 3;
}

- (id)_sidebarTrackingAdapter {
    return nil;
}

- (id)_newStandardItemWithItemIdentifier:(id)arg0 willBeInsertedIntoToolbar:(BOOL)arg1 {
    return nil;
}

- (void)setTitlebarAppearsTransparent:(BOOL)value {
    if ([NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.Notes"] || [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.TV"] || [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.iCal"] || [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.freeform"]) {
        value = NO;
    }
    _orig(void, value);
}

- (void)setTitlebarHeight:(CGFloat)value {
    if ([NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.TV"]) {
        return;
    }
    _orig(void, value);
}

// Tahoe (well, earlier versions of it) seems to read from this value exclusively for the corner radius. Why, I'm not sure...
- (double)_bottomCornerRadius {
#ifdef APPLY_BUNDLE
    return 5.0;
#else
    return 9.0; // We check if the theme bundle is being applied - use standard Sequoia radius if not
#endif
}

- (long long)titleVisibility {
    return [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.systempreferences"] ? 1 : ZKOrig(long long);
}

// Get rid of the new translucent separator for standard titlebars
- (NSTitlebarSeparatorStyle)titlebarSeparatorStyle {
    return NSTitlebarSeparatorStyleNone;
}

// Get rid of the new translucent separator for toolbar titlebars
- (NSTitlebarSeparatorStyle)contentTitlebarSeparatorStyle {
    return NSTitlebarSeparatorStyleNone;
}

- (BOOL)_sidebarSitsBelowToolbar {
    return YES;
}

endhook

hook(NSSheetMoveHelper)
- (instancetype)initWithSheet:(id)sheet {
    NSSheetMoveHelper *helper = _orig(NSSheetMoveHelper *, sheet);
    NSInteger *animationStyle = &ZKHookIvar(helper, NSInteger, "_animationStyle");
    *animationStyle = 0;

    return self;
}
endhook

hook(NSSavePanelServicePanel)
- (id)_sidebarTrackingAdapter {
    return nil;
}
endhook
