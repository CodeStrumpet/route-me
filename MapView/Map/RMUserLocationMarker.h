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
#import "RMMercatorToScreenProjection.h"
#import "RMProjection.h"
#import "RMLayerCollection.h"

@interface RMUserLocationMarker :RMMarker{
    
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
    RMMarker *dot;
    RMCircle *blinkCircle;
    RMCircle *firstcircle;
    UIImage *image;
}

@property (nonatomic, retain) RMMapContents *contents;
@property(nonatomic) CLLocationCoordinate2D pinCoordinate;
@property(nonatomic) CGFloat radius, lineWidth, blinkRadius;
@property(nonatomic) BOOL initialized;
@property(nonatomic) float zoom;
@property(nonatomic, retain) UIColor *fillColor;
@property(nonatomic, retain) UIColor *lineColor;
@property(nonatomic, retain) RMCircle *circle;
@property(nonatomic, retain) RMMarker *dot;
@property(nonatomic, retain) RMCircle *blinkCircle;
@property(nonatomic, retain)RMCircle *firstcircle;
@property(nonatomic,retain) UIImage *image;


-(id)initWithContents: (RMMapContents *) content pinLocation:(CLLocationCoordinate2D) point originalRadius:(CGFloat) radiusOfCircle;
-(void)updateLocation:(CLLocationCoordinate2D) point newRadius:(CGFloat) radiusOfCircle;
-(void)initCircle;
-(void)initdot;
-(void)initFirstCircle;
-(void)initBlinkCircle;
-(void)addAnimationToBlinkCircle;
-(void)removeBlink;
-(void)updateMainCircleSize;
-(void)updateCircles;
-(void)removeFirstCircle;
-(void)secondStepRingTransition;
-(void)removeGPSMarker:(RMUserLocationMarker*)gpsMarker;
-(void)removeGpsMarker;

- (void)addOverlay:(RMMapLayer *)layer atProjectedPoint:(RMProjectedPoint)projectedPoint;
- (void) addOverlay: (RMMapLayer*)layer AtLatLong:(CLLocationCoordinate2D)point;

- (void) moveOverlay:(RMMapLayer *)layer AtLatLon:(RMLatLong)point;
- (void) moveOverlay:(RMMapLayer *)layer AtXY:(CGPoint)point;

- (void) removeOverlay:(RMMapLayer *)layer;
- (void) removeOverlays:(NSArray *)layers;

@end
