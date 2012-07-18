//
//  AppiraterSettings.h
//  OP22
//
//  Created by Yann-Cyril PELUD on 17/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppiraterSettings : NSObject 

@property (nonatomic) NSInteger appId;
@property (nonatomic) NSInteger daysUntilPrompt;
@property (nonatomic) NSInteger usesUntilPrompt;
@property (nonatomic) NSInteger sigEventsUntilPrompt;
@property (nonatomic) NSInteger timeBeforeReminding;
@property (nonatomic, strong) NSString *urlStore;

@end
