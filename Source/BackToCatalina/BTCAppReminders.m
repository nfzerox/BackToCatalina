#import <AppKit/AppKit.h>
#import <mach-o/dyld.h>
#import <mach-o/getsect.h>
#import "ZKSwizzle.h"

ZKSwizzleInterfaceGroup(BTCRemindersMainWindowAppearance, NSWindow, NSObject, BTCReminders)
@implementation BTCRemindersMainWindowAppearance
- (void)setTitlebarAppearsTransparent:(BOOL)transparent {
    if ([[(NSWindow *)self windowController] isKindOfClass:
         NSClassFromString(@"Reminders.TTRMMainWindowController")]) transparent = YES;
    _orig(void, transparent);
}
endhook

@interface BTCRemindersHeaderBackground : NSVisualEffectView @end
@implementation BTCRemindersHeaderBackground
- (NSView *)hitTest:(NSPoint)point { return nil; }
@end

static char BTCRemindersHeaderBackgroundKey;

static void BTCLayoutRemindersHeader(NSView *wrapper) {
    if (!wrapper.superview || ![wrapper.window.windowController isKindOfClass:
        NSClassFromString(@"Reminders.TTRMMainWindowController")]) return;
    Class headerClass = NSClassFromString(@"Reminders.TTRMRemindersListHeaderView");
    NSMutableArray<NSView *> *pending = [wrapper.subviews mutableCopy];
    NSMutableArray<NSView *> *decorations = [NSMutableArray new];
    BOOL isListHeader = NO;
    while (pending.count) {
        NSView *view = pending.lastObject;
        [pending removeLastObject];
        if ([view isKindOfClass:headerClass]) { isListHeader = YES; continue; }
        if ([view isKindOfClass:NSClassFromString(@"NSBannerView")] ||
            [view isKindOfClass:NSClassFromString(@"NSTitlebarSeparatorView")])
            [decorations addObject:view];
        else [pending addObjectsFromArray:view.subviews];
    }
    if (!isListHeader) return;
    for (NSView *decoration in decorations) decoration.hidden = YES;
    BTCRemindersHeaderBackground *background = objc_getAssociatedObject(wrapper, &BTCRemindersHeaderBackgroundKey);
    if (!background) {
        background = [[BTCRemindersHeaderBackground alloc] initWithFrame:NSZeroRect];
        background.material = NSVisualEffectMaterialContentBackground;
        background.blendingMode = NSVisualEffectBlendingModeBehindWindow;
        background.state = NSVisualEffectStateFollowsWindowActiveState;
        background.clipsToBounds = YES;
        [wrapper addSubview:background positioned:NSWindowBelow relativeTo:nil];
        objc_setAssociatedObject(wrapper, &BTCRemindersHeaderBackgroundKey, background, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSRect pane = [wrapper convertRect:wrapper.superview.bounds fromView:wrapper.superview];
    NSRect bounds = wrapper.bounds;
    CGFloat top = wrapper.isFlipped ? MIN(NSMinY(pane), NSMinY(bounds)) : NSMinY(bounds);
    CGFloat bottom = wrapper.isFlipped ? NSMaxY(bounds) : MAX(NSMaxY(pane), NSMaxY(bounds));
    background.frame = NSMakeRect(NSMinX(bounds), top, NSWidth(bounds), bottom - top);
}

ZKSwizzleInterfaceGroup(BTCRemindersHeaderAccessory, _NSSplitViewItemAccessoryViewWrapper, NSObject, BTCReminders)
@implementation BTCRemindersHeaderAccessory
- (void)layout {
    _orig(void);
    BTCLayoutRemindersHeader((id)self);
}
endhook

static BOOL BTCRemindersUsesToolbarMetrics(void *caller) {
    static uintptr_t start;
    static unsigned long size;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        for (uint32_t index = 0; index < _dyld_image_count(); index++) {
            const struct mach_header_64 *header = (const void *)_dyld_get_image_header(index);
            if (header->magic == MH_MAGIC_64 && header->filetype == MH_EXECUTE) {
                start = (uintptr_t)getsegmentdata(header, "__TEXT", &size);
                break;
            }
        }
    });
    uintptr_t address = (uintptr_t)caller;
    return start && address >= start && address - start < size;
}

#define BTC_REMINDERS_METRICS_HOOK(appearanceClass) \
    hook(appearanceClass, BTCReminders) \
    - (BOOL)_usesMetricsAppearance { \
        if (BTCRemindersUsesToolbarMetrics(__builtin_extract_return_addr(__builtin_return_address(0)))) return YES; \
        return _orig(BOOL); \
    } \
    endhook

BTC_REMINDERS_METRICS_HOOK(NSCompositeAppearance)
BTC_REMINDERS_METRICS_HOOK(NSAquaAppearance)
BTC_REMINDERS_METRICS_HOOK(NSDarkAquaAppearance)
BTC_REMINDERS_METRICS_HOOK(NSVibrantLightAppearance)
BTC_REMINDERS_METRICS_HOOK(NSVibrantDarkAppearance)
