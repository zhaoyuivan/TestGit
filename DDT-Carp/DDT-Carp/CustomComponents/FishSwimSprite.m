//
//  FishSwimSprite.m
//  DDT-Carp
//
//  Created by Z on 14/12/31.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "FishSwimSprite.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"
#import "CCAnimation+Helper.h"
#import "ScrollViewNode.h"

#define MAXBEZIERMOVENUM 5
#define MINSWIMTIME 15

@interface FishSwimSprite ()
{
    NSString* _imageName;
    BOOL _isMoving;
}
@end

@implementation FishSwimSprite
-(void)update:(CCTime)delta{
    CGPoint point = _isNeedConvertPosition ? [(ScrollViewNode* )self.parent convertBackPosition:self.position] : self.position;
    if (point.x > self.contentSize.width/2 + 1024 || point.x < -self.contentSize.width/2) {
        [self newMoveRandomY:YES];
    }
}

-(id)initWithImageNamed:(NSString *)imageName andSwimRect:(CGRect)swimRange{
    return [self initWithImageNamed:imageName andSwimRect:swimRange andFaceTo:left andSpecies:carp];
}

-(id)initWithImageNamed:(NSString *)imageName andSwimRect:(CGRect)swimRange andFaceTo:(FaceTo)direction{
    return [self initWithImageNamed:imageName andSwimRect:swimRange andFaceTo:direction andSpecies:carp];
}

-(id)initWithImageNamed:(NSString *)imageName andSwimRect:(CGRect)swimRange andFaceTo:(FaceTo)direction andSpecies:(FishSpecies)species{
    _swimRange = swimRange;
    _direction = direction;
    _bezierMoveCount = -1;
    _isLockBezierMoveCount = NO;
    _species = species;
    _isCrashing = NO;
    _imageName = imageName;
    _showAnimation = NO;
    _isNeedConvertPosition = NO;
//
    _isMoving = NO;
    return [self initWithImageNamed:imageName];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    if (self.touchBegan) {
        self.touchBegan(touch);
    }
    else{
        self.userInteractionEnabled = NO;
        self.touchBeganPosition = self.position;
        [self stopAllActions];
        self.flipX = !self.flipX;
        [self flipChildren];
        _isFlipX = _direction == left ? self.flipX : !self.flipX;
    }
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    if (self.touchMoved) {
        self.touchMoved(touch);
    }
    else{
        [self stopAllActions];
        if (_isNeedConvertPosition) {
            CCScrollView* scrollView = [(ScrollViewNode* )self.parent parentScrollView];
            CGPoint touchPosition = ccpSub([touch locationInWorld], scrollView.scrollPosition);
            self.position = [(ScrollViewNode* )self.parent convertPosition:touchPosition];
//            if ([touch locationInWorld].y < 50.f){
//            
//                [scrollView setScrollPosition:ccp(0, MIN([(ScrollViewNode* )self.parent scrollViewSize].height - 768, scrollView.position.y + 100.f)) animated:YES];
//            }
//            else if([touch locationInWorld].y > 718.f) {
//                [scrollView setScrollPosition:ccp(0, MAX(0, scrollView.position.y - 100.f)) animated:YES];
//            }
        }
        else
            self.position = [touch locationInWorld];
    }
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    if (self.touchEnded) {
        self.touchEnded(touch);
    }
    else{
        self.userInteractionEnabled = YES;
        CGRect rect = self.swimRange;
        CGPoint position = self.position;
        if (_isNeedConvertPosition) {
            CCScrollView* scrollView = [(ScrollViewNode* )self.parent parentScrollView];
            if(self.swimRange.size.height > 0){
                rect = (CGRect){rect.origin.x, rect.origin.y + scrollView.scrollPosition.y, self.swimRange.size.width, self.swimRange.size.height - scrollView.position.y};
            }
            else{
                rect = (CGRect){rect.origin, self.swimRange.size.width, MIN(-self.swimRange.size.height, scrollView.scrollPosition.y)};
            }
            position = ccpAdd([(ScrollViewNode* )self.parent convertBackPosition:self.position], scrollView.scrollPosition);
//            NSLog(@"%@", NSStringFromCGPoint(position));
//            NSLog(@"%@", NSStringFromCGRect(rect));
        }
        if (!CGRectContainsPoint(rect, position)) {
            self.position = self.touchBeganPosition;
        }
        [self runAnimation];
        [self runAction:[self getMoveAction]];
    }
}

-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
    if (self.touchCanceled) {
        self.touchCanceled(touch);
    }
    else{
        self.userInteractionEnabled = YES;
        self.position = self.touchBeganPosition;
        [self runAction:[self getMoveAction]];
    }
}

-(void)onEnter{
    [super onEnter];
    [self initSetting];
}

-(void)initSetting{
    _isFlipX = arc4random()%2 ? YES : NO;
    self.flipX = _isFlipX;
    if (self.flipX) {
        [self flipChildren];
    }
    _isFlipX = _direction == left ? _isFlipX : !_isFlipX;
    [self runAnimation];
    [self runAction:[self getMoveAction]];
}

