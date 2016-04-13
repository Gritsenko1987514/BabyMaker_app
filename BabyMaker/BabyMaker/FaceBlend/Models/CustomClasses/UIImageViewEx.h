//
//  UIImageViewEx.h
//  FaceBlend
//
//  Created by Akhildas on 8/1/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MagnifierView.h"

@interface UIImageViewEx : UIImageView {
	NSTimer *touchTimer;
	MagnifierView *loop;
}

@property (nonatomic, retain) NSTimer *touchTimer;


- (void)addLoop;
- (void)handleAction:(id)timerObj;

@end
