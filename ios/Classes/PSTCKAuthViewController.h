//
//  EBAEventbritePurchaseViewController.h
//  InEvent
//
//  Created by Pedro Góes on 12/16/15.
//  Copyright © 2015 InEvent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

typedef void(^PSTCKAuthCallback)(void);

// Debug-only tracing of the 3DS auth flow. Compiled out of release builds so
// auth URLs never reach device logs in production.
#ifdef DEBUG
#define PSTCKLog(fmt, ...) NSLog((@"[Paystack] " fmt), ##__VA_ARGS__)
#else
#define PSTCKLog(...)
#endif

/**
 * View Controller subclass containing a `UIWebView` which will be used to display the Paystack web UI to perform the authorization.
 **/
@interface PSTCKAuthViewController : UIViewController

/** ************************************************************************************************ **
 * @name Initializers
 ** ************************************************************************************************ **/

/**
 * Default initializer.
 * @param authURL the authorization url from Paystack.
 * @param completion A standard block.
 * @returns An initialized instance
 **/
- (id)initWithURL:(NSURL *)authURL handler:(PSTCKAuthCallback)completion;

@end
