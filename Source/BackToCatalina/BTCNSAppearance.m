//
//  BTCNSAppearance.m
//  BackToCatalina
//
//  Created by ittrgrey on 13/07/2026.
//

#include "BackToCatalina.h"
#include "ZKSwizzle.h"

NS_ASSUME_NONNULL_BEGIN

@class NSCompositeAppearance;

@interface NSAppearance ()
+ (NSCompositeAppearance*)_aquaAppearanceWithAccessibility:(BOOL)accessibility;
+ (NSCompositeAppearance*)_darkAquaAppearanceWithAccessibility:(BOOL)accessibility;
@end

@interface NSCompositeAppearance : NSAppearance
@property (copy) NSArray* appearances;
@property (copy) NSAppearanceName name;
- (id)initWithAppearances:(NSArray*)appearances;
@end

NS_ASSUME_NONNULL_END

extern BOOL NSColorControlAccentIsGraphite(void);

// Declare every appearance sub-type the old system had
// Accessibility
NSAppearance* _accessibilitySystemAppearance;

// Aqua
NSAppearance* _systemAppearance;
NSAppearance* _graphiteAppearance;
NSAppearance* _accessibilityAppearance;
NSAppearance* _accessibilityGraphiteAppearance;

// Vibrant Dark
NSAppearance* _darkAppearance;
NSAppearance* _graphiteDarkAppearance;
NSAppearance* _accessibilityDarkAppearance;
NSAppearance* _accessibilityDarkGraphiteAppearance;

// Vibrant Light
NSAppearance* _vibrantLightAppearance;
NSAppearance* _accessibilityVibrantLightAppearance;

// Dark Aqua
NSAppearance* _darkAquaAppearance;
NSAppearance* _graphiteDarkAquaAppearance;
NSAppearance* _accessibilityDarkAquaAppearance;
NSAppearance* _accessibilityGraphiteDarkAquaAppearance;

// Load resources...
__attribute__((constructor)) static void InitVisualStyle(void)
{
    // Check for our bundle first because otherwise, well, if it isn't there we can safely not apply anything and carry on as before...
    if (carBundle)
    {
        _accessibilitySystemAppearance = [[NSAppearance alloc] initWithAppearanceNamed:@"AccessibilitySystemAppearance" bundle:carBundle];
        
        _systemAppearance = [[NSAppearance alloc] initWithAppearanceNamed:@"SystemAppearance" bundle:carBundle];
        _graphiteAppearance = [[NSAppearance alloc] initWithAppearanceNamed:@"GraphiteAppearance" bundle:carBundle];
        _accessibilityAppearance = [[NSAppearance alloc] initWithAppearanceNamed:@"AccessibilityAppearance" bundle:carBundle];
        _accessibilityGraphiteAppearance = [[NSAppearance alloc] initWithAppearanceNamed:@"AccessibilityGraphiteAppearance" bundle:carBundle];
    
        _darkAppearance = [[NSAppearance alloc] initWithAppearanceNamed:@"DarkAppearance" bundle:carBundle];
        _graphiteDarkAppearance = [[NSAppearance alloc] initWithAppearanceNamed:@"GraphiteDarkAppearance" bundle:carBundle];
        _accessibilityDarkAppearance = [[NSAppearance alloc] initWithAppearanceNamed:@"AccessibilityDarkAppearance" bundle:carBundle];
        _accessibilityDarkGraphiteAppearance = [[NSAppearance alloc] initWithAppearanceNamed:@"AccessibilityDarkGraphiteAppearance" bundle:carBundle];
        
        _vibrantLightAppearance = [[NSAppearance alloc] initWithAppearanceNamed:@"VibrantLightAppearance" bundle:carBundle];
        _accessibilityVibrantLightAppearance = [[NSAppearance alloc] initWithAppearanceNamed:@"AccessibilityVibrantLightAppearance" bundle:carBundle];
        
        _darkAquaAppearance = [[NSAppearance alloc] initWithAppearanceNamed:@"DarkAquaAppearance" bundle:carBundle];
        _graphiteDarkAquaAppearance = [[NSAppearance alloc] initWithAppearanceNamed:@"GraphiteDarkAquaAppearance" bundle:carBundle];
        _accessibilityDarkAquaAppearance = [[NSAppearance alloc] initWithAppearanceNamed:@"AccessibilityDarkAquaAppearance" bundle:carBundle];
        _accessibilityGraphiteDarkAquaAppearance = [[NSAppearance alloc] initWithAppearanceNamed:@"AccessibilityGraphiteDarkAquaAppearance" bundle:carBundle];
    
    }
}

