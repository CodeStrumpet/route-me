//
//  StamenMapSource.m
//  MapView
//
//  Created by Paul Mans on 4/9/12.
//  Copyright (c) 2012 TripAdvisor. All rights reserved.
//

#define DEFAULT_TILE_STYLE @"watercolor"

#import "StamenMapSource.h"

@implementation StamenMapSource
@synthesize tileStyleName;

-(id) init {       
    
	if(self = [super init]) 
	{
		[self setMaxZoom:18];
		[self setMinZoom:1];
        self.tileStyleName = DEFAULT_TILE_STYLE;
	}
	return self;
} 

-(NSString*) tileURL: (RMTile) tile {
    
	NSAssert4(((tile.zoom >= self.minZoom) && (tile.zoom <= self.maxZoom)),
			  @"%@ tried to retrieve tile with zoomLevel %d, outside source's defined range %f to %f", 
			  self, tile.zoom, self.minZoom, self.maxZoom);
	return [NSString stringWithFormat:@"http://tile.stamen.com/%@/%d/%d/%d.png", self.tileStyleName, tile.zoom, tile.x, tile.y];
}

-(NSString*) uniqueTilecacheKey {
	return @"OpenStreetMap";
}

-(NSString *)shortName {
	return @"Open Street Map";
}

-(NSString *)longDescription {
	return @"Open Street Map, the free wiki world map, provides freely usable map data for all parts of the world, under the Creative Commons Attribution-Share Alike 2.0 license.";
}

-(NSString *)shortAttribution {
	return @"© OpenStreetMap CC-BY-SA";
}

-(NSString *)longAttribution {
	return @"Map data © OpenStreetMap, licensed under Creative Commons Share Alike By Attribution.";
}

@end
