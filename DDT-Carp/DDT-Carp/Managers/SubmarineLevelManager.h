//
//  SubmarineLevelManager.h
//  DDT-Carp
//
//  Created by Z on 14/12/9.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubmarineLevelManager : NSObject
@property (nonatomic, strong) NSDictionary* levelInfo;
+(SubmarineLevelManager* )sharedSubmarineManager;
-(void)loadLevelInfo;
-(void)purgeSubmarineLevelManager;
@end
