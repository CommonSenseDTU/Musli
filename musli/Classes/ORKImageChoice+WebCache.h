//
//  ORKImageChoice+WebCache.h
//  Pods
//
//  Created by Anders Borch on 5/11/17.
//
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>

@interface ORKImageChoice (WebCache)

@property (nonatomic, readonly) NSURL * _Nullable imageURL;
@property (nonatomic, readonly) NSURL * _Nullable selectedImageURL;

+ (instancetype _Nonnull)choiceWithNormalImageURL:(nullable NSURL *)normal
                                 selectedImageURL:(nullable NSURL *)selected
                                 placeHolderImage:(nullable UIImage *)placeholder
                         selectedPlaceHolderImage:(nullable UIImage *)selectedPlaceholder
                                             text:(nullable NSString *)text
                                            value:(id<NSCopying, NSCoding, NSObject> _Nullable)value;

@end
