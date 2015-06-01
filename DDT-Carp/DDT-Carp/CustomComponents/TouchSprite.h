//
//  TouchSprite.h
//  DDT-LightReflection
//
//  Created by Z on 14-9-9.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "CCSprite.h"

@interface TouchSprite : CCSprite
@property (nonatomic, copy) void(^touchBegan)(UITouch* touch);
@property (nonatomic, copy) void(^touchMoved)(UITouch* touch);
@property (nonatomic, copy) void(^touchEnded)(UITouch* touch);
@property (nonatomic, copy) void(^touchCanceled)(UITouch* touch);

@end
