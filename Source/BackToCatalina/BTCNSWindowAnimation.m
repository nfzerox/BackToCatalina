#import <AppKit/AppKit.h>
#import "ZKSwizzle.h"

hook(NSWindow, BTCWindowAnimation)
- (NSWindowAnimationBehavior)animationBehavior {
    return NSWindowAnimationBehaviorNone;
}
- (void)setAnimationBehavior:(NSWindowAnimationBehavior)behavior {
    _orig(void, NSWindowAnimationBehaviorNone);
}
endhook
