//
//  RMScrollView.m
//  MapView
//
//  Created by Paul Mans on 5/31/12.
//  Copyright (c) 2012 TripAdvisor. All rights reserved.
//

#import "RMScrollView.h"

@interface RMScrollView () {
    BOOL _delegateIsRMScrollViewDelegate;
}
@end

@implementation RMScrollView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        for (UIGestureRecognizer *gesture in self.gestureRecognizers){
            if ([gesture isKindOfClass:[UIPanGestureRecognizer class]] || [gesture isKindOfClass:[UIRotationGestureRecognizer class]] || [gesture isKindOfClass:[UIPinchGestureRecognizer class]]){
                gesture.cancelsTouchesInView = NO;    
            }
        }
    }
    return self;
}

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate {
    [super setDelegate:delegate];
    if ([delegate respondsToSelector:@selector(scrollViewDidExperienceUserTouch:)]) {
        _delegateIsRMScrollViewDelegate = YES;
    }
}

- (UIView *)hitTest:(CGPoint)hit withEvent:(UIEvent *)event {
    if (_delegateIsRMScrollViewDelegate) {
        [(id<RMScrollViewDelegate>) self.delegate scrollViewDidExperienceUserTouch:self];
    }

    return [super hitTest:hit withEvent:event];
}

/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_delegateIsRMScrollViewDelegate) {
        [(id<RMScrollViewDelegate>) self.delegate scrollViewDidExperienceUserTouch:self];
    }
}
*/
/*
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches ended");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches moved");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches cancelled");
}
*/
@end
