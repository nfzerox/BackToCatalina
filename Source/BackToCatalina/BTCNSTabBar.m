//
//  BTCNSTabBar.m
//  BackToCatalina
//
//  Created by ittrgrey on 11/08/2026.
//

#include <AppKit/AppKit.h>
#include "ZKSwizzle.h"

hook(NSTabBar)

- (CGRect)frame {
    // The original value to modify...
    CGRect tabFrame = ZKOrig(CGRect);
    
    // Hacky - retrieve the superview as that controls the sizing for some reason
    NSView* tabBar = (NSView*)self;
    NSView* tabContainer = tabBar.superview;
    
    // Retrieve current frame and bounds
    CGRect tabBounds = tabBar.bounds;
    CGRect containerFrame = tabContainer.frame;
    CGRect containerBounds = tabContainer.bounds;
    
    // Set intended height (26pt for Catalina, 28pt for Big Sur)
    tabFrame.size.height = containerFrame.size.height = containerBounds.size.height = tabBounds.size.height = 26;
    
    // Reassign the container frame and bounds because the properties of each are read-only...
    tabBar.bounds = tabBounds;
    tabContainer.frame = containerFrame;
    tabContainer.bounds = containerBounds;
    
    // Return the modified tab frame itself
    return tabFrame;
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

hook(NSTabBarNewTabButton)

- (CGRect)frame {
    CGRect frame = ZKOrig(CGRect);
    
    // Restore the original width used in Catalina
    frame.size.width = 24;
    
    // Return the frame
    return frame;
}

endhook
