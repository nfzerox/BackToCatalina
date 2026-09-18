//
//  ToolbarButtons.m
//  BackToCatalina
//
//  Created by ittrgrey on 29/08/2026.
//

#include "shared.h"
#include "../ZKSwizzle.h"

static NSDictionary *BTCApplicationPrefsGlyphMap(void) {
    static NSDictionary *map;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ map = applicationPrefsGlyphMap[NSBundle.mainBundle.bundleIdentifier]; });
    return map;
}

NSImage* FindLegacyToolbarGlyph(NSString* symbolName, BOOL isPrefsWnd) {
    if (!symbolName || !carBundle) return nil;
    static NSCache *toolbarCache, *preferencesCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ toolbarCache = [NSCache new]; preferencesCache = [NSCache new]; });
    NSCache *cache = isPrefsWnd ? preferencesCache : toolbarCache;
    id cached = [cache objectForKey:symbolName];
    if (cached) return cached == NSNull.null ? nil : cached;

    if (carBundle) {
        // We can humbly assume that if our appearance bundle exists, its contents also do
        NSString* legacyGlyphName = nil;
        
        if (isPrefsWnd) {
            // Per-application override to fix any conflicting glyphs
            NSDictionary* glyphMap = BTCApplicationPrefsGlyphMap();
            legacyGlyphName = glyphMap[symbolName];
            
            // Use miscellaneous glyph map
            if (!legacyGlyphName) legacyGlyphName = prefsGlyphMap[symbolName];
        } else {
            // Standard toolbar items
            legacyGlyphName = toolbarGlyphMap[symbolName];
        }
        
        // Only proceed if we actually have a resource that we can load
        if (legacyGlyphName) {
            NSString* directory = @"/private/var/ammonia/core/tweaks/libBackToCatalina/BTC_VisualStyle.bundle/Contents/Resources/Glyphs/";
            NSString* path = [directory stringByAppendingFormat:@"%@", legacyGlyphName];
            
            NSImage* image = [[NSImage alloc] initWithContentsOfFile:path]; // first try
            if (!image) image = [[NSImage alloc] initWithContentsOfFile:legacyGlyphName]; // second try
            [image setTemplate:(!isPrefsWnd ? YES : NO)];
            
            // third and final attempt -- are we using a PNG resource from our bundle?
            if (!image) {
                image = [carBundle imageForResource:legacyGlyphName];
                [image setTemplate:NO]; // Likely NOT a template image...
            }

            if (!isPrefsWnd && ([symbolName isEqualToString:@"play.fill"] ||
                                [symbolName isEqualToString:@"pause.fill"]) && image.size.height > 15) {
                image.size = NSMakeSize(image.size.width * 15.0 / image.size.height, 15.0);
            }
            
            BTCMarkReplacementGlyph(image);
            [cache setObject:image ?: NSNull.null forKey:symbolName];
            return image;
        }
    }
    
    return NULL;
}

NSImage* GetToolbarButtonImage(NSView* view, NSImage* symbol) {
    NSString *identifier = GetSymbolName(symbol);
    if (!identifier || !carBundle || (!toolbarGlyphMap[identifier] &&
        !prefsGlyphMap[identifier] && !BTCApplicationPrefsGlyphMap()[identifier])) return symbol;
    BOOL isToolbar = ([[[view window] className] isEqualToString:@"NSToolbarFullScreenWindow"] || [view isDescendantOf:[[view window] _toolbarView]]);
    
    // We check that we're inside a toolbar view before calculating and applying our override - we don't want to replace stuff unintentionally, or do unnecessary calculations here
    if (!isToolbar) {
        return symbol;
    }
    
    BOOL isPrefsWnd = NO;
    for (NSView* potentialWidget in view.superview.superview.subviews) {
        if ([[potentialWidget className] isEqualToString:@"NSWidgetView"]) {
            isPrefsWnd = YES;
        }
    }
    
    NSImage* glyph = FindLegacyToolbarGlyph(identifier, isPrefsWnd);
    
    // Depending on whether it exists, return either our glyph, or the SF Symbol
    return glyph ? glyph : symbol;
}

CGRect CalculateToolbarImageFrame(NSView* view, NSImage* image, CGRect frame) {
    if (!BTCIsReplacementGlyph(image)) return frame;
    BOOL isSymbolImage = [image _isSymbolImage];
    BOOL isToolbar = ([[[view window] className] isEqualToString:@"NSToolbarFullScreenWindow"] || [view isDescendantOf:[[view window] _toolbarView]]);
    
    if (isSymbolImage || !isToolbar) {
        // Return unmodified frame if we are still using SF Symbols, or are not inside a toolbar
        return frame;
    }
    
    NSView* superview = view.superview;
    CGRect buttonBox = superview.bounds;
    
    BOOL isPrefsWnd = NO;
    for (NSView* potentialWidget in superview.superview.subviews) {
        if ([[potentialWidget className] isEqualToString:@"NSWidgetView"]) {
            isPrefsWnd = YES;
        }
    }
    
    double widthForCalc = isPrefsWnd ? 32 : image.size.width;
    double heightForCalc = isPrefsWnd ? widthForCalc : image.size.height;
    
    CGPoint center = CGPointMake((buttonBox.size.width / 2) - (widthForCalc / 2), floor((buttonBox.size.height / 2) - (heightForCalc / 2)));
    
    if (([superview.className containsString:@"PopUp"] || [superview.className containsString:@"PullDown"]) && [superview respondsToSelector:@selector(arrowPosition)]) {
        // calling valueForKey does not work here so we have to cast to the relevant class to check arrowPosition attribute
        NSPopUpButtonCell* button = (NSPopUpButtonCell*)superview;
        
        if (button.arrowPosition != NSPopUpNoArrow) {
            center.x = 9;
        }
    }
    
    return CGRectMake(center.x, center.y, widthForCalc, heightForCalc);
}

hook(NSSegmentItemImageView)

- (NSImage*)image {
    return GetToolbarButtonImage((NSView*)self, ZKOrig(NSImage*));
}

- (void)setFrame:(CGRect)frame {
    frame = CalculateToolbarImageFrame((NSView*)self, [self image], frame);
    return ZKOrig(void, frame);
}

- (int)_vibrancyBlendMode {
    // Fix prefs window tab icon colorization
    return 0;
}

endhook

hook(NSButtonImageView)

- (NSImage*)image {
    return GetToolbarButtonImage((NSView*)self, ZKOrig(NSImage*));
}

- (void)setFrame:(CGRect)frame {
    return ZKOrig(void, CalculateToolbarImageFrame((NSView*)self, [self image], frame));
}

- (int)_vibrancyBlendMode {
    // Fix prefs window tab icon colorization
    return 0;
}

endhook
