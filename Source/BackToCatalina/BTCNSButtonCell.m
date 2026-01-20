#import <Cocoa/Cocoa.h>
#import "ZKSwizzle.h"

hook(NSButtonCell)

// Voice Memos Edit button
- (BOOL)_shouldUseTextAppearanceInToolbar {
    return NO;
}

endhook
