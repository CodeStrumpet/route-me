//
//  GPSLocationDotAppDelegate.h
//  GPSLocationDot
//
//  Created by Alexandr Lints on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GPSLocationDotViewController;

@interface GPSLocationDotAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet GPSLocationDotViewController *viewController;

@end
