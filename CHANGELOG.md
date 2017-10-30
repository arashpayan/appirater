Change Log
==========

Version 2.3.0 *(2017-10-30)*
----------------------------
* if (iOS >= 8 && iOS <= 10.3) { use UIAlertController }
* Note when the SKStoreReviewController is called, even though we don't get feedback

Version 2.2.0 *(2017-09-23)*
----------------------------
* Use SKStoreReviewController if available
  * Available on iOS > 10.3 
  * You'll need to link the StoreKit Framework
* Armenian localization
* Fix delegate not being set after Appirater initialization (Issue #215)

Version 2.1.0 *(2016-11-04)*
----------------------------
* Fix and suppress various Xcode warnings
* Switch to NSURLSession
* Serialize incrementing events

Version 2.0.4 *(2014-09-18)*
----------------------------
* Change: Better URL for iOS 7.1 and 8 support

Version 2.0.3 *(2014-05-14)*
----------------------------
 * New: Make alert content customizable
