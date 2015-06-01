//
//  FishMoveSprite.h
//  DDT-Carp
//
//  Created by Z on 14/12/26.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "CCSprite.h"

@interface FishMoveSprite : CCSprite
@property (nonatomic) CGFloat delayTime;
@property (nonatomic) CGFloat defaultOpacity;
-(id)initWithImageNamed:(NSString *)imageName withScale:(CGFloat)scale andDelayTime:(CGFloat)delayTime;
@end
