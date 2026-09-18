#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#import "dobby.h"

static BOOL BTCNoToolbarAnimation(void) { return NO; }
static void *BTCOriginalAddRemoveDecision;
static void *BTCOriginalOverflowDecision;
static void (*BTCOriginalDirectUpdates)(id, NSTimeInterval, void (^)(void));
static void (*BTCOriginalObjCUpdates)(id, SEL, NSTimeInterval, void (^)(void));

static void BTCInstantDirectUpdates(id toolbar, NSTimeInterval duration, void (^changes)(void)) {
    BTCOriginalDirectUpdates(toolbar, 0, changes);
}

static void BTCInstantObjCUpdates(id toolbar, SEL selector, NSTimeInterval duration, void (^changes)(void)) {
    BTCOriginalObjCUpdates(toolbar, selector, 0, changes);
}

static void BTCDisableToolbarDecision(const char *selector, const char *symbol, void **original) {
    Class cls = NSClassFromString(@"NSToolbarView");
    Method method = class_getInstanceMethod(cls, sel_registerName(selector));
    if (method) {
        *original = (void *)method_setImplementation(method, (IMP)BTCNoToolbarAnimation);
        return;
    }
    void *address = DobbySymbolResolver("AppKit", symbol);
    if (!address || DobbyHook(address, (void *)BTCNoToolbarAnimation, original) != 0)
        NSLog(@"[BTC] Could not disable toolbar animation: %s", symbol);
}

void BTCInstallToolbarAnimationHooks(void) {
    BTCDisableToolbarDecision("_shouldAnimateAddOrRemoveOfView:",
        "-[NSToolbarView _shouldAnimateAddOrRemoveOfView:]", &BTCOriginalAddRemoveDecision);
    BTCDisableToolbarDecision("_shouldAnimateOverflowTransitions",
        "-[NSToolbarView _shouldAnimateOverflowTransitions]", &BTCOriginalOverflowDecision);

    Method method = class_getInstanceMethod(NSToolbar.class,
        sel_registerName("animateToolbarUpdatesWithDuration:changes:"));
    if (method) {
        BTCOriginalObjCUpdates = (void *)method_setImplementation(method, (IMP)BTCInstantObjCUpdates);
    } else {
        void *address = DobbySymbolResolver("AppKit", "-[NSToolbar animateToolbarUpdatesWithDuration:changes:]");
        if (!address || DobbyHook(address, (void *)BTCInstantDirectUpdates,
                                 (void **)&BTCOriginalDirectUpdates) != 0)
            NSLog(@"[BTC] Could not disable explicit toolbar update animations");
    }
}
