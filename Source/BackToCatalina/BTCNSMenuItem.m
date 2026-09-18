//
//  BTCNSMenuItem.m
//  BackToCatalina
//
//  Created by ittrgrey on 15/07/2026.
//

#include <AppKit/AppKit.h>
#include "BackToCatalina.h"
#include "ZKSwizzle.h"
#include "glyphs/shared.h"

extern NSImage* FindLegacySidebarGlyph(NSString* symbolName);

@interface NSMenu (BTCMenuRole)
- (BOOL)_isAppleMenu;
@end

static BOOL BTCActionMatchesFinderGoMenu(SEL action) {
    if (!action) {
        return NO;
    }
    NSString *name = NSStringFromSelector(action);
    if ([name isEqualToString:@"cmdGoHome:"]) {
        return YES;
    }
    return NO;
}

static BOOL BTCActionMatchesWindowTiling(SEL action) {
    if (!action) {
        return NO;
    }
    NSString *name = NSStringFromSelector(action);
    return [name hasPrefix:@"_zoom"] || [name hasPrefix:@"_tile"];
}

static BOOL BTCMenuIsPartOfMainMenu(NSMenu *menu) {
    NSMenu *root = menu;
    while (root.supermenu) {
        root = root.supermenu;
    }
    return root != nil && root == NSApp.mainMenu;
}

static BOOL BTCMenuIsFinderGoMenu(NSMenu *menu) {
    if (!menu || !BTCMenuIsPartOfMainMenu(menu)) {
        return NO;
    }
    for (NSMenuItem *sibling in menu.itemArray) {
        if (BTCActionMatchesFinderGoMenu(sibling.action)) {
            return YES;
        }
    }
    return NO;
}

hook(NSMenuItem)

- (NSInteger)indentationLevel {
    return MAX(1, ZKOrig(NSInteger));
}

- (NSImage *)image {
    NSImage *orig = ZKOrig(NSImage *);
    if (!isTahoeOrLater) {
        return orig;
    }
    
    NSMenuItem *item = (NSMenuItem *)self;
    if (!orig.isTemplate || item.title.length < 1) {
        return orig;
    }
    BOOL appleMenu = [item.menu respondsToSelector:@selector(_isAppleMenu)] && [item.menu _isAppleMenu];
    if (!appleMenu && !BTCMenuIsPartOfMainMenu(item.menu)) {
        return orig;
    }

    static BOOL isFinder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFinder = [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.finder"];
    });

    if (isFinder && BTCMenuIsFinderGoMenu(item.menu)) {
        NSString *identifier = GetSymbolName(orig);
        NSImage *legacyGlyph = identifier ? FindLegacySidebarGlyph(identifier) : nil;
        if (!legacyGlyph) {
            return orig;
        }
        NSImage *sizedGlyph = [legacyGlyph copy];
        sizedGlyph.size = CGSizeMake(18, 18);
        return sizedGlyph;
    }

    if (BTCActionMatchesWindowTiling(item.action)) {
        return orig;
    }

    NSString *identifier = GetSymbolName(orig);
    if ([identifier isEqualToString:@"globe"] || [identifier isEqualToString:@"star"]) {
        return orig;
    }
    
    return nil;
}

endhook
