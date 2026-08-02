//
//  BTCNotificationSound.m
//  BackToCatalina
//
//  Created by ittrgrey on 08/07/2026.
//

#include "ZKSwizzle.h"
#include <UserNotifications/UserNotifications.h>

hook(UNNotificationSound)

+ (id)_soundWithAlertType:(long long)a0 audioVolume:(id)a1 critical:(BOOL)a2 toneFileName:(id)a3 {
    if(a3 == nil)
        return ZKOrig(id, a0, a1, a2, @"Tri-Tone");
    return ZKOrig(id, a0, a1, a2, a3);
}

endhook
