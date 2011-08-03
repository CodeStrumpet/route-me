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
@synthesize pinCoordinate;
@synthesize radius,blinkRadius,lineWidth;
@synthesize initialized;
@synthesize zoom;
@synthesize fillColor, lineColor;
@synthesize circle;
@synthesize dot;
@synthesize blinkCircle;
@synthesize firstcircle;
@synthesize image;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(id)initWithContents:(RMMapContents *)content pinLocation:(CLLocationCoordinate2D)point originalRadius:(CGFloat)radiusOfCircle{
    self = [super init];
    if (self) {
        self.contents = content;
        self.radius = radiusOfCircle;
        self.pinCoordinate = point;
        self.blinkRadius = 200.0f/self.contents.zoom;
        self.lineWidth = 1;
        self.fillColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.05];
        self.lineColor = [UIColor colorWithRed:0.5 green:0.5 blue:1 alpha:1];
        self.initialized = YES;
        self.zoom = contents.zoom;
        UIImage *blueDot = [UIImage imageNamed:@"blue_position_indicator.png"];
        self.image = blueDot;
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
        self.pinCoordinate = point;
        [self moveOverlay:self.dot AtLatLon:self.pinCoordinate];
        [self moveOverlay:self.circle AtLatLon:self.pinCoordinate];
        [self updateMainCircleSize];
        self.blinkCircle.radiusInMeters = self.blinkRadius;
        self.blinkCircle.hidden = NO;
        [self addAnimationToBlinkCircle];
        [self moveOverlay:self.blinkCircle AtLatLon:self.pinCoordinate];
        [self performSelector:@selector(removeBlink) withObject:nil afterDelay:(float)8.0f];
    }
}

-(void)initCircle
{
    RMCircle *tempCircle = [[RMCircle alloc] initWithContents:self.contents radiusInMeters:self.radius latLong:self.pinCoordinate];
    self.circle = tempCircle;
    self.circle.fillColor = self.fillColor;
    self.circle.lineColor = self.lineColor;
    if(self.zoom < 14.8f){self.circle.hidden = YES;}
    else{self.circle.hidden = NO;}
    self.circle.lineWidthInPixels = self.lineWidth;
    
    [self addOverlay:self.circle AtLatLong:self.pinCoordinate]; 
    [tempCircle release];
}

-(void)initdot
{ 
    RMMarker *tempDot = [[RMMarker alloc] initWithUIImage:self.image];
    self.dot = tempDot;
    self.dot.hidden = YES;
    [self addOverlay:self.dot AtLatLong:self.pinCoordinate]; 
    [tempDot release];
}

-(void)initBlinkCircle
{
    [self updateMainCircleSize];
    RMCircle *tempCircle2 = [[RMCircle alloc] initWithContents:self.contents radiusInMeters:self.blinkRadius latLong:self.pinCoordinate];
    self.blinkCircle = tempCircle2;
    self.blinkCircle.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.blinkCircle.lineColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    self.blinkCircle.shadowColor=[UIColor colorWithRed:0 green:0 blue:1 alpha:0.8].CGColor;
    self.blinkCircle.shadowOpacity= 10;
    self.blinkCircle.lineWidthInPixels = self.lineWidth + 1.5;
    [self addAnimationToBlinkCircle];
    [self addOverlay:self.blinkCircle AtLatLong:self.pinCoordinate]; 
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
    RMCircle *tempC = [[RMCircle alloc] initWithContents:self.contents radiusInMeters:(self.blinkRadius * 200) latLong:self.pinCoordinate];
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
    
    [self addOverlay: self.firstcircle AtLatLong:self.pinCoordinate]; 
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
    [self removeOverlay:self.firstcircle];
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
    [self removeOverlay:gpsMarker.circle];
    [self removeOverlay:gpsMarker.dot];
    [self removeOverlay:gpsMarker.blinkCircle];
}

-(void)removeGpsMarker
{
    [self removeOverlay: self.circle];
    [self removeOverlay: self.dot];
    [self removeOverlay: self.blinkCircle];
}

-(void)dealloc
{
    [self.image release];
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


- (void)addOverlay:(RMMapLayer *)layer atProjectedPoint:(RMProjectedPoint)projectedPoint {
	[layer setProjectedLocation:projectedPoint];
	[layer setPosition:[[contents mercatorToScreenProjection] projectXYPoint:projectedPoint]];
	[[self.contents overlay] addSublayer:layer];
}

- (void) addOverlay: (RMMapLayer*)layer AtLatLong:(CLLocationCoordinate2D)point
{
	[self addOverlay:layer atProjectedPoint:[[self.contents projection] latLongToPoint:point]];
}


- (void) moveOverlay:(RMMapLayer *)layer AtLatLon:(RMLatLong)point
{
	[layer setProjectedLocation:[[contents projection]latLongToPoint:point]];
	[layer setPosition:[[contents mercatorToScreenProjection] projectXYPoint:[[contents projection] latLongToPoint:point]]];
}

- (void) moveOverlay:(RMMapLayer *)layer AtXY:(CGPoint)point
{
	[layer setProjectedLocation:[[contents mercatorToScreenProjection] projectScreenPointToXY:point]];
	[layer setPosition:point];
}

- (void) removeOverlay:(RMMapLayer *)layer
{
	[[contents overlay] removeSublayer:layer];
}

- (void) removeOverlays:(NSArray *)layers
{
	[[contents overlay] removeSublayers:layers];
}

@end
