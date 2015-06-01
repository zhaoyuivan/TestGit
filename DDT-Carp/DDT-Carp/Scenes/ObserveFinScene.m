//
//  ObserveFinScene.m
//  DDT-Carp
//
//  Created by Z on 15/2/3.
//  Copyright (c) 2015年 ZY. All rights reserved.
//
#import "CCAnimation+Helper.h"
#import "CCTextureCache.h"

#import "ObserveFinScene.h"
#import "SubmarineScene.h"
#import "ObserveScaleScene.h"

#define FISHORDER 100

@interface ObserveFinScene ()
{
//    observe control
    BOOL _isShowAnimation;
    
//    fin
    NSMutableArray* _removeSprites;
    NSMutableArray* _tipsArray;
    CCSprite* _boardSprite;
    CCClippingNode* _finClippingNode;
    int _puzzleCount;
}
@end

@implementation ObserveFinScene
+(ObserveFinScene *)scene{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isShowAnimation = NO;
        _puzzleCount = 0;
        _removeSprites = [[NSMutableArray alloc] init];
        _tipsArray = [[NSMutableArray alloc] init];
        
//        base words
        self.prevButton.visible = NO;
        self.nextButton.visible = NO;
        self.homeButton.visible = NO;
        self.currentScene = @"fin";
        self.imageSuffix = @"observe";
        
//        base observed
        self.observedName = @"fin";
        self.observedCount = 2;
        self.observedPositions = [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:ccp(649.5/2.f, 768 - 1241/2.f)], [NSValue valueWithCGPoint:ccp(1066.f/2.f, 768 - 1264/2.f)], nil];
    }
    return self;
}

-(void)onEnter{
    [super onEnter];
    [self createBackground];
}

