//
//  FishNode.h
//  DDT-Carp
//
//  Created by Z on 14/12/9.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "CCNode.h"

@interface FishNode : CCNode
@property (nonatomic, strong) NSDictionary* fishInfo;
@property (nonatomic) BOOL allFlipX;
@property (nonatomic) BOOL isUsePhysics;
-(id)initWithFishInfo:(NSDictionary* )fishInfo;
-(id)initWithFishInfo:(NSDictionary *)fishInfo isUsePhysics:(BOOL)isPhysics;
@end
