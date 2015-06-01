//
//  MoveSprite.h
//  DDT-Carp
//
//  Created by Z on 14/10/31.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "CCSprite.h"

@interface MoveSprite : CCSprite
@property (nonatomic) BOOL isMoveStart;
@property (nonatomic, copy) NSString* imageName;
@property (nonatomic) BOOL randomStartPoint;
@property (nonatomic) CGPoint startPointLow;
@property (nonatomic) CGPoint startPointHigh;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) BOOL randomEndPoint;
@property (nonatomic) CGPoint endPointLow;
@property (nonatomic) CGPoint endPointHigh;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) BOOL isBezierMove;
@property (nonatomic) CGPoint bezierPoint;
@property (nonatomic) BOOL isRandomDuration;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval delayCreationTime;
@property (nonatomic) BOOL isDetroySelf;
@property (nonatomic) CGFloat endScale;
@property (nonatomic, copy) void(^cycleBlock)();
@end
