#import <AppKit/AppKit.h>
#import "ZKSwizzle.h"

@interface NSObject (BTCToolbarHitContext)
- (NSEvent *)event;
- (NSPoint)point;
@end

static BOOL BTCToolbarContextClick(NSEvent *event) {
    if (!event) return NO;
    return event.type == NSEventTypeRightMouseDown ||
        (event.type == NSEventTypeLeftMouseDown &&
         (event.modifierFlags & (NSEventModifierFlagControl | NSEventModifierFlagCommand)) == NSEventModifierFlagControl);
}

static BOOL BTCToolbarBlankItem(NSToolbarItem *item) {
    return !item || [item.itemIdentifier isEqual:NSToolbarFlexibleSpaceItemIdentifier] ||
        [item.itemIdentifier isEqual:NSToolbarSpaceItemIdentifier];
}

static NSView *BTCRecoverToolbarContextHit(NSView *view, id context, NSView *hit) {
    if (hit || ![context respondsToSelector:@selector(event)] ||
        !BTCToolbarContextClick([context event])) return hit;
    if (!view.window || view.isHiddenOrHasHiddenAncestor ||
        ![context respondsToSelector:@selector(point)]) return nil;
    NSPoint point = [context point];
    if (!NSMouseInRect([view convertPoint:point fromView:nil], view.bounds, view.isFlipped)) return nil;
    for (NSView *viewer in view.subviews) {
        if (viewer.isHiddenOrHasHiddenAncestor ||
            !NSMouseInRect([viewer convertPoint:point fromView:nil], viewer.bounds, viewer.isFlipped)) continue;
        Ivar itemIvar = class_getInstanceVariable(viewer.class, "_item");
        if (!itemIvar || !BTCToolbarBlankItem(object_getIvar(viewer, itemIvar))) return nil;
    }
    return [view menuForEvent:[context event]] ? view : nil;
}

ZKSwizzleInterfaceGroup(BTCToolbarContextHitTesting, NSToolbarView, NSObject, BTCGoldenGateToolbarContextMenu)
@implementation BTCToolbarContextHitTesting
- (NSView *)hitTestForContext:(id)context {
    return BTCRecoverToolbarContextHit((id)self, context, _orig(NSView *, context));
}
endhook
