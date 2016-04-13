//
//  FaceManager.m
//  CVPoissonBlend
//
//  Created by user on 13/08/13.
//  Copyright (c) 2013 akhiljayaram. All rights reserved.
//

#import "FaceManager.h"
#import "ImageUtils.h"
#import "Constants.h"

#define EYE_WIDTH_OFFSET  0.45f
#define EYE_HEIGHT_OFFSET  1.4f

#define NOSE_WIDTH_OFFSET  0.24f

#define GENERAL_HEIGHT_OFFSET  0.33f


@implementation FaceManager {
    CGRect backgroundImageEyeViewRect,foregroundImageEyeViewRect;
    CGRect backgroundImageNoseAndMouthViewRect,foregroundImageNoseAndMouthViewRect;
    
    CGPoint backgroundImageEyeViewRectOrigin,foregroundImageEyeViewRectOrigin;
    CGPoint backgroundImageNoseAndMouthViewRectOrigin,foregroundImageNoseAndMouthViewRectOrigin;
    CGFloat backgroundAngleBetweenEyes,foregroundAngleBetweenEyes;
    

}
@synthesize backFace,frontFace; 
/*
 * Return poissonblend object with necessary datas for blending
 */
- (PoissonBlendObject *)getPoissonBlendedObject
{
    
    UIImage *backgroundFaceImage =  self.backFace.faceImage;
     // keeping the image as it withouit doing any scaling or rotation for later use
    UIImage * originalImage = backgroundFaceImage;
     
//    backgroundFaceImage = [ImageUtils rescaleTwice:backgroundFaceImage];

    
    //Rotate the background image (destination image), so that the two eyes become in 180 degress (horizontally aligned)... This is needed because we can only cut rectangular areas and blend rectangular area in currently used openCV framework
    backgroundFaceImage = [ImageUtils rotate:backgroundFaceImage radians:backFace.angleBetweenEyes WithTransform:YES];
    
    
    //Used to get the eye rect (rectangular area with two eyes and eyebros) , its origin point, nose and mouth rect (rectangular area with nose and mouth) and its origin point for the bachground face..Face object is passed for getting lefteye points , mouth points, angles which are used to make the selection of these rectangular areas 
   [self faceDetector:backgroundFaceImage  WithFace:backFace isForeground:NO];
    
    
    UIImage * foregroundFaceImage =  self.frontFace.faceImage;
//    foregroundFaceImage = [ImageUtils rescaleTwice:foregroundFaceImage];
    
    //Rotate the foreground image (source image), so that the two eyes become in 180 degress (horizontally aligned)... This is needed because we can only cut rectangular areas and blend rectangular area in currently used openCV framework
    foregroundFaceImage = [ImageUtils rotate:foregroundFaceImage radians:frontFace.angleBetweenEyes WithTransform:YES];

     //Used to get the eye rect (rectangular area with two eyes and eyebros) , its origin point, nose and mouth rect (rectangular area with nose and mouth) and its origin point for the foreground face..Face object is passed for getting lefteye points , mouth points, angles which are used to make the selection of these rectangular areas 
    [self faceDetector:foregroundFaceImage  WithFace:frontFace isForeground:YES];
    
    //Here we get cropped rect image of eyes and eyebrows of front image
    CGRect  cropRectForEyes = CGRectMake(foregroundImageEyeViewRectOrigin.x, foregroundImageEyeViewRectOrigin.y,floorf( foregroundImageEyeViewRect.size.width), floorf(foregroundImageEyeViewRect.size.height));
    UIImage * croppedImageWithEyes = [ImageUtils cropImage:foregroundFaceImage withCropRect:cropRectForEyes];
    
  
    //Here we get cropped rect image of nose and mouth of front image
    CGRect  cropRectForNoseAndMouth = CGRectMake(foregroundImageNoseAndMouthViewRectOrigin.x, foregroundImageNoseAndMouthViewRectOrigin.y,floorf( foregroundImageNoseAndMouthViewRect.size.width), floorf(foregroundImageNoseAndMouthViewRect.size.height));
    UIImage * croppedImageWithNoseAndMouth = [ImageUtils cropImage:foregroundFaceImage withCropRect:cropRectForNoseAndMouth];
    
    //Getting both widthScale and hight scale (factors that need to be multiplied with forground image rects with corresponding rect of background image) for eye rect and nose-mouth rect.
    //These scale factors will be used to get the scaled for ground images of eye area and nose area
    NSMutableDictionary *  scaleDictForEyes = [ImageUtils getTwoScaleFactorsForBachgroundRectWidth:backgroundImageEyeViewRect.size.width andBackgroundRectHeight:backgroundImageEyeViewRect.size.height WithForegroundRectWidth:foregroundImageEyeViewRect.size.width andForegroundRectHeight:foregroundImageEyeViewRect.size.height];
    float heightScaleForEyes = [[scaleDictForEyes valueForKey:@"heightScale"] floatValue ];
    float widthScaleForEyes = [[scaleDictForEyes valueForKey:@"widthScale"] floatValue ];
    NSMutableDictionary *  scaleDictForNoseMouth = [ImageUtils getTwoScaleFactorsForBachgroundRectWidth:backgroundImageNoseAndMouthViewRect.size.width andBackgroundRectHeight:backgroundImageNoseAndMouthViewRect.size.height WithForegroundRectWidth:foregroundImageNoseAndMouthViewRect.size.width andForegroundRectHeight:foregroundImageNoseAndMouthViewRect.size.height];
    float heightScaleForNoseMouth = [[scaleDictForNoseMouth valueForKey:@"heightScale"] floatValue ];
    float widthScaleForNoseMouth = [[scaleDictForNoseMouth valueForKey:@"widthScale"] floatValue ];
    
    
    //Eye area image and its rect are scaled according to the scale we got before
    croppedImageWithEyes = [ImageUtils imageWithImage:croppedImageWithEyes scaledToSize:CGSizeMake(ceilf(foregroundImageEyeViewRect.size.width*widthScaleForEyes), ceilf(foregroundImageEyeViewRect.size.height*heightScaleForEyes))];
    foregroundImageEyeViewRect = CGRectMake(foregroundImageEyeViewRect.origin.x, foregroundImageEyeViewRect.origin.y, ceilf(foregroundImageEyeViewRect.size.width*widthScaleForEyes), ceilf(foregroundImageEyeViewRect.size.height*heightScaleForEyes));
    
    //Nose-Mouth area image and its rect are scaled according to the scale we got before
    croppedImageWithNoseAndMouth = [ImageUtils imageWithImage:croppedImageWithNoseAndMouth scaledToSize:CGSizeMake(ceilf(foregroundImageNoseAndMouthViewRect.size.width*widthScaleForNoseMouth), ceilf(foregroundImageNoseAndMouthViewRect.size.height*heightScaleForNoseMouth))];
    foregroundImageNoseAndMouthViewRect = CGRectMake(foregroundImageNoseAndMouthViewRect.origin.x, foregroundImageNoseAndMouthViewRect.origin.y, ceilf(foregroundImageNoseAndMouthViewRect.size.width*widthScaleForNoseMouth), ceilf(foregroundImageNoseAndMouthViewRect.size.height*heightScaleForNoseMouth));
    
       
   //An object of poissonblendObject is made with all the necessary datas.
    poissonBlendObject = [[PoissonBlendObject alloc]init];
    poissonBlendObject.backgroundImageWithRotation =backgroundFaceImage;
    poissonBlendObject.backgroundImageWithOutRotation =originalImage;

    poissonBlendObject.eyeViewImage =croppedImageWithEyes;
    poissonBlendObject.noseAndMouthImage = croppedImageWithNoseAndMouth;
    
    poissonBlendObject.eyesViewOrigin = backgroundImageEyeViewRectOrigin;
    poissonBlendObject.noseAndMouthOrigin = backgroundImageNoseAndMouthViewRectOrigin;
    
    poissonBlendObject.angleTobeRotated = backFace.angleBetweenEyes;
    
    return poissonBlendObject;
}


