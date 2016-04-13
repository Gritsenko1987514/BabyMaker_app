//
//  ImageUtils.m
//  CVPoissonBlend
//
//  Created by user on 31/07/13.
//  Copyright (c) 2013 akhiljayaram. All rights reserved.
//

#import "ImageUtils.h"
#import "Constants.h"
@implementation ImageUtils


+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    //:TODO:Akhildas
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

+ (CGFloat)getHeight
{
    if(isiPhone5) {
        return 500.0f * SCALE;
    }
     return 423.0f * SCALE;
}

+(UIImage *) createScaledUIImageWithActualImageIfNeeded:(UIImage *)image


{
    
    
    CGImageRef cgImageRef = image.CGImage;
    int width = CGImageGetWidth(cgImageRef) ;
    int height = CGImageGetHeight(cgImageRef) ;
    int changer =width;
    if(width==3264){
        width = height;
        height = changer;
        float maxScale = [self getScleNeededWithActualImageForImageWidth:width andForImageHeight:(height)];
        width = width * maxScale;
        height = height * maxScale;
        
        
        
        UIImage * newImage = [self imageWithImage:image scaledToSize:CGSizeMake(floorf(width), floorf(height))];
        return newImage;

    }
    return image;
        
    
}
+(UIImage *)createDoubleScaledUIImageWithActualImage:(UIImage *)image
{
    CGImageRef cgImageRef = image.CGImage;
    int width = CGImageGetWidth(cgImageRef) ;
    int height = CGImageGetHeight(cgImageRef) ;
    float maxScale = 1/SCALE;
    width = width * maxScale;
    height = height * maxScale;
    
    UIImage * newImage = [self imageWithImage:image scaledToSize:CGSizeMake(floorf(width), floorf(height))];
    return newImage;
}

+(UIImage *)createScaledUIImageWithActualImage:(UIImage *)image
{
    CGImageRef cgImageRef = image.CGImage;
    int width = CGImageGetWidth(cgImageRef) ;
    int height = CGImageGetHeight(cgImageRef) ;
    float maxScale = [self getScleNeededWithActualImageForImageWidth:width andForImageHeight:(height)];
    width = width * maxScale;
    height = height * maxScale;
    
    UIImage * newImage = [self imageWithImage:image scaledToSize:CGSizeMake(floorf(width), floorf(height))];
    return newImage;
}
+(UIImage *)createScaledUIImageWithActualImageIfSmaller:(UIImage *)image
{
    CGImageRef cgImageRef = image.CGImage;
    int width = CGImageGetWidth(cgImageRef) ;
    int height = CGImageGetHeight(cgImageRef) ;
    BOOL isSmallerThanRequired = (width<IMAGE_WIDTH && height<[ImageUtils getHeight]);
    if(isSmallerThanRequired) {
    float maxScale = [self getScleNeededWithActualImageForImageWidth:width andForImageHeight:(height)];
    width = width * maxScale;
    height = height * maxScale;

    UIImage * newImage = [self imageWithImage:image scaledToSize:CGSizeMake(floorf(width), floorf(height))];
    return newImage;
    }
    return image;
}
+(float)getScale:(UIImage *)image
{
    CGImageRef cgImageRef = image.CGImage;
    int width = CGImageGetWidth(cgImageRef) ;
    int height = CGImageGetHeight(cgImageRef) ;
    float maxScale = [self getScleNeededWithActualImageForImageWidth:width andForImageHeight:(height)];
    
    return maxScale;
}

+(float) getDoubleScleNeededWithActualImageForImageWidth:(float)width andForImageHeight:(float)height


{
    
    BOOL isLargerThanRequired = (width>IMAGE_WIDTH || height>[ImageUtils getHeight]);
    
    float   hscale ;
    float   vscale ;
    float maxScale;
    if(isLargerThanRequired) {
        hscale = width/IMAGE_WIDTH;
        vscale = height/[ImageUtils getHeight];
        maxScale = (hscale>vscale?hscale:vscale);
        maxScale = 1/maxScale;
        
        
    } else {
        hscale = IMAGE_WIDTH/width;
        vscale = [ImageUtils getHeight]/height;
        maxScale = (hscale<vscale?hscale:vscale);
        
    }
    
    
    
    
    
    return maxScale;
    
    
}
+(float) getScleNeededWithActualImageForImageWidth:(float)width andForImageHeight:(float)height


