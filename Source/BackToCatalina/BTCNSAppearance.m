#import "BTCNSMutableArray.h"
#import "ZKSwizzle.h"
#import <AppKit/NSAccessibility.h>
#import <AppKit/NSAppearance.h>

NS_ASSUME_NONNULL_BEGIN

@class NSCompositeAppearance;

@interface NSAppearance ()
+ (NSCompositeAppearance *)_aquaAppearanceWithAccessibility:(BOOL)accessibility;
+ (NSCompositeAppearance *)_darkAquaAppearanceWithAccessibility:(BOOL)accessibility;
@end

@interface NSCompositeAppearance : NSAppearance
@property (copy) NSArray *appearances;
@property (copy) NSAppearanceName name;
- (id)initWithAppearances:(NSArray *)appearances;
@end

@interface NSBuiltinAppearance : NSAppearance
- (instancetype)initWithBundleResourceName:(NSString *)resourceName publicName:(NSString *)publicName catalystName:(NSString *)catalystName;
@end

@interface NSSystemAppearance : NSBuiltinAppearance
@end

@interface NSAccessibilitySystemAppearance : NSBuiltinAppearance
@end

@interface NSAquaAppearance : NSBuiltinAppearance
@end

@interface NSDarkAquaAppearance : NSBuiltinAppearance
@end

@interface NSVibrantLightAppearance : NSBuiltinAppearance
@end

@interface NSVibrantDarkAppearance : NSBuiltinAppearance
@end

NS_ASSUME_NONNULL_END


extern BOOL NSColorControlAccentIsGraphite(void);

static NSAccessibilitySystemAppearance *NSCachedAccessibilitySystemCatalinaAppearance(void) {
    return [[NSClassFromString(@"NSAccessibilitySystemAppearance") alloc] initWithBundleResourceName:@"Catalina/AccessibilitySystemAppearance" publicName:@"NSAppearanceNameAccessibilitySystem" catalystName:@"UIAppearanceHighContrastAny"];
}

static NSAquaAppearance *NSCachedAquaCatalinaAppearance(void) {
    return [[NSClassFromString(@"NSAquaAppearance") alloc] initWithBundleResourceName:@"Catalina/SystemAppearance" publicName:@"NSAppearanceNameAqua" catalystName:@"UIAppearanceLight"];
}

static NSAquaAppearance *NSCachedGraphiteCatalinaAppearance(void) {
    return [[NSClassFromString(@"NSAquaAppearance") alloc] initWithBundleResourceName:@"Catalina/GraphiteAppearance" publicName:@"NSAppearanceNameAqua" catalystName:@"UIAppearanceLight"];
}

static NSAquaAppearance *NSCachedAccessibilityCatalinaAppearance(void) {
    return [[NSClassFromString(@"NSAquaAppearance") alloc] initWithBundleResourceName:@"Catalina/AccessibilityAppearance" publicName:@"NSAppearanceNameAccessibilityAqua" catalystName:@"UIAppearanceHighContrastLight"];
}

static NSAquaAppearance *NSCachedAccessibilityGraphiteCatalinaAppearance(void) {
    return [[NSClassFromString(@"NSAquaAppearance") alloc] initWithBundleResourceName:@"Catalina/AccessibilityGraphiteAppearance" publicName:@"NSAppearanceNameAccessibilityAqua" catalystName:@"NSAppearanceNameAccessibilityAqua"];
}

static NSVibrantDarkAppearance *NSCachedVibrantDarkCatalinaAppearance(void) {
    return [[NSClassFromString(@"NSVibrantDarkAppearance") alloc] initWithBundleResourceName:@"Catalina/DarkAppearance" publicName:@"NSAppearanceNameVibrantDark" catalystName:@"NSAppearanceNameVibrantDark"];
}

static NSVibrantDarkAppearance *NSCachedDarkGraphiteCatalinaAppearance(void) {
    return [[NSClassFromString(@"NSVibrantDarkAppearance") alloc] initWithBundleResourceName:@"Catalina/GraphiteDarkAppearance" publicName:@"NSAppearanceNameVibrantDark" catalystName:@"NSAppearanceNameVibrantDark"];
}

static NSVibrantDarkAppearance *NSCachedAccessibilityDarkCatalinaAppearance(void) {
    return [[NSClassFromString(@"NSVibrantDarkAppearance") alloc] initWithBundleResourceName:@"Catalina/AccessibilityDarkAppearance" publicName:@"NSAppearanceNameAccessibilityVibrantDark" catalystName:@"NSAppearanceNameAccessibilityVibrantDark"];
}

