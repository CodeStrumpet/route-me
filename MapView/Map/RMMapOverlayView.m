//
//  RMMapOverlayView.m
//  MapView
//
//  Created by Thomas Rasch on 25.08.11.
//  Copyright (c) 2011 Alpstein. All rights reserved.
//

#import "RMMapOverlayView.h"
#import "RMMarker.h"
#import "RMAnnotation.h"
#import "RMPixel.h"

@interface RMMapOverlayView ()

- (void)handleSingleTap:(UIGestureRecognizer *)recognizer;
- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer;

@end

@implementation RMMapOverlayView
{
    BOOL _trackPanGesture;
    CGPoint _lastTranslation;
    RMAnnotation *_draggedAnnotation;
}

@synthesize delegate;

+ (Class)layerClass
{
    return [CAScrollLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
        return nil;

    self.layer.masksToBounds = YES;

    _trackPanGesture = NO;
    _lastTranslation = CGPointZero;
    _draggedAnnotation = nil;

    /*
    UITapGestureRecognizer *singleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)] autorelease];
    [self addGestureRecognizer:singleTapRecognizer];    
    */
    
    // Disable the panGestureRecognizer to allow for dragging the map while touch is on top of an overlay
    
    /*
    UIPanGestureRecognizer *panGestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)] autorelease];
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:panGestureRecognizer];
    */
    
    // Disable the doubleTapRecognizer to improve single tap performance
    /*
    UITapGestureRecognizer *doubleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)] autorelease];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    [self addGestureRecognizer:doubleTapRecognizer];
    */

    return self;
}

- (void)dealloc
{
    [_draggedAnnotation release]; _draggedAnnotation = nil;
    [super dealloc];
}

- (unsigned)sublayersCount
{
    return [self.layer.sublayers count];
}

- (void)addSublayer:(CALayer *)aLayer
{
    [self.layer addSublayer:aLayer];
}

- (void)insertSublayer:(CALayer *)aLayer atIndex:(unsigned)index
{
    [self.layer insertSublayer:aLayer atIndex:index];
}

- (void)insertSublayer:(CALayer *)aLayer below:(CALayer *)sublayer
{
    [self.layer insertSublayer:aLayer below:sublayer];
}

- (void)insertSublayer:(CALayer *)aLayer above:(CALayer *)sublayer
{
    [self.layer insertSublayer:aLayer above:sublayer];
}

- (void)moveLayersBy:(CGPoint)delta
{
    [self.layer scrollPoint:CGPointMake(-delta.x, -delta.y)];
}

- (void)replaceSublayer:(CALayer *)oldLayer with:(CALayer *)newLayer {
    [self.layer replaceSublayer:oldLayer with:newLayer];
}

- (BOOL)containsSublayer:(CALayer *)aLayer {
    BOOL contains = NO;
    if (aLayer) {
        contains = [self.layer.sublayers containsObject:aLayer];
    }
    return contains;
}

NSInteger layerSort(id num1, id num2, void *context) {
	if ([num1 isKindOfClass:[RMMarker class]] && [num2 isKindOfClass:[RMMarker class]]) {
		// if both are markers, order based on vertical map position
		RMMarker *first = (RMMarker *)num1;
		RMMarker *second = (RMMarker *)num2;
        
		double firstPos = first.annotation.projectedLocation.y;
		double secondPos = second.annotation.projectedLocation.y;
        
		if (firstPos > secondPos) {
			return NSOrderedAscending;
		} else if (firstPos < secondPos) {
			return NSOrderedDescending;
		} else {
			return NSOrderedSame;
		}
	} else {
		// if something isnt a marker, send to bottom
		if ([num1 isKindOfClass:[RMMarker class]]) {
			return NSOrderedDescending;
		} else if ([num2 isKindOfClass:[RMMarker class]]) {
			return NSOrderedAscending;
		} else {
			return NSOrderedSame;
		}
	}
}

- (void)orderLayers {
    NSArray *sortedSublayers = [self.layer.sublayers sortedArrayUsingFunction:layerSort context:NULL];
    for (CALayer *sublayer in self.layer.sublayers) {
        sublayer.zPosition = [sortedSublayers indexOfObject:sublayer];
    }
}


#pragma mark -
#pragma mark Event handling

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return NO;  // handle all touch interaction on other layers
    
    if ([[event touchesForView:self] count] > 1)
        return NO;

    CALayer *hit = [self.layer hitTest:point];

    if (!hit || ![hit isKindOfClass:[RMMarker class]])
        return NO;
    
    return ((RMMarker *)hit).annotation.enabled;   
}

