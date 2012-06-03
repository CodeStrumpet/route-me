///
//  RMShape.m
//
// Copyright (c) 2008-2012, Route-Me Contributors
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

#import "RMShape.h"
#import "RMPixel.h"
#import "RMProjection.h"
#import "RMMapView.h"
#import "RMAnnotation.h"

@implementation RMShape

@synthesize scaleLineWidth;
@synthesize scaleLineDash;
@synthesize pathBoundingBox;
@synthesize lineDashLengths;

#define kDefaultLineWidth 2.0

- (id)initWithView:(RMMapView *)aMapView
{
    if (!(self = [super init]))
        return nil;
    
    shapeLayer = [[CAShapeLayer alloc] init];
    [self addSublayer:shapeLayer];
    shapeLayer.shouldRasterize = YES;
    mapView = aMapView;
    bezierPath = [[UIBezierPath alloc] init];

    pathBoundingBox = CGRectZero;
    ignorePathUpdates = NO;
    previousBounds = CGRectZero;

    lineWidth = kDefaultLineWidth;
    shapeLayer.lineWidth = kDefaultLineWidth;
    shapeLayer.lineCap = kCALineCapButt;
    shapeLayer.lineJoin = kCALineJoinMiter;
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;

    self.masksToBounds = NO;

    scaleLineWidth = NO;
    scaleLineDash = NO;
    isFirstPoint = YES;

    if ([self respondsToSelector:@selector(setContentsScale:)])
        [(id)self setValue:[[UIScreen mainScreen] valueForKey:@"scale"] forKey:@"contentsScale"];
    
    return self;
}

- (void)dealloc
{
    mapView = nil;
    [bezierPath release]; bezierPath = nil;
    [shapeLayer release]; shapeLayer = nil;
    [super dealloc];
}

- (id <CAAction>)actionForKey:(NSString *)key
{
//    if ([key isEqualToString:@"position"] || [key isEqualToString:@"bounds"])
//        return [super actionForKey:key];
//    else
        return nil;
}


#pragma mark -

