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

- (double)fullScreenMinHeight {
    return MIN(ZKOrig(double), [[(NSTitlebarAccessoryViewController*)self view] frame].size.height);
}

endhook

hook(NSTitlebarSeparatorView)

// NSTitlebarSeparatorStyle was added in Big Sur
// So we eliminate it
- (void)setType:(NSTitlebarSeparatorStyle)type {
    return ZKOrig(void, NSTitlebarSeparatorStyleNone);
}

endhook

hook(_NSTitlebarDecorationView)

// We don't make any changes to the window, we just need it for accessing whether we have a toolbar or not
- (NSWindow*)window {
    return ZKOrig(NSWindow*);
}

// Restore original behaviour - drawn UNLESS the titlebar is transparent
- (void)setDrawsBottomSeparator:(BOOL)shouldDraw {
    return ZKOrig(void, ![[self window] titlebarAppearsTransparent]);
}

// This brings back the old bottom separator - we just have to eliminate the "new" separator style elsewhere, in NSWindow
- (void)_updateBottomSeparatorLayer {
    // Just returning here brings it back for most window frame designs...
    return;
}

endhook
