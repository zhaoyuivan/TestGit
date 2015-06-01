//
//  SparkNode.h
//  DDT-Carp
//
//  Created by Z on 14/11/2.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "CCNode.h"

typedef enum direction{
    none = 0,
    up,
    right,
    down,
    left
}ImageInitDirection;

@interface SparkNode : CCNode
@property (nonatomic, strong) NSArray* imageNamesArray;
@property (nonatomic) ImageInitDirection direction;
@property (nonatomic) CGFloat imageAngleOffset;
@property (nonatomic) CGFloat duration;
@property (nonatomic) int numberOfDirections;
@property (nonatomic) BOOL isDestroySelf;
@property (nonatomic) CGFloat distance;
@end
