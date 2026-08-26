//
//  BTCNSTableHeaderView.m
//  BackToCatalina
//
//  Created by ittrgrey on 14/08/2026.
//

#include <Foundation/Foundation.h>
#include "ZKSwizzle.h"

hook(NSTableHeaderView)

- (BOOL)_canSupportTallerHeight {
    return NO;
}

endhook
