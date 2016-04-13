//
//  FaceView.m
//  CVPoissonBlend
//
//  Created by user on 08/08/13.
//  Copyright (c) 2013 akhiljayaram. All rights reserved.
//

#import "Face.h"

@implementation Face
@synthesize imageId,imageName;
@synthesize leftEyeCentre,rightEyeCentre, mouthCentre, chinCentre,imageCentre;
@synthesize angleBetweenEyes,widthBetweenEyes;
@synthesize faceImage,faceImages;
@synthesize leftEyeRefDistance,rightEyeRefDistance, mouthRefDistance;
@synthesize leftEyeAngle,rightEyeAngle, mouthAngle;
@synthesize isMom;

-(NSString *)description
{
    return [NSString stringWithFormat:@"imageId = %@, imageName = %@, leftEyeRefDistance = %f, rightEyeRefDistance = %f, mouthRefDistance = %f, leftEyeAngle = %f, rightEyeAngle = %f, mouthAngle = %f",self.imageId,self.imageName,self.leftEyeRefDistance,self.rightEyeRefDistance,self.mouthRefDistance,self.leftEyeAngle,self.rightEyeAngle,self.mouthAngle];
}
@end
