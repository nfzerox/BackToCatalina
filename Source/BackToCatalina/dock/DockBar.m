//
//  DockBar.m
//  BackToCatalina
//
//  Created by ittrgrey on 27/07/2026.
//

#include "../ZKSwizzle.h"
#include "shared.h"

hook(DockBar)

- (float)distanceBottom {
    return ZKOrig(float) - 5.0;
}

- (void)setFloorFrame:(CGRect)frame {
    NSString* orientation = GetDockOrientation();
    
    // Discovered in a VM that when left with the default settings, the orientation isn't supplied to us
    // The only way around this, therefore, is to only specifically check for left and right, and default to bottom dock behaviour in other cases
    // As far as I'm currently aware this doesn't introduce any further issues
    if ([orientation isEqualToString:@"left"]) {
        frame.size.width += 6.0;
    } else if ([orientation isEqualToString:@"right"]) {
        frame.size.width += 7.0;
    } else {
        frame.size.height += 6.0;
    }
    
    return ZKOrig(void, frame);
}

endhook
