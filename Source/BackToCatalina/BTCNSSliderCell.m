#import <Cocoa/Cocoa.h>
#import "ZKSwizzle.h"

hook(NSSliderCell)
- (BOOL)_usesModernStyleForAppearance:(id)appearance {
    // Slider in Music app
    return NO;
}
endhook