- (void)recalculateGeometry
{
    
    if (ignorePathUpdates)
        return;
    
    CGPoint newPosition = self.annotation.position;

    float scale = 1.0f / [mapView metersPerPixel];
    float scaledLineWidth;
    CGRect pixelBounds, screenBounds;
    float offset;
    const float outset = 100.0f; // provides a buffer off screen edges for when path is scaled or moved
    
    if (scaleLineWidth)
        scaledLineWidth = lineWidth * scale;
    else
        scaledLineWidth = lineWidth;

    // The bounds are actually in mercators...
    /// \bug if "bounds are actually in mercators", shouldn't be using a CGRect
    CGRect boundsInMercators = bezierPath.bounds;

    boundsInMercators = CGRectInset(boundsInMercators, -scaledLineWidth, -scaledLineWidth);
    pixelBounds = CGRectInset(boundsInMercators, -scaledLineWidth, -scaledLineWidth);
    pixelBounds = RMScaleCGRectAboutPoint(pixelBounds, scale, CGPointZero);

    CGRect previousNonClippedBounds = nonClippedBounds;
    nonClippedBounds = pixelBounds;
    
    // Clip bound rect to screen bounds.
    // If bounds are not clipped, they won't display when you zoom in too much.
    screenBounds = [mapView frame];
    
    //    RMLog(@"x:%f y:%f screen bounds: %f %f %f %f", myPosition.x, myPosition.y,  screenBounds.origin.x, screenBounds.origin.y, screenBounds.size.width, screenBounds.size.height);
    
    // Clip top
    offset = newPosition.y + pixelBounds.origin.y - screenBounds.origin.y + outset;
    if (offset < 0.0f)
    {
        pixelBounds.origin.y -= offset;
        pixelBounds.size.height += offset;
    }
    
    // Clip left
    offset = newPosition.x + pixelBounds.origin.x - screenBounds.origin.x + outset;
    if (offset < 0.0f)
    {
        pixelBounds.origin.x -= offset;
        pixelBounds.size.width += offset;
    }

    // Clip bottom
    offset = newPosition.y + pixelBounds.origin.y + pixelBounds.size.height - screenBounds.origin.y - screenBounds.size.height - outset;
    if (offset > 0.0f)
    {
        pixelBounds.size.height -= offset;
    }

    // Clip right
    offset = newPosition.x + pixelBounds.origin.x + pixelBounds.size.width - screenBounds.origin.x - screenBounds.size.width - outset;
    if (offset > 0.0f)
    {
        pixelBounds.size.width -= offset;
    }
    
    CGRect clippedBounds = pixelBounds;
    
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    positionAnimation.repeatCount = 0;
    positionAnimation.autoreverses = NO;
    positionAnimation.fromValue = [NSValue valueWithCGPoint:self.position];
    positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
    [super setPosition:newPosition];
    [self addAnimation:positionAnimation forKey:@"animatePosition"];
    
    // bounds are animated non-clipped but set with clipping
    CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundsAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    boundsAnimation.repeatCount = 0;
    boundsAnimation.autoreverses = NO;
    boundsAnimation.fromValue = [NSValue valueWithCGRect:previousNonClippedBounds];
    boundsAnimation.toValue = [NSValue valueWithCGRect:nonClippedBounds];
    self.bounds = clippedBounds;
    [self addAnimation:boundsAnimation forKey:@"animateBounds"];
    
    //    RMLog(@"new bounds: %f %f %f %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    
    CGPoint previousNonClippedAnchorPoint = CGPointMake(-previousNonClippedBounds.origin.x / previousNonClippedBounds.size.width, -previousNonClippedBounds.origin.y / previousNonClippedBounds.size.height);
    CGPoint nonClippedAnchorPoint = CGPointMake(-nonClippedBounds.origin.x / nonClippedBounds.size.width, -nonClippedBounds.origin.y / nonClippedBounds.size.height);
    CGPoint clippedAnchorPoint = CGPointMake(-pixelBounds.origin.x / pixelBounds.size.width, -pixelBounds.origin.y / pixelBounds.size.height);
    
    // anchorPoint is animated non-clipped but set with clipping
    CABasicAnimation *anchorPointAnimation = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
    anchorPointAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anchorPointAnimation.repeatCount = 0;
    anchorPointAnimation.autoreverses = NO;
    anchorPointAnimation.fromValue = [NSValue valueWithCGPoint:previousNonClippedAnchorPoint];
    anchorPointAnimation.toValue = [NSValue valueWithCGPoint:nonClippedAnchorPoint];
    self.anchorPoint = clippedAnchorPoint;
    [self addAnimation:anchorPointAnimation forKey:@"animateAnchorPoint"];
    
    // scale path
    
    shapeLayer.lineWidth = scaledLineWidth;
    
    // NSLog(@"line width = %f, content scale = %f", scaledLineWidth, [mapView metersPerPixel]);
    
    if (lineDashLengths)
    {
        if (scaleLineDash)
        {
            NSMutableArray *scaledLineDashLengths = [NSMutableArray array];
            
            for (NSNumber *lineDashLength in lineDashLengths)
                [scaledLineDashLengths addObject:[NSNumber numberWithFloat:lineDashLength.floatValue * scale]];
            
            shapeLayer.lineDashPattern = scaledLineDashLengths;
        }
        else
        {
            shapeLayer.lineDashPattern = lineDashLengths;
        }
    }
    
    CGAffineTransform scaling = CGAffineTransformMakeScale(scale, scale);
    UIBezierPath *scaledPath = [bezierPath copy];
    [scaledPath applyTransform:scaling];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.repeatCount = 0;
    animation.autoreverses = NO;
    animation.fromValue = (id) shapeLayer.path;
    animation.toValue = (id) scaledPath.CGPath;
    shapeLayer.path = scaledPath.CGPath;
    [shapeLayer addAnimation:animation forKey:@"animatePath"];
    
    [scaledPath release];
    
    [self setNeedsDisplay];
}


#pragma mark -

