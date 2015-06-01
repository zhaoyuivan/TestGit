//
//  Fireworks.h
//  DDT-LightReflection
//
//  Created by Z on 14-9-26.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "CCNode.h"

@interface Fireworks : CCNode
@property (nonatomic, copy) NSString* imageString;
@property (nonatomic, copy) NSString* imageStingSuffix;
@property (nonatomic) int imageCount;
@property (nonatomic) int fireworkNumber;
@property (nonatomic) CGFloat minScale;
@property (nonatomic) CGFloat maxScale;
@property (nonatomic) CGFloat minLifeCycle;
@property (nonatomic) CGFloat maxLifeCycle;
@property (nonatomic) BOOL isFadeToZero;
@property (nonatomic) int distance;
@end
