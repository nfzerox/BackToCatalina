//
//  BTSNSSolarium.m
//  BackToCatalina
//
//  Created by ittrgrey on 07/07/2026.
//

#include "ZKSwizzle.h"

// Further ensure that Solarium characteristics are force-disabled where applicable.
// For some reason there is a whole NSSolarium class, as well... Not overly sure why, but it seems to control about half of the visual behaviour.
// The other half is handled in NSAppearance (which has also been overridden).

hook(_NSSolarium)
+ (BOOL)isEnabled {
    return FALSE;
}

+ (BOOL)isEnabledIgnoringCompatibility {
    return FALSE;
}
endhook
