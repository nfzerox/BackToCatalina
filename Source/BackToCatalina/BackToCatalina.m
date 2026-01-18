#import "ZKSwizzle.h"
#import <Cocoa/Cocoa.h>
#import <UserNotifications/UserNotifications.h>
#import "dobby.h"

Boolean (*_CFExecutableLinkedOnOrAfterOld)(signed long long version);

Boolean _CFExecutableLinkedOnOrAfterNew(signed long long version) {
    return (version < 16);
}


Boolean (*SidebarGoldenMetricsOld)(void);
Boolean SidebarGoldenMetricsNew() {
    return false;
}

Boolean (*TableViewGoldenStylesOld)(void);
Boolean TableViewGoldenStylesNew() {
    return false;
}

Boolean (*CompatWidgetOld)(void);
Boolean CompatWidgetNew() {
    return true;
}

Boolean (*SelectionRolloverOld)(void);
Boolean SelectionRolloverNew() {
    return false;
}

NSBundle* carBundle;
NSAppearance* aqua;
NSAppearance* darkAqua;

WEAK_IMPORT_ATTRIBUTE
@interface NSThemeFrame : NSView @end

@interface load : NSObject @end
@interface tbHook: NSTrackingSeparatorToolbarItem @end
@interface splitViewHook : NSSplitViewItem @end
@interface appearanceHook : NSView @end
@interface windowHook : NSWindow @end
@interface windowHookMin : NSWindow @end
@interface fontHook : NSFont @end
@interface statusHook : NSStatusItem @end
@interface notificationHook : NSUserNotification @end
@interface notificationHook2 : UNNotificationSound @end
@interface tableHook : NSTableView @end
@interface themeHook : NSThemeFrame @end

@implementation load

