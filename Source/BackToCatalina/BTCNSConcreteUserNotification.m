//
//  BTCNSConcreteUserNotification.m
//  BackToCatalina
//
//  Created by ittrgrey on 08/07/2026.
//

#include <AppKit/AppKit.h>
#include "ZKSwizzle.h"

hook(_NSConcreteUserNotification)

- (void)setSoundName:(NSString *)soundName {
    if ([soundName isEqual:NSUserNotificationDefaultSoundName])
        return ZKOrig(void, @"Tri-tone");
    return ZKOrig(void, soundName);
}

endhook
