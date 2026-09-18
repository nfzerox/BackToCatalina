#import <AppKit/AppKit.h>
#import "ZKSwizzle.h"

@interface NSWindow (BTCSidebarActions)
- (id)_sidebarTrackingAdapter;
- (void)toggleSidebar:(id)sender;
@end

static NSSplitViewController *BTCWindowSidebarController(NSWindow *window) {
    if (window.attachedSheet || (NSApp.modalWindow && NSApp.modalWindow != window) ||
        [window _sidebarTrackingAdapter] || !window.contentViewController) return nil;
    NSArray<NSViewController *> *level = @[window.contentViewController];
    while (level.count) {
        NSMutableArray *next = [NSMutableArray new];
        NSSplitViewController *candidate = nil;
        for (NSViewController *controller in level) {
            if (!controller.isViewLoaded || controller.view.window != window ||
                controller.view.hiddenOrHasHiddenAncestor) continue;
            if ([controller isKindOfClass:NSSplitViewController.class]) {
                NSSplitViewController *split = (id)controller;
                for (NSSplitViewItem *item in split.splitViewItems) {
                    if (item.behavior == NSSplitViewItemBehaviorSidebar && item.canCollapse) {
                        if (candidate) return nil;
                        candidate = split;
                        break;
                    }
                }
            }
            [next addObjectsFromArray:controller.childViewControllers];
        }
        if (candidate) return candidate;
        level = next;
    }
    return nil;
}

hook(NSWindow, BTCWindowSidebarActions)
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)item {
    BOOL valid = _orig(BOOL, item);
    if (valid || item.action != @selector(toggleSidebar:)) return valid;
    NSSplitViewController *controller = BTCWindowSidebarController((id)self);
    if (!controller) return valid;
    if ([(id)item isKindOfClass:NSToolbarItem.class])
        return [(id<NSToolbarItemValidation>)controller validateToolbarItem:(id)item];
    return [controller validateUserInterfaceItem:item];
}
- (void)toggleSidebar:(id)sender {
    NSSplitViewController *controller = BTCWindowSidebarController((id)self);
    if (controller) [controller toggleSidebar:sender];
    else _orig(void, sender);
}
endhook
