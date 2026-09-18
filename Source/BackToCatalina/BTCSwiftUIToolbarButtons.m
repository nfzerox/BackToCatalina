#import <AppKit/AppKit.h>
#import "ZKSwizzle.h"

static BOOL BTCSwiftUIToolbarButton(NSButton *button) {
    if (!button.bordered || button.bezelStyle != NSBezelStyleTexturedRounded) return NO;
    NSString *name = NSStringFromClass(button.class);
    if (![name containsString:@"SwiftUIAppKitButton"] && ![name containsString:@"SwiftUIPopupButton"]) return NO;
    for (NSView *view = button.superview; view; view = view.superview) {
        NSString *ancestor = NSStringFromClass(view.class);
        if ([ancestor containsString:@"ToolbarItemHostingView"]) return YES;
    }
    return NO;
}

ZKSwizzleInterfaceGroup(BTCSwiftUIButtonMetrics, NSButton, NSObject, BTCSwiftUIToolbarButtons)
@implementation BTCSwiftUIButtonMetrics
- (BOOL)_getIntrinsicArtworkSize:(NSSize *)size alignmentRectInsets:(NSEdgeInsets *)alignment
             idealContentInsets:(NSEdgeInsets *)ideal maxContentInsets:(NSEdgeInsets *)maximum {
    BOOL result = _orig(BOOL, size, alignment, ideal, maximum);
    if (result && BTCSwiftUIToolbarButton((id)self)) {
        if (size) size->width = MAX(size->width, 32);
        if (ideal) { ideal->left = MAX(ideal->left, 11); ideal->right = MAX(ideal->right, 11); }
        if (maximum) { maximum->left = MAX(maximum->left, 11); maximum->right = MAX(maximum->right, 11); }
    }
    return result;
}
endhook

ZKSwizzleInterfaceGroup(BTCSwiftUIButtonContentInsets, NSButtonAppearanceBasedVisualProvider, NSObject, BTCSwiftUIToolbarButtons)
@implementation BTCSwiftUIButtonContentInsets
- (void)idealContentInsets:(NSEdgeInsets *)ideal maximumContentInsets:(NSEdgeInsets *)maximum
                  forRect:(NSRect)rect flipped:(BOOL)flipped {
    _orig(void, ideal, maximum, rect, flipped);
    NSButton *button = ZKHookIvar(self, NSButton *, "_button");
    if (button && BTCSwiftUIToolbarButton(button)) {
        if (ideal) { ideal->left = MAX(ideal->left, 11); ideal->right = MAX(ideal->right, 11); }
        if (maximum) { maximum->left = MAX(maximum->left, 11); maximum->right = MAX(maximum->right, 11); }
    }
}
endhook