{ 
    
    BOOL isLargerThanRequired = (width>IMAGE_WIDTH || height>[ImageUtils getHeight]);
    
    float   hscale ;
    float   vscale ;
    float maxScale;
    if(isLargerThanRequired) {
        hscale = width/IMAGE_WIDTH;
        vscale = height/[ImageUtils getHeight];
        maxScale = (hscale>vscale?hscale:vscale);
        maxScale = 1/maxScale;
        
        
    } else {
        hscale = IMAGE_WIDTH/width;
        vscale = [ImageUtils getHeight]/height;
        maxScale = (hscale<vscale?hscale:vscale);
        
    }
    
    
    
    
   
    return maxScale;
    
    
}
+(float) getScaleFactorsForBachgroundRectWidth:(float)backwidth andBackgroundRectHeight:(float)backheight WithForegroundRectWidth:(float)frontwidth andForegroundRectHeight:(float)frontHeight


{
    
    BOOL isLargerThanRequired = (frontwidth>backwidth || frontHeight>backheight);
    
    float   hscale ;
    float   vscale ;
    float maxScale;
    if(isLargerThanRequired) {
        hscale = frontwidth/backwidth;
        vscale = frontHeight/backheight;
        maxScale = (hscale>vscale?hscale:vscale);
        maxScale = 1/maxScale;
        
        
    } else {
        hscale = backwidth/frontwidth;
        vscale = backheight/frontHeight;
        maxScale = (hscale<vscale?hscale:vscale);
        
    }
    
    
    
    
    
    return maxScale;
    
    
}


+(NSMutableDictionary *) getTwoScaleFactorsForBachgroundRectWidth:(float)backwidth andBackgroundRectHeight:(float)backheight WithForegroundRectWidth:(float)frontwidth andForegroundRectHeight:(float)frontHeight


{
    
    BOOL isLargerThanRequired = (frontwidth>backwidth || frontHeight>backheight);
    
    float   hscale ;
    float   vscale ;
    
    NSMutableDictionary * sizeDict = [[NSMutableDictionary alloc]init];
    
    if(isLargerThanRequired) {
        hscale = 1/(frontwidth/backwidth);
        vscale = 1/(frontHeight/backheight);
        
        
    } else {
        hscale = backwidth/frontwidth;
        vscale = backheight/frontHeight;
        
    }
    
    [sizeDict setObject:[NSNumber numberWithFloat:vscale] forKey:@"heightScale"];
    [sizeDict setObject:[NSNumber numberWithFloat:hscale] forKey:@"widthScale"];

    
    
    return sizeDict;
    
    
}
+(UIImage *)cropImage:(UIImage *)image withCropRect:(CGRect)cropRect
{
//    debugLog(@"Cropped rect:%@",NSStringFromCGRect(cropRect));
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage],cropRect);
    //    // or use the UIImage wherever you like
    UIImage * croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
    
}

