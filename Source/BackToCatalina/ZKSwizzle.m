//
//  ZKSwizzle.m
//  ZKSwizzle
//
//  Created by Alexander S Zielenski on 7/24/14.
//  Copyright (c) 2014 Alexander S Zielenski. All rights reserved.
//

#import "ZKSwizzle.h"
static char sourceDestinationKey;

@interface NSObject (ZKSwizzle)
+ (void)_ZK_unconditionallySwizzle;
+ (BOOL)_ZK_ignoreTypes;
@end

void *ZKIvarPointer(id self, const char *name) {
    Ivar ivar = class_getInstanceVariable(object_getClass(self), name);
    return ivar == NULL ? NULL : (__bridge void *)self + ivar_getOffset(ivar);
}

static SEL destinationSelectorForSelector(SEL cmd, Class dst) {
    return NSSelectorFromString([@"_ZK_old_" stringByAppendingFormat:@"%s_%@", class_getName(dst), NSStringFromSelector(cmd)]);
}

static Class classFromInfo(const char *info) {
    const char *start = info ? strchr(info, '[') : NULL;
    const char *end = start ? strchr(++start, ' ') : NULL;
    if (!start || !end || end == start) {
        return NULL;
    }
    char *name = strndup(start, (size_t)(end - start));
    if (!name) return NULL;
    Class cls = objc_getClass(name);
    free(name);
    return cls;
}

static SEL selectorFromInfo(const char *info, SEL fallback) {
    const char *start = info ? strchr(info, '[') : NULL;
    start = start ? strchr(start, ' ') : NULL;
    const char *end = start ? strchr(++start, ']') : NULL;
    if (!start || !end || end == start) return fallback;
    char *name = strndup(start, (size_t)(end - start));
    if (!name) return fallback;
    SEL selector = sel_registerName(name);
    free(name);
    return selector;
}

// takes __PRETTY_FUNCTION__ for info which gives the name of the swizzle source class
/*
 
 We add the original implementation onto the swizzle class
 On ZKOrig, we use __PRETTY_FUNCTION__ to get the name of the swizzle class
 Then we get the implementation of that selector on the swizzle class
 Then we call it directly, passing in the correct selector and self
 
 */
static ZKIMP resolveSuper(id object, SEL sel, Class destination);

static ZKIMP resolveOriginal(id self, SEL sel, const char *info, Class cls, Class destination, SEL destSel) {
    if (sel == NULL || self == NULL || info == NULL) {
        [NSException raise:@"Invalid Arguments" format:@"One of self: %@, self: %@, or info: %s is NULL", self, NSStringFromSelector(sel), info];
        return NULL;
    }
    
    Class dest = object_getClass(self);
    
    if (cls == NULL || dest == NULL) {
        [NSException raise:@"Failed obtain class pair" format:@"src: %@ | dst: %@ | sel: %@", NSStringFromClass(cls), NSStringFromClass(dest), NSStringFromSelector(sel)];
        return NULL;
    }
    
    if (!class_respondsToSelector(dest, destSel)) {
        if (cls != [self class]) {
            // There is no implementation at this class level. Call the super implementation
            return resolveSuper(self, sel, destination);
        }
        
        [NSException raise:@"Failed to retrieve method" format:@"Got null for the source class %@ with selector %@ (%@)", NSStringFromClass(cls), NSStringFromSelector(sel), NSStringFromSelector(destSel)];
        return NULL;
    }
    
    ZKIMP implementation = (ZKIMP)class_getMethodImplementation(dest, destSel);
    if (implementation == NULL) {
        [NSException raise:@"Failed to get implementation" format:@"The objective-c runtime could not get the implementation for %@ on the class %@. There is no fix for this", NSStringFromClass(cls), NSStringFromSelector(sel)];
    }
    
    return implementation;
}

ZKIMP ZKOriginalImplementation(id self, SEL sel, const char *info) {
    sel = selectorFromInfo(info, sel);
    Class cls = classFromInfo(info);
    return resolveOriginal(self, sel, info, cls, objc_getAssociatedObject(cls, &sourceDestinationKey),
                           cls && sel ? destinationSelectorForSelector(sel, cls) : NULL);
}

static void initializeSite(ZKCallSite *site, SEL sel, const char *info) {
    dispatch_once(&site->once, ^{
        site->source = classFromInfo(info);
        site->destination = objc_getAssociatedObject(site->source, &sourceDestinationKey);
        site->selector = selectorFromInfo(info, sel);
        if (site->source) site->originalSelector = destinationSelectorForSelector(site->selector, site->source);
    });
}

