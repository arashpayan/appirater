//
//  AppiraterDelegate.h
//  Banana Stand
//
//  Created by Robert Haining on 9/25/12.
//  Copyright (c) 2012 News.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Appirater;
@protocol AppiraterAlert;

@protocol AppiraterDelegate <NSObject>

@optional
-(BOOL)appiraterShouldDisplayAlert:(Appirater *)appirater;
-(void)appiraterDidDisplayAlert:(Appirater *)appirater;
-(void)appiraterDidDeclineToRate:(Appirater *)appirater;
-(void)appiraterDidOptToRate:(Appirater *)appirater;
-(void)appiraterDidOptToRemindLater:(Appirater *)appirater;
-(void)appiraterWillPresentModalView:(Appirater *)appirater animated:(BOOL)animated;
-(void)appiraterDidDismissModalView:(Appirater *)appirater animated:(BOOL)animated;
-(id<AppiraterAlert>)appirater:(Appirater *)appirater
           wantsToShowAlertWithTitle:(NSString *)title
                             message:(NSString *)message
                   cancelButtonTitle:(NSString *)cancelButtonTitle
                  cancelButtonAction:(void(^)(void))cancelButtonAction
                     rateButtonTitle:(NSString *)rateButtonTitle
                    rateButtonAction:(void(^)(void))rateButtonAction
                    laterButtonTitle:(NSString *)laterButtonTitleOrNil
                   laterButtonAction:(void(^)(void))laterButtonActionOrNil;
@end

