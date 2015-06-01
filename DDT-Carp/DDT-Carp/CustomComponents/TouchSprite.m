//
//  TouchSprite.m
//  DDT-LightReflection
//
//  Created by Z on 14-9-9.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "TouchSprite.h"

@implementation TouchSprite

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    if (self.touchBegan) {
        self.touchBegan(touch);
    }
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    if (self.touchMoved) {
        self.touchMoved(touch);
    }
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    if (self.touchEnded) {
        self.touchEnded(touch);
    }
}

-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
    if (self.touchCanceled) {
        self.touchCanceled(touch);
    }
}

-(void)onExit{
    
    [super onExit];
}

-(void)dealloc{
    self.touchBegan = nil;
    self.touchMoved = nil;
    self.touchEnded = nil;
    self.touchCanceled = nil;
}
@end