+(void)load {
    carBundle = [NSBundle bundleWithPath:@"/private/var/ammonia/core/tweaks/SystemAppearance.bundle"];
    aqua = [[NSAppearance alloc] initWithAppearanceNamed:@"NSAppearanceNameAqua" bundle:carBundle];
    darkAqua = [[NSAppearance alloc] initWithAppearanceNamed:@"NSAppearanceNameDarkAqua" bundle:carBundle];
    
    DobbyHook(DobbySymbolResolver("AppKit", "_NSSidebarUsesGoldenMetrics"),
              SidebarGoldenMetricsNew,
              &SidebarGoldenMetricsOld);
    
    DobbyHook(DobbySymbolResolver("AppKit", "_NSTableViewCanUseGoldenStyles"),
              TableViewGoldenStylesNew,
              &TableViewGoldenStylesOld);
    
    DobbyHook(DobbySymbolResolver("AppKit", "_NSToolbarItemViewerCompatabilitySelectionWidgetDefaultValueFunction"),
              CompatWidgetNew,
              &CompatWidgetOld);
    
    DobbyHook(DobbySymbolResolver("AppKit", "_NSToolbarItemViewerSupportsSelectionRolloverDefaultValueFunction"),
              SelectionRolloverNew,
              &SelectionRolloverOld);

    if([[NSBundle mainBundle] principalClass] || [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPrincipalClass"]){
        DobbyHook(DobbySymbolResolver(NULL, "_CFExecutableLinkedOnOrAfter"),
                  _CFExecutableLinkedOnOrAfterNew,
                  &_CFExecutableLinkedOnOrAfterOld);
        ZKSwizzle(windowHookMin, NSWindow);
    }
    else {
        ZKSwizzle(windowHook, NSWindow);
    }
    ZKSwizzle(appearanceHook, NSView);
    ZKSwizzle(themeHook, NSThemeFrame);
    ZKSwizzle(tbHook, NSTrackingSeparatorToolbarItem);
    ZKSwizzle(fontHook, NSFont);
    ZKSwizzle(statusHook, NSStatusItem);
    ZKSwizzle(notificationHook, _NSConcreteUserNotification);
    ZKSwizzle(notificationHook2, UNNotificationSound);
    ZKSwizzle(splitViewHook, NSSplitViewItem);
    ZKSwizzle(tableHook, NSTableView);
}

@end

@implementation windowHook

- (NSWindowToolbarStyle)toolbarStyle {
    if ([self titleVisibility] == NSWindowTitleVisible)
        return NSWindowToolbarStyleExpanded;
    else
        return NSWindowToolbarStyleUnifiedCompact;
}

- (NSUInteger)sheetBehavior {
    return 3;
}

@end

@implementation windowHookMin

-(void)setToolbarStyle:(NSWindowToolbarStyle)toolbarStyle {
    return;
}

- (NSUInteger)sheetBehavior {
    return 3;
}

@end

@implementation themeHook

-(double)_titlebarHeight {
    return ZKOrig(double);
}

+(double)_windowTitlebarTitleMinHeight:(unsigned long long)a0 {
    return MIN(ZKOrig(double, a0), 21.0);
}

-(double)_minYTitlebarButtonsOffset {
    return [self _titlebarHeight] - 22.0;
}

-(double)_toolbarOffsetIfTitleIsHidden {
    if([[self window] titleVisibility] == NSWindowTitleVisible)
        return -4.0;
    else
        return ZKOrig(double);
}

-(double)_distanceFromToolbarBaseToTitlebar {
    if ([[[self window] toolbar] isVisible] ){
        if([[self window] titleVisibility] == NSWindowTitleVisible)
            return ZKOrig(double) + 5.0;
        else
            return ZKOrig(double) - 1.0;
    }
    else {
        return ZKOrig(double);
    }
}

-(double)_toolbarLeadingSpace {
    return ZKOrig(double) + 2.0;
}

-(double)_toolbarTrailingSpace {
    return ZKOrig(double) + 2.0;
}

@end


@implementation tbHook

+(instancetype)trackingSeparatorToolbarItemWithIdentifier:(NSToolbarItemIdentifier)identifier splitView:(NSSplitView *)splitView dividerIndex:(NSInteger)dividerIndex {
    return ZKOrig(tbHook*, identifier, nil, dividerIndex);
}

-(BOOL)isHidden {
    return true;
}

@end

@implementation splitViewHook

-(BOOL)allowsFullHeightLayout {
    return false;
}

@end

@implementation appearanceHook

-(NSAppearance *)appearance {
    NSString* interfaceStyle = [NSUserDefaults.standardUserDefaults stringForKey:@"AppleInterfaceStyle"];
    if ([interfaceStyle isEqual:@"Dark"] && darkAqua)
        return darkAqua;
    else if (aqua)
        return aqua;

    return ZKOrig(NSAppearance *);
}
@end

@implementation fontHook
+(NSFont*)titleBarFontOfSize:(CGFloat)fontSize {
    return [NSFont systemFontOfSize:fontSize];
}
@end

@implementation statusHook
-(void)setVisible:(BOOL)visible {
    if ([[self autosaveName] isEqual:@"BentoBox"])
        return ZKOrig(void, false);
    else
        return ZKOrig(void, visible);
}
@end

@implementation notificationHook
- (void)setSoundName:(NSString *)soundName {
    if ([soundName isEqual:NSUserNotificationDefaultSoundName])
        return ZKOrig(void, @"Tri-tone");
    return ZKOrig(void, soundName);
}

@end

@implementation notificationHook2
+ (id)_soundWithAlertType:(long long)a0 audioVolume:(id)a1 critical:(BOOL)a2 toneFileName:(id)a3 {
    if(a3 == nil)
        return ZKOrig(id, a0, a1, a2, @"Tri-Tone");
    return ZKOrig(id, a0, a1, a2, a3);
}

@end

@implementation tableHook
- (NSSize)intercellSpacing {
    NSSize orig = ZKOrig(NSSize);
    if (orig.width == 17 && orig.height == 0)
        return NSMakeSize(3,2);
    return orig;
}

- (CGFloat)rowHeight {
    CGFloat orig = ZKOrig(CGFloat);
    if (orig == 24.0 && [self rowSizeStyle] == NSTableViewRowSizeStyleCustom)
        return 17.0;
    return orig;
}
@end
