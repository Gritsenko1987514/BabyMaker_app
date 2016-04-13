//
//  FaceView.h
//  CVPoissonBlend
//
//  Created by user on 08/08/13.
//  Copyright (c) 2013 akhiljayaram. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Face : NSObject

@property (nonatomic,strong) NSString *imageId;
@property (nonatomic,strong) NSString *imageName;
@property (nonatomic, assign) CGPoint leftEyeCentre,rightEyeCentre, mouthCentre, chinCentre,imageCentre;
@property (nonatomic, assign) CGFloat angleBetweenEyes;
@property (nonatomic, retain) UIImage * faceImage;
@property (nonatomic, retain) NSString * faceImages;
@property (nonatomic, assign) CGFloat widthBetweenEyes;

@property (nonatomic, assign) CGFloat leftEyeRefDistance,rightEyeRefDistance, mouthRefDistance;
@property (nonatomic, assign) CGFloat leftEyeAngle,rightEyeAngle, mouthAngle;
@property (nonatomic, assign) BOOL isMom;

@end
