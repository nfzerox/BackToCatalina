//
//  BTCNSWorkspace.m
//  BackToCatalina
//
//  Created by ittrgrey on 19/07/2026.
//

#include <Foundation/Foundation.h>
#include "ZKSwizzle.h"

// Stop-gap: Replace glass with reduced motion appearance
// TODO: Investigate notificationcenter further
// Control Center is less significant here because, well, it literally did not exist prior to Big Sur. That being said, it may make sense to work on porting Sequoia or earlier's version as it would be more compact and fitting for the overall aesthetic and user experience, even if it isn't *perfectly* matching.
hook(NSWorkspace)

BOOL isNotificationCenterOrControlCenter(void) {
    NSString* bundleId = [[NSBundle mainBundle] bundleIdentifier];
    
    return [bundleId isEqualToString:@"com.apple.notificationcenterui"] || [bundleId isEqualToString:@"com.apple.controlcenter"];
}

- (BOOL)accessibilityDisplayShouldReduceMotion {
    return isNotificationCenterOrControlCenter() ? true : ZKOrig(BOOL);
}

endhook

