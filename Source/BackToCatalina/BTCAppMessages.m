#include <AppKit/AppKit.h>
#include <QuartzCore/QuartzCore.h>
#include "ZKSwizzle.h"

@protocol BTCMessagesUIKitView <NSObject>
@property(nonatomic) CGRect bounds;
@property(nonatomic) CGRect frame;
@property(nonatomic, strong) id backgroundColor;
@property(nonatomic) NSUInteger autoresizingMask;
@property(nonatomic, strong) id<BTCMessagesUIKitView> contentView;
@property(nonatomic, readonly) CALayer *layer;
- (void)addSubview:(id)view;
- (void)removeFromSuperview;
@end

@interface NSObject (BTCMessagesSplitView)
- (id)splitViewController;
- (NSInteger)splitViewControllerColumn;
- (id<BTCMessagesUIKitView>)view;
- (id<BTCMessagesUIKitView>)separatorView;
- (id)initWithEffect:(id)effect;
+ (id)_blurThroughWithStyle:(NSInteger)style;
+ (id)_splitViewBorderColor;
- (id<BTCMessagesUIKitView>)plusButton;
- (id<BTCMessagesUIKitView>)emojiButton;
- (id<BTCMessagesUIKitView>)contentClipView;
- (id)traitCollection;
- (CGFloat)displayScale;
+ (id)separatorColor;
- (id)resolvedColorWithTraitCollection:(id)traits;
- (id)viewController;
- (id)topViewController;
- (id)toolbar;
- (NSArray *)items;
- (BOOL)isToolbarHidden;
- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated;
- (id)traitOverrides;
- (void)setNSIntegerValue:(NSInteger)value forTrait:(Class)trait;
@end

@protocol BTCMessagesUIKitColor <NSObject>
@property(nonatomic, readonly) CGColorRef CGColor;
@end

static BOOL BTCMessagesPrimaryColumn(id implementation, id column) {
    return [column splitViewControllerColumn] == 0 &&
        [[implementation splitViewController] isKindOfClass:NSClassFromString(@"CKMessagesController")];
}

static char BTCMessagesSidebarEffectKey;
static char BTCMessagesSidebarColumnKey;
static char BTCMessagesSidebarContentKey;

static id BTCMessagesSidebarBlurEffect(void) {
    static id effect;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        Class effectClass = NSClassFromString(@"_UIBlurThroughEffect");
        if ([effectClass respondsToSelector:@selector(_blurThroughWithStyle:)])
            effect = [effectClass _blurThroughWithStyle:0];
    });
    return effect;
}

static NSArray *BTCMessagesToolbarIdentifiers(NSArray *identifiers) {
    NSString *compose = @"CKMacToolbarNewComposeItemIdentifier";
    NSString *divider = @"NSToolbarPrimarySidebarTrackingSeparatorItem";
    if (![identifiers containsObject:compose] || ![identifiers containsObject:divider]) return identifiers;
    NSMutableArray *result = [identifiers mutableCopy];
    [result removeObject:compose];
    while ([result.firstObject isEqual:NSToolbarFlexibleSpaceItemIdentifier]) [result removeObjectAtIndex:0];
    NSUInteger index = [result indexOfObject:divider];
    if (index > 0 && ![result[index - 1] isEqual:NSToolbarFlexibleSpaceItemIdentifier])
        [result insertObject:NSToolbarFlexibleSpaceItemIdentifier atIndex:index++];
    [result insertObject:compose atIndex:index];
    return result;
}

hook(CKMacToolbarController, BTCMessages)
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return BTCMessagesToolbarIdentifiers(_orig(NSArray *, toolbar));
}
endhook

hook(UISplitViewControllerDefaultImplProvider, BTCMessages)
- (Class)implClassForSplitViewController:(id)controller {
    Class original = _orig(Class, controller);
    Class messagesController = NSClassFromString(@"CKMessagesController");
    Class adaptive = NSClassFromString(@"_UISplitViewControllerAdaptiveImpl");
    if (original && messagesController && adaptive && [controller isKindOfClass:messagesController] &&
        original == NSClassFromString(@"UISplitViewControllerPanelImpl")) {
        return adaptive;
    }
    return original;
}
endhook

static char BTCMessagesComposerOutlineKey;

