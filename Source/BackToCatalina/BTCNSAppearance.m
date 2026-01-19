#import <AppKit/NSAppearance.h>
#import "ZKSwizzle.h"

@interface NSAppearance ()
@end

@interface NSCompositeAppearance : NSAppearance
@end

@interface NSBuiltinAppearance : NSAppearance
@end

@interface NSSystemAppearance : NSBuiltinAppearance
@end

@interface NSAccessibilitySystemAppearance : NSBuiltinAppearance
@end

@interface NSAquaAppearance : NSBuiltinAppearance
@end

@interface NSDarkAquaAppearance : NSBuiltinAppearance
@end

@interface NSVibrantLightAppearance : NSBuiltinAppearance
@end

@interface NSVibrantDarkAppearance : NSBuiltinAppearance
@end

hook(NSCompositeAppearance)
- (BOOL)_usesMetricsAppearance {
    return NO;
}
endhook

hook(NSVibrantDarkAppearance)
- (BOOL)_usesMetricsAppearance {
    return NO;
}
endhook

hook(NSVibrantLightAppearance)
- (BOOL)_usesMetricsAppearance {
    return NO;
}
endhook

hook(NSAquaAppearance)
- (BOOL)_usesMetricsAppearance {
    return NO;
}
endhook

hook(NSDarkAquaAppearance)
- (BOOL)_usesMetricsAppearance {
    return NO;
}
endhook
