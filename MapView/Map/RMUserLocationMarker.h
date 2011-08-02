//
//  RMUserLocationMarker.h
//  MapView
//
//  Created by Alexandr Lints on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RMMarker.h"
#import "RMCircle.h"
#import "RMMarkerManager.h"
#import "RMMapContents.h"

@interface RMUserLocationMarker : RMMarker{
    
    RMMapContents *contents;
    CLLocationCoordinate2D pinLocation;
    CGFloat radius;
    CGFloat blinkRadius;
    BOOL initialized;
    UIColor *fillColor;
    UIColor *lineColor;
    CGFloat lineWidth;
    float zoom;
    RMCircle *circle;
}

@property (nonatomic, retain) RMMapContents *contents;
@property(nonatomic) CLLocationCoordinate2D pinLocation;
@property(nonatomic) CGFloat radius, lineWidth, blinkRadius;
@property(nonatomic) BOOL initialized;
@property(nonatomic) float zoom;
@property(nonatomic, retain) UIColor *fillColor;
@property(nonatomic, retain) UIColor *lineColor;
@property(nonatomic, retain) RMCircle *circle;

-(id)initWithMarkerManager: (RMMapContents *) content pinLocation:(CLLocationCoordinate2D) point;
-(void)initCircle;
@end
