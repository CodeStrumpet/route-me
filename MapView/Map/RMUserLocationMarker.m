//
//  RMUserLocationMarker.m
//  MapView
//
//  Created by Alexandr Lints on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RMUserLocationMarker.h"

@implementation RMUserLocationMarker

@synthesize contents;
@synthesize pinLocation;
@synthesize radius,blinkRadius,lineWidth;
@synthesize initialized;
@synthesize zoom;
@synthesize fillColor, lineColor;
@synthesize circle;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(id)initWithMarkerManager:(RMMapContents *)content pinLocation:(CLLocationCoordinate2D)point{
    self = [super init];
    if (self) {
        
        UIImage *blueDot = [UIImage imageNamed:@"blue_position_indicator.png"]; 
        [self replaceUIImage:blueDot];
        self.contents = content;
        self.radius = 500;
        self.pinLocation = point;
        self.blinkRadius = 200.0f/self.contents.zoom;
        self.lineWidth = 1;
        self.fillColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.05];
        self.lineColor = [UIColor colorWithRed:0.5 green:0.5 blue:1 alpha:1];
        self.initialized = YES;
        //self.hidden = YES; 
        self.zoom = contents.zoom;
        [self initCircle];
    }
    return self;
}

-(void)initCircle
{
    RMCircle *tempCircle = [[RMCircle alloc] initWithContents:self.contents radiusInMeters:self.radius latLong:self.pinLocation];
    self.circle = tempCircle;
    self.circle.fillColor = self.fillColor;
    self.circle.lineColor = self.lineColor;
//    if(self.zoom < 14.8f){self.circle.hidden = YES;}
//    else{self.circle.hidden = NO;}
    self.circle.lineWidthInPixels = self.lineWidth;
    
    [self.contents.markerManager addMarker:self.circle AtLatLong:self.pinLocation]; 
    [tempCircle release];
}

-(void)dealloc
{
    [self.circle release];
    self.initialized = NO;
    [fillColor release];
    [lineColor release];
    [self.contents release];
    [super dealloc];
}



@end