-(void)runAnimation{
    if (_showAnimation) {
        if (_animationCount == 0 || _animationDelayTime <= 0.f || [_animationFileSuffix isEqualToString:@""] || [_animationFileName isEqualToString:@""] || _animationFileName == nil || _animationFileSuffix == nil) {
            return;
        }
        else{
            CCAnimation* fishAnimation = [CCAnimation animationWithFile:_animationFileName withSuffix:_animationFileSuffix frameCount:_animationCount delay:_animationDelayTime];
            [self runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:fishAnimation]]];
        }
    }
}

-(CCActionSequence* )getMoveAction{
    _bezierMoveCount = _isLockBezierMoveCount ? _bezierMoveCount : arc4random()%(MAXBEZIERMOVENUM + 1);
    CGFloat maxWidth = [[CCDirector sharedDirector] viewSize].width + self.contentSize.width + 100;
    CGFloat spacingDistance = _bezierMoveCount == 0 ? 0.f : maxWidth/_bezierMoveCount;
    CCTime duration = _bezierMoveCount == 0 ? MINSWIMTIME + (arc4random()%5) : ((MINSWIMTIME + (arc4random()%5))/_bezierMoveCount);
    NSMutableArray* bezierMoveArray = [[NSMutableArray alloc] init];
    CGPoint startPosition = _isNeedConvertPosition ? [(ScrollViewNode* )self.parent convertBackPosition:self.position] : self.position;
//    NSLog(@"startPosition- %@", NSStringFromCGPoint(startPosition));
    for (int i = 0; i < _bezierMoveCount; i++) {
        ccBezierConfig bezierMoveConfig;
        CGPoint endPosition = ccp(startPosition.x + spacingDistance * (_isFlipX ? 1.f : -1.f), startPosition.y);
        CGPoint midPoint = ccpMidpoint(startPosition, endPosition);
        bezierMoveConfig.endPosition = _isNeedConvertPosition ? [(ScrollViewNode* )self.parent convertPosition:endPosition] : endPosition;
        bezierMoveConfig.controlPoint_1 = _isNeedConvertPosition ? [(ScrollViewNode* )self.parent convertPosition:ccp(midPoint.x, midPoint.y + MAX(MIN((midPoint.x - endPosition.x), 100), -100))] : ccp(midPoint.x, midPoint.y + MAX(MIN((midPoint.x - endPosition.x), 100), -100));
        bezierMoveConfig.controlPoint_2 = _isNeedConvertPosition ? [(ScrollViewNode* )self.parent convertPosition:ccp(midPoint.x, midPoint.y + MAX(MIN((endPosition.x - midPoint.x), 100), -100))] : ccp(midPoint.x, midPoint.y + MAX(MIN((endPosition.x - midPoint.x), 100), -100));
        CCActionBezierTo* bezierMoveAction = [CCActionBezierTo actionWithDuration:duration bezier:bezierMoveConfig];
        [bezierMoveArray addObject:bezierMoveAction];
        startPosition = endPosition;
    }
    if(_bezierMoveCount == 0){
        CCActionMoveTo* moveAction = [CCActionMoveTo actionWithDuration:duration position:_isNeedConvertPosition ? [(ScrollViewNode* )self.parent convertPosition:ccp(startPosition.x + maxWidth * (_isFlipX ? 1.f : -1.f), startPosition.y)] : ccp(startPosition.x + maxWidth * (_isFlipX ? 1.f : -1.f), startPosition.y)];
        [bezierMoveArray addObject:moveAction];
    }
    CCActionSequence* sequenceMove = [CCActionSequence actionWithArray:bezierMoveArray];
    return sequenceMove;
}

-(void)newMoveRandomY:(BOOL)isRandomY{
    [self stopAllActions];
    [self runAnimation];
    self.flipX = !self.flipX;
    [self flipChildren];
    _isFlipX = _direction == left ? self.flipX : !self.flipX;
    if (isRandomY) {
        int positionY = 50 + arc4random()%(abs((int)_swimRange.size.height) - 50);
        positionY = _swimRange.size.height > 0 ? positionY : -positionY;
        CGPoint point = _isNeedConvertPosition ? [(ScrollViewNode* )self.parent convertBackPosition:self.position] : self.position;
        self.position = _isNeedConvertPosition ? [(ScrollViewNode* )self.parent convertPosition:ccp(point.x < -self.contentSize.width/2 ? -self.contentSize.width/2 : self.contentSize.width/2 + 1024, _swimRange.origin.y + positionY)] : ccp(point.x < -self.contentSize.width/2 ? -self.contentSize.width/2 : self.contentSize.width/2 + 1024, _swimRange.origin.y + positionY);
    }
    [self runAction:[self getMoveAction]];
}

-(void)flipChildren{
    for (CCNode* sprite in self.children) {
        sprite.position = ccp(self.contentSize.width - sprite.position.x, sprite.position.y);
    }
}



@end
