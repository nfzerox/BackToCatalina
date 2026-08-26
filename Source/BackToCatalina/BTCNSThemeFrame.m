//
//  BTCNSThemeFrame.m
//  BackToCatalina
//
//  Created by ittrgrey on 08/07/2026.
//
#include <AppKit/AppKit.h>
#include "ZKSwizzle.h"

@interface NSThemeFrame : NSView @end

hook(NSThemeFrame)

// Has to be re-retrieved using this hook method
- (NSWindow*)window {
    return ZKOrig(NSWindow*);
}

// For macOS 15 and earlier...
+ (double)_windowTitlebarTitleMinHeight:(unsigned long long)a0 {
    return MIN(ZKOrig(double, a0), 22.0);
}

// Tahoe function version - adds new parameter to account for...
+ (double)_windowTitlebarTitleMinHeight:(unsigned long long)_windowTitlebarTitleMinHeight hasSolariumAppearance:(BOOL)hasSolariumAppearance {
    return MIN(ZKOrig(double, _windowTitlebarTitleMinHeight, hasSolariumAppearance), 22.0);
}

- (double)_minYTitlebarButtonsOffset {
    return -2.0;
}

- (double)_toolbarOffsetIfTitleIsHidden {
    if([[self window] titleVisibility] == NSWindowTitleVisible)
        return -3.0;
    else
        return ZKOrig(double);
}

- (double)_distanceFromToolbarBaseToTitlebar {
    // EXTREMELY UGLY CODE!!!
    // Why? Bizarre edge-cases in Mail and Safari had to be accounted for here
    // These edge-cases can be explained as: much more simplified code WOULD work, but tab overviews used in Mail and Safari (especially the latter, which already uses its own custom tab class so isn't picked up by usual means...) only hide the tab bar, meaning that just checking for titlebar accessory view controllers (or the tabbedWindows check, which would fail on Safari anyway due to not using NSTabBar) results in incorrect behaviour.
    // To mitigate this, we have to add a check for whether the tab bar (always an accessory view controller at its core) is hidden or not
    // In this case it's been integrated into the function checks because unlike in C++, we don't have lambdas...
    // In a sense, the logic itself is actually fairly simple, despite the nature of the code
    
    if ([[[self window] toolbar] isVisible]) {
        if ([[self window] titleVisibility] == NSWindowTitleVisible) {
            if ([[[self window] titlebarAccessoryViewControllers] count] >= 0 && ([[[self window] titlebarAccessoryViewControllers] indexOfObjectPassingTest:^BOOL(__kindof NSTitlebarAccessoryViewController* _Nonnull obj, NSUInteger idx, BOOL* _Nonnull stop) { return ![obj isHidden]; }] != NSNotFound)) {
                return ZKOrig(double) + 4.0;
            } else {
                return ZKOrig(double) + 5.0;
            }
        }
        else if ([[[self window] titlebarAccessoryViewControllers] count] >= 0 && ([[[self window] titlebarAccessoryViewControllers] indexOfObjectPassingTest:^BOOL(__kindof NSTitlebarAccessoryViewController* _Nonnull obj, NSUInteger idx, BOOL* _Nonnull stop) { return ![obj isHidden]; }] != NSNotFound)) {
            return ZKOrig(double) - 1.0;
        }
    }
    
    return ZKOrig(double);
}

- (double)_toolbarLeadingSpace {
    return ZKOrig(double) + 2.0;
}

- (double)_toolbarTrailingSpace {
    return ZKOrig(double) + 2.0;
}

- (CGRect)_maxTitlebarTitleRect {
    CGRect frame = ZKOrig(CGRect);
    
    frame.size.height -= 2;
    return frame;
}

// TODO: Investigate minx and maxx titlebarwidgetinset for goldengate position fixing

endhook