static NSVibrantDarkAppearance *NSCachedAccessibilityDarkGraphiteCatalinaAppearance(void) {
    return [[NSClassFromString(@"NSVibrantDarkAppearance") alloc] initWithBundleResourceName:@"Catalina/AccessibilityDarkGraphiteAppearance" publicName:@"NSAppearanceNameAccessibilityVibrantDark" catalystName:@"NSAppearanceNameAccessibilityVibrantDark"];
}

static NSVibrantLightAppearance *NSCachedVibrantLightCatalinaAppearance(void) {
    return [[NSClassFromString(@"NSVibrantLightAppearance") alloc] initWithBundleResourceName:@"Catalina/VibrantLightAppearance" publicName:@"NSAppearanceNameVibrantLight" catalystName:@"NSAppearanceNameVibrantLight"];
}

static NSVibrantLightAppearance *NSCachedAccessibilityVibrantLightCatalinaAppearance(void) {
    return [[NSClassFromString(@"NSVibrantLightAppearance") alloc] initWithBundleResourceName:@"Catalina/AccessibilityVibrantLightAppearance" publicName:@"NSAppearanceNameAccessibilityVibrantLight" catalystName:@"NSAppearanceNameAccessibilityVibrantLight"];
}

static NSDarkAquaAppearance *NSCachedDarkAquaCatalinaAppearance(void) {
    return [[NSClassFromString(@"NSDarkAquaAppearance") alloc] initWithBundleResourceName:@"Catalina/DarkAquaAppearance" publicName:@"NSAppearanceNameDarkAqua" catalystName:@"UIAppearanceDark"];
}

static NSDarkAquaAppearance *NSCachedDarkAquaGraphiteCatalinaAppearance(void) {
    return [[NSClassFromString(@"NSDarkAquaAppearance") alloc] initWithBundleResourceName:@"Catalina/GraphiteDarkAquaAppearance" publicName:@"NSAppearanceNameDarkAqua" catalystName:@"UIAppearanceDark"];
}

static NSDarkAquaAppearance *NSCachedDarkAquaAccessibilityCatalinaAppearance(void) {
    return [[NSClassFromString(@"NSDarkAquaAppearance") alloc] initWithBundleResourceName:@"Catalina/AccessibilityDarkAquaAppearance" publicName:@"NSAppearanceNameAccessibilityDarkAqua" catalystName:@"UIAppearanceHighContrastDark"];
}

static NSDarkAquaAppearance *NSCachedDarkAquaAccessibilityGraphiteCatalinaAppearance(void) {
    return [[NSClassFromString(@"NSDarkAquaAppearance") alloc] initWithBundleResourceName:@"Catalina/AccessibilityGraphiteDarkAquaAppearance" publicName:@"NSAppearanceNameAccessibilityGraphiteDarkAqua" catalystName:@"NSAppearanceNameAccessibilityGraphiteDarkAqua"];
}

hook(NSString)
- (NSString *)stringByAppendingPathComponent:(NSString *)str {
    if (str.length == 23 && ((NSString *)self).length == 28 && [str isEqualTo:@"SystemAppearance.bundle"] && [self isEqualTo:@"/System/Library/CoreServices"]) {
        return @"/private/var/ammonia/core/tweaks/libBackToCatalina/SystemAppearance.bundle";
    }
    return _orig(NSString *, str);
}
endhook

hook(NSAppearance)

+ (NSCompositeAppearance *)_aquaAppearanceWithAccessibility:(BOOL)accessibility {
    NSCompositeAppearance *composite = _orig(NSCompositeAppearance *, accessibility);
    BOOL grpahite = NSColorControlAccentIsGraphite();
    NSMutableArray *compositeAppearances = [composite.appearances mutableCopy];
    grpahite ? [compositeAppearances btc_insertObjectToFrontOfArray:NSCachedGraphiteCatalinaAppearance()] : nil;
    if (accessibility) {
        [compositeAppearances btc_insertObjectToFrontOfArray:NSCachedAccessibilitySystemCatalinaAppearance()];
        [compositeAppearances btc_insertObjectToFrontOfArray:NSCachedAccessibilityCatalinaAppearance()];
    }
    if (grpahite && accessibility) {
        [compositeAppearances btc_insertObjectToFrontOfArray:NSCachedAccessibilityGraphiteCatalinaAppearance()];
    }
    return [[NSClassFromString(@"NSCompositeAppearance") alloc] initWithAppearances:compositeAppearances];
}

