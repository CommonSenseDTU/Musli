//
//  ORKChoiceButtonView+WebCache.m
//  Musli
//
//  Created by Anders Borch on 5/11/17.
//
//

#import <objc/runtime.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "ORKChoiceButtonView+WebCache.h"
#import "ORKImageChoice+WebCache.h"

@implementation ORKChoiceButtonView (WebCache)

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(initWithImageChoice:);
        SEL swizzledSelector = @selector(initWithImageChoice_sd:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(class,
                                            originalSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Method Swizzling

- (instancetype)initWithImageChoice_sd:(ORKImageChoice *)choice {
    self = [self initWithImageChoice_sd:choice];
    if (self) {
        if (choice.selectedImageURL) {
            [self.button sd_setImageWithURL:choice.selectedImageURL forState:UIControlStateSelected];
        }
        if (choice.imageURL) {
            [self.button sd_setImageWithURL:choice.imageURL forState:UIControlStateNormal];
        }
    }
    return self;
}

@end
