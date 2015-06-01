//
//  ScrollViewNode.h
//  DDT-Carp
//
//  Created by Z on 15/1/5.
//  Copyright (c) 2015年 DDTown. All rights reserved.
//

#import "CCNode.h"
@class CCScrollView;

@interface ScrollViewNode : CCNode
@property (nonatomic) CGSize scrollViewSize;
@property (nonatomic, readwrite, unsafe_unretained) CCScrollView* parentScrollView;
-(CGPoint)convertPosition:(CGPoint)position;
-(CGPoint)convertBackPosition:(CGPoint)position;
@end
