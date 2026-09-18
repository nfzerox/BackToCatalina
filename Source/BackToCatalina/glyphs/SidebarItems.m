//
//  SidebarItems.m
//  BackToCatalina
//
//  Created by ittrgrey on 29/08/2026.
//

#include "shared.h"
#include "../ZKSwizzle.h"

NSImage* FindLegacySidebarGlyph(NSString* symbolName) {
    if (!symbolName || !carBundle) return nil;
    static NSCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ cache = [NSCache new]; });
    id cached = [cache objectForKey:symbolName];
    if (cached) return cached == NSNull.null ? nil : cached;

    if (carBundle) {
        // We can humbly assume that if our appearance bundle exists, its contents also do
        NSString* legacyGlyphName = finderSidebarGlyphMap[symbolName] ?: sidebarGlyphMap[symbolName];
        if (legacyGlyphName) {
            if ([legacyGlyphName containsString:@"/"]) {
                // path likely already included
                NSImage* image = [[NSImage alloc] initWithContentsOfFile:legacyGlyphName];
                [image setTemplate:YES];
                BTCMarkReplacementGlyph(image);
                
                [cache setObject:image ?: NSNull.null forKey:symbolName];
                return image;
            } else if (legacyGlyphName) {
                // Do the same as we do for toolbar glyphs
                NSString* directory = @"/private/var/ammonia/core/tweaks/libBackToCatalina/BTC_VisualStyle.bundle/Contents/Resources/Glyphs/";
                NSString* path = [directory stringByAppendingFormat:@"%@", legacyGlyphName];
            
                NSImage* image = [[NSImage alloc] initWithContentsOfFile:path];
                [image setTemplate:YES];
                BTCMarkReplacementGlyph(image);
                
                [cache setObject:image ?: NSNull.null forKey:symbolName];
                return image;
                
            }
        }
    }
    
    return NULL;
}

BOOL IsInsideSidebarStyleList(NSView* view) {
    while (view) {
        if ([view isKindOfClass:[NSTableView class]]) {
            return ((NSTableView*)view).selectionHighlightStyle == NSTableViewSelectionHighlightStyleSourceList;
        }
        view = view.superview;
    }
    return NO;
}

NSImage* GetSidebarButtonImage(NSView* view, NSImage* symbol) {
    NSString *identifier = GetSymbolName(symbol);
    if (!identifier || !carBundle) return symbol;
    if (!IsInsideSidebarStyleList(view)) {
        // Return unmodified image if we aren't a sidebar
        return symbol;
    }

    NSImage* glyph = FindLegacySidebarGlyph(identifier);
    
    // Depending on whether it exists, return either our glyph, or the SF Symbol
    return glyph ? glyph : symbol;
}

CGRect CalculateSidebarImageFrame(NSView* view, NSImage* image, CGRect frame) {
    if (!BTCIsReplacementGlyph(image)) return frame;
    BOOL isSymbolImage = [image _isSymbolImage];
    
    if (isSymbolImage || !IsInsideSidebarStyleList(view)) {
        // Return unmodified frame if we are still using SF Symbols in this case
        return frame;
    }
    
    NSView* superview = view.superview;
    CGRect buttonBox = superview.bounds;
    
    int desiredSquare = 18;
    
    CGPoint center = CGPointMake((buttonBox.size.width / 2) - (desiredSquare / 2), (buttonBox.size.height / 2) - (desiredSquare / 2));
    
    // Return the new centered square box
    return CGRectMake(center.x, center.y, desiredSquare, desiredSquare);
}

hook(_NSImageViewSimpleImageView)

- (NSImage*)image {
    return GetSidebarButtonImage((NSView*)self, ZKOrig(NSImage*));
}

- (void)setFrame:(CGRect)frame {
    frame = CalculateSidebarImageFrame((NSView*)self, [self image], frame);
    return ZKOrig(void, frame);
}

endhook