-(void)prevPress:(CCButton *)button{
    if(self.step == 1){
        [[CCDirector sharedDirector] replaceScene:[SubmarineScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    }
    [self handleButtons:NO];
}

-(void)nextPress:(CCButton *)button{
    if (self.step == 1) {
        [[CCDirector sharedDirector] replaceScene:[ObserveScaleScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    }
    else if(self.step == 2){
        [self finGoOver];
    }
    [self handleButtons:NO];
}

-(void)createBackground{
//    bg
    CCSprite* bgSprite = [CCSprite spriteWithImageNamed:@"bg_observe.png"];
    bgSprite.anchorPoint = ccp(0, 0);
    bgSprite.position = ccp(0, 0);
    [self.backgroundNode addChild:bgSprite z:1];
    
//    fish
    CCSprite* fishSprite = [CCSprite spriteWithImageNamed:@"carp_observe.png"];
    fishSprite.name = @"carp";
    fishSprite.position = ccp(1047/2, 768 - 915.5/2);
    [self.backgroundNode addChild:fishSprite z:FISHORDER];
    
//    gill
    CCSprite* gillSprite = [CCSprite spriteWithImageNamed:@"gill_observe.png"];
    gillSprite.position = ccp(491.5/2, 768 - 989.5/2);
    [self.backgroundNode addChild:gillSprite z:FISHORDER];
}

-(void)createScene{
    [self createObservedSprite];
}

#pragma mark - fin observe
-(void)observeFin{
    if(_isShowAnimation){
        return;
    }
    _isShowAnimation = YES;
    [self handleButtons:NO];
    self.homeButton.enabled = NO;
    
//    fin bg
    CCSprite* finBgSprite = [CCSprite spriteWithImageNamed:@"fin_bg_observe.png"];
    finBgSprite.name = @"fin_bg";
    finBgSprite.position = ccp(429, 142);
    [self.backgroundNode addChild:finBgSprite z:FISHORDER + 1];
    
//   show board
    _boardSprite = [CCSprite spriteWithImageNamed:@"board_fin_observe.png"];
    _boardSprite.position = ccp(1024 + _boardSprite.contentSize.width/2, 768 - _boardSprite.contentSize.height/2 - 20);
    [self.backgroundNode addChild:_boardSprite z:FISHORDER + 4];
    
    __unsafe_unretained ObserveFinScene* weakSelf = self;
    [_boardSprite runAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:1.f position:ccp(-_boardSprite.contentSize.width, 0)], [CCActionCallBlock actionWithBlock:^{
        [weakSelf createFinSprites];
    }], nil]];
}

-(void)createFinSprites{
//    tag
    CGPoint positions[] = {ccp(534/2.f, 768 - 242.5/2.f), ccp(534/2.f, 768 - 523.5/2.f)};
    NSArray* iconName = @[@"quant_fin_observe.png", @"dudu_fin_observe.png"];
    CGPoint iconPositions[] = {ccp(484/2.f, 768 - 242.5/2.f), ccp(478/2.f, 768 - 532.5/2.f)};
    NSMutableArray* rightRects = [[NSMutableArray alloc] initWithObjects:
                                  [NSMutableArray arrayWithObjects:
                                   [NSValue valueWithCGRect:(CGRect){1270.5/2.f - 155.5/2.f, 768 - 667/2.f - 107, 155.5, 214}],
                                   [NSValue valueWithCGRect:(CGRect){1534.5/2.f - 155.5/2.f, 768 - 672/2.f - 107, 155.5, 214}],
                                   nil],
                                  [NSMutableArray arrayWithObjects:
                                   [NSValue valueWithCGRect:(CGRect){1313/2.f - 80, 768 - 538/2.f - 82, 160, 164}],
                                   [NSValue valueWithCGRect:(CGRect){1577/2.f - 80, 768 - 543/2.f - 82, 160, 164}],
                                   nil],
                                  nil];
    __block NSMutableArray* rightRectsTemp = rightRects;
    
    for (int i = 0; i < 2; i++) {
        CCSprite* tagSprite = [CCSprite spriteWithImageNamed:@"tag_fin_observe.png"];
        tagSprite.position = positions[i];
        tagSprite.name = [NSString stringWithFormat:@"tag%d", i + 1];
        [self.backgroundNode addChild:tagSprite z:FISHORDER + 3];
        
        TouchSprite* iconSprite = [TouchSprite spriteWithImageNamed:iconName[i]];
        iconSprite.position = [tagSprite convertToNodeSpace:iconPositions[i]];
        iconSprite.name = [iconName[i] componentsSeparatedByString:@"_"].firstObject;
        [tagSprite addChild:iconSprite z:1];
        iconSprite.userInteractionEnabled = NO;
        
        __block TouchSprite* iconSpriteBlock = iconSprite;
        __unsafe_unretained TouchSprite* iconSpriteTemp = iconSprite;
        __unsafe_unretained CCNode* backgroundNodeTemp = self.backgroundNode;
        __unsafe_unretained ObserveFinScene* weakSelf = self;
        __block CGPoint iconPointTemp = iconPositions[i];
        tagSprite.position = ccpAdd(positions[i], ccp(tagSprite.contentSize.width, 0));
        [tagSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:1.f position:positions[i]], [CCActionCallBlock actionWithBlock:^{
            [iconSpriteBlock removeFromParent];
            iconSpriteBlock.position = iconPointTemp;
            iconSpriteBlock.userInteractionEnabled = YES;
            [backgroundNodeTemp addChild:iconSpriteBlock z:FISHORDER + 10];
        }], nil]];
        
        iconSprite.touchBegan = ^(UITouch* touch){
            [weakSelf iconTouchBeganBlock:touch sender:iconSpriteTemp];
        };
        
        iconSprite.touchMoved = ^(UITouch* touch){
            [weakSelf iconTouchMovedBlock:touch sender:iconSpriteTemp];
        };
        
        iconSprite.touchEnded = ^(UITouch* touch){
            [weakSelf iconTouchEndedBlock:touch sender:iconSpriteTemp andRectArray:rightRectsTemp];
        };
        
        iconSprite.touchCanceled = ^(UITouch* touch){
            [weakSelf iconTouchCanceledBlock:touch sender:iconSpriteTemp];
        };
    }
    
//    clipping node
    CCSprite* stencilSprite = [CCSprite spriteWithImageNamed:@"clip_fin_observe.png"];
    stencilSprite.anchorPoint = ccp(0.5, 0.5);
    stencilSprite.position = ccp(1024 - stencilSprite.contentSize.width/2, 768 - 503.5/2.f - 20);
    _finClippingNode = [CCClippingNode clippingNodeWithStencil:stencilSprite];
    _finClippingNode.contentSize = self.contentSize;
    _finClippingNode.alphaThreshold = 0.f;
    [self.backgroundNode addChild:_finClippingNode z:FISHORDER + 5];
    
//    water
    CCSprite* waterSprite = [CCSprite spriteWithImageNamed:@"water1_fin_observe.png"];
    waterSprite.position = ccp(1360/2.f, 768 - 812/2.f - waterSprite.contentSize.height);
    waterSprite.name = @"water";
    [_finClippingNode addChild:waterSprite];
    
    [waterSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:1.f position:ccp(1360/2.f, 768 - 812/2.f)], [CCActionCallBlock actionWithBlock:^{

    }], nil]];
    
