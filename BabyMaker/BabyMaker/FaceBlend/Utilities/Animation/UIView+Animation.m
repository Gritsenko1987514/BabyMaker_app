//
//  UIView+Animation.m
//  FaceBlend
//
//  Created by akhiljayaram on 22/08/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)
- (void) moveTo:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions)option
{
    [UIView animateWithDuration:secs delay:0.0 options:option
                     animations:^{
                         self.frame = CGRectMake(destination.x,destination.y, self.frame.size.width, self.frame.size.height);
                     }
                     completion:nil];
}

- (void) showViewWithDuration:(float)secs option:(UIViewAnimationOptions)option
{
    [UIView animateWithDuration:secs delay:0.0 options:option
                     animations:^{
                         CGRect destRect = CGRectMake(self.frame.origin.x,self.frame.origin.y- self.frame.size.height, self.frame.size.width, self.frame.size.height);
                         self.frame = destRect;
                     }
                     completion:nil];
}
- (void) hideViewWithDuration:(float)secs option:(UIViewAnimationOptions)option
{
    [UIView animateWithDuration:secs delay:0.0 options:option
                     animations:^{
                         self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y+ self.frame.size.height, self.frame.size.width, self.frame.size.height);
                     }
                     completion:nil];
}
- (void) addSubviewWithZoomInAnimation:(UIView*)view duration:(float)secs option:(UIViewAnimationOptions)option atPoint:(CGPoint)centre
{
    // first reduce the view to 1/100th of its original dimension
    CGAffineTransform trans = CGAffineTransformScale(view.transform, 0.01, 0.01);
    view.alpha = 0;
    view.transform = trans;	// do it instantly, no animation
    view.center = centre;
    [self setUserInteractionEnabled:NO];
    [self addSubview:view];
    // now return the view to normal dimension, animating this tranformation
    [UIView animateWithDuration:secs delay:0.0 options:option
                     animations:^{
                         view.transform = CGAffineTransformScale(view.transform, 100.0, 100.0);
                         view.alpha = 1;
                         [self setUserInteractionEnabled:YES];

                     }
                     completion:nil];
}

- (void) removeWithZoomOutAnimation:(float)secs option:(UIViewAnimationOptions)option withSuperView:(UIView *)superView
{
	[UIView animateWithDuration:secs delay:0.0 options:option
                     animations:^{
                         [superView setUserInteractionEnabled:NO];

                         self.transform = CGAffineTransformScale(self.transform, 0.01, 0.01);
                     }
                     completion:^(BOOL finished) {
                         self.alpha = 0;
                         [superView setUserInteractionEnabled:YES];

                         [self removeFromSuperview];
                         self.transform = CGAffineTransformScale(self.transform,100.0, 100.0);
                     }];
}
- (void) trsahAnimation:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions)option withSuperView:(UIView *)superView 
{
    
    CGRect frame = self.frame;
    [UIView animateWithDuration:secs delay:0.0 options:option
                     animations:^{
//                         self.frame = CGRectMake(destination.x,destination.y, 0, 0);
                           self.frame = CGRectMake(0,superView.bounds.size.height, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                         [superView sendSubviewToBack:self];
                        self.frame = frame;
                         [self setHidden:YES];

                     }];
}

@end
