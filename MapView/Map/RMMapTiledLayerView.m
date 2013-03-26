//
//  RMMapTiledLayerView.m
//  MapView
//
//  Created by Thomas Rasch on 17.08.11.
//  Copyright (c) 2011 Alpstein. All rights reserved.
//

#import "RMMapTiledLayerView.h"

#import "RMMapView.h"
#import "RMTileSource.h"
#import "RMTileImage.h"

@interface RMMapOverlayView ()

- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer;
- (void)handleTwoFingerDoubleTap:(UIGestureRecognizer *)recognizer;

@end

@implementation RMMapTiledLayerView
{
    RMMapView *mapView;
    id <RMTileSource> tileSource;
}

@synthesize delegate;
@synthesize useSnapshotRenderer;

+ (Class)layerClass
{
    return [CATiledLayer class];
}

- (CATiledLayer *)tiledLayer
{  
    return (CATiledLayer *)self.layer;
}

- (id)initWithFrame:(CGRect)frame mapView:(RMMapView *)aMapView forTileSource:(id <RMTileSource>)aTileSource
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    mapView = [aMapView retain];
    tileSource = [aTileSource retain];
    
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    self.opaque = NO;
    
    self.useSnapshotRenderer = NO;
    
    CATiledLayer *tiledLayer = [self tiledLayer];
//    size_t levelsOf2xMagnification = mapView.tileSourcesContainer.maxZoom;
//    if (mapView.adjustTilesForRetinaDisplay) levelsOf2xMagnification += 1;
//    tiledLayer.levelsOfDetail = levelsOf2xMagnification;
//    tiledLayer.levelsOfDetailBias = levelsOf2xMagnification;
    
    tiledLayer.levelsOfDetail = [[mapView tileSource] maxZoom];
    tiledLayer.levelsOfDetailBias = [[mapView tileSource] maxZoom];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)] autorelease];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    
    UITapGestureRecognizer *singleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)] autorelease];
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerDoubleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerDoubleTap:)] autorelease];
    twoFingerDoubleTapRecognizer.numberOfTapsRequired = 2;
    twoFingerDoubleTapRecognizer.numberOfTouchesRequired = 2;
    
    UITapGestureRecognizer *twoFingerSingleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerSingleTap:)] autorelease];
    twoFingerSingleTapRecognizer.numberOfTouchesRequired = 2;
    [twoFingerSingleTapRecognizer requireGestureRecognizerToFail:twoFingerDoubleTapRecognizer];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)] autorelease];
    
    [self addGestureRecognizer:singleTapRecognizer];
    [self addGestureRecognizer:doubleTapRecognizer];
    [self addGestureRecognizer:twoFingerDoubleTapRecognizer];
    [self addGestureRecognizer:twoFingerSingleTapRecognizer];
    [self addGestureRecognizer:longPressRecognizer];
    
    return self;
}

- (void)dealloc
{
    [mapView.tileSource cancelAllDownloads];
    self.layer.contents = nil;
    [mapView.tileSource release]; mapView.tileSource = nil;
    [mapView release]; mapView = nil;
    [super dealloc];
}