//    ship
    CCSprite* shipSprite = [CCSprite spriteWithImageNamed:@"ship_fin_observe.png"];
    shipSprite.position = ccp(1024 + shipSprite.contentSize.width/2, 768 - 459.5/2.f);
    shipSprite.name = @"ship";
    [self.backgroundNode addChild:shipSprite z:FISHORDER + 6];
    
    [shipSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionMoveTo actionWithDuration:1.f position:ccp(1423/2.f, 768 - 459.5/2.f)], [CCActionCallBlock actionWithBlock:^{
        
    }], nil]];
    
//    dark dudu
    CGPoint duduPositions[] = {ccp(1313/2.f, 768 - 538/2.f), ccp(1577/2.f, 768 - 543/2.f)};
    CGPoint handPositions[] = {ccp(1275/2.f, 768 - 588.5/2.f), ccp(1539/2.f, 768 - 593.5/2.f)};
    CGPoint quantPositions[] = {ccp(1270.5/2.f, 768 - 667/2.f), ccp(1534.5/2.f, 768 - 672/2.f)};
    for (int i = 0; i < 2; i++) {
        CCSprite* darkDuduSprite = [CCSprite spriteWithImageNamed:@"dudu_dark_fin_observe.png"];
        darkDuduSprite.position = duduPositions[i];
        darkDuduSprite.opacity = 0.f;
        [self.backgroundNode addChild:darkDuduSprite z:FISHORDER + 5];
        
        CCSprite* quantSprite = [CCSprite spriteWithImageNamed:@"quant_dark_fin_observe.png"];
        quantSprite.position = quantPositions[i];
        quantSprite.opacity = 0.f;
        [self.backgroundNode addChild:quantSprite z:FISHORDER + 7];
        
        CCSprite* handSprite = [CCSprite spriteWithImageNamed:@"hand_dark_fin_observe.png"];
        handSprite.position = handPositions[i];
        handSprite.opacity = 0.f;
        [self.backgroundNode addChild:handSprite z:FISHORDER + 8];
        
        [darkDuduSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
        [quantSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
        [handSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
        [_removeSprites addObject:darkDuduSprite];
        [_removeSprites addObject:quantSprite];
        [_removeSprites addObject:handSprite];
    }
    
//    clouds
    CGPoint cloudPositions[] = {ccp(500, 650), ccp(900, 660), ccp(800, 680)};
    for (int i = 0; i < 3; i++) {
        CCSprite* cloudSprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"cloud%d_fin_observe.png", i + 1]];
        cloudSprite.position = cloudPositions[i];//[_boardSprite convertToNodeSpace:cloudPositions[i]];
        cloudSprite.opacity = 0.f;
        [_finClippingNode addChild:cloudSprite z:3 - i];
        __block CCSprite* cloudSpriteTemp = cloudSprite;
        [cloudSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], [CCActionCallBlock actionWithBlock:^{
            [cloudSpriteTemp runAction:[ActionProvider getRepeatSlowMove:5.f + i andDistance:30.f + i * 5.f]];
        }], nil]];
    }
}

