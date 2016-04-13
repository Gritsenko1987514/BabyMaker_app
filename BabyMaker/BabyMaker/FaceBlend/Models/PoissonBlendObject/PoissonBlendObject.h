//
//  PoissonBlendObject.h
//  CVPoissonBlend
//
//  Created by user on 13/08/13.
//  Copyright (c) 2013 akhiljayaram. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PoissonBlendObject : NSObject


@property (nonatomic, assign) CGPoint eyesViewOrigin,noseAndMouthOrigin;
@property (nonatomic, assign) CGFloat angleTobeRotated;

@property (nonatomic, retain) UIImage * eyeViewImage;
@property (nonatomic, retain) UIImage * noseAndMouthImage;

@property (nonatomic, retain) UIImage * backgroundImageWithRotation;
@property (nonatomic, retain) UIImage * backgroundImageWithOutRotation;

@end
