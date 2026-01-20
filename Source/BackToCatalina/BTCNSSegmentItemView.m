#import <Cocoa/Cocoa.h>
#import "ZKSwizzle.h"

hook(NSSegmentItemView)

- (BOOL)useSlidingSegmentStyle {
    return NO;
}

- (BOOL)useTextToolbarStyle {
    return NO;
}

endhook


hook(NSSegmentedCell)
- (BOOL)_shouldUseSlidingSegmentedControl {
    return NO;
}
endhook
