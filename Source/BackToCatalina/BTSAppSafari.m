#import "BackToCatalina.h"
#import "ZKSwizzle.h"

@interface UnifiedField : NSTextField
@end

@interface CombinedSidebarTabGroupToolbarButton : NSView
@end

@interface UnifiedFieldBezelView : NSTextField
@end

@interface UnifiedFieldButtonMetrics : NSObject
@end

hook(BadgeButton)
- (BOOL)allowsVibrancy {
    return NO;
}
endhook

hook(UnifiedField)
- (CGFloat)_defaultButtonYOffset {
    return -1;
}
+ (CGFloat)urlTextYOffset {
    return -2;
}
- (CGFloat)_siteIconYOffset {
    return 4;
}
- (CGFloat)_urlTextHeight {
    return 23;
}
- (CGFloat)_urlFieldHeight {
    return 23;
}
- (CGFloat)_progressBarCornerRadius {
    NSUInteger browsingMode = ZKHookIvar(self, NSUInteger, "_browsingMode");
    if (browsingMode == 1) {
        return 4.5;
    } else {
        return 3.5;
    }
}
endhook

hook(ToolbarController)
- (UnifiedField *)_createUnifiedFieldForToolbar:(BOOL)toolbar {
    UnifiedField *field = _orig(UnifiedField *, toolbar);
    field.controlSize = NSControlSizeRegular;
    return field;
}
endhook

hook(CombinedSideBarTabGroupImageView)
- (BOOL)allowsVibrancy {
    return NO;
}
endhook

static void * ConstraintsWhenHasTitlePropertyKey = &ConstraintsWhenHasTitlePropertyKey;
static void * ConstraintWhenNoTitlePropertyKey = &ConstraintWhenNoTitlePropertyKey;

hook(CombinedSidebarTabGroupToolbarButton)
- (NSArray<NSLayoutConstraint *> *)constraintsWhenHasTitle {
    return objc_getAssociatedObject(self, ConstraintsWhenHasTitlePropertyKey);
}

