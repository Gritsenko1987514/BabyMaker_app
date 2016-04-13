//
//  Facedetecter.m
//  FaceBlend
//
//  Created by user on 30/08/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import "Facedetecter.h"

@implementation Facedetecter

+(NSArray *)getFeaturesFromImage:(UIImage *) actualImage {
    
    CIImage *image = [[CIImage alloc] initWithImage:actualImage];
    NSDictionary * opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:CIDetectorImageOrientation];
    
    //    [NSDictionary dictionaryWithObject: [[image properties]valueForKey:[[kCGImagePropertyOrientation
    //                                                                         forKey:CIDetectorImageOrientation]];
    CIContext *context2  =   [CIContext contextWithOptions:opts];
    NSString *accuracy = CIDetectorAccuracyHigh;
    NSDictionary *options = [NSDictionary dictionaryWithObject:accuracy forKey:CIDetectorAccuracy];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:context2 options:options];
    NSArray *features = [detector featuresInImage:image];
    [image release];
    return features;
}
@end