-(void)iconTouchBeganBlock:(UITouch* )touch sender:(TouchSprite* )iconSprite{
    iconSprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"%@_real_fin_observe.png", iconSprite.name]];
    iconSprite.position = [touch locationInNode:self.backgroundNode];
    iconSprite.zOrder = FISHORDER + 11;
    if([iconSprite.name isEqualToString:@"dudu"]){
        CCSprite* handSprite = [CCSprite spriteWithImageNamed:@"hand_real_fin_observe.png"];
        handSprite.position = ccpSub(ccp(1275/2.f, 768 - 588.5/2.f), ccp(1313/2.f - iconSprite.contentSize.width/2.f, 768 - 538/2.f - iconSprite.contentSize.height/2.f));
        [iconSprite addChild:handSprite];
    }
}

-(void)iconTouchMovedBlock:(UITouch* )touch sender:(TouchSprite* )iconSprite{
    CGPoint touchPoint = [touch locationInNode:self.backgroundNode];
    iconSprite.position = touchPoint;
}

-(void)iconTouchEndedBlock:(UITouch* )touch sender:(TouchSprite* )iconSprite andRectArray:(NSMutableArray* )rectArray{
    iconSprite.userInteractionEnabled = NO;
    NSMutableArray* rects = nil;
    if([iconSprite.name isEqualToString:@"quant"]){
        rects = rectArray[0];
    }
    else{
        rects = rectArray[1];
    }
    [self duduGoRightPosition:rects andIconSprite:iconSprite];
}

-(void)duduGoRightPosition:(NSMutableArray* )rects andIconSprite:(TouchSprite* )iconSprite{
    int index = 0;
    for (index = 0; index < rects.count; index++) {
        if (CGRectContainsPoint([rects[index] CGRectValue], iconSprite.position)) {
            break;
        }
    }
    if (index == rects.count) {
        [self iconGoback:iconSprite];
    }
    else{
        [self iconLand:iconSprite andPosition:ccpAdd([rects[index] CGRectValue].origin, ccp(iconSprite.contentSize.width/2, iconSprite.contentSize.height/2)) withOriginalPosition:[iconSprite.name isEqualToString:@"dudu"] ? ccp(478/2.f, 768 - 532.5/2.f) : ccp(484/2.f, 768 - 242.5/2.f) andIsBack:rects.count == 1 ? NO : YES];
        [rects removeObjectAtIndex:index];
    }
}

-(void)iconLand:(TouchSprite* )iconSprite andPosition:(CGPoint)position withOriginalPosition:(CGPoint)originalPosition andIsBack:(BOOL)isBack{
    _puzzleCount++;
    __unsafe_unretained TouchSprite* iconSpriteTemp = iconSprite;
    __unsafe_unretained CCNode* backgroundTemp = self.backgroundNode;
    __unsafe_unretained NSMutableArray* removeSpritesTemp = _removeSprites;
    [iconSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:0.1f position:position], [CCActionCallBlock actionWithBlock:^{
        iconSpriteTemp.zOrder = FISHORDER + 5;
        CCSprite* puzzle = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"%@_real_fin_observe.png", iconSpriteTemp.name]];
        puzzle.position = position;
        puzzle.name = [NSString stringWithFormat:@"puzzle%d", _puzzleCount];
        [backgroundTemp addChild:puzzle z:FISHORDER + 5];
        if([iconSpriteTemp.name isEqualToString:@"dudu"]){
            CCSprite* handSprite = [CCSprite spriteWithImageNamed:@"hand_real_fin_observe.png"];
            handSprite.position = [puzzle convertToWorldSpace:ccpSub(ccp(1275/2.f, 768 - 588.5/2.f), ccp(1313/2.f - puzzle.contentSize.width/2.f, 768 - 538/2.f - puzzle.contentSize.height/2.f))];
            [backgroundTemp addChild:handSprite z:FISHORDER + 8];
            [removeSpritesTemp addObject:handSprite];
        }
        else{
            puzzle.zOrder = FISHORDER + 7;
        }
        [removeSpritesTemp addObject:puzzle];
        iconSpriteTemp.opacity = 0;
        [iconSpriteTemp removeAllChildren];
        if (isBack) {
            iconSpriteTemp.zOrder = FISHORDER + 10;
            iconSpriteTemp.position = originalPosition;
            iconSpriteTemp.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"%@_fin_observe.png", iconSpriteTemp.name]];
            [iconSpriteTemp runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1.f], [CCActionCallBlock actionWithBlock:^{
                iconSpriteTemp.userInteractionEnabled = YES;
            }], nil]];
        }
        else{
            [iconSpriteTemp removeFromParent];
        }
        if(_puzzleCount == 4){
            //            animation start
            _puzzleCount = 0;
            [self finAnimationStart];
        }
    }], nil]];
}

