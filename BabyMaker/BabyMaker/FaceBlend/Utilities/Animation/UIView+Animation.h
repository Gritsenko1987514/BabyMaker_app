//
//  UIView+Animation.h
//  FaceBlend
//
//  Created by akhiljayaram on 22/08/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Animation)
- (void) moveTo:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions)option;
- (void) addSubviewWithZoomInAnimation:(UIView*)view duration:(float)secs option:(UIViewAnimationOptions)option  atPoint:(CGPoint)centre;
- (void) removeWithZoomOutAnimation:(float)secs option:(UIViewAnimationOptions)option withSuperView:(UIView *)superView;

- (void) showViewWithDuration:(float)secs option:(UIViewAnimationOptions)option;
- (void) hideViewWithDuration:(float)secs option:(UIViewAnimationOptions)option;
- (void) trsahAnimation:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions)option withSuperView:(UIView *)superView;
@end
