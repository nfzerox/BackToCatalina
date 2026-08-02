#include <AppKit/AppKit.h>
#include "ZKSwizzle.h"

hook(NSSegmentItemView)

- (BOOL)useSlidingSegmentStyle {
    return NO;
}

- (BOOL)useTextToolbarStyle {
    return NO;
}

- (void)setControlSize:(NSControlSize)controlSize {
   // NSControlSizeLarge did not exist prior to macOS 11
   if (controlSize == NSControlSizeLarge) controlSize = NSControlSizeRegular;
   
   return ZKOrig(void, controlSize);
}

endhook


hook(NSSegmentedCell)

- (BOOL)_shouldUseSlidingSegmentedControl {
    return NO;
}

- (void)setControlSize:(NSControlSize)controlSize {
   // NSControlSizeLarge did not exist prior to macOS 11
   if (controlSize == NSControlSizeLarge) controlSize = NSControlSizeRegular;
   
   return ZKOrig(void, controlSize);
}

endhook

hook(NSSegmentedControlBezelConfiguration)

- (void)setControlSize:(NSControlSize)controlSize {
   // NSControlSizeLarge did not exist prior to macOS 11
   if (controlSize == NSControlSizeLarge) controlSize = NSControlSizeRegular;
   
   return ZKOrig(void, controlSize);
}

endhook