-(void)iconTouchCanceledBlock:(UITouch* )touch sender:(TouchSprite* )iconSprite{
    iconSprite.userInteractionEnabled = NO;
    [self iconGoback:iconSprite];
}

-(void)iconGoback:(TouchSprite* )iconSprite{
    iconSprite.zOrder = FISHORDER + 10;
    CGPoint endPosition = CGPointZero;
    CCTime duration = 0.f;
    const CGFloat speed = 1500.f;
    if ([iconSprite.name isEqualToString:@"quant"]) {
        endPosition = ccp(484/2.f, 768 - 242.5/2.f);
    }
    else{
        endPosition = ccp(478/2.f, 768 - 532.5/2.f);
    }
    duration = ccpDistance(endPosition, iconSprite.position)/speed;
    __block TouchSprite* iconSpriteTemp = iconSprite;
    [iconSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:duration position:endPosition], [CCActionCallBlock actionWithBlock:^{
        iconSpriteTemp.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"%@_fin_observe.png", iconSpriteTemp.name]];
        iconSpriteTemp.userInteractionEnabled = YES;
        [iconSpriteTemp removeAllChildren];
    }], nil]];
}

-(void)finAnimationStart{
//    tag
    for (int i = 0; i < self.backgroundNode.children.count; i++) {
        CCSprite* tag = (CCSprite* )self.backgroundNode.children[i];
        if (tag.name.length == 4 && [[tag.name substringToIndex:3] isEqual:@"tag"]) {
            __block CCSprite* tagTemp = tag;
            [tag runAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:0.5f position:ccp(tag.contentSize.width, 0)], [CCActionCallBlock actionWithBlock:^{
                [tagTemp removeFromParent];
            }], nil]];
        }
    }
    
//    remove sprites
    for (CCSprite* darkSpirte in _removeSprites) {
        [darkSpirte removeFromParent];
    }
    [_removeSprites removeAllObjects];
    
//    ship & water
    CCSprite* shipSprite = (CCSprite* )[self.backgroundNode getChildByName:@"ship" recursively:NO];
    [shipSprite removeFromParent];
    shipSprite.position = [_finClippingNode convertToNodeSpace:shipSprite.position];
    [_finClippingNode addChild:shipSprite z:2];
    shipSprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"ship1_fin_observe.png"];
    shipSprite.position = ccp(shipSprite.position.x, shipSprite.position.y - 77.5/2.f);
    
    CCAnimation* shipAnimation = [CCAnimation animationWithFile:@"ship" withSuffix:@"_fin_observe" frameCount:14 delay:1/12.f];
    CCAnimation* waterAnimation = [CCAnimation animationWithFile:@"water" withSuffix:@"_fin_observe" frameCount:9 delay:1/4.f];
    __unsafe_unretained CCSprite* waterSpriteTemp = (CCSprite* )[_finClippingNode getChildByName:@"water" recursively:NO];
    __unsafe_unretained CCSprite* shipSpriteTemp = shipSprite;
    [shipSprite runAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionScaleTo actionWithDuration:1.f scale:0.6], [CCActionMoveBy actionWithDuration:1.f position:ccp(0, -20)], nil], [CCActionCallBlock actionWithBlock:^{
        [shipSpriteTemp runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:shipAnimation]]];
        [waterSpriteTemp runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:waterAnimation]]];
        [shipSpriteTemp runAction:[CCActionRepeatForever actionWithAction:[CCActionSpawn actions:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.25f], [CCActionJumpBy actionWithDuration:1.5f position:CGPointZero height:20 jumps:1], [CCActionDelay actionWithDuration:0.5f], nil], [CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionRepeat actionWithAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:0.25f position:ccp(0, 3)], [CCActionDelay actionWithDuration:1/16.f], [CCActionMoveBy actionWithDuration:0.25f position:ccp(0, -3)], [CCActionDelay actionWithDuration:1/16.f], nil] times:2], nil], nil]]];
    }], nil]];
    
