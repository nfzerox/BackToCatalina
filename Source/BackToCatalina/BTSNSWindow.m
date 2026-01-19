#import <Cocoa/Cocoa.h>
#import "ZKSwizzle.h"

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