- (void)didMoveToWindow
{
    self.contentScaleFactor = 1.0f;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    CGRect rect   = CGContextGetClipBoundingBox(context);
    CGRect bounds = self.bounds;
    short zoom    = log2(bounds.size.width / rect.size.width);
    
    //    NSLog(@"drawLayer: {{%f,%f},{%f,%f}}", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (self.useSnapshotRenderer)
    {
        zoom = (short)ceilf(mapView.adjustedZoomForRetinaDisplay);
        CGFloat rectSize = bounds.size.width / powf(2.0, (float)zoom);
        
        int x1 = floor(rect.origin.x / rectSize),
        x2 = floor((rect.origin.x + rect.size.width) / rectSize),
        y1 = floor(fabs(rect.origin.y / rectSize)),
        y2 = floor(fabs((rect.origin.y + rect.size.height) / rectSize));
        
        //NSLog(@"Tiles from x1:%d, y1:%d to x2:%d, y2:%d @ zoom %d", x1, y1, x2, y2, zoom);
        
        if (zoom >= mapView.tileSource.minZoom && zoom <= mapView.tileSource.maxZoom)
        {
            UIGraphicsPushContext(context);
            
            for (int x=x1; x<=x2; ++x)
            {
                for (int y=y1; y<=y2; ++y)
                {
                    UIImage *tileImage = [mapView.tileSource imageForTile:RMTileMake(x, y, zoom) inCache:[mapView tileCache]];
                    [tileImage drawInRect:CGRectMake(x * rectSize, y * rectSize, rectSize, rectSize)];
                }
            }
            
            UIGraphicsPopContext();
        }
    }
    else
    {
        int x = floor(rect.origin.x / rect.size.width),
        y = floor(fabs(rect.origin.y / rect.size.height));
        
        //NSLog(@"Tile @ x:%d, y:%d, zoom:%d", x, y, zoom);
        
        UIGraphicsPushContext(context);
        
        UIImage *tileImage = nil;
                
        if (zoom >= mapView.tileSource.minZoom && zoom <= mapView.tileSource.maxZoom) {
            tileImage = [mapView.tileSource imageForTile:RMTileMake(x, y, zoom) 
                                                 inCache:[mapView tileCache]];
        }
        
        if (!tileImage)
        {
            if (mapView.missingTilesDepth == 0)
            {
                tileImage = [RMTileImage errorTile];
            }
            else
            {
                NSUInteger currentTileDepth = 1, currentZoom = zoom - currentTileDepth;
                
                // tries to return lower zoom level tiles if a tile cannot be found
                while ( !tileImage && currentZoom >= mapView.tileSource.minZoom && currentTileDepth <= mapView.missingTilesDepth)
                {
                    float nextX = x / powf(2.0, (float)currentTileDepth),
                    nextY = y / powf(2.0, (float)currentTileDepth);
                    float nextTileX = floor(nextX),
                    nextTileY = floor(nextY);
                    
                    tileImage = [mapView.tileSource imageForTile:RMTileMake((int)nextTileX, (int)nextTileY, currentZoom) 
                                                         inCache:[mapView tileCache]];
                    
                    //NSLog(@"Loading tile Image for %f %f", nextTileX, nextTileY);
                    
                    if (tileImage) {
                        //NSLog(@"Tile found");
                        
                        // crop
                        float cropSize = 1.0 / powf(2.0, (float)currentTileDepth);
                        
                        CGRect cropBounds = CGRectMake(tileImage.size.width * (nextX - nextTileX),
                                                       tileImage.size.height * (nextY - nextTileY),
                                                       tileImage.size.width * cropSize,
                                                       tileImage.size.height * cropSize);
                        
                        CGImageRef imageRef = CGImageCreateWithImageInRect([tileImage CGImage], cropBounds);
                        tileImage = [UIImage imageWithCGImage:imageRef];
                        CGImageRelease(imageRef);
                        
                        break;
                    }
                    
                    currentTileDepth++;
                    currentZoom = zoom - currentTileDepth;
                }
                if (!tileImage) {
                    tileImage = [RMTileImage errorTile];
                }
            }
        }
        
        if (mapView.debugTiles)
        {
            UIGraphicsBeginImageContext(tileImage.size);
            
            CGContextRef debugContext = UIGraphicsGetCurrentContext();
            
            CGRect debugRect = CGRectMake(0, 0, tileImage.size.width, tileImage.size.height);
            
            [tileImage drawInRect:debugRect];
            
            CGColorRef color = CGColorCreateCopyWithAlpha([[UIColor redColor] CGColor], 0.25);
            
            UIFont *font = [UIFont systemFontOfSize:36.0];
            
            CGContextSetStrokeColorWithColor(debugContext, color);
            CGContextSetLineWidth(debugContext, 5.0);
            
            CGContextStrokeRect(debugContext, debugRect);
            
            CGContextSetFillColorWithColor(debugContext, color);
            
            NSString *debugString = [NSString stringWithFormat:@"%i,%i,%i", zoom, x, y];
            
            CGSize debugSize = [debugString sizeWithFont:font];
            
            [debugString drawInRect:CGRectMake(5.0, 5.0, debugSize.width, debugSize.height) withFont:font];
            
            tileImage = UIGraphicsGetImageFromCurrentImageContext();
            
            CFRelease(color);
            
            UIGraphicsEndImageContext();
        }
        
        [tileImage drawInRect:rect];
        
        UIGraphicsPopContext();
    }
    
    [pool release]; pool = nil;
}

#pragma mark -
#pragma mark Event handling

- (void)handleSingleTap:(UIGestureRecognizer *)recognizer
{
    if ([delegate respondsToSelector:@selector(mapTiledLayerView:singleTapAtPoint:)])
        [delegate mapTiledLayerView:self singleTapAtPoint:[recognizer locationInView:mapView]];
}

- (void)handleTwoFingerSingleTap:(UIGestureRecognizer *)recognizer
{
    if ([delegate respondsToSelector:@selector(mapTiledLayerView:twoFingerSingleTapAtPoint:)])
        [delegate mapTiledLayerView:self twoFingerSingleTapAtPoint:[recognizer locationInView:mapView]];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    CGPoint aPoint = [recognizer locationInView:mapView];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if ([delegate respondsToSelector:@selector(mapTiledLayerView:longPressAtPoint:)])
            [delegate mapTiledLayerView:self longPressAtPoint:aPoint];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if ([delegate respondsToSelector:@selector(mapTiledLayerView:longPressAndDrag:)]) {
            [delegate mapTiledLayerView:self longPressAndDrag:aPoint];
        }
    } else {
        if ([delegate respondsToSelector:@selector(mapTiledLayerView:longPressEnd:)]) {
            [delegate mapTiledLayerView:self longPressEnd:aPoint];
        }
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer
{
    if ([delegate respondsToSelector:@selector(mapTiledLayerView:doubleTapAtPoint:)])
        [delegate mapTiledLayerView:self doubleTapAtPoint:[recognizer locationInView:mapView]];
}

- (void)handleTwoFingerDoubleTap:(UIGestureRecognizer *)recognizer
{
    if ([delegate respondsToSelector:@selector(mapTiledLayerView:twoFingerDoubleTapAtPoint:)])
        [delegate mapTiledLayerView:self twoFingerDoubleTapAtPoint:[recognizer locationInView:mapView]];
}

@end