-(void)faceDetector:(UIImage*)image  WithFace:(Face *)face isForeground:(BOOL)isForeground
{
    

    [self markFaceAreaAndFeaturesInImageView:image   WithFace:face isForeground:isForeground];
    
}
-(void)markFaceAreaAndFeaturesInImageView:(UIImage*)image WithFace:(Face *)face isForeground:(BOOL)isForeground
{
    
    
    

    CGPoint mleftEyePoint,mrightEyePoint,mmouthPoint;
    
    CGImageRef cgImageRef = image.CGImage;
    float imagviewWidth = CGImageGetWidth(cgImageRef) ;
    float imagviewHeight = CGImageGetHeight(cgImageRef) ;
    
//    float maxScale = [ImageUtils getScleNeededWithActualImageForImageWidth:imagviewWidth andForImageHeight:imagviewHeight];
    float widthPercentage = 1;
    float heightPercentage = 1;
    
    //getting image centre position
    CGPoint centrePositioin = CGPointMake((imagviewWidth/2)*widthPercentage, (imagviewHeight/2)*heightPercentage);
    
    //Recalculating eyecentre,righteyeCentre,mouthCentre --- (we have the eyecentre,righteyeCentre,mouthCentre in face object..but now the images are rotated to make both eyes horizontally aligned.so these points are also rotated. so we want to recalculate them with the angle its rotated about the centre)
    CGPoint invertedleftEyeCentre= [ImageUtils getRotatedPoint:centrePositioin WithAngle:face.leftEyeAngle+face.angleBetweenEyes WithDistance:face.leftEyeRefDistance*SCALE];
    mleftEyePoint = invertedleftEyeCentre;
    CGPoint invertedRightEyeCentre= [ImageUtils getRotatedPoint:centrePositioin WithAngle:face.rightEyeAngle+face.angleBetweenEyes WithDistance:face.rightEyeRefDistance*SCALE];
    mrightEyePoint = invertedRightEyeCentre;
    CGPoint invertedlMouthCentre= [ImageUtils getRotatedPoint:centrePositioin WithAngle:face.mouthAngle+face.angleBetweenEyes WithDistance:face.mouthRefDistance*SCALE];
    mmouthPoint = invertedlMouthCentre;
    
 
    //The width between eyes is caluclated - () this value is used for getting offset values ()
    
    int widthBetweenEyes = mrightEyePoint.x-mleftEyePoint.x;
    
    CGFloat f = [ImageUtils pointPairToBearingDegrees:mrightEyePoint secondPoint:mleftEyePoint];
    if(isForeground) {
        foregroundAngleBetweenEyes = -f;
    } else {
        backgroundAngleBetweenEyes = -f;
    }
    
    
    //Calculating inner rect for eyes--
    CGRect eyesRect = CGRectMake(mleftEyePoint.x,mleftEyePoint.y, mrightEyePoint.x-mleftEyePoint.x,widthBetweenEyes*GENERAL_HEIGHT_OFFSET);
   
    //Calculating outet rect for eyes--(this will contain more areas around eyes with the calculated offset)
    float eyesRectWidth = eyesRect.size.width;
    float eyesRectHeight = eyesRect.size.height;
    CGPoint eyeOuterRectOrigin = CGPointMake(mleftEyePoint.x-eyesRectWidth*EYE_WIDTH_OFFSET,mleftEyePoint.y-eyesRectHeight*EYE_HEIGHT_OFFSET);
    CGRect eyeOuterRect = CGRectMake(eyeOuterRectOrigin.x,eyeOuterRectOrigin.y, (eyesRectWidth*(1+(2*EYE_WIDTH_OFFSET))),eyesRectHeight*(1+EYE_HEIGHT_OFFSET));
   
    
    //Calculating inner rect for nose-mouth--
    
    CGRect noseMouthRect = CGRectMake(mleftEyePoint.x,mleftEyePoint.y+(widthBetweenEyes*GENERAL_HEIGHT_OFFSET), mrightEyePoint.x-mleftEyePoint.x,mmouthPoint.y-mleftEyePoint.y-(widthBetweenEyes*GENERAL_HEIGHT_OFFSET));
    
    float noseMouthRectWidth = noseMouthRect.size.width;
    float noseMouthRectHeight = noseMouthRect.size.height;
    //Calculating outet rect for nose-mouth--(this will contain more areas around eyes with the calculated offset) 
    CGPoint noseMouthOuterRectOrigin = CGPointMake(mleftEyePoint.x-(widthBetweenEyes*NOSE_WIDTH_OFFSET),mleftEyePoint.y+(widthBetweenEyes*GENERAL_HEIGHT_OFFSET));
    CGRect noseMouthOuterRect = CGRectMake(noseMouthOuterRectOrigin.x,noseMouthOuterRectOrigin.y, (noseMouthRectWidth)*(1+(2*NOSE_WIDTH_OFFSET)),noseMouthRectHeight*1);
    
   
    //saving the required values
    if(!isForeground) {
        backgroundImageEyeViewRect      = eyeOuterRect;
        backgroundImageEyeViewRectOrigin = eyeOuterRectOrigin;
        
        backgroundImageNoseAndMouthViewRect = noseMouthOuterRect;
        backgroundImageNoseAndMouthViewRectOrigin = noseMouthOuterRectOrigin;
        
    } else  {
        foregroundImageEyeViewRect      = eyeOuterRect;
        foregroundImageEyeViewRectOrigin = eyeOuterRectOrigin;
        
        foregroundImageNoseAndMouthViewRect = noseMouthOuterRect;
        foregroundImageNoseAndMouthViewRectOrigin = noseMouthOuterRectOrigin;
        
    }
    
    

    
    
}



@end
