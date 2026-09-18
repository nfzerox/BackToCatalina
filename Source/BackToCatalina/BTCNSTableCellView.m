//
//  BTCNSTableCellView.m
//  BackToCatalina
//
//  Created by ittrgrey on 26/07/2026.
//

#include "ZKSwizzle.h"
#import <AppKit/AppKit.h>

hook(NSTableCellView)

// Make System Settings look less gross with NSSidebarUsesGoldenMetrics disabled
- (void)setFrameOrigin:(NSPoint)origin {
    // Fix the lack of padding from the left-hand side
    // The header should always have this identifier
    if (origin.x == 37.0 && [[(NSTableCellView *)self identifier] isEqualToString:@"ListCell"]) {
        // Ensure the offset is the sidebar specifically so we don't accidentally capture other instances
        origin.x -= 17.0;
    }
    
    return ZKOrig(void, origin);
}

endhook
