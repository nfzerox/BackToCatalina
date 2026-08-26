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
    NSString* orientation = GetDockOrientation();
    int catalinaRadius = 5;
    
    CALayer* material = ZKHookIvar(layer, CALayer*, "_materialLayer");
    CALayer* innerRim = ZKHookIvar(layer, CALayer*, "_innerRimLayer");
    
    // On light mode this part doesn't generally render prior to Big Sur
    innerRim.hidden = ![[[NSAppearance currentDrawingAppearance] name] containsString:@"Dark"];
    
    CALayer* rim = ZKHookIvar(layer, CALayer*, "_rim");
    
    material.cornerRadius = innerRim.cornerRadius = rim.cornerRadius = catalinaRadius;
    
    CACornerMask mask = (kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner);
    if ([orientation isEqualToString:@"left"]) {
        mask = (kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner);
        
        innerRim.position = CGPointMake(innerRim.position.x - 1, material.position.y);
        innerRim.bounds = CGRectMake(innerRim.bounds.origin.x, innerRim.bounds.origin.y, innerRim.bounds.size.width + 2, material.bounds.size.height);
    } else if ([orientation isEqualToString:@"right"]) {
        mask = (kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner);
        
        innerRim.position = CGPointMake(innerRim.position.x + 1, material.position.y);
        innerRim.bounds = CGRectMake(innerRim.bounds.origin.x, innerRim.bounds.origin.y, innerRim.bounds.size.width + 2, material.bounds.size.height);
    } else { // bottom orientation
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
    int offset = 5;
    
    if ([orientation isEqualToString:@"left"]) {
        frame.origin.x -= offset;
        frame.size.width += offset;
    } else if ([orientation isEqualToString:@"right"]) {
        // do nothing - this would be a switch select statement but AFAICS this isn't possible with obj-c appkit api
    } else {
        frame.origin.y -= offset; // covers bottom orientation
        frame.size.height += offset;
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

// Pre-Tahoe requires this for sizing the frame
// The function was replaced in Tahoe with DockBar->setFloorFrame and also requires use of FloorLayer->setFrame that we don't need here
- (void)updateFrame:(CGRect)frame tileSize:(float)size {
    NSString* orientation = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.apple.dock"] valueForKey:@"orientation"];
    if ([orientation isEqualToString:@"left"]) {
        frame.origin.x -= 5;
        frame.size.width += 5;
    }
    else if ([orientation isEqualToString:@"right"]) {
        frame.size.width += 5;
    }
    else {
        frame.origin.y -= 5;
        frame.size.height += 5;
    }
    ZKOrig(void, frame, size);
}

endhook
