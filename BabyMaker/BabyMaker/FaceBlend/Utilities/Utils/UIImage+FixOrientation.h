//
//  UIImage+FixOrientation.h
//  FaceBlend
//
//  Created by user on 22/08/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FixOrientation)
- (UIImage *)fixOrientation;
- (UIImage *)imageWithImage:(UIImage *)image cornerRadius:(NSInteger)conerRadius withSize:(CGSize)size;
@end
