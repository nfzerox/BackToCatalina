//
//  BTCNSFont.m
//  BackToCatalina
//
//  Created by ittrgrey on 08/07/2026.
//

#include <AppKit/AppKit.h>
#include "ZKSwizzle.h"

hook(NSFont)

+ (NSFont*)_windowTitleFontWithSubtitle:(BOOL)subtitle toolbarStyle:(NSWindowToolbarStyle)toolbarStyle {
    return [NSFont systemFontOfSize:0];
}

+ (NSFont*)titleBarFontOfSize:(CGFloat)fontSize {
    return [NSFont systemFontOfSize:fontSize];
}

endhook