- (void)addPointToProjectedPoint:(RMProjectedPoint)point withDrawing:(BOOL)isDrawing
{
    //	RMLog(@"addLineToXY %f %f", point.x, point.y);

    if (isFirstPoint)
    {
        isFirstPoint = FALSE;
        projectedLocation = point;

        self.position = [mapView projectedPointToPixel:projectedLocation];
        // RMLog(@"screen position set to %f %f", self.position.x, self.position.y);
        [bezierPath moveToPoint:CGPointMake(0.0f, 0.0f)];
    }
    else
    {
        point.x = point.x - projectedLocation.x;
        point.y = point.y - projectedLocation.y;

        if (isDrawing)
            [bezierPath addLineToPoint:CGPointMake(point.x, -point.y)];
        else
            [bezierPath moveToPoint:CGPointMake(point.x, -point.y)];

        [self recalculateGeometry];
    }

    [self setNeedsDisplay];
}

- (void)moveToProjectedPoint:(RMProjectedPoint)projectedPoint
{
    [self addPointToProjectedPoint:projectedPoint withDrawing:NO];
}

- (void)moveToScreenPoint:(CGPoint)point
{
    RMProjectedPoint mercator = [mapView pixelToProjectedPoint:point];
    [self moveToProjectedPoint:mercator];
}

- (void)moveToCoordinate:(CLLocationCoordinate2D)coordinate
{
    RMProjectedPoint mercator = [[mapView projection] coordinateToProjectedPoint:coordinate];
    [self moveToProjectedPoint:mercator];
}

- (void)addLineToProjectedPoint:(RMProjectedPoint)projectedPoint
{
    [self addPointToProjectedPoint:projectedPoint withDrawing:YES];
}

- (void)addLineToScreenPoint:(CGPoint)point
{
    RMProjectedPoint mercator = [mapView pixelToProjectedPoint:point];
    [self addLineToProjectedPoint:mercator];
}

- (void)addLineToCoordinate:(CLLocationCoordinate2D)coordinate
{
    RMProjectedPoint mercator = [[mapView projection] coordinateToProjectedPoint:coordinate];
    [self addLineToProjectedPoint:mercator];
}

- (void)performBatchOperations:(void (^)(RMShape *aShape))block
{
    ignorePathUpdates = YES;
    block(self);
    ignorePathUpdates = NO;

    [self recalculateGeometry];
}

#pragma mark - Accessors

- (void)closePath
{
    [bezierPath closePath];
}

- (float)lineWidth
{
    return lineWidth;
}

- (void)setLineWidth:(float)newLineWidth
{
    lineWidth = newLineWidth;
    [self recalculateGeometry];
}

- (NSString *)lineCap
{
    return shapeLayer.lineCap;
}

- (void)setLineCap:(NSString *)newLineCap
{
    shapeLayer.lineCap = newLineCap;
    [self setNeedsDisplay];
}

- (NSString *)lineJoin
{
    return shapeLayer.lineJoin;
}

- (void)setLineJoin:(NSString *)newLineJoin
{
    shapeLayer.lineJoin = newLineJoin;
    [self setNeedsDisplay];
}

- (UIColor *)lineColor
{
    return [UIColor colorWithCGColor:shapeLayer.strokeColor];
}

- (void)setLineColor:(UIColor *)aLineColor
{
    if (shapeLayer.strokeColor != aLineColor.CGColor)
    {
        shapeLayer.strokeColor = aLineColor.CGColor;
        [self setNeedsDisplay];
    }
}

- (UIColor *)fillColor
{
    return [UIColor colorWithCGColor:shapeLayer.fillColor];
}

- (void)setFillColor:(UIColor *)aFillColor
{
    if (shapeLayer.fillColor != aFillColor.CGColor)
    {
        shapeLayer.fillColor = aFillColor.CGColor;
        [self setNeedsDisplay];
    }
}

- (NSString *)fillRule
{
    return shapeLayer.fillRule;
}

- (void)setFillRule:(NSString *)fillRule
{
    shapeLayer.fillRule = fillRule;
}

- (CGFloat)lineDashPhase
{
    return shapeLayer.lineDashPhase;
}

- (void)setLineDashPhase:(CGFloat)dashPhase
{
    shapeLayer.lineDashPhase = dashPhase;
}

- (void)setPosition:(CGPoint)newPosition
{
    if (CGPointEqualToPoint(newPosition, super.position) && CGRectEqualToRect(self.bounds, previousBounds))
        return;

    [self recalculateGeometry];
}

@end
