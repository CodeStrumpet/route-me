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
@synthesize dot;
@synthesize blinkCircle;
@synthesize firstcircle;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(id)initWithMarkerManager:(RMMapContents *)content pinLocation:(CLLocationCoordinate2D)point originalRadius:(CGFloat)radiusOfCircle{
    self = [super init];
    if (self) {
        self.contents = content;
        self.radius = radiusOfCircle;
        self.pinLocation = point;
        self.blinkRadius = 200.0f/self.contents.zoom;
        self.lineWidth = 1;
        self.fillColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.05];
        self.lineColor = [UIColor colorWithRed:0.5 green:0.5 blue:1 alpha:1];
        self.initialized = YES;
        self.zoom = contents.zoom;
        [self initFirstCircle];
        [self initCircle];
        [self initdot];
        [self initBlinkCircle];
    }
    return self;
}

-(void)updateLocation:(CLLocationCoordinate2D)point newRadius:(CGFloat)radiusOfCircle
{
    if(initialized)
    {
        self.radius = radiusOfCircle;
        if(self.zoom < 14.8f){self.circle.hidden = YES;}
        else{self.circle.hidden = NO;}
        self.circle.radiusInMeters = self.radius;
        self.pinLocation = point;
        [self.contents.markerManager moveMarker:self.dot AtLatLon:self.pinLocation];
        [self.contents.markerManager moveMarker:self.circle AtLatLon:self.pinLocation];
        [self updateMainCircleSize];
        self.blinkCircle.radiusInMeters = self.blinkRadius;
        self.blinkCircle.hidden = NO;
        [self addAnimationToBlinkCircle];
        [self.contents.markerManager moveMarker:self.blinkCircle AtLatLon:self.pinLocation];
        [self performSelector:@selector(removeBlink) withObject:nil afterDelay:(float)8.0f];
    }
}

-(void)initCircle
{
    RMCircle *tempCircle = [[RMCircle alloc] initWithContents:self.contents radiusInMeters:self.radius latLong:self.pinLocation];
    self.circle = tempCircle;
    self.circle.fillColor = self.fillColor;
    self.circle.lineColor = self.lineColor;
    if(self.zoom < 14.8f){self.circle.hidden = YES;}
    else{self.circle.hidden = NO;}
    self.circle.lineWidthInPixels = self.lineWidth;
    
    [self.contents.markerManager addMarker:self.circle AtLatLong:self.pinLocation]; 
    [tempCircle release];
}

-(void)initdot
{
    UIImage *blueDot = [UIImage imageNamed:@"blue_position_indicator.png"]; 
    RMMarker *tempDot = [[RMMarker alloc] initWithUIImage:blueDot];
    self.dot = tempDot;
    self.dot.hidden = YES;
    [self.contents.markerManager addMarker:self.dot AtLatLong:self.pinLocation]; 
    [tempDot release];
}

-(void)initBlinkCircle
{
    [self updateMainCircleSize];
    RMCircle *tempCircle2 = [[RMCircle alloc] initWithContents:self.contents radiusInMeters:self.blinkRadius latLong:self.pinLocation];
    self.blinkCircle = tempCircle2;
    self.blinkCircle.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.blinkCircle.lineColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    self.blinkCircle.shadowColor=[UIColor colorWithRed:0 green:0 blue:1 alpha:0.8].CGColor;
    self.blinkCircle.shadowOpacity= 10;
    self.blinkCircle.lineWidthInPixels = self.lineWidth + 1.5;
    [self addAnimationToBlinkCircle];
    [self.contents.markerManager addMarker:self.blinkCircle AtLatLong:self.pinLocation]; 
    [self performSelector:@selector(removeBlink) withObject:nil afterDelay:(float)5.0f];
    [tempCircle2 release];
}

