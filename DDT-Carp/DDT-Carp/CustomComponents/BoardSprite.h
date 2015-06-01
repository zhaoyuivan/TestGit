//
//  BoardSprite.h
//  DDT-Carp
//
//  Created by Z on 14/10/28.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "CCSprite.h"

@interface BoardSprite : CCSprite
@property (nonatomic, copy) NSString* titleImage;
@property (nonatomic, copy) NSString* goNextImage;
@property (nonatomic, copy) void(^beforeGoDownBlock)();
@property (nonatomic, copy) void(^afterGoDownBlock)();
+(BoardSprite* )spriteWithTitleImageString:(NSString* )titleImage andGoNextImageString:(NSString* )goNextImage;
-(void)getGoNextHandle:(BoardSprite* )boardSprite;
@end