- (RMAnnotation *)findAnnotationInLayer:(CALayer *)layer
{
    if ([layer respondsToSelector:@selector(annotation)])
        return [((RMMarker *)layer) annotation];

    CALayer *superlayer = [layer superlayer];

    if (superlayer != nil && [superlayer respondsToSelector:@selector(annotation)])
        return [((RMMarker *)superlayer) annotation];
    else if ([superlayer superlayer] != nil && [[superlayer superlayer] respondsToSelector:@selector(annotation)])
        return [((RMMarker *)[superlayer superlayer]) annotation];

    return nil;
}

- (void)handleSingleTap:(UIGestureRecognizer *)recognizer
{
    CALayer *hit = [self.layer hitTest:[recognizer locationInView:self]];

    if (!hit)
        return;

    CALayer *superlayer = [hit superlayer];

    // See if tap was on a marker or marker label and send delegate protocol method
    if ([hit isKindOfClass:[RMMarker class]])
    {
        if ([delegate respondsToSelector:@selector(mapOverlayView:tapOnAnnotation:atPoint:)])
            [delegate mapOverlayView:self tapOnAnnotation:[((RMMarker *)hit) annotation] atPoint:[recognizer locationInView:self]];
    }
    else if (superlayer != nil && [superlayer isKindOfClass:[RMMarker class]])
    {
        if ([delegate respondsToSelector:@selector(mapOverlayView:tapOnLabelForAnnotation:atPoint:)])
            [delegate mapOverlayView:self tapOnLabelForAnnotation:[((RMMarker *)superlayer) annotation] atPoint:[recognizer locationInView:self]];
    }
    else if ([superlayer superlayer] != nil && [[superlayer superlayer] isKindOfClass:[RMMarker class]])
    {
        if ([delegate respondsToSelector:@selector(mapOverlayView:tapOnLabelForAnnotation:atPoint:)])
            [delegate mapOverlayView:self tapOnLabelForAnnotation:[((RMMarker *)[superlayer superlayer]) annotation] atPoint:[recognizer locationInView:self]];
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer
{
    CALayer *hit = [self.layer hitTest:[recognizer locationInView:self]];

    if (!hit)
        return;

    CALayer *superlayer = [hit superlayer];

    // See if tap was on a marker or marker label and send delegate protocol method
    if ([hit isKindOfClass:[RMMarker class]])
    {
        if ([delegate respondsToSelector:@selector(mapOverlayView:doubleTapOnAnnotation:atPoint:)])
            [delegate mapOverlayView:self doubleTapOnAnnotation:[((RMMarker *)hit) annotation] atPoint:[recognizer locationInView:self]];
    }
    else if (superlayer != nil && [superlayer isKindOfClass:[RMMarker class]])
    {
        if ([delegate respondsToSelector:@selector(mapOverlayView:doubleTapOnLabelForAnnotation:atPoint:)])
            [delegate mapOverlayView:self doubleTapOnLabelForAnnotation:[((RMMarker *)superlayer) annotation] atPoint:[recognizer locationInView:self]];
    }
    else if ([superlayer superlayer] != nil && [[superlayer superlayer] isKindOfClass:[RMMarker class]])
    {
        if ([delegate respondsToSelector:@selector(mapOverlayView:doubleTapOnLabelForAnnotation:atPoint:)])
            [delegate mapOverlayView:self doubleTapOnLabelForAnnotation:[((RMMarker *)[superlayer superlayer]) annotation] atPoint:[recognizer locationInView:self]];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CALayer *hit = [self.layer hitTest:[recognizer locationInView:self]];

        if (!hit)
            return;

        if ([hit respondsToSelector:@selector(enableDragging)] && ![(RMMarker *)hit enableDragging])
            return;

        _lastTranslation = CGPointZero;
        [_draggedAnnotation release];
        _draggedAnnotation = [[self findAnnotationInLayer:hit] retain];

        if ([delegate respondsToSelector:@selector(mapOverlayView:shouldDragAnnotation:)])
            _trackPanGesture = [delegate mapOverlayView:self shouldDragAnnotation:_draggedAnnotation];
        else
            _trackPanGesture = NO;
    }

    if (!_trackPanGesture)
        return;

    if (recognizer.state == UIGestureRecognizerStateChanged && [delegate respondsToSelector:@selector(mapOverlayView:didDragAnnotation:withDelta:)])
    {
        CGPoint translation = [recognizer translationInView:self];
        CGPoint delta = CGPointMake(_lastTranslation.x - translation.x, _lastTranslation.y - translation.y);
        _lastTranslation = translation;

        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        [delegate mapOverlayView:self didDragAnnotation:_draggedAnnotation withDelta:delta];
        [CATransaction commit];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded && [delegate respondsToSelector:@selector(mapOverlayView:didEndDragAnnotation:)])
    {
        [delegate mapOverlayView:self didEndDragAnnotation:_draggedAnnotation];
        _trackPanGesture = NO;
        [_draggedAnnotation release]; _draggedAnnotation = nil;
    }
}

@end
