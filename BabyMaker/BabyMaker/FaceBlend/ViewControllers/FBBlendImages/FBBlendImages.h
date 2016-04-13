//
//  FBBlendImages.h
//  FaceBlend
//
//  Created by Akhildas on 8/2/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import <opencv2/stitching/detail/blenders.hpp>
#include <vector>
#import "PoissonBlendObject.h"
#import "FBInstagramActivity.h"

@interface FBBlendImages : UIViewController <UIScrollViewDelegate,UIAlertViewDelegate,InstagramShareDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIView *shareAndDeleteView;
@property (nonatomic,strong) UIImage *sourceImage;
@property (nonatomic,strong) UIImage *sourceImage2;
@property (nonatomic,strong) UIImage *destImage;
@property (strong, nonatomic) IBOutlet UIImageView *processingImageView;
@property (nonatomic) CGPoint leftEye,rightEye,mouth;
@property (nonatomic) CGPoint leftEyeDest,rightEyeDest,mouthDest,chinDest;
@property (strong, nonatomic) IBOutlet UIView *shareView;
@property (nonatomic,strong) PoissonBlendObject *poissonObj;
@property (weak, nonatomic) IBOutlet UILabel *navigationTitle;
@property (nonatomic,assign) NSUInteger  shownImageIndex;
@property (nonatomic,assign) BOOL  isGalleryFullView;

- (IBAction)doneButton:(id)sender;
- (IBAction)shareButtonClicked:(id)sender;
- (IBAction)deleteImage:(id)sender;

@end
