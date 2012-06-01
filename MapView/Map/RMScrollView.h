//
//  RMScrollView.h
//  MapView
//
//  Created by Paul Mans on 5/31/12.
//  Copyright (c) 2012 TripAdvisor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMScrollView : UIScrollView 
    

@end


@protocol RMScrollViewDelegate <UIScrollViewDelegate>

- (void)scrollViewDidExperienceUserTouch:(RMScrollView *)scrollView;

@end
