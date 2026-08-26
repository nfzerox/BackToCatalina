//
//  BTCNSPopUpButtonAppearanceBasedVisualProvider.m
//  BackToCatalina
//
//  Created by ittrgrey on 22/08/2026.
//

#include <Foundation/Foundation.h>
#include "ZKSwizzle.h"

hook(NSPopUpButtonAppearanceBasedVisualProvider)

- (double)artworkBaselineOffsetFromFrameInRect:(CGRect)rect flipped:(BOOL)flipped {
    return 0;
}

- (CGRect)_imageAlignmentRectInImageRect:(CGRect)imageRect image:(id)image coordinateSpace:(id)coordinateSpace {
    CGRect orig = ZKOrig(CGRect, imageRect, image, coordinateSpace);
    
    orig.origin.y += 0.5;
    
    return orig;
}

endhook
