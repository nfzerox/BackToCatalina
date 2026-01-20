#import <Cocoa/Cocoa.h>
#import "dobby.h"
#import "ZKSwizzle.h"

Boolean (*AlertGlassSolariumEnabledOld)();
Boolean AlertGlassSolariumEnabledNew() {
    return false;
}

__attribute__((constructor)) void InitTweak(void) {
#if !TARGET_CPU_X86_64
    DobbyHook(DobbySymbolResolver(NULL, "_NSAlertGlassSolariumEnabled"),
              AlertGlassSolariumEnabledNew,
              &AlertGlassSolariumEnabledOld);
#endif
}

hook(NSAlert)

static NSDictionary* wideAlertMetrics;
static BOOL shouldForceRegularControlSize = NO;
static NSAlert *performingSurgeryOnAlert;

- (void)_resetLayoutDone {
    _orig(void);
    int *layoutStyle = &ZKHookIvar(self, int, "_layoutStyle");
    if (layoutStyle) {
        *layoutStyle = 3;
    }
}

-(void)_buildLayoutConstraintsForMetricsAppearance:(id)arg0 views:(id)arg1 metrics:(id)arg2 title:(id)arg3 formattedMessage:(id)arg4 numButtons:(NSUInteger)arg5 hasSecond:(BOOL)arg6 {
    shouldForceRegularControlSize = YES;
    _orig(void, arg0, arg1, arg2, arg3, arg4, arg5, arg6);
    shouldForceRegularControlSize = NO;
}

- (void)_buildLayoutConstraintsForWideAppearance:(id)arg0 views:(id)arg1 metrics:(NSDictionary *)metrics title:(id)arg3 formattedMessage:(id)arg4 numButtons:(NSUInteger)arg5 hasSecond:(BOOL)arg6 {
    if (!wideAlertMetrics) {
        NSMutableDictionary *mutableMetrics = [metrics mutableCopy];
        mutableMetrics[@"TopMargin"] = @16;
        mutableMetrics[@"BelowMessageTextYSpacing"] = @18;
        mutableMetrics[@"BelowExtraViewYSpacing"] = @21;
        mutableMetrics[@"TitleToEdgeMinYSpacing"] = @16;
        mutableMetrics[@"TitleToMessageYSpacing"] = @8;
        mutableMetrics[@"ImageToTextXSpacing"] = @18;
        mutableMetrics[@"HelpButtonToEdgeYSpacing"] = @18;
        mutableMetrics[@"TopToImageViewSpacing"] = @24;
        mutableMetrics[@"BottomMargin"] = @18;

        wideAlertMetrics = mutableMetrics;
    }
    performingSurgeryOnAlert = self;
    _orig(void, arg0, arg1, wideAlertMetrics, arg3, arg4, arg5, arg6);
    performingSurgeryOnAlert = nil;
    CGFloat *minPanelWidth = &ZKHookIvar(self, CGFloat, "_minPanelWidth");
    if (minPanelWidth) {
        *minPanelWidth = 451;
    }
    NSArray *buttons = ZKHookIvar(self, NSArray *, "_buttons");
    for (NSButton *button in buttons) {
        if ([button respondsToSelector:@selector(setControlSize:)]) {
            button.controlSize = NSControlSizeRegular;
        }
    }
}

endhook

hook(NSButton)
- (void)setControlSize:(NSControlSize)controlSize {
    _orig(void, shouldForceRegularControlSize ? NSControlSizeRegular : controlSize);
}
endhook

hook(NSLayoutConstraint)
+ (NSArray<NSLayoutConstraint *> *)constraintsWithVisualFormat:(NSString *)format options:(NSLayoutFormatOptions)opts metrics:(nullable NSDictionary<NSString *, id> *)metrics views:(NSDictionary<NSString *, id> *)views {
    if (performingSurgeryOnAlert) {
        if ([format isEqualToString:@"|-[imageView(IconSize)]-(ImageToTextXSpacing)-[messageField]-|"] || [format isEqualToString:@"|-Margin-[imageView(IconSize)]-(ImageToTextXSpacing)-[messageField]-Margin-|"]) {
            format = @"|-(TopToImageViewSpacing)-[imageView(IconSize)]-(ImageToTextXSpacing)-[messageField]-Margin-|";
        } else if ([format isEqualToString:@"V:|-[imageView(IconSize)]"] || [format isEqualToString:@"V:|-Margin-[imageView(IconSize)]"]) {
            format = @"V:|-(TopMargin)-[imageView(IconSize)]";
        } else if ([format isEqualToString:@"V:[first]-|"] || [format isEqualToString:@"V:[first]-Margin-|"]) {
            format = @"V:[first]-(BottomMargin)-|";
        } else if ([format isEqualToString:@"[imageView]-(ImageToTextXSpacing)-[informationField]-|"]) {
            format = @"[imageView]-(ImageToTextXSpacing)-[informationField]-Margin-|";
        } else if ([format isEqualToString:@"|-[helpButton]"]) {
            format = @"|-Margin-[helpButton]";
        } else if ([format isEqualToString:@"[first]-|"]) {
            format = @"[first]-Margin-|";
        }
    }
    NSArray *constraints = _orig(NSArray<NSLayoutConstraint *> *, format, opts, metrics, views);
    return constraints;
}

+ (NSLayoutConstraint *)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(nullable id)view2 attribute:(NSLayoutAttribute)attr2 {
    if (performingSurgeryOnAlert) {
        if (attr1 == NSLayoutAttributeCenterY
            && relation == NSLayoutRelationEqual
            && attr2 == NSLayoutAttributeCenterY
            && view1 == ZKHookIvar(performingSurgeryOnAlert, NSImageView *, "_imageView")
            && view2 == ZKHookIvar(performingSurgeryOnAlert, NSTextField *, "_messageField")) {
            return _orig(NSLayoutConstraint *, view1, NSLayoutAttributeTop, relation, view2, NSLayoutAttributeTop);
        } else if (attr1 == NSLayoutAttributeBottom
                   && relation == NSLayoutRelationEqual
                   && attr2 == NSLayoutAttributeBottom
                   && view2 == ZKHookIvar(performingSurgeryOnAlert, NSView *, "_first")) {
            return _orig(NSLayoutConstraint *, view1, NSLayoutAttributeCenterY, relation, view2, NSLayoutAttributeCenterY);
        } else if (attr1 == NSLayoutAttributeLeading
                   && relation == NSLayoutRelationEqual
                   && attr2 == NSLayoutAttributeLeading
                   && view1 == ZKHookIvar(performingSurgeryOnAlert, NSView *, "_second")
                   && view2 == ZKHookIvar(performingSurgeryOnAlert, NSTextField *, "_messageField")) {
            return [NSLayoutConstraint constraintWithItem:view1 attribute:attr1 relatedBy:relation toItem:view2 attribute:attr2 multiplier:1 constant:-2];
        }
    }
    NSLayoutConstraint *constraint = _orig(NSLayoutConstraint *, view1, attr1, relation, view2, attr2);
    return constraint;
}

endhook