#ifdef APPLY_BUNDLE
// Apply safe hooks we need (not using NSString method...)
hook(NSAppearance)

+ (NSAppearance*)_aquaAppearanceWithAccessibility:(BOOL)accessibility {
    NSCompositeAppearance* composite = _orig(NSCompositeAppearance*, accessibility);
    if (_accessibilitySystemAppearance && _accessibilityAppearance) {
        NSMutableArray* appearances = [composite.appearances mutableCopy];
        BOOL useGraphite = NSColorControlAccentIsGraphite();
        useGraphite ? [appearances insertObject:_graphiteAppearance atIndex:0] : nil;
        if (accessibility) {
            [appearances insertObject:_accessibilitySystemAppearance atIndex:0];
            [appearances insertObject:_accessibilityAppearance atIndex:0];
        }
        if (useGraphite && accessibility) {
            [appearances insertObject:_accessibilityGraphiteAppearance atIndex:0];
        }
        composite = [[NSClassFromString(@"NSCompositeAppearance") alloc] initWithAppearances:appearances];
    }
    return composite;
}

+ (NSAppearance*)_aquaAppearance {
    NSCompositeAppearance* composite = _orig(NSCompositeAppearance*);
    if (_systemAppearance) {
        NSMutableArray* appearances = [composite.appearances mutableCopy];
        BOOL useAccessibility = NSWorkspace.sharedWorkspace.accessibilityDisplayShouldIncreaseContrast;
        BOOL useGraphite = NSColorControlAccentIsGraphite();
        [appearances insertObject:_systemAppearance atIndex:0];
        
        if (useGraphite) {
            [appearances insertObject:_graphiteAppearance atIndex:0];
        }
        
        if (useAccessibility) {
            [appearances insertObject:_accessibilitySystemAppearance atIndex:0];
            [appearances insertObject:_accessibilityAppearance atIndex:0];
        }
        
        if (useGraphite && useAccessibility) {
            [appearances insertObject:_accessibilityGraphiteAppearance atIndex:0];
        }
        
        composite = [[NSClassFromString(@"NSCompositeAppearance") alloc] initWithAppearances:appearances];
        composite.name = @"NSAppearanceNameAqua";
    }
    return composite;
}

+ (NSAppearance*)_vibrantDarkAppearance {
    NSCompositeAppearance* composite = _orig(NSCompositeAppearance*);
    if (_darkAquaAppearance && _darkAppearance) {
        NSMutableArray* appearances = [composite.appearances mutableCopy];
        BOOL useAccessibility = NSWorkspace.sharedWorkspace.accessibilityDisplayShouldIncreaseContrast;
        BOOL useGraphite = NSColorControlAccentIsGraphite();
        [appearances insertObject:_darkAquaAppearance atIndex:0];
        
        if (useGraphite) {
            [appearances insertObject:_graphiteDarkAquaAppearance atIndex:0];
        }
        
        [appearances insertObject:_darkAppearance atIndex:0];
        
        if (useGraphite) {
            [appearances insertObject:_graphiteDarkAppearance atIndex:0];
        }
        
        if (useAccessibility) {
            [appearances insertObject:_accessibilitySystemAppearance atIndex:0];
            [appearances insertObject:_accessibilityDarkAquaAppearance atIndex:0];
            
            if (useGraphite) {
                [appearances insertObject:_accessibilityDarkGraphiteAppearance atIndex:0];
            }
            
            [appearances insertObject:_accessibilityDarkAppearance atIndex:0];
            
            if (useGraphite) {
                [appearances insertObject:_accessibilityDarkGraphiteAppearance atIndex:0];
            }
        }
        
        composite = [[NSClassFromString(@"NSCompositeAppearance") alloc] initWithAppearances:appearances];
        composite.name = @"NSAppearanceNameVibrantDark";
    }
    return composite;
}

