//
//  AppiraterDelegate.h
//  Banana Stand
//
//  Created by Robert Haining on 9/25/12.
//  Copyright (c) 2012 News.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Appirater;

@protocol AppiraterDelegate <NSObject>

@optional
-(void)appiraterDidDisplayAlert:(Appirater *)appirater;
-(void)appiraterDidDeclineToRate:(Appirater *)appirater;
-(void)appiraterDidOptToRate:(Appirater *)appirater;
-(void)appiraterDidOptToRemindLater:(Appirater *)appirater;
-(void)appiraterWillPresentModalView:(Appirater *)appirater animated:(BOOL)animated;
-(void)appiraterDidDismissModalView:(Appirater *)appirater animated:(BOOL)animated;

-(NSString *)titleForAppiraterRatingAlert:(Appirater *)appirater;
-(NSString *)messageForAppiraterRatingAlert:(Appirater *)appirater;
-(NSString *)titleForRateButtonInAppiraterRatingAlert:(Appirater *)appirater;
-(NSString *)titleForRemindButtonInAppiraterRatingAlert:(Appirater *)appirater;
-(NSString *)titleForCancelButtonInAppiraterRatingAlert:(Appirater *)appirater;

@end
