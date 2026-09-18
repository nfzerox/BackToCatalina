#import <AppKit/AppKit.h>
#import "ZKSwizzle.h"

static void BTCUseStandardShortcutEditorBackground(NSView *root) {
    for (NSView *view in root.subviews) {
        if ([view isKindOfClass:NSVisualEffectView.class] &&
            [(NSVisualEffectView *)view material] == NSVisualEffectMaterialUnderPageBackground) {
            view.hidden = YES;
        }
    }
}

ZKSwizzleInterfaceGroup(BTCShortcutsEditorBackground, Shortcuts.EditorViewController, NSObject, BTCShortcuts)
@implementation BTCShortcutsEditorBackground

- (void)viewDidLoad {
    ZKOrig(void);
    BTCUseStandardShortcutEditorBackground([(NSViewController *)self view]);
}

- (void)viewWillAppear {
    ZKOrig(void);
    BTCUseStandardShortcutEditorBackground([(NSViewController *)self view]);
}

@end
