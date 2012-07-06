//
//  RMLocationMarker.m
//  MapView
//
//  Created by Philip on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RMLocationMarker.h"
#import "RMCircle.h"
#import <QuartzCore/QuartzCore.h>

@interface RMLocationMarker() {}
@property (nonatomic, retain) RMMapView* map;
@end

@implementation RMLocationMarker {
    CALayer* innerCircle;
    CALayer* haloRing;
    CAShapeLayer* ringShape;
}

@synthesize map;

/**
 *  Second phase of animation
 */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        [ringShape setStrokeColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.3f].CGColor];
        [ringShape setFillColor:[UIColor colorWithRed:0.80f green:0.78f blue:0.78f alpha:0.7f].CGColor];
        [ringShape setLineWidth:8.5f];
        
        CABasicAnimation* signalAnimationScale = [[CABasicAnimation alloc] init];
        [signalAnimationScale setDuration:1.55f];
        [signalAnimationScale setRepeatCount:INT_MAX];
        [signalAnimationScale setKeyPath:@"transform.scale"];
        [signalAnimationScale setFromValue:[NSNumber numberWithFloat:0.0f]];
        [signalAnimationScale setToValue:[NSNumber numberWithFloat:1.0f]];
        
        CABasicAnimation* signalAnimationAlpha = [[CABasicAnimation alloc] init];
        [signalAnimationAlpha setDuration:1.55f];
        [signalAnimationAlpha setRepeatCount:INT_MAX];
        [signalAnimationAlpha setKeyPath:@"opacity"];
        [signalAnimationAlpha setFromValue:[NSNumber numberWithFloat:1.0f]];
        [signalAnimationAlpha setToValue:[NSNumber numberWithFloat:0.0f]];
        
        [haloRing addAnimation:signalAnimationScale forKey:@"signal.scale"];
        [haloRing addAnimation:signalAnimationAlpha forKey:@"signal.alpha"];
        
        [signalAnimationScale release];
        [signalAnimationAlpha release];
    }
}

/**
 *  Create location marker and start initial zoom in animation
 */
- (id)initWithView:(RMMapView *)aMapView {
    if (self = [super init]) {
        [self setMap:aMapView];
        [self setBounds:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
        [self setMasksToBounds:NO];
        
        innerCircle = [[CALayer alloc] init];        
        UIImage *indicatorImage = [UIImage imageNamed:@"blue_position_indicator"];
        [innerCircle setContents:(id)indicatorImage.CGImage];
        [innerCircle setFrame:CGRectMake(0.0f, 0.0f, indicatorImage.size.width, indicatorImage.size.height)];
        [innerCircle setPosition:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
        
        haloRing = [[CALayer alloc] init];
        [haloRing setFrame:self.bounds];
        
        ringShape = [[CAShapeLayer alloc] init];
        CGMutablePathRef haloRingPath = CGPathCreateMutable();
        CGPathAddEllipseInRect(haloRingPath, nil, haloRing.bounds);
        [ringShape setPath:haloRingPath];
        [ringShape setStrokeColor:[UIColor colorWithRed:0.343f green:0.5663 blue:0.8588f alpha:0.75f].CGColor];
        [ringShape setFillColor:[UIColor colorWithRed:0.545f green:0.6824f blue:0.8588f alpha:0.25f].CGColor];
        [ringShape setLineWidth:0.5f];
        CGPathRelease(haloRingPath);
        
        [haloRing addSublayer:ringShape];
        [self addSublayer:haloRing];
        [self addSublayer:innerCircle];
        
        CABasicAnimation* initialAnimation = [[CABasicAnimation alloc] init];
        [initialAnimation setKeyPath:@"transform.scale"];
        [initialAnimation setRepeatCount:1];
        [initialAnimation setDuration:0.85f];
        [initialAnimation setFromValue:[NSNumber numberWithFloat:4.0f]];
        [initialAnimation setToValue:[NSNumber numberWithFloat:0.25f]];
        [initialAnimation setDelegate:self];
        [initialAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [initialAnimation setRemovedOnCompletion:NO];
        [initialAnimation setFillMode:kCAFillModeForwards];
        
        [haloRing addAnimation:initialAnimation forKey:@"initial.animation"];
    }
    
    return self;
}

- (void)dealloc {
    [innerCircle release], innerCircle = nil;
    [haloRing release], haloRing = nil;
    [self setMap:nil];
    [super dealloc];
}

@end