+ (NSAppearance*)_vibrantLightAppearance {
    NSCompositeAppearance* composite = _orig(NSCompositeAppearance*);
    if (_systemAppearance && _vibrantLightAppearance) {
        NSMutableArray* appearances = [composite.appearances mutableCopy];
        BOOL useAccessibility = NSWorkspace.sharedWorkspace.accessibilityDisplayShouldIncreaseContrast;
        BOOL useGraphite = NSColorControlAccentIsGraphite();
        [appearances insertObject:_systemAppearance atIndex:0];
        
        if (useGraphite) {
            [appearances insertObject:_graphiteAppearance atIndex:0];
        }
        
        if (useAccessibility) {
            [appearances insertObject:_accessibilitySystemAppearance atIndex:0];
            [appearances insertObject:_accessibilityAppearance atIndex:0];
            
            if (useGraphite) {
                [appearances insertObject:_accessibilityGraphiteAppearance atIndex:0];
            }
        } else {
            [appearances insertObject:_vibrantLightAppearance atIndex:0];
        }
        
        composite = [[NSClassFromString(@"NSCompositeAppearance") alloc] initWithAppearances:appearances];
        composite.name = @"NSAppearanceNameVibrantLight";
    }
    return composite;
}

+ (NSAppearance*)_darkAquaAppearanceWithAccessibility:(BOOL)accessibility {
    NSCompositeAppearance* composite = _orig(NSCompositeAppearance*, accessibility);
    if (_accessibilitySystemAppearance && _accessibilityAppearance) {
        NSMutableArray* appearances = [composite.appearances mutableCopy];
        BOOL useGraphite = NSColorControlAccentIsGraphite();
        useGraphite ? [appearances insertObject:_graphiteAppearance atIndex:0] : nil;
        
        if (accessibility) {
            [appearances insertObject:_accessibilitySystemAppearance atIndex:0];
            [appearances insertObject:_accessibilityDarkAquaAppearance atIndex:0];
        }
        
        if (useGraphite) {
            [appearances insertObject:_graphiteDarkAquaAppearance atIndex:0];
        }
        
        if (useGraphite && accessibility) {
            [appearances insertObject:_accessibilityGraphiteDarkAquaAppearance atIndex:0];
        }
        
        composite = [[NSClassFromString(@"NSCompositeAppearance") alloc] initWithAppearances:appearances];
    }
    return composite;
}

+ (NSAppearance*)_darkAquaAppearance {
    NSCompositeAppearance* composite = _orig(NSCompositeAppearance*);
    if (_darkAquaAppearance) {
        NSMutableArray* appearances = [composite.appearances mutableCopy];
        BOOL useGraphite = NSColorControlAccentIsGraphite();
        [appearances insertObject:_darkAquaAppearance atIndex:0];
        
        if (useGraphite) {
            [appearances insertObject:_graphiteDarkAquaAppearance atIndex:0];
        }
        
        composite = [[NSClassFromString(@"NSCompositeAppearance") alloc] initWithAppearances:appearances];
        composite.name = @"NSAppearanceNameDarkAqua";
    }
    return composite;
}

// These fix toolbar buttons being translucent in some places... Bizarre but okay
+ (NSAppearance*)_fauxVibrantDarkAppearance {
    return [self _vibrantDarkAppearance];
}

+ (NSAppearance*)_fauxVibrantLightAppearance {
    return [self _vibrantLightAppearance];
}

// Disabling this value reverts older-style controls (i.e. NSButton) that existed before macOS 11 to the colouring used in versions 10.10 to 10.13
// Documented here incase it is needed by anyone in the future
//- (BOOL)_allowsSystemControlTintColors {
//    return YES;
//}

endhook
#endif

// A back-stop: Even if solarium is somehow switched on system-wide, we will disable it for all applications on our end...
static BOOL IsSolariumEnabled(void) {
    return NO;
}

