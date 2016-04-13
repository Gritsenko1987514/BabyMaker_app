//
//  Facedetecter.h
//  FaceBlend
//
//  Created by user on 30/08/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Facedetecter : NSObject
+(NSArray *)getFeaturesFromImage:(UIImage *) actualImage;

@end
