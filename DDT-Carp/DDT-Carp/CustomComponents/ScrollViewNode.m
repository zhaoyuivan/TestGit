//
//  ScrollViewNode.m
//  DDT-Carp
//
//  Created by Z on 15/1/5.
//  Copyright (c) 2015年 DDTown. All rights reserved.
//

#import "ScrollViewNode.h"

@implementation ScrollViewNode
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentSizeType = CCSizeTypeNormalized;
    }
    return self;
}

-(void) addChild: (CCNode*) child z:(NSInteger)z {
    NSAssert( child != nil, @"Argument must be non-nil");
    if (child.positionType.corner == CCPositionTypeNormalized.corner && child.positionType.xUnit == CCPositionTypeNormalized.xUnit && child.positionType.yUnit == CCPositionTypeNormalized.yUnit) {
    }
    else{
        child.positionType = CCPositionTypeNormalized;
        child.position = [self convertPosition:child.position];
        
    }
    [self addChild:child z:z name:child.name];
    [child convertPositionFromPoints:child.position type:child.positionType];
}

-(CGPoint)convertPosition:(CGPoint)position{
    return ccp(position.x/self.scrollViewSize.width, (self.scrollViewSize.height - (768 - position.y))/self.scrollViewSize.height);
}

-(CGPoint)convertBackPosition:(CGPoint)position{
    return ccp(position.x * self.scrollViewSize.width, 768 - (self.scrollViewSize.height - position.y * self.scrollViewSize.height));
}

@end
