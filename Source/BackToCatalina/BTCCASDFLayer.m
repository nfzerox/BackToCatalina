//
//  BTCCASDFLayer.m
//  BackToCatalina
//
//  Created by ittrgrey on 20/07/2026.
//

#include <Foundation/Foundation.h>
#include "ZKSwizzle.h"

hook(CASDFLayer)

// Get rid of the specular chiclet highlight because it's ugly and doesn't fit with our intended visual
- (double)effectOffset {
    return INFINITY;
}

endhook