static void BTCOutlineMessagesComposer(id entry) {
    id traits = [entry traitCollection];
    Class colorClass = NSClassFromString(@"UIColor");
    if (![colorClass respondsToSelector:@selector(separatorColor)]) return;
    id color = [colorClass separatorColor];
    if ([color respondsToSelector:@selector(resolvedColorWithTraitCollection:)])
        color = [color resolvedColorWithTraitCollection:traits];
    CGColorRef borderColor = [(id<BTCMessagesUIKitColor>)color CGColor];
    CGFloat scale = MAX(1, [traits displayScale]);
    id<BTCMessagesUIKitView> views[] = {
        [entry respondsToSelector:@selector(plusButton)] ? [entry plusButton] : nil,
        [entry respondsToSelector:@selector(contentClipView)] ? [entry contentClipView] : nil,
        [entry respondsToSelector:@selector(emojiButton)] ? [entry emojiButton] : nil
    };
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    for (NSUInteger index = 0; index < sizeof(views) / sizeof(views[0]); index++) {
        id<BTCMessagesUIKitView> view = views[index];
        if (!view) continue;
        CALayer *outline = objc_getAssociatedObject(view, &BTCMessagesComposerOutlineKey);
        if (!outline) {
            outline = [CALayer layer];
            outline.name = @"BTCMessagesComposerOutline";
            [view.layer addSublayer:outline];
            objc_setAssociatedObject(view, &BTCMessagesComposerOutlineKey, outline, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        outline.frame = view.bounds;
        outline.contentsScale = scale;
        outline.borderWidth = 1;
        outline.borderColor = borderColor;
        outline.cornerRadius = MIN(15, CGRectGetHeight(view.bounds) / 2);
    }
    [CATransaction commit];
}

hook(CKMessageEntryView, BTCMessages)
- (void)layoutSubviews {
    _orig(void);
    BTCOutlineMessagesComposer(self);
}
- (void)_dynamicUserInterfaceTraitDidChange {
    _orig(void);
    BTCOutlineMessagesComposer(self);
}
endhook

hook(_UISplitViewControllerAdaptiveImpl, BTCMessages)
- (void)_layoutColumnViewForColumn:(id)column layout:(id)layout {
    BOOL primary = BTCMessagesPrimaryColumn(self, column);
    id<BTCMessagesUIKitView> view = primary ? [(NSObject *)column view] : nil;
    if (view && !objc_getAssociatedObject(view, &BTCMessagesSidebarColumnKey))
        objc_setAssociatedObject(view, &BTCMessagesSidebarColumnKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _orig(void, column, layout);
    if ([column splitViewControllerColumn] == 4 &&
        [[(NSObject *)self splitViewController] isKindOfClass:NSClassFromString(@"CKMessagesController")]) {
        id navigation = [column viewController];
        Class details = NSClassFromString(@"CommunicationDetails.DetailsViewController");
        if (details && [navigation respondsToSelector:@selector(setToolbarHidden:animated:)] &&
            [[navigation topViewController] isKindOfClass:details] &&
            ![navigation isToolbarHidden] && [[navigation toolbar] items].count == 0) {
            [navigation setToolbarHidden:YES animated:NO];
        }
    }
    if (!primary) return;
    id<BTCMessagesUIKitView> effectView = objc_getAssociatedObject(view, &BTCMessagesSidebarEffectKey);
    id<BTCMessagesUIKitView> content = view.contentView;
    if (content && content != effectView) view.contentView = content;
    view.backgroundColor = nil;
}
- (void)_layoutSeparatorViewForColumn:(id)column layout:(id)layout {
    _orig(void, column, layout);
    if (!BTCMessagesPrimaryColumn(self, column)) return;
    id<BTCMessagesUIKitView> separator = [column separatorView];
    CGRect bounds = separator.bounds;
    if (bounds.size.width == 0 && bounds.size.height > 0) {
        bounds.size.width = 1;
        separator.bounds = bounds;
    }
    Class colorClass = NSClassFromString(@"UIColor");
    if ([colorClass respondsToSelector:@selector(_splitViewBorderColor)])
        separator.backgroundColor = [colorClass _splitViewBorderColor];
}
endhook

hook(_UISplitViewControllerAdaptiveColumnView, BTCMessages)
- (void)setContentView:(id<BTCMessagesUIKitView>)content {
    if (!objc_getAssociatedObject(self, &BTCMessagesSidebarColumnKey)) {
        _orig(void, content);
        return;
    }
    id<BTCMessagesUIKitView> view = (id)self;
    id sidebarEffect = BTCMessagesSidebarBlurEffect();
    id<BTCMessagesUIKitView> effectView = objc_getAssociatedObject(view, &BTCMessagesSidebarEffectKey);
    if (!effectView && sidebarEffect) {
        effectView = [[NSClassFromString(@"UIVisualEffectView") alloc] initWithEffect:sidebarEffect];
        Class sidebarTrait = NSClassFromString(@"UITraitSemanticContext");
        if (sidebarTrait && [(NSObject *)effectView respondsToSelector:@selector(traitOverrides)]) {
            id overrides = [(NSObject *)effectView traitOverrides];
            if ([overrides respondsToSelector:@selector(setNSIntegerValue:forTrait:)])
                [overrides setNSIntegerValue:2 forTrait:sidebarTrait];
        }
        effectView.autoresizingMask = (1 << 1) | (1 << 4);
        objc_setAssociatedObject(view, &BTCMessagesSidebarEffectKey, effectView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    if (!content) {
        [objc_getAssociatedObject(self, &BTCMessagesSidebarContentKey) removeFromSuperview];
        objc_setAssociatedObject(self, &BTCMessagesSidebarContentKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        _orig(void, content);
        return;
    }
    if (!effectView || content == effectView) {
        _orig(void, content);
        return;
    }
    id<BTCMessagesUIKitView> previous = objc_getAssociatedObject(self, &BTCMessagesSidebarContentKey);
    _orig(void, effectView);
    effectView.frame = view.bounds;
    if (previous != content) {
        [previous removeFromSuperview];
        [effectView.contentView addSubview:content];
        content.autoresizingMask = (1 << 1) | (1 << 4);
        objc_setAssociatedObject(self, &BTCMessagesSidebarContentKey, content, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    content.frame = effectView.contentView.bounds;
}
endhook