//    clouds
    for (CCSprite* cloud in _finClippingNode.children) {
        if ([cloud.name isEqualToString:@"water"] || [cloud.name isEqualToString:@"ship"]) {
            continue;
        }
        [cloud stopAllActions];
        CGFloat distance = 1024 + cloud.contentSize.width - cloud.position.x;
        CCTime duration = distance/200.f;//(724 + cloud.contentSize.width * 2) * 5.f;
        [cloud runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:duration position:ccp(1024 + cloud.contentSize.width, cloud.position.y)], [CCActionCallBlock actionWithBlock:^{
            cloud.position = ccp(300 - cloud.contentSize.width, cloud.position.y);
            [cloud runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:(724 + cloud.contentSize.width * 2)/200.f position:ccp(1024 + cloud.contentSize.width, cloud.position.y)], [CCActionCallBlock actionWithBlock:^{
                cloud.position = ccp(300 - cloud.contentSize.width, cloud.position.y);
            }], nil]]];
        }], nil]];
        
    }
    
//    fins
    CGPoint rotationPoints[] = {ccp(553/2.f, 768 - 1178/2.f), ccp(1001/2.f, 768 - 1187/2.f)};
    for (int i = 0; i < self.observedSpriteArray.count; i++) {
        CCSprite* fin = self.observedSpriteArray[i];
        CGPoint tempPoint = ccpSub(rotationPoints[i], ccpSub(fin.position, ccpMult((CGPoint){fin.contentSize.width, fin.contentSize.height}, 0.5f)));
        fin.anchorPoint = ccp(tempPoint.x/fin.contentSize.width, tempPoint.y/fin.contentSize.height);
        fin.position = rotationPoints[i];
        [fin runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionRotateTo actionWithDuration:0.6f angle:10.f], [CCActionRotateTo actionWithDuration:0.5f angle:0.f], nil]]];
    }
    
//    tips
    const CGFloat defaultLength = 30.f;
    
    NSString* tipOne = NSLocalizedString(@"fin_tip1", nil);
    NSString* tipTwo = NSLocalizedString(@"fin_tip2", nil);
    CGFloat fontSize = [NSLocalizedString(@"fin_tip_font_size", nil) doubleValue];
    CGFloat letterWidth = [NSLocalizedString(@"fin_tip_letter_width", nil) doubleValue];
    
    CGPoint rectPositions[] = {ccp(389/2.f, 768 - 300/2.f), ccp(389/2.f, 768 - 550/2.f)};
    CGPoint labelPositions[] = {ccp(360/2.f, 768 - 300/2.f), ccp(360/2.f, 768 - 550/2.f)};
    NSArray* tips = @[tipOne, tipTwo];
    ccColor4F fontColors[] = {ccc4f(123/255.f, 243/255.f, 219/255.f, 1.f), ccc4f(1.f, 232/255.f, 81/255.f, 1.f)};
    CGSize fontDimensions[] = {(CGSize){9 * defaultLength, 0.f}, (CGSize){9 * defaultLength, 0.f}};
    
    for (int i = 0; i < 2; i++) {
        CGFloat rectScaleY = 1.f;
        CGFloat offset = 0.f;
        CCSprite* rect = [CCSprite spriteWithImageNamed:@"tips_bg.png"];
        
        if ([(NSString* )tips[i] length] * letterWidth / fontDimensions[i].width > 2.f) {
            int row = ceil([(NSString* )tips[i] length] * letterWidth / fontDimensions[i].width);
            rectScaleY = row/2.f;
            NSLog(@"1 - %f, 2 - %f, rectScaleY - %f", [(NSString* )tips[i] length] * letterWidth, fontDimensions[i].width, rectScaleY);
            offset = (rectScaleY - 1) * rect.contentSize.height;
        }
        
        CCNode* tipNode = [CCNode node];
        tipNode.contentSize = rect.contentSize;
        tipNode.anchorPoint = ccp(1.f, 0.5f);
        tipNode.position = ccp(rectPositions[i].x + rect.contentSize.width/2.f, rectPositions[i].y);
//        tipNode.scaleY = rectScaleY;
        [self.backgroundNode addChild:tipNode z:FISHORDER + 3];
        
        rect.position = [tipNode convertToNodeSpace:ccpSub(rectPositions[i], ccp(0.f, offset * (i + 0.5f)))];
        rect.scaleY = rectScaleY;
        [tipNode addChild:rect z:1];
        
        CCLabelTTF* tip = [CCLabelTTF labelWithString:tips[i] fontName:@"STYuanti-SC-Regular" fontSize:fontSize dimensions:fontDimensions[i]];
        tip.position = [tipNode convertToNodeSpace:ccpSub(labelPositions[i], ccp(0.f, offset * (i + 0.5f)))];
        tip.horizontalAlignment = CCTextAlignmentCenter;
        tip.color = [CCColor colorWithCcColor4f:fontColors[i]];
        [tipNode addChild:tip z:1];
        
        [_tipsArray addObject:tipNode];
        
        tipNode.scaleX = 0.f;
    }
    
    for (CCNode* tipNode in _tipsArray) {
        [tipNode runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionScaleTo actionWithDuration:1.f scaleX:1.f scaleY:1.f], nil]];
    }
    
    [self createGoNextSprite];
}