-(void)addAnimationToBlinkCircle
{
    CABasicAnimation *theAnimationForScalling;
    theAnimationForScalling=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    theAnimationForScalling.duration = 2;
    theAnimationForScalling.repeatCount= 5;
    theAnimationForScalling.removedOnCompletion = YES;
    theAnimationForScalling.fromValue=[NSNumber numberWithBool:NO];
    theAnimationForScalling.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.blinkCircle addAnimation:theAnimationForScalling forKey:@"transform.scale"];
    
    CABasicAnimation *theAnimationForOpaque;
    theAnimationForOpaque=[CABasicAnimation animationWithKeyPath:@"opacity"];
    theAnimationForOpaque.duration = 2;
    theAnimationForOpaque.repeatCount= 5;
    theAnimationForOpaque.removedOnCompletion = YES;
    theAnimationForOpaque.fromValue=[NSNumber numberWithFloat:1];
    theAnimationForOpaque.toValue = [NSNumber numberWithFloat:0];
    theAnimationForOpaque.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.blinkCircle addAnimation:theAnimationForOpaque forKey:@"opacityanim"];
}

-(void)removeBlink
{
    self.blinkCircle.hidden = YES;
}

-(void)initFirstCircle
{
    RMCircle *tempC = [[RMCircle alloc] initWithContents:self.contents radiusInMeters:(self.blinkRadius * 200) latLong:self.pinLocation];
    self.firstcircle = tempC;
    self.firstcircle.fillColor = self.fillColor;
    self.firstcircle.lineColor = self.lineColor;
    self.firstcircle.lineWidthInPixels = self.lineWidth+2;
    
    CABasicAnimation *theAnimationForScalling2;
    theAnimationForScalling2=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    theAnimationForScalling2.duration = 1;
    theAnimationForScalling2.repeatCount= 1;
    theAnimationForScalling2.removedOnCompletion = YES;
    theAnimationForScalling2.toValue=[NSNumber numberWithFloat:0.5];
    theAnimationForScalling2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.firstcircle addAnimation:theAnimationForScalling2 forKey:@"transform"];
    
    [self.contents.markerManager addMarker:self.firstcircle AtLatLong:self.pinLocation]; 
    [self performSelector:@selector(secondStepRingTransition) withObject:nil afterDelay:(float)0.95f];
    [tempC release];
    
}
-(void)secondStepRingTransition
{
    CABasicAnimation *theAnimationForScalling3;
    theAnimationForScalling3=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    theAnimationForScalling3.duration = 0.5;
    theAnimationForScalling3.repeatCount= 1;
    theAnimationForScalling3.removedOnCompletion = YES;
    theAnimationForScalling3.fromValue=[NSNumber numberWithFloat:0.5];
    
    theAnimationForScalling3.toValue=[NSNumber numberWithFloat:0];
    theAnimationForScalling3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.firstcircle addAnimation:theAnimationForScalling3 forKey:@"transform2"];
    [self performSelector:@selector(removeFirstCircle) withObject:nil afterDelay:(float)0.345f];
}

-(void)removeFirstCircle
{
    [self.contents.markerManager removeMarker:self.firstcircle];
    self.dot.hidden = NO;
}

-(void)updateMainCircleSize
{
    if(self.zoom < 16.0f){self.blinkRadius = 300.0f;}
    else if(self.zoom < 15.0f){self.blinkRadius = 600.0f;} 
    else if(self.zoom < 14.0f){self.blinkRadius = 800.0f;} 
    else if(self.zoom < 13.0f){self.blinkRadius = 1200.0f;} 
    else if(self.zoom < 11.0f){self.blinkRadius = 2000.0f;} 
    else{self.blinkRadius = self.radius / 2;}
}

-(void)updateCircles
{
    self.zoom = self.contents.zoom;
    if(self.zoom < 14.8f){self.circle.hidden = YES;}
    else{self.circle.hidden = NO;}
    [self updateMainCircleSize];
}

-(void)removeGPSMarker:(RMUserLocationMarker*)gpsMarker
{
    [self.contents.markerManager removeMarker:gpsMarker.circle];
    [self.contents.markerManager removeMarker:gpsMarker.dot];
    [self.contents.markerManager removeMarker:gpsMarker.blinkCircle];
    [self.contents.markerManager removeMarker:gpsMarker.firstcircle];
}

-(void)removeGpsMarker
{
    [self.contents.markerManager removeMarker: self.circle];
    [self.contents.markerManager removeMarker:self.dot];
    [self.contents.markerManager removeMarker:self.blinkCircle];
}

-(void)dealloc
{
    [self.firstcircle release];
    [self.blinkCircle release];
    [self.dot release];
    [self.circle release];
    self.initialized = NO;
    [fillColor release];
    [lineColor release];
    [self.contents release];
    [super dealloc];
}

@end