+ (NSAppearance *)_aquaAppearance {
    NSCompositeAppearance *composite = _orig(NSCompositeAppearance *);
    BOOL useAccessibility = NSWorkspace.sharedWorkspace.accessibilityDisplayShouldIncreaseContrast;
    BOOL useGraphite = NSColorControlAccentIsGraphite();
    NSMutableArray *appearances = [composite.appearances mutableCopy];
    
    [appearances btc_insertObjectToFrontOfArray:NSCachedAquaCatalinaAppearance()];
    if (useGraphite) {
        [appearances btc_insertObjectToFrontOfArray:NSCachedGraphiteCatalinaAppearance()];
    }
    if (useAccessibility) {
        [appearances btc_insertObjectToFrontOfArray:NSCachedAccessibilitySystemCatalinaAppearance()];
        [appearances btc_insertObjectToFrontOfArray:NSCachedAccessibilityCatalinaAppearance()];
    }
    if (useGraphite && useAccessibility) {
        [appearances btc_insertObjectToFrontOfArray:NSCachedAccessibilityGraphiteCatalinaAppearance()];
    }
    composite = [[NSClassFromString(@"NSCompositeAppearance") alloc] initWithAppearances:appearances];
    composite.name = @"NSAppearanceNameAqua";
    return composite;
}

+ (NSAppearance *)_vibrantDarkAppearance {
    NSCompositeAppearance *composite = _orig(NSCompositeAppearance *);
    BOOL useAccessibility = NSWorkspace.sharedWorkspace.accessibilityDisplayShouldIncreaseContrast;
    BOOL useGraphite = NSColorControlAccentIsGraphite();
    NSMutableArray *appearances = [composite.appearances mutableCopy];
    [appearances btc_insertObjectToFrontOfArray:NSCachedDarkAquaCatalinaAppearance()];
    useGraphite ? [appearances btc_insertObjectToFrontOfArray:NSCachedDarkAquaGraphiteCatalinaAppearance()] : nil;
    if (useAccessibility) {
        [appearances btc_insertObjectToFrontOfArray:NSCachedVibrantDarkCatalinaAppearance()];
        useGraphite ? [appearances btc_insertObjectToFrontOfArray:NSCachedDarkGraphiteCatalinaAppearance()] : nil;
        [appearances btc_insertObjectToFrontOfArray:NSCachedAccessibilitySystemCatalinaAppearance()];
        [appearances btc_insertObjectToFrontOfArray:NSCachedDarkAquaAccessibilityCatalinaAppearance()];
        useGraphite ? [appearances btc_insertObjectToFrontOfArray:NSCachedDarkAquaAccessibilityGraphiteCatalinaAppearance()] : nil;
        [appearances btc_insertObjectToFrontOfArray:NSCachedAccessibilityDarkCatalinaAppearance()];
        useGraphite ? [appearances btc_insertObjectToFrontOfArray:NSCachedAccessibilityDarkGraphiteCatalinaAppearance()] : nil;
    } else {
        [appearances btc_insertObjectToFrontOfArray:NSCachedVibrantDarkCatalinaAppearance()];
        useGraphite ? [appearances btc_insertObjectToFrontOfArray:NSCachedDarkGraphiteCatalinaAppearance()] : nil;
    }
    composite = [[NSClassFromString(@"NSCompositeAppearance") alloc] initWithAppearances:appearances];
    composite.name = @"NSAppearanceNameVibrantDark";
    return composite;
}

+ (NSAppearance *)_vibrantLightAppearance {
    NSCompositeAppearance *composite = _orig(NSCompositeAppearance *);
    BOOL useAccessibility = NSWorkspace.sharedWorkspace.accessibilityDisplayShouldIncreaseContrast;
    BOOL useGraphite = NSColorControlAccentIsGraphite();
    NSMutableArray *appearances = [composite.appearances mutableCopy];
    [appearances btc_insertObjectToFrontOfArray:NSCachedAquaCatalinaAppearance()];
    useGraphite ? [appearances btc_insertObjectToFrontOfArray:NSCachedGraphiteCatalinaAppearance()] : nil;
    if (useAccessibility) {
        [appearances btc_insertObjectToFrontOfArray:NSCachedAccessibilitySystemCatalinaAppearance()];
        [appearances btc_insertObjectToFrontOfArray:NSCachedAccessibilityCatalinaAppearance()];
        useGraphite ? [appearances btc_insertObjectToFrontOfArray:NSCachedAccessibilityGraphiteCatalinaAppearance()] : nil;
    }
    [appearances btc_insertObjectToFrontOfArray:NSCachedVibrantLightCatalinaAppearance()];
    useAccessibility ? [appearances btc_insertObjectToFrontOfArray:NSCachedAccessibilityVibrantLightCatalinaAppearance()] : nil;
    composite = [[NSClassFromString(@"NSCompositeAppearance") alloc] initWithAppearances:appearances];
    composite.name = @"NSAppearanceNameVibrantLight";
    return composite;
}

