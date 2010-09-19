/*
 This file is part of Appirater.
 
 Copyright (c) 2010, Arash Payan
 All rights reserved.
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */
/*
 * Appirater.h
 * appirater
 *
 * Created by Arash Payan on 9/5/09.
 * http://arashpayan.com
 * Copyright 2010 Arash Payan. All rights reserved.
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
#define APPIRATER_MESSAGE				@"If you enjoy using %@, would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your support!"

/*
 This is the title of the message alert that users will see.
 */
#define APPIRATER_MESSAGE_TITLE			@"Rate %@"

/*
 The text of the button that rejects reviewing the app.
 */
#define APPIRATER_CANCEL_BUTTON			NSLocalizedString(@"No, Thanks", nil)

/*
 Text of button that will send user to app review page.
 */
#define APPIRATER_RATE_BUTTON			@"Yes, rate %@"

/*
 Text for button to remind the user to review later.
 */
#define APPIRATER_RATE_LATER			NSLocalizedString(@"Remind me later", nil)

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
