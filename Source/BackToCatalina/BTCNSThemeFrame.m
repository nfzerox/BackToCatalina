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
-(NSWindow*)window {
    return ZKOrig(NSWindow*);
}

-(double)_titlebarHeight {
    return ZKOrig(double);
}

// For macOS 15 and earlier...
+(double)_windowTitlebarTitleMinHeight:(unsigned long long)a0 {
    return MIN(ZKOrig(double, a0), 21.0);
}

// Tahoe function version - adds new parameter to account for...
+(double)_windowTitlebarTitleMinHeight:(unsigned long long)_windowTitlebarTitleMinHeight hasSolariumAppearance:(BOOL)hasSolariumAppearance {
    return MIN(ZKOrig(double, _windowTitlebarTitleMinHeight, hasSolariumAppearance), 21.0);
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

// TODO: Investigate minx and maxx titlebarwidgetinset for goldengate position fixing

endhook
