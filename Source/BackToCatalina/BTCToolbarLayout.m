#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#import "ZKSwizzle.h"
#import "BTCPhotosWindow.h"

static NSString *const BTCLayoutVersion = @"BTCToolbarSpacing.v1";
static char BTCStateKey, BTCDelegateKey;

@interface NSToolbar (BTCLayoutView)
- (NSView *)_toolbarView;
- (void)_userMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
@end

@interface BTCToolbarLayoutState : NSObject
@property BOOL pending;
@property BOOL repairing;
@property BOOL handled;
@property BOOL userOwned;
@property BOOL resolvingDefaults;
@property NSUInteger mutationDepth;
@end
@implementation BTCToolbarLayoutState
@end

static BTCToolbarLayoutState *BTCState(NSToolbar *toolbar) {
    BTCToolbarLayoutState *state = objc_getAssociatedObject(toolbar, &BTCStateKey);
    if (!state) {
        state = [BTCToolbarLayoutState new];
        objc_setAssociatedObject(toolbar, &BTCStateKey, state, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return state;
}

static BOOL BTCSearchItem(NSToolbarItem *item) {
    if ([item isKindOfClass:NSSearchToolbarItem.class]) return YES;
    return [item.view isKindOfClass:NSSearchField.class];
}

static BOOL BTCHasCenteredItem(NSToolbar *toolbar, NSArray<NSString *> *identifiers) {
    if (@available(macOS 13.0, *)) {
        for (NSString *identifier in identifiers)
            if ([toolbar.centeredItemIdentifiers containsObject:identifier]) return YES;
    }
    return NO;
}

static NSArray<NSString *> *BTCFixedIdentifiers(NSArray<NSString *> *input, NSString *searchID) {
    NSMutableArray *result = [input mutableCopy];
    while ([result.firstObject isEqual:NSToolbarFlexibleSpaceItemIdentifier])
        [result removeObjectAtIndex:0];
    if (searchID && ![result containsObject:NSToolbarFlexibleSpaceItemIdentifier]) {
        NSUInteger index = [result indexOfObject:searchID];
        if (index != NSNotFound && index > 0)
            [result insertObject:NSToolbarFlexibleSpaceItemIdentifier atIndex:index];
    }
    return result;
}

static NSString *BTCMarkerKey(NSToolbar *toolbar) {
    return [BTCLayoutVersion stringByAppendingFormat:@".%@", toolbar.identifier];
}

static BOOL BTCSavedToolbar(NSToolbar *toolbar) {
    return toolbar.autosavesConfiguration && toolbar.allowsUserCustomization && toolbar.identifier.length;
}

static void BTCRepairToolbarSpacing(NSToolbar *toolbar) {
    BTCToolbarLayoutState *state = BTCState(toolbar);
    if (state.repairing || state.userOwned || toolbar.customizationPaletteIsRunning || !toolbar.items.count) return;
    BOOL saved = BTCSavedToolbar(toolbar);
    if (saved && [[NSUserDefaults standardUserDefaults] objectForKey:BTCMarkerKey(toolbar)]) return;
    if (!saved && toolbar.allowsUserCustomization && state.handled) return;
    NSArray *items = toolbar.items;
    NSArray *before = [items valueForKey:@"itemIdentifier"];
    NSString *searchID = BTCSearchItem(items.lastObject) ? [items.lastObject itemIdentifier] : nil;
    if (BTCHasCenteredItem(toolbar, before)) searchID = nil;
    NSArray *after = BTCFixedIdentifiers(before, searchID);
    if ([before isEqual:after]) return;

    NSDictionary *backup = toolbar.configurationDictionary ?: @{};
    state.repairing = YES;
    @try {
    while ([toolbar.items.firstObject.itemIdentifier isEqual:NSToolbarFlexibleSpaceItemIdentifier])
        [toolbar removeItemAtIndex:0];
    if (searchID && ![[toolbar.items valueForKey:@"itemIdentifier"] containsObject:NSToolbarFlexibleSpaceItemIdentifier]
        && toolbar.items.count > 1)
        [toolbar insertItemWithItemIdentifier:NSToolbarFlexibleSpaceItemIdentifier atIndex:toolbar.items.count - 1];
    } @finally { state.repairing = NO; }
    NSArray *actual = [toolbar.items valueForKey:@"itemIdentifier"];
    if (![actual isEqual:after]) return;
    state.handled = YES;
    if (saved) {
        [[NSUserDefaults standardUserDefaults] setObject:@{@"original":backup, @"before":before, @"applied":actual}
                                                forKey:BTCMarkerKey(toolbar)];
    }
}

static BOOL BTCSectionBoundary(NSToolbarItem *item) {
    return [item.itemIdentifier isEqual:NSToolbarSpaceItemIdentifier] ||
           [item.itemIdentifier isEqual:NSToolbarFlexibleSpaceItemIdentifier] ||
           [item isKindOfClass:NSTrackingSeparatorToolbarItem.class];
}

static NSArray<NSToolbarItem *> *BTCPhotosToolbarSections(NSArray<NSToolbarItem *> *items,
                                                         NSSet<NSString *> *centered) {
    if (!BTCSearchItem(items.lastObject)) return items;
    NSMutableArray<NSToolbarItem *> *result = [items mutableCopy];
    NSUInteger center = [result indexOfObjectPassingTest:^BOOL(NSToolbarItem *item, NSUInteger idx, BOOL *stop) {
        return [centered containsObject:item.itemIdentifier];
    }];
    if (center != NSNotFound) {
        NSUInteger start = center + 1;
        while (start < result.count && [result[start].itemIdentifier isEqual:NSToolbarFlexibleSpaceItemIdentifier]) start++;
        NSUInteger end = start;
        while (end < result.count && !BTCSectionBoundary(result[end]) && !BTCSearchItem(result[end])) end++;
        NSUInteger destination = [result indexOfObjectPassingTest:^BOOL(NSToolbarItem *item, NSUInteger idx, BOOL *stop) {
            return [item.itemIdentifier isEqual:NSToolbarFlexibleSpaceItemIdentifier];
        }];
        if (destination != NSNotFound && destination < center && start < end &&
            end < result.count && [result[end].itemIdentifier isEqual:NSToolbarSpaceItemIdentifier]) {
            NSArray *section = [result subarrayWithRange:NSMakeRange(start, end - start)];
            [result removeObjectsInRange:NSMakeRange(start, end - start)];
            [result insertObjects:section atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(destination, section.count)]];
        }
    } else {
        NSUInteger end = result.count - 1;
        NSToolbarItem *spring = nil;
        while (end > 0 && BTCSectionBoundary(result[end - 1])) {
            NSToolbarItem *item = result[--end];
            if ([item.itemIdentifier isEqual:NSToolbarFlexibleSpaceItemIdentifier]) {
                if (spring) return items;
                spring = item;
            }
        }
        NSUInteger start = end;
        while (start > 0 && !BTCSectionBoundary(result[start - 1])) start--;
        if (spring && start > 0 && start < end) {
            [result removeObjectIdenticalTo:spring];
            [result insertObject:spring atIndex:start];
        }
    }
    for (NSUInteger index = 0; index + 1 < result.count; index++) {
        NSToolbarItem *item = result[index];
        if ([item.itemIdentifier isEqual:NSToolbarFlexibleSpaceItemIdentifier]) break;
        if (![item.view isKindOfClass:NSSegmentedControl.class] ||
            [(NSSegmentedControl *)item.view segmentCount] != 2) continue;
        NSUInteger next = index + 1;
        while (next < result.count && [result[next].itemIdentifier isEqual:NSToolbarSpaceItemIdentifier]) next++;
        if (next > index + 1 && next < result.count && !BTCSectionBoundary(result[next]) &&
            !BTCSearchItem(result[next]) && ![centered containsObject:result[next].itemIdentifier])
            [result removeObjectsInRange:NSMakeRange(index + 1, next - index - 1)];
        break;
    }
    while (result.count > 1 &&
           [result[result.count - 2].itemIdentifier isEqual:NSToolbarSpaceItemIdentifier])
        [result removeObjectAtIndex:result.count - 2];
    return result;
}

static void BTCRepairToolbar(NSToolbar *toolbar) {
    BTCRepairToolbarSpacing(toolbar);
    BTCToolbarLayoutState *state = BTCState(toolbar);
    if (state.repairing || state.userOwned || toolbar.allowsUserCustomization ||
        toolbar.customizationPaletteIsRunning ||
        ![toolbar respondsToSelector:@selector(_toolbarView)] ||
        !BTCIsPhotosMainWindow([toolbar _toolbarView].window) ||
        ![toolbar respondsToSelector:@selector(_userMoveItemFromIndex:toIndex:)]) return;
    NSSet *centered = nil;
    if (@available(macOS 13.0, *)) centered = toolbar.centeredItemIdentifiers;
    else return;
    NSArray *desired = BTCPhotosToolbarSections(toolbar.items, centered);
    if ([desired isEqual:toolbar.items]) return;
    state.repairing = YES;
    @try {
        for (NSUInteger index = toolbar.items.count; index > 0; index--) {
            NSToolbarItem *item = toolbar.items[index - 1];
            if ([item.itemIdentifier isEqual:NSToolbarSpaceItemIdentifier] &&
                [desired indexOfObjectIdenticalTo:item] == NSNotFound)
                [toolbar removeItemAtIndex:index - 1];
        }
        for (NSUInteger index = 0; index < desired.count; index++) {
            NSUInteger current = [toolbar.items indexOfObjectIdenticalTo:desired[index]];
            if (current == NSNotFound) break;
            if (current != index) [toolbar _userMoveItemFromIndex:current toIndex:index];
        }
    } @finally { state.repairing = NO; }
}

static void BTCScheduleToolbar(NSToolbar *toolbar) {
    if (!toolbar || !NSThread.isMainThread) return;
    BTCToolbarLayoutState *state = BTCState(toolbar);
    if (state.repairing || state.userOwned) return;
    state.pending = YES;
    if ([toolbar respondsToSelector:@selector(_toolbarView)])
        [toolbar _toolbarView].needsLayout = YES;
}

static void BTCPrepareToolbarLayout(NSToolbar *toolbar) {
    if (!toolbar || !NSThread.isMainThread) return;
    BTCToolbarLayoutState *state = objc_getAssociatedObject(toolbar, &BTCStateKey);
    if (!state.pending || state.repairing || state.mutationDepth) return;
    state.pending = NO;
    BTCRepairToolbar(toolbar);
}

static NSString *BTCDefaultSearchID(id<NSToolbarDelegate> delegate, NSToolbar *toolbar, NSArray *ids) {
    if (BTCHasCenteredItem(toolbar, ids)) return nil;
    for (NSString *identifier in ids.reverseObjectEnumerator) {
        if ([identifier isEqual:NSToolbarFlexibleSpaceItemIdentifier] ||
            [identifier isEqual:NSToolbarSpaceItemIdentifier]) return nil;
        NSToolbarItem *item = nil;
        for (NSToolbarItem *existing in toolbar.items)
            if ([existing.itemIdentifier isEqual:identifier]) { item = existing; break; }
        if (!item && [delegate respondsToSelector:@selector(toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:)])
            item = [delegate toolbar:toolbar itemForItemIdentifier:identifier willBeInsertedIntoToolbar:NO];
        if (item) return BTCSearchItem(item) ? identifier : nil;
        if ([identifier hasPrefix:@"NSToolbar"]) return nil;
    }
    return nil;
}

static void BTCWrapDelegate(id delegate) {
    if (!delegate) return;
    Class cls = object_getClass(delegate);
    if (objc_getAssociatedObject(cls, &BTCDelegateKey)) return;
    objc_setAssociatedObject(cls, &BTCDelegateKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    SEL selector = @selector(toolbarDefaultItemIdentifiers:);
    Method method = class_getInstanceMethod(cls, selector);
    if (method) {
        IMP original = method_getImplementation(method);
        IMP wrapper = imp_implementationWithBlock(^NSArray *(id object, NSToolbar *toolbar) {
            NSArray *ids = ((id (*)(id, SEL, id))original)(object, selector, toolbar);
            if (!ids) return ids;
            NSArray *trimmed = BTCFixedIdentifiers(ids, nil);
            BTCToolbarLayoutState *state = BTCState(toolbar);
            if (state.resolvingDefaults || [trimmed containsObject:NSToolbarFlexibleSpaceItemIdentifier])
                return trimmed;
            state.resolvingDefaults = YES;
            NSString *searchID = nil;
            @try { searchID = BTCDefaultSearchID(object, toolbar, trimmed); }
            @finally { state.resolvingDefaults = NO; }
            return BTCFixedIdentifiers(trimmed, searchID);
        });
        class_replaceMethod(cls, selector, wrapper, method_getTypeEncoding(method));
    }
    SEL allowed = @selector(toolbarAllowedItemIdentifiers:);
    Method allowedMethod = class_getInstanceMethod(cls, allowed);
    if (allowedMethod) {
        IMP original = method_getImplementation(allowedMethod);
        IMP wrapper = imp_implementationWithBlock(^NSArray *(id object, NSToolbar *toolbar) {
            NSArray *ids = ((id (*)(id, SEL, id))original)(object, allowed, toolbar);
            if (!ids || [ids containsObject:NSToolbarFlexibleSpaceItemIdentifier]) return ids;
            return [ids arrayByAddingObject:NSToolbarFlexibleSpaceItemIdentifier];
        });
        class_replaceMethod(cls, allowed, wrapper, method_getTypeEncoding(allowedMethod));
    }
}

static void BTCObserveExistingToolbars(void) {
    for (NSWindow *window in NSApp.windows) {
        BTCWrapDelegate(window.toolbar.delegate);
        BTCScheduleToolbar(window.toolbar);
    }
}

__attribute__((constructor)) static void BTCInstallToolbarLayoutObservers(void) {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    for (NSNotificationName name in @[NSToolbarWillAddItemNotification, NSToolbarDidRemoveItemNotification])
        [center addObserverForName:name object:nil queue:nil usingBlock:^(NSNotification *note) {
            BTCScheduleToolbar(note.object);
        }];
    [center addObserverForName:NSApplicationDidFinishLaunchingNotification object:nil queue:NSOperationQueue.mainQueue
                  usingBlock:^(NSNotification *note) { BTCObserveExistingToolbars(); }];
    [center addObserverForName:NSWindowDidBecomeKeyNotification object:nil queue:NSOperationQueue.mainQueue
                  usingBlock:^(NSNotification *note) {
        NSToolbar *toolbar = [(NSWindow *)note.object toolbar];
        BTCWrapDelegate(toolbar.delegate);
        BTCScheduleToolbar(toolbar);
    }];
    dispatch_async(dispatch_get_main_queue(), ^{ BTCObserveExistingToolbars(); });
}

hook(NSToolbar)
- (void)setDelegate:(id)delegate {
    BTCWrapDelegate(delegate);
    _orig(void, delegate);
    BTCScheduleToolbar((NSToolbar *)self);
}
- (void)insertItemWithItemIdentifier:(NSString *)identifier atIndex:(NSInteger)index {
    BTCToolbarLayoutState *state = BTCState((NSToolbar *)self);
    state.mutationDepth++;
    @try { _orig(void, identifier, index); }
    @finally { state.mutationDepth--; }
    BTCScheduleToolbar((NSToolbar *)self);
}
- (void)removeItemAtIndex:(NSInteger)index {
    BTCToolbarLayoutState *state = BTCState((NSToolbar *)self);
    state.mutationDepth++;
    @try { _orig(void, index); }
    @finally { state.mutationDepth--; }
    BTCScheduleToolbar((NSToolbar *)self);
}
- (void)setCenteredItemIdentifiers:(NSSet<NSString *> *)identifiers {
    _orig(void, identifiers);
    BTCScheduleToolbar((NSToolbar *)self);
}
- (void)runCustomizationPalette:(id)sender {
    NSToolbar *toolbar = (NSToolbar *)self;
    BTCState(toolbar).userOwned = YES;
    if (BTCSavedToolbar(toolbar) && ![[NSUserDefaults standardUserDefaults] objectForKey:BTCMarkerKey(toolbar)])
        [[NSUserDefaults standardUserDefaults] setObject:@{@"userOwned":@YES} forKey:BTCMarkerKey(toolbar)];
    _orig(void, sender);
}
endhook

@interface NSObject (BTCToolbarLayoutView)
- (NSToolbar *)toolbar;
@end

hook(NSToolbarView)
- (void)layout {
    BTCPrepareToolbarLayout([self toolbar]);
    _orig(void);
}
endhook

hook(NSWindow)
- (void)setToolbar:(NSToolbar *)toolbar {
    BTCWrapDelegate(toolbar.delegate);
    BTCScheduleToolbar(toolbar);
    _orig(void, toolbar);
}
endhook
