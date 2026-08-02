//
//  BTCNSTabView.m
//  BackToCatalina
//
//  Created by ittrgrey on 29/07/2026.
//

#include <AppKit/AppKit.h>
#include "ZKSwizzle.h"

hook(NSTabView)

- (void)setControlSize:(NSControlSize)controlSize {
    // NSControlSizeLarge did not exist prior to macOS 11
    if (controlSize == NSControlSizeLarge) controlSize = NSControlSizeRegular;
    
    return ZKOrig(void, controlSize);
}

endhook
