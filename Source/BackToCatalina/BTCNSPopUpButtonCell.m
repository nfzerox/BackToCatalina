//
//  BTCNSPopupButtonCell.m
//  BackToCatalina
//
//  Created by ittrgrey on 17/07/2026.
//

#include "ZKSwizzle.h"

hook(NSPopUpButtonCell)

// This should revert dropdown buttons to their previous design style (with the accent-coloured arrow background and border)
- (BOOL)_configurationSupportsFormStyle {
    return NO;
}

endhook

