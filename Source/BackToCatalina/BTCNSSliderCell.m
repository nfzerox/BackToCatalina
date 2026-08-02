#include <AppKit/AppKit.h>
#include "ZKSwizzle.h"

hook(NSSliderCell)
- (BOOL)_usesModernStyleForAppearance:(id)appearance {
    // Slider in Music app
    return NO;
}

- (void)setControlSize:(NSControlSize)controlSize {
    // NSControlSizeLarge did not exist prior to macOS 11
    if (controlSize == NSControlSizeLarge) controlSize = NSControlSizeRegular;
    
    return ZKOrig(void, controlSize);
}

endhook
