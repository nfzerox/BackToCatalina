//
//  FloorLayer.m
//  BackToCatalina
//
//  Created by ittrgrey on 27/07/2026.
//

#include "../ZKSwizzle.h"
#include "shared.h"

/// Function implementations
static void CatalinaDock_LayoutSublayers(CALayer* layer) {
    CALayer* shadow = ZKHookIvar(layer, CALayer*, "_shadowLayer");
    shadow.hidden = YES; // Didn't exist before Big Sur - unwanted
    
    NSString* orientation = GetDockOrientation();
    int catalinaRadius = 5;
    
    CALayer* material = ZKHookIvar(layer, CALayer*, "_materialLayer");
    CALayer* innerRim = ZKHookIvar(layer, CALayer*, "_innerRimLayer");
    CALayer* rim = ZKHookIvar(layer, CALayer*, "_rim");
    
    material.cornerRadius = innerRim.cornerRadius = rim.cornerRadius = catalinaRadius;
    
    CACornerMask mask = (kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner);
    if ([orientation isEqualToString:@"left"]) {
        mask = (kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner);
    } else if ([orientation isEqualToString:@"right"]) {
        mask = (kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner);
    } else { // bottom orientation
        // We only need to correct the rim border position when the dock is at the bottom of the screen
        // It seems to already be occluded on the left/right orientations so let's just go along with that
        innerRim.position = CGPointMake(innerRim.position.x, material.position.y - 1);
        innerRim.bounds = CGRectMake(innerRim.bounds.origin.x, innerRim.bounds.origin.y, innerRim.bounds.size.width, material.bounds.size.height + 2);
    }
    
    material.maskedCorners = innerRim.maskedCorners = rim.maskedCorners = mask;
    
    for (CALayer* sublayer in material.sublayers) {
        sublayer.cornerRadius = 0;
    }
    
    return;
}

static CGRect CatalinaDock_SetFrame(CGRect frame) {
    NSString* orientation = GetDockOrientation();
    int offset = 6;
    
    if ([orientation isEqualToString:@"left"]) {
        frame.origin.x -= offset;
    } else if ([orientation isEqualToString:@"right"]) {
        // do nothing - this would be a switch select statement but AFAICS this isn't possible with obj-c appkit api
    } else {
        frame.origin.y -= offset; // covers bottom orientation
    }
    
    return frame;
}

/// Tahoe - Legacy Dock
hook(_TtC8DockCore16LegacyFloorLayer)

- (void)layoutSublayers {
    ZKOrig(void);
    CatalinaDock_LayoutSublayers((CALayer*)self);
}

- (void)setFrame:(CGRect)frame {
    frame = CatalinaDock_SetFrame(frame);
    return ZKOrig(void, frame);
}

endhook

/// Big Sur through Sequoia - Dock
hook(FloorLayer)

- (void)layoutSublayers {
    ZKOrig(void);
    CatalinaDock_LayoutSublayers((CALayer*)self);
}

- (void)setFrame:(CGRect)frame {
    frame = CatalinaDock_SetFrame(frame);
    return ZKOrig(void, frame);
}

endhook
