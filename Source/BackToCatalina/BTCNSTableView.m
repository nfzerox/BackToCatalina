#include <AppKit/AppKit.h>
#include "BackToCatalina.h"
#include "ZKSwizzle.h"
#include "dobby.h"

static _Thread_local NSUInteger BTCSidebarFontUpdateDepth;
static NSFont *(*BTCOriginalConvertFontWeight)(NSFont *, CGFloat);
static NSFont *BTCConvertFontWeight(NSFont *font, CGFloat weight) {
    if (BTCSidebarFontUpdateDepth && weight == NSFontWeightSemibold) return font;
    return BTCOriginalConvertFontWeight(font, weight);
}

void BTCInstallSidebarFontHook(void) {
    void *address = DobbySymbolResolver("AppKit", "_NSConvertFontToWeightIfNeeded");
    if (!address || DobbyHook(address, (void *)BTCConvertFontWeight,
                             (void **)&BTCOriginalConvertFontWeight) != 0)
        NSLog(@"[BTC] Could not suppress automatic sidebar font weight");
}

hook(NSTableView)

- (NSInteger)_resolvedSidebarType {
    return 2;
}

- (CGSize)intercellSpacing {
    CGSize orig = ZKOrig(CGSize);
    
    if (orig.width == 17 && orig.height == 0) {
        return CGSizeMake(3, 2);
    }
    
    return orig;
}

- (CGFloat)rowHeight {
    CGFloat orig = ZKOrig(CGFloat);
    
    if (orig == 24.0 && [(NSTableView*)self rowSizeStyle] == NSTableViewRowSizeStyleCustom) {
        return 17.0;
    }
    
    return orig;
}

endhook

hook(NSTableView, BTCGoldenGateSidebarFont)

- (NSDictionary *)_sourceListCellAttributesWithDefaultsForBlur:(NSDictionary *)defaults selected:(BOOL)selected emphasized:(BOOL)emphasized {
    BTCSidebarFontUpdateDepth++;
    @try { return ZKOrig(NSDictionary *, defaults, selected, emphasized); }
    @finally { BTCSidebarFontUpdateDepth--; }
}

endhook

hook(NSTableCellView, BTCGoldenGateSidebarFont)

- (void)_updateFont {
    BTCSidebarFontUpdateDepth++;
    @try { ZKOrig(void); }
    @finally { BTCSidebarFontUpdateDepth--; }
}

endhook

hook(NSTableViewStyleData)

// If NSSidebarUsesGoldenMetrics are on, it results in stuff being rounded and looking strange
// This addresses that - other differentials do however remain at the moment.

- (double)rowBackgroundInset {
    return 0;
}

- (double)cornerRadius {
    return 0;
}

endhook
