#include <AppKit/AppKit.h>
#include "ZKSwizzle.h"

hook(NSTableView)

- (NSInteger)_resolvedSidebarType {
    return 2;
}

- (CGSize)intercellSpacing {
    CGSize orig = ZKOrig(CGSize);
    
    if (orig.width == 17 && orig.height == 0) {
        return CGSizeMake(3, 2);
    }
    
    return orig;
}

- (CGFloat)rowHeight {
    CGFloat orig = ZKOrig(CGFloat);
    
    if (orig == 24.0 && [(NSTableView*)self rowSizeStyle] == NSTableViewRowSizeStyleCustom) {
        return 17.0;
    }
    
    return orig;
}

endhook

hook(NSTableViewStyleData)

// If NSSidebarUsesGoldenMetrics are on, it results in stuff being rounded and looking strange
// This addresses that - other differentials do however remain at the moment.

- (double)rowBackgroundInset {
    return 0;
}

- (double)cornerRadius {
    return 0;
}

endhook
