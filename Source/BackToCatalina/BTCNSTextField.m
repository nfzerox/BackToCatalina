//
//  BTCNSTextField.m
//  BackToCatalina
//
//  Created by ittrgrey on 10/07/2026.
//

#include "BackToCatalina.h"
#include "ZKSwizzle.h"

@interface NSTextField (BTCLayoutQueries)
- (BOOL)_wantsSeparatedSubviews;
- (id)hostingToolbarItem;
@end

hook(NSTextField)

- (BOOL)supportsFauxSolariumControlMetrics {
    return NO;
}

// Fix searchbox height in System Settings
- (void)setFrameSize:(CGSize)frameSize {
    // HACKY!!
    // Actual core of the problem relates to the way the image is incompatible with the 9-silce format that newer SystemAppearance *is* compatible with. Pre-BigSur, all input fields therefore had to be the same height. Catalina and earlier therefore need this issue mitigated.
    NSTextField *field = (NSTextField *)self;
    if (frameSize.height > 22.0 && isTahoeOrLater && [field isBezeled] &&
        [field _wantsSeparatedSubviews] && ![field hostingToolbarItem]) frameSize.height = 22.0;
    
    return ZKOrig(void, frameSize);
}

// Fix overall textbox height so that it cannot be absurdly large
- (void)setControlSize:(NSControlSize)controlSize {
    // NSControlSizeLarge did not exist prior to macOS 11
    if (controlSize == NSControlSizeLarge) controlSize = NSControlSizeRegular;
    
    return ZKOrig(void, controlSize);
}

// Class used in Finder is TTextField - not part of standard OS-level headers, but this itself seems to be a subclass of NSTextField
- (void)setFrameOrigin:(NSPoint)origin {
    // Fix the lack of padding from the left-hand side
    // The header should always have this identifier
    if (origin.x <= 6.0 && [[(NSTextField *)self identifier] isEqualToString:@"xSidebarHeader"]) {
        // Check that the origin value is already lower than it ought to be to avoid affecting visuals when NSSidebarUsesGoldenStyles is enabled
        origin.x += 6.0;
    }
    
    return ZKOrig(void, origin);
}

endhook

hook(NSTextFieldAppearanceBasedVisualProvider)

// Revert to 10.15 behaviour
+ (BOOL)wantsSeparatedSubviewsWithBezelConfiguration:(id)bezelConfiguration {
    return NO;
}

endhook