+ (UIImage *)imageByCropping:(UIImage *)image toRect:(CGRect)rect
{
    if (UIGraphicsBeginImageContextWithOptions) {
        UIGraphicsBeginImageContextWithOptions(rect.size,
                                               /* opaque */ NO,
                                               /* scaling factor */ 0.0);
    } else {
        UIGraphicsBeginImageContext(rect.size);
    }
    
    // stick to methods on UIImage so that orientation etc. are automatically
    // dealt with for us
    [image drawAtPoint:CGPointMake(-rect.origin.x, -rect.origin.y)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

#pragma mark ordinary overlay merging

+(UIImage *)mergeTwoImages:(UIImage *)image1 sec:(UIImage *)image2 WithFirestImageSize:(CGSize)size1 WithSecondImageSize:(CGSize) size2 WithSecondOrigin:(CGPoint)secondOrigin  {

    UIGraphicsBeginImageContext( size1 );
    if(image1 != nil) {
    [image1 drawInRect:CGRectMake(0,0,ceilf(size1.width),ceilf(size1.height))];
    }
    [image2 drawInRect:CGRectMake(ceilf(secondOrigin.x),ceilf(secondOrigin.y),ceilf(size2.width),ceilf(size2.height)) blendMode:kCGBlendModeNormal alpha:1];
    UIImage *mixedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return mixedImage;
}

+ (CGFloat) pointPairToBearingDegrees:(CGPoint)startingPoint secondPoint:(CGPoint) endingPoint
{
    CGPoint originPoint = CGPointMake(endingPoint.x - startingPoint.x, endingPoint.y - startingPoint.y); // get origin point to origin by subtracting end from start
    float bearingRadians = atan2f(originPoint.y, originPoint.x); // get bearing in radians
    float bearingDegrees = bearingRadians * (180.0 / M_PI); // convert to degrees
//    bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees)); // correct discontinuity
    return bearingDegrees;
}
+ (UIImage *)rotate:(UIImage *)image radians:(float)degrees WithTransform:(BOOL)transform
{
//
    
    if(degrees==0||degrees==360) {
        return image;
    }
//
//    degrees = degrees+.25;
//
//       degrees = ceilf(degrees*2);
//        degrees = floorf(degrees/2);
//        degrees = (degrees/2);
//
//    
//    if(degrees==0||degrees==360) {
//        return image;
//    }
//    degrees = round(degrees * 2.0) / 2.0;
    if(degrees<180) {
        degrees = floorf(degrees);

    } else {
        degrees = ceilf(degrees);
//         degrees = round(degrees * 2.0) / 2.0;
  
    }
        if(degrees==0||degrees==360) {
            return image;
        }
    CGImageRef cgImageRef = image.CGImage;
    int Origwidth = CGImageGetWidth(cgImageRef) ;
    int Origheight = CGImageGetHeight(cgImageRef) ;
    
    int width = Origwidth;
    int height = Origheight;
    
//    if(width%2 != 0) {
//        width = width-1;
//    }
//    if(height%2 != 0) {
//        height = height-1;
//    }
//    
//    CGRect cropRect = CGRectMake(0, 0, width, height);
//    
//    image = [ImageUtils imageByCropping:image toRect:cropRect];

    // calculate the size of the rotated view's containing box for our drawing space
    int offset = 0;
    if(!transform) {
        offset = 0;
    }
     UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,ceilf(width)+offset, ceilf(height)+offset)];
    [rotatedViewBox setBackgroundColor:[UIColor blackColor]];
    CGSize rotatedSize = rotatedViewBox.frame.size;

    if(!transform) {
        degrees = 360-degrees;
    }
     float angleInRadians = degrees * (M_PI / 180);
    if(transform) {
        CGAffineTransform t = CGAffineTransformMakeRotation(angleInRadians);
        rotatedViewBox.transform = t;
         rotatedSize = rotatedViewBox.frame.size;

    }
    
    int newBoxWidth = ceilf(rotatedSize.width);
    int newBoxHeight = ceilf(rotatedSize.height);
//    if(newBoxWidth%2 != 0) {
//        newBoxWidth = newBoxWidth+1;
//    }
//    if(newBoxHeight%2 != 0) {
//        newBoxHeight = newBoxHeight+1;
//    }
    CGSize aw = CGSizeMake(ceilf(newBoxWidth)+2, ceilf(newBoxHeight)+2);

    // Create the bitmap context
    UIGraphicsBeginImageContext(aw);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
//    UIView *rotatedViewBox2 = [[UIView alloc] initWithFrame:CGRectMake(0,0,floorf(rotatedSize.width), floorf(rotatedSize.height))];
//    [rotatedViewBox2 setBackgroundColor:[UIColor blackColor]];

    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, ceilf(aw.width/2), ceilf(aw.height/2));
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap,angleInRadians);
    CGRect a = CGRectMake(ceilf(-(width / 2)), ceilf(-(height / 2)), (width),(height));
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
//    CGImageRef imageRef = [image CGImage];
    CGContextDrawImage(bitmap, a,cgImageRef );
//    debugLog(@"x=%f,y=%f",-image.size.width / 2, -image.size.height / 2);
//    debugLog(@"w=%f,h=%f",image.size.width ,image.size.height );

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
     CGRect a2 = CGRectMake(1,1, ceilf(newBoxWidth), ceilf(newBoxHeight));
    newImage = [ImageUtils cropImage:newImage withCropRect:a2];
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (CGPoint) getRotatedPoint:(CGPoint) refPoint WithAngle:(float)degrees WithDistance:(float)distance
{
    float radius = distance;
    
    float rads =degrees * (M_PI / 180);
    ;
    //position_ is your preknown position as you said
    //find a the point to roate
    //position_.x-radius is always 0 degrees of your current point
//    CGFloat x = cos(rads) * ((refPoint.x-radius)-refPoint.x) - sin(rads) * ((refPoint.y-radius)-refPoint.y) + refPoint.x;
//    CGFloat y = sin(rads) * ((refPoint.x-radius)-refPoint.x) + cos(rads) * ((refPoint.y-radius)-refPoint.y) + refPoint.y;
    CGFloat x = (cos(rads) * radius)+ refPoint.x;
    CGFloat y = (sin(rads) * radius)+ refPoint.y;
    
    //get the new point
    CGPoint newLocation = CGPointMake(x, y);
    return newLocation;
}