-(void)finGoOver{
    __unsafe_unretained ObserveFinScene* weakSelf = self;
    __unsafe_unretained CCSprite* boardSpriteTemp = _boardSprite;
    __unsafe_unretained CCNode* backgroundNodeTemp = self.backgroundNode;
    __unsafe_unretained CCClippingNode* clipNodeTemp = _finClippingNode;
    for (CCNode* tipNode in _tipsArray) {
        [tipNode runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scaleX:0.f scaleY:1.f], [CCActionCallBlock actionWithBlock:^{
            [tipNode removeAllChildren];
            [tipNode removeFromParent];
        }], nil]];
    }
    
    [_boardSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.1f], [CCActionMoveBy actionWithDuration:1.f position:ccp(_boardSprite.contentSize.width, 0)], [CCActionCallBlock actionWithBlock:^{
//        [weakSelf observerGoBack];
        [boardSpriteTemp removeAllChildren];
        [boardSpriteTemp removeFromParent];
        [clipNodeTemp removeFromParent];
        clipNodeTemp.stencil = nil;
        __unsafe_unretained CCSprite* finBg = (CCSprite* )[backgroundNodeTemp getChildByName:@"fin_bg" recursively:NO];
        [finBg runAction:[CCActionSequence actions:[CCActionFadeOut actionWithDuration:1.f], [CCActionCallBlock actionWithBlock:^{
            [finBg removeFromParent];
        }], nil]];
        for (CCSprite* fin in weakSelf.observedSpriteArray) {
            __block CCSprite* finTemp = fin;
            [fin runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:0.f], [CCActionCallBlock actionWithBlock:^{
                [finTemp removeFromParent];
                
            }], nil]];
        }
        [weakSelf.observedSpriteArray removeAllObjects];
    }], nil]];
    
    [_finClippingNode runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.1f], [CCActionMoveBy actionWithDuration:1.f position:ccp(_boardSprite.contentSize.width, 0)], nil]];
    
    [self runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:3.5f], [CCActionCallBlock actionWithBlock:^{
        [[CCDirector sharedDirector] replaceScene:[ObserveScaleScene scene]];
    }], nil]];
    [weakSelf.observerSprite removeFromParent];
    weakSelf.observerSprite = nil;
    _isShowAnimation = NO;
}

-(void)createGoNextSprite{
    self.step++;
    self.nextButton.visible = YES;
    self.nextButton.enabled = YES;
}




-(void)onExit{
//    delete？？
    [_finClippingNode removeAllChildren];
    _finClippingNode.stencil = nil;
    [_boardSprite removeAllChildren];
    [self.backgroundNode removeAllChildren];
    
    _puzzleCount = 0;
    [_tipsArray removeAllObjects];
    [_removeSprites removeAllObjects];
    [self removeAllChildren];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    [super onExit];
}

-(void)dealloc{
    
}
@end
