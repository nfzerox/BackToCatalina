#import "BackToCatalina.h"

#import "dobby.h"
#import "ZKSwizzle.h"
#import <UserNotifications/UserNotifications.h>

NSBundle* carBundle;
BOOL isTahoeOrLater;

Boolean (*_CFExecutableLinkedOnOrAfterOld)(signed long long version);

Boolean _CFExecutableLinkedOnOrAfterNew(signed long long version) {
    return (version < 16);
}


Boolean (*SidebarGoldenMetricsOld)(void);
Boolean SidebarGoldenMetricsNew(void) {
    return false;
}

Boolean (*TableViewGoldenStylesOld)(void);
Boolean TableViewGoldenStylesNew(void) {
    return false;
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
@interface NSThemeFrame : NSView @end

@interface load : NSObject @end
@interface tbHook: NSTrackingSeparatorToolbarItem @end
@interface splitViewHook : NSSplitViewItem @end
@interface windowHook : NSWindow @end
@interface windowHookMin : NSWindow @end
@interface fontHook : NSFont @end
@interface notificationHook : NSUserNotification @end
@interface notificationHook2 : UNNotificationSound @end
@interface themeHook : NSThemeFrame @end

@implementation load

+(void)load {
    carBundle = [NSBundle bundleWithPath:@"/private/var/ammonia/core/tweaks/libBackToCatalina/SystemAppearance.bundle"];
    isTahoeOrLater = [NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:tahoeVersion];

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
    if (!isTahoeOrLater) {
        ZKSwizzle(themeHook, NSThemeFrame);
    }
    ZKSwizzle(tbHook, NSTrackingSeparatorToolbarItem);
    ZKSwizzle(fontHook, NSFont);
    ZKSwizzle(notificationHook, _NSConcreteUserNotification);
    ZKSwizzle(notificationHook2, UNNotificationSound);
    ZKSwizzle(splitViewHook, NSSplitViewItem);
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

@implementation fontHook
+ (NSFont *)_windowTitleFontWithSubtitle:(BOOL)subtitle toolbarStyle:(NSWindowToolbarStyle)toolbarStyle {
    return [NSFont systemFontOfSize:0];
}

+(NSFont*)titleBarFontOfSize:(CGFloat)fontSize {
    return [NSFont systemFontOfSize:fontSize];
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