ZKIMP ZKOriginalImplementationAtSite(id self, SEL sel, const char *info, ZKCallSite *site) {
    if (!self || !sel || !info || !site) return ZKOriginalImplementation(self, sel, info);
    initializeSite(site, sel, info);
    Class destination = site->destination ?: objc_getAssociatedObject(site->source, &sourceDestinationKey);
    return resolveOriginal(self, site->selector, info, site->source, destination, site->originalSelector);
}

ZKIMP ZKSuperImplementation(id object, SEL sel, const char *info) {
    sel = selectorFromInfo(info, sel);
    return resolveSuper(object, sel, objc_getAssociatedObject(classFromInfo(info), &sourceDestinationKey));
}

ZKIMP ZKSuperImplementationAtSite(id object, SEL sel, const char *info, ZKCallSite *site) {
    if (!object || !sel || !info || !site) return ZKSuperImplementation(object, sel, info);
    initializeSite(site, sel, info);
    return resolveSuper(object, site->selector, site->destination ?: objc_getAssociatedObject(site->source, &sourceDestinationKey));
}

static ZKIMP resolveSuper(id object, SEL sel, Class destination) {
    if (sel == NULL || object == NULL) {
        [NSException raise:@"Invalid Arguments" format:@"One of self: %@, self: %@ is NULL", object, NSStringFromSelector(sel)];
        return NULL;
    }
    
    Class cls = object_getClass(object);
    if (cls == NULL) {
        [NSException raise:@"Invalid Argument" format:@"Could not obtain class for the passed object"];
        return NULL;
    }
    
    // Two scenarios:
    // 1.) The superclass was not swizzled, no problem
    // 2.) The superclass was swizzled, problem
    
    // We want to return the swizzled class's superclass implementation
    // If this is a subclass of such a class, we want two behaviors:
    // a.) If this imp was also swizzled, no problem, return the superclass's swizzled imp
    // b.) This imp was not swizzled, return the class that was originally swizzled's superclass's imp
    if (destination != NULL) {
        BOOL isClassMethod = class_isMetaClass(cls);
        cls = isClassMethod ? object_getClass(destination) : destination;
    }
    
    cls = class_getSuperclass(cls);
    
    // This is a root class, it has no super class
    if (cls == NULL) {
        [NSException raise:@"Invalid Argument" format:@"Could not obtain superclass for the passed object"];
        return NULL;
    }
    
    if (!class_respondsToSelector(cls, sel)) {
        [NSException raise:@"Failed to retrieve method" format:@"We could not find the super implementation for the class %@ and selector %@, are you sure it exists?", NSStringFromClass(cls), NSStringFromSelector(sel)];
        return NULL;
    }
    
    ZKIMP implementation = (ZKIMP)class_getMethodImplementation(cls, sel);
    if (implementation == NULL) {
        [NSException raise:@"Failed to get implementation" format:@"The objective-c runtime could not get the implementation for %@ on the class %@. There is no fix for this", NSStringFromClass(cls), NSStringFromSelector(sel)];
    }
    
    return implementation;
}

static BOOL enumerateMethods(Class, Class);
BOOL _ZKSwizzle(Class src, Class dest) {
#ifdef DEBUG_DISABLE
    return NO;
#endif
    if (dest == NULL)
        return NO;
    
    NSString *destName = NSStringFromClass(dest);
    if (!destName) {
        return NO;
    }
    
    Class previousDestination = objc_getAssociatedObject(src, &sourceDestinationKey);
    if (previousDestination) {
        [NSException raise:@"Invalid Argument"
                    format:@"This source class (%@) was already swizzled with another, (%@)", NSStringFromClass(src), NSStringFromClass(previousDestination)];
        return NO;
    }
    objc_setAssociatedObject(src, &sourceDestinationKey, dest, OBJC_ASSOCIATION_ASSIGN);
    BOOL success = enumerateMethods(dest, src);
    // The above method only gets instance methods. Do the same method for the metaclass of the class
    success     &= enumerateMethods(object_getClass(dest), object_getClass(src));
    
    return success;
}

BOOL _ZKSwizzleClass(Class cls) {
    return _ZKSwizzle(cls, [cls superclass]);
}

static BOOL classIgnoresTypes(Class cls) {
    if (!class_isMetaClass(cls)) {
        cls = object_getClass(cls);
    }
    
    if (class_respondsToSelector(cls, @selector(_ZK_ignoreTypes))) {
        Class cls2 = class_createInstance(cls, 0);
        return [cls2 _ZK_ignoreTypes];
    }
    
    return NO;
}

