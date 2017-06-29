//
//  ORKImageChoice+WebCache.m
//  Pods
//
//  Created by Anders Borch on 5/11/17.
//
//

#import "ORKImageChoice+WebCache.h"

@interface ORKImageChoice ()

@property (nonatomic, strong) NSURL * _Nullable imageURL;
@property (nonatomic, strong) NSURL * _Nullable selectedImageURL;

@end

@implementation ORKImageChoice (WebCache)

+ (instancetype)choiceWithNormalImageURL:(nullable NSURL *)normal
                        selectedImageURL:(nullable NSURL *)selected
                        placeHolderImage:(nullable UIImage *)placeholder
                selectedPlaceHolderImage:(nullable UIImage *)selectedPlaceholder
                                    text:(nullable NSString *)text
                                   value:(id<NSCopying, NSCoding, NSObject>)value
{
    return [[ORKImageChoice alloc] initWithNormalImageURL:normal
                                         selectedImageURL:selected
                                         placeHolderImage:placeholder
                                 selectedPlaceHolderImage:selectedPlaceholder
                                                     text:text
                                                    value:value];
}

- (instancetype)initWithNormalImageURL:(NSURL *)normal
                      selectedImageURL:(NSURL *)selected
                      placeHolderImage:(nullable UIImage *)placeholder
              selectedPlaceHolderImage:(nullable UIImage *)selectedPlaceholder
                                  text:(NSString *)text
                                 value:(id<NSCopying,NSCoding,NSObject>)value {
    self = [self initWithNormalImage:placeholder selectedImage:selectedPlaceholder
                                text:text
                               value:value];
    if (self) {
        self.imageURL = normal;
        self.selectedImageURL = selected;
    }
    return self;
}

@end
