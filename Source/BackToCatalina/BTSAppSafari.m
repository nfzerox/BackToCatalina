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

- (void)drawRect:(NSRect)rect {
    UnifiedFieldBezelView *view = (UnifiedFieldBezelView *)self;
    NSRect bounds = view.bounds;
    [view.cell drawWithFrame:bounds inView:view];
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
