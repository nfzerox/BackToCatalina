#include <AppKit/AppKit.h>
#include "ZKSwizzle.h"

hook(NSContextMenuImpl)

- (int)_backgroundStyle {
    return 0;
}

- (double)markWidthsForItem:(id)item {
    return 4.0;
}
- (NSObject*)selectionMaterialView {
    return ZKOrig(NSObject*);
}

- (CGRect)_selectionLayerFrameForView:(id)view {
    CGRect orig = ZKOrig(CGRect, view);
    orig.size = [view bounds].size;
    orig.origin.x = 0;
    NSVisualEffectView* backing = [[self selectionMaterialView] valueForKey:@"_backingView"];
    [backing setValue:@(0) forKey:@"_materialCornerRadius"];
    return orig;
}
endhook
