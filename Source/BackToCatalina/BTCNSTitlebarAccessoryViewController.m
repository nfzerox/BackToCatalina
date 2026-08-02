//
//  BTCNSTitlebarAccessoryViewController.m
//  BackToCatalina
//
//  Created by ittrgrey on 22/07/2026.
//

#include <AppKit/AppKit.h>
#include "ZKSwizzle.h"

hook(NSTitlebarAccessoryViewController)

// Reverts to pre-BigSur behaviour
- (BOOL)allowsAutomaticSeparator {
    return NO;
}

endhook

hook(NSTitlebarSeparatorView)

// NSTitlebarSeparatorStyle was added in Big Sur
// So we eliminate it
- (void)setType:(NSTitlebarSeparatorStyle)type {
    return ZKOrig(void, NSTitlebarSeparatorStyleNone);
}

endhook

hook(NSTabBarViewButton)

- (BOOL)isOpaque {
    // Unhide the top border view
    NSView* topBorderView = ZKHookIvar(self, NSView*, "_topBorderView");
    topBorderView.hidden = NO;
    
    // Return our original value since, well, we don't actually need to change the function output :P
    return ZKOrig(BOOL);
}

endhook
