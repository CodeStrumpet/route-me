//
//  RMMarkerManager.h
//
// Copyright (c) 2008-2009, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import <UIKit/UIKit.h>

#import "RMMapContents.h"
#import "RMMarker.h"

@class RMProjection;

@interface RMMarkerManager : NSObject {
	RMMapContents *contents;
    NSMutableArray *userDotLayers;
        CGAffineTransform rotationTransform;
}

@property (assign, readwrite)  RMMapContents *contents;
@property (nonatomic, retain)  NSMutableArray *userDotLayers;

- (id)initWithContents:(RMMapContents *)mapContents;

- (void)addMarker:(RMMarker *)marker atProjectedPoint:(RMProjectedPoint)projectedPoint;
- (void) addMarker: (RMMarker*)marker AtLatLong:(CLLocationCoordinate2D)point;
- (void) removeMarkers;
- (void) hideAllMarkers;
- (void) unhideAllMarkers;

- (NSArray *)markers;
- (NSArray *)markersWithUserDotExcluded;
- (void) removeMarker:(RMMarker *)marker;
- (void) removeMarkers:(NSArray *)markers;
- (CGPoint) screenCoordinatesForMarker: (RMMarker *)marker;
- (CLLocationCoordinate2D) latitudeLongitudeForMarker: (RMMarker *) marker;
- (NSArray *) markersWithinScreenBounds;
- (BOOL) isMarkerWithinScreenBounds:(RMMarker*)marker;
- (BOOL) isMarker:(RMMarker*)marker withinBounds:(CGRect)rect;
- (BOOL) managingMarker:(RMMarker*)marker;
- (void) moveMarker:(RMMarker *)marker AtLatLon:(RMLatLong)point;
- (void) moveMarker:(RMMarker *)marker AtXY:(CGPoint)point;
- (void)setRotation:(float)angle;



@end