- (void)setConstraintsWhenHasTitle:(NSArray<NSLayoutConstraint *> *)constraintsWhenHasTitle {
    objc_setAssociatedObject(self, ConstraintsWhenHasTitlePropertyKey, constraintsWhenHasTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSLayoutConstraint *)constraintWhenNoTitle {
    return objc_getAssociatedObject(self, ConstraintWhenNoTitlePropertyKey);
}

- (void)setConstraintWhenNoTitle:(NSLayoutConstraint *)constraintWhenNoTitle {
    objc_setAssociatedObject(self, ConstraintWhenNoTitlePropertyKey, constraintWhenNoTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)allowsVibrancy {
    return NO;
}

- (instancetype)initWithSidebarVisibility:(BOOL)visibility privateBrowsing:(BOOL)private {
    CombinedSidebarTabGroupToolbarButton *combined = _orig(CombinedSidebarTabGroupToolbarButton *, visibility, private);
    NSButton *sidebarButton = ZKHookIvar(combined, NSButton *, "_sidebarButton");
    sidebarButton.imagePosition = NSImageAbove;
    NSTextField *privateBrowsingLabel = ZKHookIvar(combined, NSTextField *, "_privateBrowsingLabel");
    privateBrowsingLabel.stringValue = [NSString stringWithFormat:@"  %@", privateBrowsingLabel.stringValue];
    privateBrowsingLabel.font = [NSFont systemFontOfSize:13];
    NSButton *tabGroupPickerButton = ZKHookIvar(combined, NSButton *, "_tabGroupPickerButton");
    tabGroupPickerButton.font = [NSFont systemFontOfSize:13];
    [self setConstraintsWhenHasTitle:@[
        [tabGroupPickerButton.widthAnchor constraintLessThanOrEqualToConstant:200],
        [tabGroupPickerButton.widthAnchor constraintGreaterThanOrEqualToConstant:17.5],
    ]];
    [self setConstraintWhenNoTitle:[tabGroupPickerButton.widthAnchor constraintEqualToConstant:15]];
    [NSLayoutConstraint activateConstraints:self.constraintsWhenHasTitle];
    return self;
}

- (void)setLocatedInSidebar:(BOOL)inSidebar {
    _orig(void, YES);
}

- (void)setTabGroupPickerButtonTitle:(NSString *)title withIcon:(id)icon {
    if (title.length) {
        title = [NSString stringWithFormat:@"  %@", title];
        [NSLayoutConstraint deactivateConstraints:@[self.constraintWhenNoTitle]];
        [NSLayoutConstraint activateConstraints:self.constraintsWhenHasTitle];
    } else {
        [NSLayoutConstraint deactivateConstraints:self.constraintsWhenHasTitle];
        [NSLayoutConstraint activateConstraints:@[self.constraintWhenNoTitle]];
    }
    _orig(void, title, icon);
}
endhook


static NSImage *_backgroundPrivateWindowCapLeft(void)
{
    return [carBundle imageForResource:@"com.apple.Safari.PrivateWindowUnifiedFieldCapLeft"];
}

static NSImage *_backgroundPrivateWindowCapRight(void)
{
    return [carBundle imageForResource:@"com.apple.Safari.PrivateWindowUnifiedFieldCapRight"];
}

static NSImage *_backgroundPrivateWindowFill(void)
{
    return [carBundle imageForResource:@"com.apple.Safari.PrivateWindowUnifiedFieldStretch"];
}

hook(UnifiedFieldBezelView)
- (void)_updateBackingMaterial {
}

- (void)_updateAppearance {
}

- (void)_setLayerBorderWidthIfNeeded:(id)arg {
}

- (void)_finishInitialization {
    UnifiedFieldBezelView *view = (UnifiedFieldBezelView *)self;
    view.editable = NO;
    view.drawsBackground = NO;
}

- (void)_drawDarkPrivateBrowsingBezel
{
    NSRect strokeRect = NSInsetRect(((UnifiedFieldBezelView *)self).bounds, 1, 1);
    strokeRect.size.height = 22;
    NSRect fillRect = NSInsetRect(strokeRect, 1, 1);
    NSBezierPath *fillPath = [NSBezierPath bezierPathWithRoundedRect:fillRect xRadius:3.75 yRadius:3.75];
    [[NSColor colorNamed:@"UnifiedFieldPrivateBrowsingBezelFillColor"] set];
    [fillPath fill];
    NSBezierPath *strokePath = [NSBezierPath bezierPathWithRoundedRect:strokeRect xRadius:3.75 yRadius:3.75];
    [strokePath setClip];
    strokePath.lineWidth = 2;
    [[NSColor colorNamed:@"UnifiedFieldPrivateBrowsingBezelStrokeColor"] set];
    [strokePath stroke];
}

- (void)drawRect:(NSRect)rect {
    UnifiedFieldBezelView *view = (UnifiedFieldBezelView *)self;
    NSRect bounds = view.bounds;
    NSUInteger browsingMode = ZKHookIvar(self, NSUInteger, "_browsingMode");
    if (browsingMode == 1) {
        if ([[view.effectiveAppearance bestMatchFromAppearancesWithNames:@[ NSAppearanceNameAqua, NSAppearanceNameDarkAqua ]] isEqualToString:NSAppearanceNameDarkAqua]) {
            [self _drawDarkPrivateBrowsingBezel];
        } else {
            NSDrawThreePartImage(bounds, _backgroundPrivateWindowCapLeft(), _backgroundPrivateWindowFill(), _backgroundPrivateWindowCapRight(), NO, NSCompositingOperationSourceOver, 1.0, view.isFlipped);
        }
    } else {
        [view.cell drawWithFrame:bounds inView:view];
    }
}
endhook

hook(UnifiedFieldButtonMetrics)
- (instancetype)initForBrowsingMode:(NSUInteger)mode {
    UnifiedFieldButtonMetrics *metrics = _orig(UnifiedFieldButtonMetrics *, mode);
    CGFloat *yOffset = &ZKHookIvar(metrics, CGFloat, "_yOffset");
    *yOffset = 0;
    return self;
}
endhook

hook(ToolbarDownloadsButton)
- (void)layout {
    _orig(void);
    NSView *progressBar = ZKHookIvar(self, NSView *, "_progressBar");
    NSRect frame = progressBar.frame;
    frame.origin.y = frame.origin.y - 5;
    progressBar.frame = frame;

}
endhook
