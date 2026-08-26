//
//  DockBar.m
//  BackToCatalina
//
//  Created by ittrgrey on 27/07/2026.
//

#include "../ZKSwizzle.h"
#include "shared.h"

hook(DockBar)

- (float)distanceTop {
    return ZKOrig(float) + 1.0;
}

- (float)distanceBottom {
    return ZKOrig(float) - 5.0;
}

// Added in Tahoe
// Replaces FloorLayer->updateFrame
- (void)setFloorFrame:(CGRect)frame {
    NSString* orientation = GetDockOrientation();
    int offset = 5;
    
    // Discovered in a VM that when left with the default settings, the orientation isn't supplied to us
    // The only way around this, therefore, is to only specifically check for left and right, and default to bottom dock behaviour in other cases
    // As far as I'm currently aware this doesn't introduce any further issues
    if ([orientation isEqualToString:@"left"]) {
        frame.size.width += offset;
    } else if ([orientation isEqualToString:@"right"]) {
        frame.size.width += offset;
    } else {
        frame.size.height += offset;
    }
    
    return ZKOrig(void, frame);
}

endhook
