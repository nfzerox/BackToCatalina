#import <Cocoa/Cocoa.h>
#import "ZKSwizzle.h"

hook(NSContextMenuImpl)
- (int)_backgroundStyle {
    return 0;
}
endhook
