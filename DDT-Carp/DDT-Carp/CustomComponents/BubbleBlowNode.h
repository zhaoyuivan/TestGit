//
//  BubbleBlowNode.h
//  DDT-Carp
//
//  Created by Z on 14/12/10.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "CCNode.h"

@interface BubbleBlowNode : CCNode
@property (nonatomic, strong) NSArray* imagesArray;
@property (nonatomic) BOOL isRepeat;
@property (nonatomic) CGFloat startX;
@property (nonatomic) NSRange startYRange;
@property (nonatomic) NSRange startScaleRange;
@property (nonatomic) CGFloat distance;
@property (nonatomic) CGFloat duration;
@property (nonatomic) int bubbleNum;
@end
