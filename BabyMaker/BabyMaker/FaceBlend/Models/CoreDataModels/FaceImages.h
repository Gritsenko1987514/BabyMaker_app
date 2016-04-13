//
//  FaceImages.h
//  BabyMaker
//
//  Created by LinChunWei on 10/11/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FaceImages : NSManagedObject

@property (nonatomic, retain) NSNumber * angleBetweenEyes;
@property (nonatomic, retain) NSString * chinCentre;
@property (nonatomic, retain) NSString * faceImage;
@property (nonatomic, retain) NSString * imageCentre;
@property (nonatomic, retain) NSString * imageId;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) NSNumber * leftEyeAngle;
@property (nonatomic, retain) NSString * leftEyeCentre;
@property (nonatomic, retain) NSNumber * leftEyeRefDistance;
@property (nonatomic, retain) NSNumber * mouthAngle;
@property (nonatomic, retain) NSString * mouthCentre;
@property (nonatomic, retain) NSNumber * mouthRefDistance;
@property (nonatomic, retain) NSNumber * rightEyeAngle;
@property (nonatomic, retain) NSString * rightEyeCentre;
@property (nonatomic, retain) NSNumber * rightEyeRefDistance;
@property (nonatomic, retain) NSNumber * widthBetweenEyes;
@property (nonatomic, retain) NSNumber * isMom;

@end
