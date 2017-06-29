//
//  ORKChoiceButtonView+WebCache.h
//  Musli
//
//  Created by Anders Borch on 5/11/17.
//
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>

@interface ORKChoiceButtonView : UIView

- (instancetype)initWithImageChoice:(ORKImageChoice *)choice;

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, copy) NSString *labelText;

@end

@interface ORKChoiceButtonView (WebCache)

+ (void)initialize;

@end
