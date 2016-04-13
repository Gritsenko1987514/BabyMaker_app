//
//  UIImageViewEx.m
//  FaceBlend
//
//  Created by Akhildas on 8/1/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import "UIImageViewEx.h"

@implementation UIImageViewEx

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

@synthesize touchTimer;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
	
    
	// just create one loop and re-use it.
    UITouch *touch = [[ event allTouches] anyObject];

    if(touch.view.tag != 102)
    {
        self.touchTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                           target:self
                                                         selector:@selector(addLoop)
                                                         userInfo:nil
                                                          repeats:NO];
	if(loop == nil){
		loop = [[MagnifierView alloc] init];
		loop.viewToMagnify = self;
	}
	
	
	loop.touchPoint = [touch locationInView:self];
	[loop setNeedsDisplay];
    } else {
        [self.touchTimer invalidate];
        self.touchTimer = nil;
        [loop removeFromSuperview];
        

    }

}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [[ event allTouches] anyObject];

    if(touch.view.tag != 102) {

	[self handleAction:touches];
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
	[self.touchTimer invalidate];
	self.touchTimer = nil;
    UITouch *touch = [[ event allTouches] anyObject];

    if(touch.view.tag != 102) {

	[loop removeFromSuperview];
    }
}

- (void)addLoop {
	// add the loop to the superview.  if we add it to the view it magnifies, it'll magnify itself!
    
	[self.superview addSubview:loop];
	// here, we could do some nice animation instead of just adding the subview...
}

- (void)handleAction:(id)timerObj {
	NSSet *touches = timerObj;
	UITouch *touch = [touches anyObject];
	loop.touchPoint = [touch locationInView:self];
	[loop setNeedsDisplay];
}

@end
