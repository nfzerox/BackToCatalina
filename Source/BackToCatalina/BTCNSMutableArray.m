#import "BTCNSMutableArray.h"

@implementation NSMutableArray (BTCCategory)

- (void)btc_insertObjectToFrontOfArray:(id)object {
    if (!object) {
        NSLog(@"=== serious issue, trying to insert nil object ===");
        return;
    }
    [self insertObject:object atIndex:0];
}

@end
