#import <Cocoa/Cocoa.h>
#import "ZKSwizzle.h"

@interface NSToolbarItem ()
- (NSView *)_view;
@end

@interface NSSearchToolbarItemView : NSView
@end

@interface NSToolbarItemViewer : NSView
@end

@interface NSToolbarItemGroupLayoutWrapper : NSView
@end

@interface NSToolbarItemGroupView : NSView
@end

@interface NSToolbarView : NSView
@end

@interface _NSToolbarItemViewerLabelCell : NSTextFieldCell
@end

@interface NSToolbarLabel : NSTextField
@end

hook(NSSearchToolbarItemView)

- (instancetype)initWithSearchToolbarItem:(NSSearchToolbarItem *)item {
    NSSearchToolbarItemView *view = _orig(NSSearchToolbarItemView *, item);
    view.clipsToBounds = NO;
    return self;
}

endhook

hook(_NSToolbarItemViewerLabelCell)
- (BOOL)_shouldUseStyledTextInView:(NSView *)view {
    return ((_NSToolbarItemViewerLabelCell *)self).state != NSControlStateValueOn;
}
endhook

hook(NSToolbarItemViewer)
- (instancetype)initWithItem:(NSToolbarItem *)item forToolbarView:(id)view {
    NSToolbarItemViewer *viewer = _orig(NSToolbarItemViewer *, item, view);
    viewer.clipsToBounds = NO;
    return self;
}

-(void)configureForLayoutInDisplayMode:(NSUInteger)arg0 andSizeMode:(NSUInteger)arg1 inToolbarView:(id)arg2 {
    NSToolbarItem *item = ZKHookIvar(self, NSToolbarItem *, "_item");
    // Unclip Xcode run/stop button and Safari sidebar button
    item._view.clipsToBounds = NO;
    _orig(void, arg0, arg1, arg2);
}

-(BOOL)_usesRegularSelectionWidgetSize {
    // Fix all pref window tabs being shaded
    return NO;
}
endhook

hook(NSToolbarItemGroupLayoutWrapper)
- (instancetype)initWithItem:(NSToolbarItem *)item {
    NSToolbarItemGroupLayoutWrapper *wrapper = _orig(NSToolbarItemGroupLayoutWrapper *, item);
    item._view.clipsToBounds = NO;
    wrapper.clipsToBounds = NO;
    return self;
}
endhook

hook(NSToolbarItemGroupView)
- (instancetype)initWithItem:(NSToolbarItem *)item {
    NSToolbarItemGroupView *view = _orig(NSToolbarItemGroupView *, item);
    item._view.clipsToBounds = NO;
    view.clipsToBounds = NO;
    return self;
}
endhook

hook(NSToolbarView)
- (instancetype)initWithFrame:(CGRect)frame {
    NSToolbarView *view = _orig(NSToolbarView *, frame);
    view.clipsToBounds = NO;
    return self;
}

#if 0
- (id)_sidebarTrackingAdapter {
    return nil;
}

- (id)_itemViewerThatTracksTheSidebar {
    return nil;
}

- (id)_itemViewerThatTracksTheTrailingSidebar {
    return nil;
}
#endif
endhook

#if 0
hook(NSTrackingSeparatorToolbarItem)
- (instancetype)initWithItemIdentifier:(NSToolbarItemIdentifier)identifier {
    self = _super(id, identifier);
    return self;
}
endhook
#endif

hook(NSToolbarLabel)
- (instancetype)init {
    NSToolbarLabel *orig = _orig(id);
    orig.textColor = NSColor.labelColor;
    return self;
}
endhook
