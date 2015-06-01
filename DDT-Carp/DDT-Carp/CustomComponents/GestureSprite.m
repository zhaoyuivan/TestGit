//
//  GestureSprite.m
//  DDT-Carp
//
//  Created by Z on 15/1/13.
//  Copyright (c) 2015年 DDTown. All rights reserved.
//

#import "GestureSprite.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"

@interface GestureSprite ()<UIGestureRecognizerDelegate>
{
    NSMutableArray* _gestureArray;
}
@end

@implementation GestureSprite
-(void)addGesture:(UIGestureRecognizer* )gesture{
    if (!_gestureArray) {
        _gestureArray = [[NSMutableArray alloc] init];
    }
    gesture.delegate = self;
    [[CCDirector sharedDirector].view addGestureRecognizer:gesture];
    [_gestureArray addObject:gesture];
}

-(void)removeGesture:(UIGestureRecognizer* )gesture{
    if (!_gestureArray || !_gestureArray.count) {
        return;
    }
    [[CCDirector sharedDirector].view removeGestureRecognizer:gesture];
    [_gestureArray removeObject:gesture];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint touchPoint = [touch locationInWorld];
    NSLog(@"%d", CGRectContainsPoint(self.boundingBox, touchPoint));
    NSLog(@"rect - %@, point - %@", NSStringFromCGRect(self.boundingBox), NSStringFromCGPoint(touchPoint));
//    return CGRectContainsPoint(self.boundingBox, touchPoint);
    return [self hitTestWithWorldPos:touchPoint];
}

-(void)onExit{
    NSMutableArray* gestureArray = [[CCDirector sharedDirector].view.gestureRecognizers mutableCopy];
    [gestureArray removeObjectsInArray:_gestureArray];
    [CCDirector sharedDirector].view.gestureRecognizers = gestureArray;
    [_gestureArray removeAllObjects];
    [super onExit];
}

-(void)dealloc{
    
}

@end