+ (CGFloat)getDistanceBetweenPoint:(CGPoint)p1 WitSecondPoint:(CGPoint)p2 {
    CGFloat xDist = (p2.x - p1.x);
    CGFloat yDist = (p2.y - p1.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}
+ (CGFloat)getHeightOffset:(UIImage *) image {
//    CGImageRef cgImageRef = image.CGImage;
//    int height = CGImageGetHeight(cgImageRef) ;
//    int hightOffset = ([ImageUtils getHeight]-height)/2;
    return ceilf(0);
}
+(UIImage *)getCroppedImageFromImage:(UIImage *)image WithCentreWithCentrePosition:(CGPoint)centre AndHasCentre:(BOOL) hasCentre  {
    CGImageRef cgImageRef = image.CGImage;
    int imageWidth = CGImageGetWidth(cgImageRef) ;
    int imageHeight = CGImageGetHeight(cgImageRef) ;
    if(!hasCentre) {
        centre.x = imageWidth/2;
        centre.y = imageHeight/2;
    }
    
    if(imageWidth==IMAGE_WIDTH && imageHeight==[ImageUtils getHeight]) {
        return image;
    }
    float cropRectWidth = IMAGE_WIDTH;
    float cropRectHeight = [ImageUtils getHeight];
    
    //    if(imageWidth>IMAGE_WIDTH && imageHeight > [ImageUtils getHeight]) {
    //
    //    }
    float widthRatio = (float)(imageWidth/(float)IMAGE_WIDTH);
    float heightRatio = (float)(imageHeight/(float)[ImageUtils getHeight]);
    
    
    float ratio = MIN(widthRatio, heightRatio);
    
    cropRectWidth = cropRectWidth* ratio;
    cropRectHeight = cropRectHeight* ratio;
    
    CGFloat vValue = centre.y-(cropRectHeight/2);
    CGFloat hValue = centre.x-(cropRectWidth/2);
    
    CGFloat vValuePlus = centre.y+(cropRectHeight/2);
    CGFloat hValuePlus = centre.x+(cropRectWidth/2);
    
    if(vValue<0) {
        vValue = vValue-vValue;
    } else if (vValuePlus>imageHeight) {
        vValue = vValue-(vValuePlus-imageHeight);

    }
    if(hValue<0) {
        hValue = hValue-hValue;
    }
    else if (hValuePlus>imageWidth) {
        hValue = hValue-(hValuePlus-imageWidth);

    }
    
    
    
    
    CGPoint cropRectOrigin = CGPointMake(hValue, vValue);
    CGRect  cropRect = CGRectMake(floorf(cropRectOrigin.x), floorf(cropRectOrigin.y), floorf(cropRectWidth),floorf(cropRectHeight));
    
    UIImage * newImage = [ImageUtils cropImage:image withCropRect:cropRect];
    
    
    return newImage;
}

+(CGPoint)getCroppingRectOrigin:(UIImage *)image WithCentreWithCentrePosition:(CGPoint)centre AndHasCentre:(BOOL) hasCentre  {
    CGImageRef cgImageRef = image.CGImage;
    int imageWidth = CGImageGetWidth(cgImageRef) ;
    int imageHeight = CGImageGetHeight(cgImageRef) ;
    if(!hasCentre) {
        centre.x = imageWidth/2;
        centre.y = imageHeight/2;
    }
    
    if(imageWidth==IMAGE_WIDTH && imageHeight==[ImageUtils getHeight]) {
        return CGPointMake(0, 0);
    }
    float cropRectWidth = IMAGE_WIDTH;
    float cropRectHeight = [ImageUtils getHeight];
    
    //    if(imageWidth>IMAGE_WIDTH && imageHeight > [ImageUtils getHeight]) {
    //
    //    }
    float widthRatio = (float)(imageWidth/(float)IMAGE_WIDTH);
    float heightRatio = (float)(imageHeight/(float)[ImageUtils getHeight]);
    
    
    float ratio = MIN(widthRatio, heightRatio);
    
    cropRectWidth = cropRectWidth* ratio;
    cropRectHeight = cropRectHeight* ratio;
    
    CGFloat vValue = centre.y-(cropRectHeight/2);
    CGFloat hValue = centre.x-(cropRectWidth/2);
    
    CGFloat vValuePlus = centre.y+(cropRectHeight/2);
    CGFloat hValuePlus = centre.x+(cropRectWidth/2);
    
    if(vValue<0) {
        vValue = vValue-vValue;
    } else if (vValuePlus>imageHeight) {
        vValue = vValue-(vValuePlus-imageHeight);
        
    }
    if(hValue<0) {
        hValue = hValue-hValue;
    }
    else if (hValuePlus>imageWidth) {
        hValue = hValue-(hValuePlus-imageWidth);
        
    }
    
    
    
    
    CGPoint cropRectOrigin = CGPointMake(floorf(hValue), floorf(vValue));
       
    
    return cropRectOrigin;
}

+(UIImage *)rescaleTwice:(UIImage *)image
{
    int width = IMAGE_WIDTH/2 ;
    int height = [ImageUtils getHeight]/2 ;
    
    
    UIImage * newImage = [self imageWithImage:image scaledToSize:CGSizeMake(floorf(width), floorf(height))];
     width = IMAGE_WIDTH ;
     height = [ImageUtils getHeight] ;
     newImage = [self imageWithImage:newImage scaledToSize:CGSizeMake(floorf(width), floorf(height))];
    
    return newImage;
}

+(NSString *)convertPointToString:(CGPoint)point
{
    return  NSStringFromCGPoint(point);
}
+(CGPoint)convertStringToPoint:(NSString *)string
{
    return CGPointFromString(string);
}

+(UIImage *)getThumbNail:(UIImage *)image
{
    CGSize size = image.size;
    UIImage * thumb = [ImageUtils imageWithImage:image scaledToSize:CGSizeMake(160, (160 / size.width) * size.height)];
    //thumb = [ImageUtils cropImage:thumb withCropRect:CGRectMake(0, 0, 80,100)];
    
    return thumb;
}

+(NSString *)saveImageToApplicationDocumentsFolder:(UIImage *)image
{
    UIImage * thumb = [ImageUtils getThumbNail:image];
    //thumb = image;
    
    NSString * names =   [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    NSString *imageName = [NSString stringWithFormat:@"%@%@.jpg",RESULT_IMAGE_NAME_PREFIX,names];
    NSString *thumbName = [NSString stringWithFormat:@"%@%@.jpg",RESULT_IMAGE_THUMB_NAME_PREFIX,names];
    
    NSString *imageFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:RESULT_FOLDER];
    NSString *thumbFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:RESULT_THUMBS_FOLDER];
    // New Folder is your folder name
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:imageFilePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:thumbFilePath]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:thumbFilePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    
    NSString *imageFileName = [imageFilePath stringByAppendingFormat:@"/%@",imageName];
    NSString *thumbFileName = [thumbFilePath stringByAppendingFormat:@"/%@",thumbName];


    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSData *thumbData = UIImageJPEGRepresentation(thumb, 1.0);

    [imageData writeToFile:imageFileName atomically:YES];
    [thumbData writeToFile:thumbFileName atomically:YES];
    return thumbName;
    
    
}



