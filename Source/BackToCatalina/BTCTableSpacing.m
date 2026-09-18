#import <AppKit/AppKit.h>
#import "ZKSwizzle.h"

@interface NSObject (BTCTableStyle)
- (BOOL)isSourceList;
@end

hook(NSTableViewStyleData)

- (CGFloat)topPadding {
    return [(id)self isSourceList] ? ZKOrig(CGFloat) : 0;
}

endhook

hook(NSTableView)

- (NSEdgeInsets)_styleInsets {
    NSEdgeInsets insets = ZKOrig(NSEdgeInsets);
    if (((NSTableView *)self).effectiveStyle != NSTableViewStyleSourceList) insets.top = 0;
    return insets;
}

- (NSEdgeInsets)_styleContentInsets {
    NSEdgeInsets insets = ZKOrig(NSEdgeInsets);
    if (((NSTableView *)self).effectiveStyle != NSTableViewStyleSourceList) insets.top = 0;
    return insets;
}

endhook

@interface NSToolbar (BTCFinderTableSpacing)
- (NSView *)_toolbarView;
@end

static void BTCAlignFinderListHeader(NSScrollView *scroll) {
    Class listClass = NSClassFromString(@"TListView");
    if (!listClass || ![scroll.documentView isKindOfClass:listClass]) return;
    NSTableView *table = (NSTableView *)scroll.documentView;
    NSWindow *window = scroll.window;
    NSToolbar *toolbar = window.toolbar;
    if (!table.headerView || !toolbar.visible ||
        ![toolbar respondsToSelector:@selector(_toolbarView)]) return;
    NSView *toolbarView = toolbar._toolbarView;
    if (!toolbarView || toolbarView.window != window || toolbarView.hidden) return;

    NSRect toolbarRect = [scroll convertRect:toolbarView.bounds fromView:toolbarView];
    CGFloat top = scroll.isFlipped ? NSMaxY(toolbarRect) - NSMinY(scroll.bounds)
        : NSMaxY(scroll.bounds) - NSMinY(toolbarRect);
    NSEdgeInsets insets = scroll.contentInsets;
    CGFloat excess = insets.top - top;
    if (top >= 0 && excess > 0.5 && excess <= 4) {
        insets.top = top;
        scroll.contentInsets = insets;
    }
}

hook(TScrollView, BTCFinderTableSpacing)

- (void)tile {
    ZKOrig(void);
    BTCAlignFinderListHeader((NSScrollView *)self);
}

endhook
