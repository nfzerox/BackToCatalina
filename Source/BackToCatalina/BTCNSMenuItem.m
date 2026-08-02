//
//  BTCNSMenuItem.m
//  BackToCatalina
//
//  Created by ittrgrey on 15/07/2026.
//

#include "ZKSwizzle.h"

hook(NSMenuItem)

- (NSInteger)indentationLevel {
    return MAX(1, ZKOrig(NSInteger));
}

endhook
