//
//  BTSNSSolarium.m
//  BackToCatalina
//
//  Created by ittrgrey on 07/07/2026.
//

#import <Cocoa/Cocoa.h>
#import "dobby.h"
#include <time.h>

enum { BTCSolariumDisabled = 0, BTCSolariumCompatibility = 1, BTCSolariumEnabled = 2 };

static long (*SolariumEnablementOrig)(long idiom);
static long SolariumEnablementNew(long idiom) {
    return BTCSolariumCompatibility;
}

static bool (*SolariumIsEnabledOrig)(long idiom);
static bool SolariumIsEnabledNew(long idiom) {
    return false;
}

static bool (*SolariumIsEnabledForOrig)(long idiom);
static bool SolariumIsEnabledForNew(long idiom) {
    return false;
}

static BOOL (*NSSolariumEnabledOrig)(void);
static BOOL NSSolariumEnabledNew(void) {
    return NO;
}

static BOOL (*CUISolariumEnabledOrig)(void);
static BOOL CUISolariumEnabledNew(void) {
    return NO;
}

static void *BTCResolve(const char *image, const char *sym) {
    void *p = DobbySymbolResolver(image, sym);
    if (!p && sym[0] == '_') p = DobbySymbolResolver(image, sym + 1);
    if (!p) p = DobbySymbolResolver(NULL, sym);
    if (!p && sym[0] == '_') p = DobbySymbolResolver(NULL, sym + 1);
    return p;
}

static BOOL BTCInstall(const char *image, const char *sym, void *fake, void **orig) {
    BOOL profile = getenv("BTC_PROFILE_HOOK_INSTALL") != NULL;
    uint64_t start = profile ? clock_gettime_nsec_np(CLOCK_UPTIME_RAW) : 0;
    void *addr = BTCResolve(image, sym);
    uint64_t resolved = profile ? clock_gettime_nsec_np(CLOCK_UPTIME_RAW) : 0;
    if (!addr) {
        NSLog(@"[BTC] resolve FAILED: %s/%s", image ? image : "*", sym);
        return NO;
    }
    int rc = DobbyHook(addr, fake, orig);
    if (profile) fprintf(stderr, "BTC_INSTALL %s resolve_ms=%.3f hook_ms=%.3f\n", sym,
                         (resolved-start)/1e6, (clock_gettime_nsec_np(CLOCK_UPTIME_RAW)-resolved)/1e6);
    NSLog(@"[BTC] hook %@ %s/%s @ %p", rc == 0 ? @"OK" : @"ERR", image ? image : "*", sym, addr);
    return rc == 0;
}

__attribute__((constructor))
static void BTCSolariumInit(void) {
    BTCInstall("SwiftUICore",
               "_$s7SwiftUI8SolariumV10enablementyAC15EnablementLevelOAC0E5IdiomOFZ",
               (void *)SolariumEnablementNew, (void **)&SolariumEnablementOrig);
    BTCInstall("SwiftUICore",
               "_$s7SwiftUI8SolariumV9isEnabledySbAC15EnablementIdiomOFZ",
               (void *)SolariumIsEnabledNew, (void **)&SolariumIsEnabledOrig);
    BTCInstall("SwiftUICore",
               "_$s7SwiftUI8SolariumV9isEnabled3forSbAA17AnyInterfaceIdiomV_tFZ",
               (void *)SolariumIsEnabledForNew, (void **)&SolariumIsEnabledForOrig);

    BTCInstall("AppKit", "_NSSolariumEnabled",
               (void *)NSSolariumEnabledNew, (void **)&NSSolariumEnabledOrig);

    (void)CUISolariumEnabledNew; (void)CUISolariumEnabledOrig;

    NSLog(@"[BTC] installed for %@", NSProcessInfo.processInfo.processName);
}
