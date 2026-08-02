//
//  BTCNSTrackingSeparatorToolbarItem.m
//  BackToCatalina
//
//  Created by ittrgrey on 08/07/2026.
//
#include <AppKit/AppKit.h>
#include "ZKSwizzle.h"

hook(NSTrackingSeparatorToolbarItem)

+(instancetype)trackingSeparatorToolbarItemWithIdentifier:(NSToolbarItemIdentifier)identifier splitView:(NSSplitView *)splitView dividerIndex:(NSInteger)dividerIndex {
    return ZKOrig(NSTrackingSeparatorToolbarItem*, identifier, nil, dividerIndex);
}

-(BOOL)isHidden {
    return true;
}

endhook
