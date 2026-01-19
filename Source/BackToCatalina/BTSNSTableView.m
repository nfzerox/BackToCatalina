#import <Cocoa/Cocoa.h>
#import "ZKSwizzle.h"

hook(NSTableView)
- (NSInteger)_resolvedSidebarType {
    return 2;
}
endhook

hook(NSSplitViewItem)
- (BOOL)allowsFullHeightLayout {
    NSSplitViewItem *item = (NSSplitViewItem *)self;
    item.allowsFullHeightLayout = NO;
    return _orig(BOOL);
}

- (void)setAllowsFullHeightLayout:(BOOL)allows {
    _orig(void, NO);
}
endhook
