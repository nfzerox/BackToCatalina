#import <AppKit/AppKit.h>
#import "ZKSwizzle.h"

@interface NSView (BTCCalendarHost)
- (NSView *)contentView;
@end

static void BTCLayoutCalendarContent(NSView *host) {
    NSWindow *window = host.window;
    if (!window || (window.styleMask & NSWindowStyleMaskFullSizeContentView)) return;
    NSView *content = host.contentView;
    if (!content || content.superview != host) return;
    NSRect frame = host.bounds;
    if (!NSEqualRects(content.frame, frame)) content.frame = frame;
}

hook(CalUIFrameHostingView, BTCCalendar)
- (void)viewDidMoveToWindow {
    ZKOrig(void);
    BTCLayoutCalendarContent((NSView *)self);
}
- (void)setFrameSize:(NSSize)size {
    ZKOrig(void, size);
    BTCLayoutCalendarContent((NSView *)self);
}
- (void)addSubview:(NSView *)view {
    ZKOrig(void, view);
    BTCLayoutCalendarContent((NSView *)self);
}
endhook
