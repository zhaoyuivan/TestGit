//
//  BubbleRise.h
//  DDT-Carp
//
//  Created by Z on 14/10/27.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "CCNode.h"

@interface BubbleRise : CCNode
@property (nonatomic) NSInteger numberOfBubbles;
@property (nonatomic) BOOL randomNumberOfBubbles;
@property (nonatomic, copy) NSString* imageName;
@property (nonatomic, copy) NSString* imageSuffixName;
@property (nonatomic) NSInteger numberOfImages;
@property (nonatomic) CGFloat riseHeight;
@property (nonatomic) NSTimeInterval riseTime;

@property (nonatomic) BOOL isDestroySelf;
@end