static BOOL enumerateMethods(Class destination, Class source) {
#if OBJC_API_VERSION < 2
    [NSException raise:@"Unsupported feature" format:@"ZKSwizzle is only available in objc 2.0"];
    return NO;
    
#else
    
    unsigned int methodCount;
    Method *methodList = class_copyMethodList(source, &methodCount);
    BOOL success = YES;
    BOOL ignoreTypes = classIgnoresTypes(source);
    
    for (int i = 0; i < methodCount; i++) {
        Method method = methodList[i];
        SEL selector  = method_getName(method);
        NSString *methodName = NSStringFromSelector(selector);
        
        // Don't do anything with the unconditional swizzle
        if (sel_isEqual(selector, @selector(_ZK_unconditionallySwizzle)) ||
            sel_isEqual(selector, @selector(_ZK_ignoreTypes))) {
            continue;
        }
        
        // We only swizzle methods that are implemented
        if (class_respondsToSelector(destination, selector)) {
            Method originalMethod = class_getInstanceMethod(destination, selector);
            
            const char *originalType = method_getTypeEncoding(originalMethod);
            const char *newType = method_getTypeEncoding(method);
            if (strcmp(originalType, newType) != 0 && !ignoreTypes) {
                NSLog(@"ZKSwizzle: incompatible type encoding for %@. (expected %s, got %s)", methodName, originalType, newType);
                // Incompatible type encoding
                success = NO;
                continue;
            }
            
            Method superImp = class_getInstanceMethod(class_getSuperclass(destination), selector);
            
            if (originalMethod != superImp) {
                // We are re-adding the destination selector because it could be on a superclass and not on the class itself. This method could fail
                class_addMethod(destination, selector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
                
                SEL destSel = destinationSelectorForSelector(selector, source);
                if (!class_addMethod(destination, destSel, method_getImplementation(method), method_getTypeEncoding(originalMethod))) {
                    NSLog(@"ZKSwizzle: failed to add method %@ onto class %@ with selector %@", NSStringFromSelector(selector), NSStringFromClass(source), NSStringFromSelector(destSel));
                    success = NO;
                    continue;
                }
                
                method_exchangeImplementations(class_getInstanceMethod(destination, selector), class_getInstanceMethod(destination, destSel));
            } else {
                // If the method we are hooking is not implemented on the subclass at hook-time,
                // we want orig calls from those hooks to go to the superclass. (ZKOriginalImplementation
                //    redirects to ZKSuperImplementation when destinationSelectorForSelector() is not implemented
                //    on the target class, that, combined with the fact that ZKOrig is called from a hook, means
                //    calls should redirect to super)
                success &= class_addMethod(destination, selector, method_getImplementation(method), method_getTypeEncoding(method));
            }
            
        } else {
            // Add any extra methods to the class but don't swizzle them
            success &= class_addMethod(destination, selector, method_getImplementation(method), method_getTypeEncoding(method));
        }
    }
    
    unsigned int propertyCount;
    objc_property_t *propertyList = class_copyPropertyList(source, &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t property = propertyList[i];
        const char *name = property_getName(property);
        unsigned int attributeCount;
        objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributeCount);
        
        if (class_getProperty(destination, name) == NULL) {
            class_addProperty(destination, name, attributes, attributeCount);
        } else {
            class_replaceProperty(destination, name, attributes, attributeCount);
        }
        
        free(attributes);
    }
    
    free(propertyList);
    free(methodList);
    return success;
#endif
}

// Options were to use a group class and traverse its subclasses
// or to create a groups dictionary
// This works because +load on NSObject is called before attribute((constructor))
static NSMutableDictionary *groups = nil;
void _$ZKRegisterInterface(Class cls, const char *groupName) {
    if (!groups)
        groups = [[NSMutableDictionary dictionary] retain];
    
    NSString *groupString = @(groupName);
    NSMutableArray *groupList = groups[groupString];
    if (!groupList) {
        groupList = [NSMutableArray array];
        groups[groupString] = groupList;
    }
    
    [groupList addObject:NSStringFromClass(cls)];
}

BOOL _ZKSwizzleGroup(const char *groupName) {
    NSArray *groupList = groups[@(groupName)];
    if (!groupList) {
        [NSException raise:@"Invalid Argument" format:@"ZKSwizzle: There is no group by the name of %s", groupName];
        return NO;
    }
    
    BOOL success = YES;
    for (NSString *className in groupList) {
        Class cls = NSClassFromString(className);
        if (cls == NULL)
            continue;
        
        if (class_respondsToSelector(object_getClass(cls), @selector(_ZK_unconditionallySwizzle))) {
            [cls _ZK_unconditionallySwizzle];
        } else {
            success = NO;
        }
    }
    
    return success;
}
