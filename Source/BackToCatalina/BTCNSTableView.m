#include "ZKSwizzle.h"

hook(NSTableView)
- (NSInteger)_resolvedSidebarType {
    return 2;
}
endhook

hook(NSTableViewStyleData)

// If NSSidebarUsesGoldenMetrics are on, it results in stuff being rounded and looking strange
// This addresses that - other differentials do however remain at the moment.

- (double)rowBackgroundInset {
    return 0;
}

- (double)cornerRadius {
    return 0;
}

- (double)rowHeight {
    return MIN(ZKOrig(double), 24);
}

endhook