+ (NSAppearance *)_darkAquaAppearanceWithAccessibility:(BOOL)useAccessibility {
    NSCompositeAppearance *composite = _orig(NSCompositeAppearance *, useAccessibility);
    BOOL useGraphite = NSColorControlAccentIsGraphite();
    NSMutableArray *appearances = [composite.appearances mutableCopy];
    if (useAccessibility) {
        [appearances btc_insertObjectToFrontOfArray:NSCachedAccessibilitySystemCatalinaAppearance()];
        [appearances btc_insertObjectToFrontOfArray:NSCachedDarkAquaAccessibilityCatalinaAppearance()];
    }

    if (useGraphite) {
        [appearances btc_insertObjectToFrontOfArray:NSCachedDarkAquaGraphiteCatalinaAppearance()];
    }
    
    if (useGraphite && useAccessibility) {
        [appearances btc_insertObjectToFrontOfArray:NSCachedDarkAquaAccessibilityGraphiteCatalinaAppearance()];
    }
    return [[NSClassFromString(@"NSCompositeAppearance") alloc] initWithAppearances:appearances];
}

+ (NSAppearance *)_darkAquaAppearance {
    NSCompositeAppearance *composite = _orig(NSCompositeAppearance *);
    BOOL useAccessibility = NSWorkspace.sharedWorkspace.accessibilityDisplayShouldIncreaseContrast;
    BOOL useGraphite = NSColorControlAccentIsGraphite();
    NSMutableArray *appearances = [composite.appearances mutableCopy];
    [appearances btc_insertObjectToFrontOfArray:NSCachedDarkAquaCatalinaAppearance()];
    useGraphite ? [appearances btc_insertObjectToFrontOfArray:NSCachedDarkAquaGraphiteCatalinaAppearance()] : nil;
    if (useAccessibility) {
        [appearances btc_insertObjectToFrontOfArray:NSCachedAccessibilitySystemCatalinaAppearance()];
        [appearances btc_insertObjectToFrontOfArray:NSCachedDarkAquaAccessibilityCatalinaAppearance()];
    }
    if (useGraphite && useAccessibility) {
        [appearances btc_insertObjectToFrontOfArray:NSCachedDarkAquaAccessibilityGraphiteCatalinaAppearance()];
    }
    composite = [[NSClassFromString(@"NSCompositeAppearance") alloc] initWithAppearances:appearances];
    composite.name = @"NSAppearanceNameDarkAqua";
    return composite;
}

- (BOOL)_isBuiltinAppearance {
    return NO;
}
endhook

hook(NSBuiltinAppearance)
- (BOOL)_isBuiltinAppearance {
    return NO;
}
endhook

hook(NSCompositeAppearance)
- (BOOL)_isBuiltinAppearance {
    return NO;
}

- (BOOL)_usesMetricsAppearance {
    return NO;
}
endhook

// Customize Toolbar: show button with bezels
hook(NSVibrantDarkAppearance)

- (NSAppearance *)_appearanceForNonVibrantContent {
    return [NSAppearance appearanceNamed:@"NSAppearanceNameDarkAqua"];
}

- (BOOL)_usesMetricsAppearance {
    return NO;
}

endhook

hook(NSVibrantLightAppearance)

- (NSAppearance *)_appearanceForNonVibrantContent {
    return [NSAppearance appearanceNamed:@"NSAppearanceNameAqua"];
}

- (BOOL)_usesMetricsAppearance {
    return NO;
}

endhook

hook(NSAquaAppearance)
- (BOOL)_usesMetricsAppearance {
    return NO;
}
endhook

hook(NSDarkAquaAppearance)
- (BOOL)_usesMetricsAppearance {
    return NO;
}
endhook
