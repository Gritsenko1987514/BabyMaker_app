//
//  ImageUtils.h
//  CVPoissonBlend
//
//  Created by user on 31/07/13.
//  Copyright (c) 2013 akhiljayaram. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtils : NSObject

+(UIImage *) createScaledUIImageWithActualImage:(UIImage *)image;
+(float) getScleNeededWithActualImageForImageWidth:(float)width andForImageHeight:(float)height;
+(UIImage *)cropImage:(UIImage *)image withCropRect:(CGRect)cropRect;
+(float) getScaleFactorsForBachgroundRectWidth:(float)backwidth andBackgroundRectHeight:(float)backheight WithForegroundRectWidth:(float)frontwidth andForegroundRectHeight:(float)frontHeight;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+(UIImage *)mergeTwoImages:(UIImage *)image1 sec:(UIImage *)image2 WithFirestImageSize:(CGSize)size1 WithSecondImageSize:(CGSize) size2 WithSecondOrigin:(CGPoint)secondOrigin ;
+(NSMutableDictionary *) getTwoScaleFactorsForBachgroundRectWidth:(float)backwidth andBackgroundRectHeight:(float)backheight WithForegroundRectWidth:(float)frontwidth andForegroundRectHeight:(float)frontHeight;

+(UIImage *) createScaledUIImageWithActualImageIfNeeded:(UIImage *)image;
+ (CGFloat) pointPairToBearingDegrees:(CGPoint)startingPoint secondPoint:(CGPoint) endingPoint;
+ (UIImage *)rotate:(UIImage *)image radians:(float)degrees WithTransform:(BOOL)transform;


+ (CGPoint) getRotatedPoint:(CGPoint) refPoint WithAngle:(float)rads WithDistance:(float)distance;
+ (CGFloat)getDistanceBetweenPoint:(CGPoint)p1 WitSecondPoint:(CGPoint)p2;
+ (CGFloat)getHeightOffset:(UIImage *) image;
+(UIImage *)getCroppedImageFromImage:(UIImage *)image WithCentreWithCentrePosition:(CGPoint)centre AndHasCentre:(BOOL) hasCentre ;
+(UIImage *)rescaleTwice:(UIImage *)image;
+(CGFloat)getHeight;
+ (UIImage *)imageByCropping:(UIImage *)image toRect:(CGRect)rect;
+(float)getScale:(UIImage *)image;
+(CGPoint)getCroppingRectOrigin:(UIImage *)image WithCentreWithCentrePosition:(CGPoint)centre AndHasCentre:(BOOL) hasCentre 
    ;
+(UIImage *)createScaledUIImageWithActualImageIfSmaller:(UIImage *)image;
+(NSString *)convertPointToString:(CGPoint)point;
+(CGPoint)convertStringToPoint:(NSString *)string;
+(NSString *)saveImageToApplicationDocumentsFolder:(UIImage *)image;
+(NSArray *)getImagesPathsFromDocumentsFolder:(BOOL)isThumbs;
+(void)deleteImageFromPath:(NSString *)fileName;
+(float) getDoubleScleNeededWithActualImageForImageWidth:(float)width andForImageHeight:(float)height;
+(UIImage *)createDoubleScaledUIImageWithActualImage:(UIImage *)image;

@end