+(NSArray *)getImagesPathsFromDocumentsFolder:(BOOL)isThumbs
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * folderName = RESULT_FOLDER;
    if(isThumbs) {
        folderName = RESULT_THUMBS_FOLDER;
    } 
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:folderName];
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    

    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath
                      
                                                                         error:nil];
    
    //    NSString *fileName = [filePath stringByAppendingFormat:@"/%@",[files objectAtIndex:0]];
    //
    //    UIImage *img = [UIImage imageWithContentsOfFile:fileName];
    return files;
    
    
}

+(void)deleteImageFromPath:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
 
    NSString *filePath1 = [documentsDirectory stringByAppendingPathComponent:RESULT_FOLDER];
    NSString *filePath2 = [documentsDirectory stringByAppendingPathComponent:RESULT_THUMBS_FOLDER];
    
    NSString * fileNameActual = [fileName stringByReplacingOccurrencesOfString:RESULT_IMAGE_THUMB_NAME_PREFIX
                                                   withString:RESULT_IMAGE_NAME_PREFIX];
    NSString *imageFileName1 = [filePath1 stringByAppendingFormat:@"/%@",fileNameActual];

    NSString *imageFileName2= [filePath2 stringByAppendingFormat:@"/%@",fileName];

    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath1]) {
       
    } else {        [[NSFileManager defaultManager] removeItemAtPath: imageFileName1 error: &error];

    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath2]) {
        
    } else {
        [[NSFileManager defaultManager] removeItemAtPath: imageFileName2 error: &error];
        
    }
    

}
  @end