// https://stackoverflow.com/questions/51672124/how-can-dark-mode-be-detected-on-macos-10-14
BOOL currentAppearanceIsDark(void)
{
    NSAppearance* appearance = NSApplication.sharedApplication.effectiveAppearance;
    NSAppearanceName basicAppearance = [appearance bestMatchFromAppearancesWithNames:@[
        NSAppearanceNameAqua,
        NSAppearanceNameDarkAqua
    ]];
    
    return [basicAppearance isEqualToString:NSAppearanceNameDarkAqua];
}

hook(NSCompositeAppearance)

- (NSAppearance*)_appearanceForVibrantContent {
    // Control Center and Spotlight are deterministic based on the wallpaper - let them do their own thing
    // Clock app toolbar is meant to be dark at all times
    if ([NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.controlcenter"] ||
        [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.Spotlight"] ||
        [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.clock"]) return ZKOrig(NSAppearance*);
    
    return currentAppearanceIsDark() ? [NSAppearance appearanceNamed:@"NSAppearanceNameVibrantDark"] : [NSAppearance appearanceNamed:@"NSAppearanceNameVibrantLight"];
}

- (NSAppearance*)_appearanceForNonVibrantContent {
    // Control Center and Spotlight are deterministic based on the wallpaper - let them do their own thing
    // Clock app toolbar is meant to be dark at all times
    if ([NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.controlcenter"] ||
        [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.Spotlight"] ||
        [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.clock"]) return ZKOrig(NSAppearance*);
    
    return currentAppearanceIsDark() ? [NSAppearance appearanceNamed:@"NSAppearanceNameDarkAqua"] : [NSAppearance appearanceNamed:@"NSAppearanceNameAqua"];
}

- (BOOL)_usesMetricsAppearance {
    return NO;
}

- (BOOL)_wantsSolarium {
    return IsSolariumEnabled();
}

endhook

// Customize Toolbar: show button with bezels
hook(NSVibrantDarkAppearance)

- (NSAppearance*)_appearanceForVibrantContent {
    return [NSAppearance appearanceNamed:@"NSAppearanceNameVibrantDark"];
}

- (NSAppearance*)_appearanceForNonVibrantContent {
    return [NSAppearance appearanceNamed:@"NSAppearanceNameDarkAqua"];
}

- (BOOL)_usesMetricsAppearance {
    return NO;
}

- (BOOL)_wantsSolarium {
    return IsSolariumEnabled();
}

endhook

hook(NSVibrantLightAppearance)

- (NSAppearance*)_appearanceForVibrantContent {
    return [NSAppearance appearanceNamed:@"NSAppearanceNameVibrantLight"];
}

- (NSAppearance*)_appearanceForNonVibrantContent {
    return [NSAppearance appearanceNamed:@"NSAppearanceNameAqua"];
}

- (BOOL)_usesMetricsAppearance {
    return NO;
}

- (BOOL)_wantsSolarium {
    return IsSolariumEnabled();
}

endhook

hook(NSAquaAppearance)

- (NSAppearance*)_appearanceForVibrantContent {
    return [NSAppearance appearanceNamed:@"NSAppearanceNameVibrantLight"];
}

- (NSAppearance*)_appearanceForNonVibrantContent {
    return [NSAppearance appearanceNamed:@"NSAppearanceNameAqua"];
}

- (BOOL)_usesMetricsAppearance {
    return NO;
}

- (BOOL)_wantsSolarium {
    return IsSolariumEnabled();
}

endhook

hook(NSDarkAquaAppearance)

- (NSAppearance*)_appearanceForVibrantContent {
    return [NSAppearance appearanceNamed:@"NSAppearanceNameVibrantDark"];
}

- (NSAppearance*)_appearanceForNonVibrantContent {
    return [NSAppearance appearanceNamed:@"NSAppearanceNameDarkAqua"];
}

- (BOOL)_usesMetricsAppearance {
    return NO;
}

- (BOOL)_wantsSolarium {
    return IsSolariumEnabled();
}

endhook

