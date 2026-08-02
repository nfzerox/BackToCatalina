//
//  BTCNSButton.m
//  BackToCatalina
//
//  Created by ittrgrey on 29/07/2026.
//

#include <AppKit/AppKit.h>
#include "ZKSwizzle.h"

hook(NSButton)

- (void)setControlSize:(NSControlSize)controlSize {
    // NSControlSizeLarge did not exist prior to macOS 11
    if (controlSize == NSControlSizeLarge) controlSize = NSControlSizeRegular;
    
    return ZKOrig(void, controlSize);
}

endhook

hook(NSButtonCell)

// Voice Memos Edit button
- (BOOL)_shouldUseTextAppearanceInToolbar {
    return NO;
}

- (void)setControlSize:(NSControlSize)controlSize {
    // NSControlSizeLarge did not exist prior to macOS 11
    if (controlSize == NSControlSizeLarge) controlSize = NSControlSizeRegular;
    
    return ZKOrig(void, controlSize);
}

endhook

@interface NSButtonBezelConfiguration : NSObject
@property (nonatomic) long long interactionState;
@end

hook(NSButtonBezelConfiguration)

- (void)setControlSize:(NSControlSize)controlSize {
    // NSControlSizeLarge did not exist prior to macOS 11
    if (controlSize == NSControlSizeLarge) controlSize = NSControlSizeRegular;
    
    return ZKOrig(void, controlSize);
}

endhook

hook(NSButtonAppearanceBasedVisualProvider)

- (BOOL)hasBezelTint {
    // Modern versions of macOS replace the blue mouse-down highlight with a translucent grey one, meaning the text is kept as its darker colour in light mode
    // This is a problem with the Catalina visual style, which effects the old behaviour
    // The solution here is to handle the states ourselves
    // This then mostly resolves the issue, except for on alert dialogs where the button state is held whilst the animation plays out, but this is likely another issue
    
    NSButtonBezelConfiguration* cfg = [self valueForKey:@"_bezelConfiguration"];
    return (cfg.interactionState == 0) ? ZKOrig(BOOL) : YES;
}
endhook
