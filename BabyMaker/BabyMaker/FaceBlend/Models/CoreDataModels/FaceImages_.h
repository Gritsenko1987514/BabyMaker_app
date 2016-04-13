//
//  FaceImages.h
//  FaceBlend
//
//  Created by Akhildas on 8/21/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FaceImages : NSManagedObject

@property (nonatomic) double angleBetweenEyes;
@property (nonatomic, retain) NSString * chinCentre;
@property (nonatomic, retain) NSString * faceImage;
@property (nonatomic, retain) NSString * imageCentre;
@property (nonatomic, retain) NSString * imageId;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic) double leftEyeAngle;
@property (nonatomic, retain) NSString * leftEyeCentre;
@property (nonatomic) double leftEyeRefDistance;
@property (nonatomic) double mouthAngle;
@property (nonatomic, retain) NSString * mouthCentre;
@property (nonatomic) double mouthRefDistance;
@property (nonatomic) double rightEyeAngle;
@property (nonatomic, retain) NSString * rightEyeCentre;
@property (nonatomic) double rightEyeRefDistance;
@property (nonatomic) double widthBetweenEyes;

@property (nonatomic, retain) NSNumber *isMum;
@end
