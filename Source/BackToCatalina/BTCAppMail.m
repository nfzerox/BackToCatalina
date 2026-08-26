//
//  BTCAppMail.m
//  BackToCatalina
//
//  Created by ittrgrey on 14/08/2026.
//

#include <AppKit/AppKit.h>
#include "ZKSwizzle.h"

hook(MailBarContainerView)

// Revert Mail's scope bar to its earlier height
- (CGRect)frame {
    CGRect frame = ZKOrig(CGRect);
    
    // Restore pre-BigSur height
    frame.size.height = 25;
    
    // And continue...
    return frame;
}

endhook
