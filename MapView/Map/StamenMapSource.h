//
//  StamenMapSource.h
//  MapView
//
//  Created by Paul Mans on 4/9/12.
//  Copyright (c) 2012 TripAdvisor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMAbstractMercatorWebSource.h"

@interface StamenMapSource : RMAbstractMercatorWebSource <RMAbstractMercatorWebSource> {

    NSString *tileStyleName;
}

@property (nonatomic, retain) NSString *tileStyleName;


@end