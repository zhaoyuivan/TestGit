//
//  GestureSprite.h
//  DDT-Carp
//
//  Created by Z on 15/1/13.
//  Copyright (c) 2015年 DDTown. All rights reserved.
//

#import "TouchSprite.h"

@interface GestureSprite : TouchSprite
-(void)addGesture:(UIGestureRecognizer* )gesture;
-(void)removeGesture:(UIGestureRecognizer* )gesture;
@end
