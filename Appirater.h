/* This file is part of Appirater.
 
 Appirater is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License (or the Lesser GPL)
 as published by the Free Software Foundation; either version 3 of the
 License, or (at your option) any later version.
 
 Appirater is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 */
/*
 * Appirater.h
 * appirater
 *
 * Created by Arash Payan on 9/5/09.
 * http://arashpayan.com
 * Copyright 2009 Paxdot. All rights reserved.
 */

#import <Foundation/Foundation.h>

extern NSString *const kAppiraterLaunchDate;
extern NSString *const kAppiraterLaunchCount;
extern NSString *const kAppiraterCurrentVersion;
extern NSString *const kAppiraterRatedCurrentVersion;
extern NSString *const kAppiraterDeclinedToRate;

/*
 Place your Apple generated software id here.
 */
#define APPIRATER_APP_ID				301377083

/*
 Your app's name.
 */
#define APPIRATER_APP_NAME				[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey]

/*
 This is the message your users will see once they've passed the day+launches
 threshold.
 */
#define APPIRATER_MESSAGE				[NSString stringWithFormat:@"If you enjoy using %@, would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your support!", APPIRATER_APP_NAME]

/*
 This is the title of the message alert that users will see.
 */
#define APPIRATER_MESSAGE_TITLE			[NSString stringWithFormat:@"Rate %@", APPIRATER_APP_NAME]

/*
 The text of the button that rejects reviewing the app.
 */
#define APPIRATER_CANCEL_BUTTON			@"No, Thanks"

/*
 Text of button that will send user to app review page.
 */
#define APPIRATER_RATE_BUTTON			[NSString stringWithFormat:@"Rate %@", APPIRATER_APP_NAME]

/*
 Text for button to remind the user to review later.
 */
#define APPIRATER_RATE_LATER			@"Remind me later"

/*
 Users will need to have the same version of your app installed for this many
 days before they will be prompted to rate it.
 */
#define DAYS_UNTIL_PROMPT				30		// double

/*
 Users will need to launch the same version of the app this many times before
 they will be prompted to rate it.
 */
#define LAUNCHES_UNTIL_PROMPT			15		// integer

/*
 'YES' will show the Appirater alert everytime. Useful for testing how your message
 looks and making sure the link to your app's review page works.
 */
#define APPIRATER_DEBUG				NO

@interface Appirater : NSObject <UIAlertViewDelegate> {

}

+ (void)appLaunched;

@end
