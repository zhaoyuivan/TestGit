//
//  FishSprite.h
//  DDT-Carp
//
//  Created by Z on 14/11/3.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "TouchSprite.h"

typedef enum state{
    initial = 0,
    lauched,
    over
}TouchState;

typedef enum swimDirection{
    moveToLeft = 0,
    moveToRight
}MoveDirection;

@interface FishSprite : TouchSprite
@property (nonatomic) TouchState state;
@property (nonatomic) MoveDirection direction;
@end
