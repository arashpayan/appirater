//
//  AppiraterDataSource.h
//
//  Created by Bram Huenaerts on 17/10/13.
//  Copyright (c) 2013 chronux. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Appirater;

@protocol AppiraterDataSource <NSObject>

@optional

/*
 Your localized app's name.
 */
-(NSString *)appName;

/*
 This is the message your users will see once they've passed the day+launches
 threshold.
 */
-(NSString *)message;

/*
 This is the title of the message alert that users will see.
 */
-(NSString *)messageTitle;

/*
 The text of the button that rejects reviewing the app.
 */
-(NSString *)cancelButtonTitle;

/*
 Text of button that will send user to app review page.
 */
-(NSString *)rateNowButtonTitle;

/*
 Text for button to remind the user to review later.
 */
-(NSString *)rateLaterButtonTitle;

@end
