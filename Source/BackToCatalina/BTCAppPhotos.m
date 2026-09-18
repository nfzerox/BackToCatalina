#include <AppKit/AppKit.h>
#include "ZKSwizzle.h"
#include "BTCPhotosWindow.h"

hook(NSWindow, BTCPhotos)
- (long long)titleVisibility {
    return BTCIsPhotosMainWindow((NSWindow *)self) ? NSWindowTitleHidden : ZKOrig(long long);
}
- (void)setTitleVisibility:(NSWindowTitleVisibility)visibility {
    _orig(void, BTCIsPhotosMainWindow((NSWindow *)self) ? NSWindowTitleHidden : visibility);
}
- (void)setSubtitle:(NSString *)subtitle {
    _orig(void, BTCIsPhotosMainWindow((NSWindow *)self) ? @"" : subtitle);
}
- (NSWindowToolbarStyle)toolbarStyle {
    return BTCIsPhotosMainWindow((NSWindow *)self) ? NSWindowToolbarStyleUnifiedCompact : NSWindowToolbarStyleUnified;
}
- (void)setToolbarStyle:(NSWindowToolbarStyle)style {
    _orig(void, BTCIsPhotosMainWindow((NSWindow *)self) ? NSWindowToolbarStyleUnifiedCompact : NSWindowToolbarStyleUnified);
}
- (NSWindowToolbarStyle)_effectiveToolbarStyle {
    return BTCIsPhotosMainWindow((NSWindow *)self) ? NSWindowToolbarStyleUnifiedCompact : ZKOrig(NSWindowToolbarStyle);
}
- (void)setWindowController:(NSWindowController *)controller {
    _orig(void, controller);
    NSWindow *window = (NSWindow *)self;
    if (BTCIsPhotosMainWindow(window)) {
        window.titleVisibility = NSWindowTitleHidden;
        window.subtitle = @"";
        window.toolbarStyle = NSWindowToolbarStyleUnifiedCompact;
    }
}
endhook

hook(NSButtonCell, BTCPhotos)
- (NSAttributedString *)_currentTitle {
    NSAttributedString *attributes = ZKOrig(NSAttributedString *);
    NSView *control = [(NSButtonCell *)self controlView];
    if (![control isKindOfClass:NSButton.class]) return attributes;
    NSButton *button = (NSButton *)control;
    if (attributes && button.action == NSSelectorFromString(@"a_toggleEdit:") &&
        button.state == NSControlStateValueOn && BTCIsPhotosMainWindow(button.window)) {
        for (NSView *parent = button.superview; parent; parent = parent.superview) {
            if (![parent isKindOfClass:NSClassFromString(@"NSToolbarView")]) continue;
            NSMutableAttributedString *result = [attributes mutableCopy];
            __block NSColor *color = nil;
            [button.effectiveAppearance performAsCurrentDrawingAppearance:^{
                color = [NSColor.labelColor colorUsingColorSpace:NSColorSpace.sRGBColorSpace];
            }];
            [result addAttribute:NSForegroundColorAttributeName value:color ?: NSColor.labelColor
                           range:NSMakeRange(0, result.length)];
            return result;
        }
    }
    return attributes;
}
endhook

@interface NSObject (BTCPhotosSourceController)
- (NSViewController *)detailViewController;
- (NSEdgeInsets)zoomToFitInsets;
- (void)setZoomToFitInsets:(NSEdgeInsets)insets;
- (id)configuration;
- (void)setConfiguration:(id)configuration;
@end

static CGFloat BTCPhotosImageTopInset(NSView *view) {
    CGFloat top = view.safeAreaInsets.top;
    CGFloat scale = view.window.backingScaleFactor;
    return top > 0 && scale > 0 ? MAX(0, top - 1.0 / scale) : top;
}

hook(UXView, BTCPhotos)
- (NSEdgeInsets)computedSafeAreaInsets {
    NSEdgeInsets insets = ZKOrig(NSEdgeInsets);
    NSView *view = (NSView *)self;
    id source = view.window.contentViewController;
    if (![source isKindOfClass:NSClassFromString(@"UXSourceController")]) return insets;
    NSView *detail = [[source detailViewController] view];
    if (view.superview != detail || NSWidth(view.bounds) <= 0) return insets;

    NSRect visible = [view convertRect:detail.bounds fromView:detail];
    insets.left = MAX(insets.left, MIN(NSWidth(view.bounds), NSMinX(visible) - NSMinX(view.bounds)));
    insets.right = MAX(insets.right, MIN(NSWidth(view.bounds), NSMaxX(view.bounds) - NSMaxX(visible)));
    return insets;
}

endhook

hook(IPXCanvasItemView, BTCPhotos)
- (void)viewDidMoveToWindow {
    _orig(void);
    NSView *view = (NSView *)self;
    if (BTCIsPhotosMainWindow(view.window))
        [self setConfiguration:[self configuration]];
}
- (void)setConfiguration:(id)configuration {
    NSView *view = (NSView *)self;
    if (BTCIsPhotosMainWindow(view.window) &&
        !(view.window.styleMask & NSWindowStyleMaskFullScreen) &&
        [configuration isKindOfClass:NSClassFromString(@"IPXEditViewConfiguration")]) {
        CGFloat top = BTCPhotosImageTopInset(view);
        NSEdgeInsets insets = [configuration zoomToFitInsets];
        if (top > 0 && insets.top > top) {
            configuration = [configuration copy];
            insets.top = top;
            [configuration setZoomToFitInsets:insets];
        }
    }
    _orig(void, configuration);
}
endhook

hook(IPXViewerController, BTCPhotos)
- (NSEdgeInsets)edgeInsets {
    NSEdgeInsets insets = ZKOrig(NSEdgeInsets);
    NSView *view = [(NSViewController *)self view];
    if (BTCIsPhotosMainWindow(view.window) &&
        !(view.window.styleMask & NSWindowStyleMaskFullScreen)) {
        CGFloat top = BTCPhotosImageTopInset(view);
        if (top > 0 && insets.top > top) insets.top = top;
    }
    return insets;
}
- (NSEdgeInsets)previewEdgeInsets {
    NSEdgeInsets insets = ZKOrig(NSEdgeInsets);
    NSView *view = [(NSViewController *)self view];
    if (BTCIsPhotosMainWindow(view.window) &&
        !(view.window.styleMask & NSWindowStyleMaskFullScreen)) {
        CGFloat top = BTCPhotosImageTopInset(view);
        if (top > 0 && insets.top > top) insets.top = top;
    }
    return insets;
}
endhook
