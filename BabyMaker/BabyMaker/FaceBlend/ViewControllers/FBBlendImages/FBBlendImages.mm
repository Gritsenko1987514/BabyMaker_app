//
//  FBBlendImages.m
//  FaceBlend
//
//  Created by Akhildas on 8/2/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import "FBBlendImages.h"
#import "poissonInt.h"
#import "ImageUtils.h"
#import "UIView+Animation.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "FBInstagramActivity.h"
#import "FBAppDelegate.h"

@interface FBBlendImages ()
{
    BOOL isShareViewShown;
    BOOL isBlended;
    NSUInteger currentImageIndex;
    NSMutableArray * galleryImages;
    int tappedPage;
    NSString * savedImageName;
    BOOL isUIActivityContollerVisible;
    float actWidth;
    float actHeight;
    CGFloat originX;
    CGFloat originy;
    UIActivityViewController* activityViewController ;
    
}

@end

@implementation FBBlendImages
@synthesize sourceImage;
@synthesize destImage;
@synthesize leftEye,rightEye,mouth;
@synthesize leftEyeDest,rightEyeDest,mouthDest,chinDest;
@synthesize poissonObj;
@synthesize shownImageIndex,isGalleryFullView;
//@synthesize deleteImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)setWindowSize:(BOOL)increase

{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        if(increase) {
            self.contentView.frame = CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height + 20);
        } else {
            self.view.clipsToBounds =YES;
            
            self.contentView.frame =  CGRectMake(0, 20,self.view.frame.size.width,self.view.frame.size.height - 20);
            
        }
        
    }
    
}

-(void)setSHareViewFrame
{
     if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
    self.shareAndDeleteView.frame = CGRectMake(0, self.contentView.frame.size.height,  self.shareAndDeleteView.frame.size.width,  self.shareAndDeleteView.frame.size.height);
     } else {
          self.shareAndDeleteView.frame = CGRectMake(0, self.contentView.frame.size.height-20,  self.shareAndDeleteView.frame.size.width,  self.shareAndDeleteView.frame.size.height);
     }
}
- (void)viewDidLoad
{
//    [[FBAppDelegate application]setWindowSize:YES];


    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    [self setShareButtonImage];
    [self.processingImageView setUserInteractionEnabled:YES];

    CGRect newBounds = CGRectMake(self.processingImageView.frame.origin.x, self.processingImageView.frame.origin.y, self.processingImageView.bounds.size.width, ([ImageUtils getHeight]/SCALE)+3);
    self.processingImageView.frame = newBounds;

    self.scrollView.frame = newBounds;
//    self.scrollView.frame.origin = CGPointMake(0, 57);

    isShareViewShown = NO;
    if(self.isGalleryFullView) {
    }
    else
    {
      
        [self.processingImageView setHidden:NO];
        [self.scrollView setHidden:YES];
    }
}

-(void)showGallery {
    isBlended = YES;
    isGalleryFullView = YES;
    [self.processingImageView setHidden:YES];
    [self.scrollView setHidden:NO];
    
    [self addGestureRecognizer];
    currentImageIndex = shownImageIndex;
    [self getImagesAndAddtoScrollView];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];
}



-(void)viewDidAppear:(BOOL)animated
{
    [[FBAppDelegate application] logGoogleAnalytics:@"UI" action:@"ViewSwitch" label:@"BlendImages - FBBlendImages" value:nil];
    
    self.navigationController.navigationBarHidden = YES;
    if (isBlended)
    {
        
    }
    else
    {
        [[FBAppDelegate application]setWindowSize:YES];
        [self setWindowSize:NO];
        [self setSHareViewFrame];

        if(self.isGalleryFullView)
        {
            [self showGallery];

        }
        else
        {
            [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            
            dispatch_queue_t backgroundQueue = dispatch_queue_create("com.faceblend.queue", 0);
            
            dispatch_async(backgroundQueue, ^{
                UIImage *processedImage = [self blendImages];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self completedLoading:processedImage];
                });
            });
        }
        
    }
    
}

-(void)setShareButtonImage {
    [self.shareButton setImage:[UIImage imageNamed:@"shareButton"] forState:UIControlStateNormal];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [self.shareButton setImage:[UIImage imageNamed:@"shareButton7"] forState:UIControlStateNormal];
    }
}

- (void)showChartboost:(NSString *)str
{
    Chartboost *cb = [Chartboost sharedChartboost];
    cb.appId = CHARTBOOST_APP_ID;
    cb.appSignature = CHARTBOOST_APP_SIGNATURE;
    cb.delegate = nil;
    [cb startSession];
    [cb showInterstitial:str];
}

- (void)showPlayHaven:(NSString *)placement
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:PRO_UPGRADE_ID] == YES)
        return;
    
    PHPublisherContentRequest * request = [PHPublisherContentRequest requestForApp:@"42b68a73d0c14f1aaf6eb5e76ce3ac5c" secret:@"e1bf4489b19943e8b6258f1eaa2bcd44" placement:placement delegate:self];
    [request setShowsOverlayImmediately:YES];
    [request setAnimated:YES];
    [request send];
}

-(void)getImagesAndAddtoScrollView
{
    [self getImagesFromDocumentsFolder];
    
    [self setupScrollView];
    if(galleryImages != nil && !galleryImages.count>0) {
        [self setWindowSize:YES];
        [[FBAppDelegate application]setWindowSize:NO];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    [self scrollToPage:currentImageIndex];
}
-(void)getImagesFromDocumentsFolder
{
    NSArray * fileNames = [ImageUtils getImagesPathsFromDocumentsFolder:YES ];
    
    NSEnumerator*   reverseEnumerator = [fileNames reverseObjectEnumerator];
   
    galleryImages = [[NSMutableArray alloc]init];
    for ( NSString *fileName in reverseEnumerator) {
        //        UIImage *img = [UIImage imageWithContentsOfFile:fileName];

        [galleryImages addObject:fileName];
        
    }
    
    
}

-(void) setupScrollView {
    //add the scrollview to the view
    
    self.scrollView.pagingEnabled = YES;
    [self.scrollView setAlwaysBounceVertical:NO];
    [self.scrollView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    NSInteger numberOfViews = 0;
    //setup internal views
    if(galleryImages != nil) {
     numberOfViews = galleryImages.count;
    }
    for (int i = 0; i < numberOfViews; i++) {
        CGFloat xOrigin = i * self.scrollView.frame.size.width;
        int offset = 0;
        UIImageView *image = [[UIImageView alloc] initWithFrame:
                              CGRectMake(xOrigin+offset, 0+offset,
                                         self.scrollView.frame.size.width-(2*offset),
                                         self.scrollView.frame.size.height-(2*offset))];
        image.image = [self fetchImageWithFileName:[galleryImages objectAtIndex:i]];
        image.contentMode = UIViewContentModeScaleAspectFill;
        image.clipsToBounds = YES;
        [image setUserInteractionEnabled:YES];
        image.tag = i;
        
        [self.scrollView addSubview:image];
    }
    //set the scroll view content size
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width *
                                             numberOfViews,
                                             self.scrollView.frame.size.height);
}

-(void)addGestureRecognizer {

    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:) ];
    if(isGalleryFullView) {
        [self.scrollView addGestureRecognizer:tapRecognizer];

    } else {
        [self.processingImageView addGestureRecognizer:tapRecognizer];

    }
    

    
}

- (void)tapAction:(UITapGestureRecognizer*)sender{
    if(isGalleryFullView) {
    CGPoint tapPoint = [sender locationInView:self.scrollView];
    tappedPage = [self getPageIndexWhenTappedAtXValue:tapPoint.x];
    }
    [self showAndHideShareView];
}
-(int)getPageIndexWhenTappedAtXValue:(CGFloat)xValue
{
    int pageNo = (xValue/self.scrollView.bounds.size.width);
    return pageNo;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIImage *)fetchImageWithFileName:(NSString *)fileName
{
    
 
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:RESULT_FOLDER];
    // New Folder is your folder name
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    fileName = [fileName stringByReplacingOccurrencesOfString:RESULT_IMAGE_THUMB_NAME_PREFIX
                                         withString:RESULT_IMAGE_NAME_PREFIX];
    NSString *fullFileName = [filePath stringByAppendingFormat:@"/%@",fileName];
    
    debugLog(@"thumbFileName%@",fullFileName);

    return [UIImage imageWithContentsOfFile:fullFileName];
}
- (IBAction)doneButton:(id)sender
{
    [self setWindowSize:YES];
    [[FBAppDelegate application]setWindowSize:NO];

    //    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)completedLoading:(UIImage *)image
{
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
    image = [self getRotatedAndRecroppedImage:image WithAngle:poissonObj.angleTobeRotated];
    
    [self.processingImageView setImage:image];
    [self.processingImageView setUserInteractionEnabled:YES];
    savedImageName = [ImageUtils saveImageToApplicationDocumentsFolder:image];
    isBlended = YES;
    shownImageIndex = 0;
     [self showGallery];
}

-(UIImage *)blendImages
{
    
    PoissonBlendObject * p1 = self.poissonObj;
    UIImage * front = p1.eyeViewImage;
    UIImage * frontMouth =p1.noseAndMouthImage;
    UIImage * back = p1.backgroundImageWithRotation;
    UIImage * backOriginal = p1.backgroundImageWithOutRotation;
    
    
    
    CGImageRef cgImageRef = back.CGImage;
    float nowWidth = CGImageGetWidth(cgImageRef) ;
    float nowHeight = CGImageGetHeight(cgImageRef) ;
    CGImageRef cgImageRef2 = backOriginal.CGImage;
     actWidth = CGImageGetWidth(cgImageRef2) ;
     actHeight = CGImageGetHeight(cgImageRef2) ;
     originX= ceilf((nowWidth - actWidth)/2);
     originy= ceilf((nowHeight - actHeight)/2);
    
    
    CGImageRef cgImageRef11 = front.CGImage;
    float nowWidth1 = CGImageGetWidth(cgImageRef11) ;
    float nowHeight1 = CGImageGetHeight(cgImageRef11) ;
    CGImageRef cgImageRef22 = frontMouth.CGImage;
    float nowWidth2 = CGImageGetWidth(cgImageRef22) ;
    float nowHeight2 = CGImageGetHeight(cgImageRef22) ;
    CGImageRef cgImageRef33 = back.CGImage;
    float nowWidth3 = CGImageGetWidth(cgImageRef33) ;
    float nowHeight3 = CGImageGetHeight(cgImageRef33) ;
    
    CGRect frRect = CGRectMake(ceilf(p1.eyesViewOrigin.x),ceilf(p1.eyesViewOrigin.y), nowWidth1, nowHeight1);
    CGRect frNoseRect = CGRectMake(ceilf(p1.noseAndMouthOrigin.x),ceilf(p1.noseAndMouthOrigin.y), nowWidth2, nowHeight2);
    CGRect backBlendRect =  CGRectMake(ceilf(p1.eyesViewOrigin.x-4),ceilf(p1.eyesViewOrigin.y-4), nowWidth1+nowWidth2+8, nowHeight1+nowHeight2+8);
    
    CGRect baRect = CGRectMake(ceilf(0),0, nowWidth3, nowHeight3);
    
    
    
    front = [ImageUtils mergeTwoImages:back sec:front WithFirestImageSize:baRect.size WithSecondImageSize:frRect.size WithSecondOrigin:CGPointMake(ceilf(p1.eyesViewOrigin.x),ceilf(p1.eyesViewOrigin.y))];
    front = [ImageUtils cropImage:front withCropRect:frRect];
    frontMouth = [ImageUtils mergeTwoImages:back sec:frontMouth WithFirestImageSize:baRect.size WithSecondImageSize:frNoseRect.size WithSecondOrigin:CGPointMake(ceilf(p1.noseAndMouthOrigin.x),ceilf(p1.noseAndMouthOrigin.y))];
    frontMouth = [ImageUtils cropImage:frontMouth withCropRect:frNoseRect];
    
    UIImage * backBlend = [ImageUtils cropImage:back withCropRect:backBlendRect];
    
    Mat src = [self cvMatFromUIImage:front];
    Mat src2 = [self cvMatFromUIImage:frontMouth];
    Mat dst = [self cvMatFromUIImage:backBlend];
    
    cvtColor(dst, dst, CV_RGBA2RGB);
    cvtColor(src, src, CV_RGBA2RGB);
    cvtColor(src2, src2, CV_RGBA2RGB);
    
    IplImage dest = dst;
    IplImage source = src;
    
    IplImage source2 = src2;
    

//    IplImage *image = poisson_blend(&dest, &source, floorf(p1.eyesViewOrigin.y),floorf(p1.eyesViewOrigin.x));
    
    
    IplImage *image = poisson_blend(&dest, &source, 4,4,NO);
    
    
//    IplImage *image2 = poisson_blend(image, &source2, floorf(p1.noseAndMouthOrigin.y),floorf(p1.noseAndMouthOrigin.x));
     IplImage *image2 = poisson_blend(image, &source2, nowHeight1,floorf(p1.noseAndMouthOrigin.x-backBlendRect.origin.x),YES);
    
    UIImage * poissonBlendedImage = [self UIImageFromCVMat:Mat(image2)];
    
    CGRect backBlendCropRect =  CGRectMake(2,2, nowWidth1+nowWidth2+4, nowHeight1+nowHeight2+4);
    
    poissonBlendedImage = [ImageUtils cropImage:poissonBlendedImage withCropRect:backBlendCropRect];

    poissonBlendedImage = [ImageUtils mergeTwoImages:back sec:poissonBlendedImage WithFirestImageSize:back.size WithSecondImageSize:poissonBlendedImage.size WithSecondOrigin:CGPointMake(ceilf(p1.eyesViewOrigin.x-2),ceilf(p1.eyesViewOrigin.y-2))];

//    CGFloat a =p1.angleTobeRotated;


//        poissonBlendedImage = [self getRotatedAndRecroppedImage:poissonBlendedImage WithAngle:a];




    
    
   
    cvReleaseImage(&image);
    cvReleaseImage(&image2);

    
    return poissonBlendedImage;
    
   }

-(UIImage *)getRotatedAndRecroppedImage:(UIImage *)poissonBlendedImage WithAngle:(CGFloat)a {
    poissonBlendedImage = [ImageUtils rotate:poissonBlendedImage radians:a WithTransform:NO] ;
    
//    [self.processingImageView setImage:poissonBlendedImage];
    
   CGRect  cropBackRect = CGRectMake(originX+4,originy+6, actWidth-8, actHeight-14);
//   CGRect  cropBackRect = CGRectMake(originX,originy, actWidth, actHeight);
//
//    //
    poissonBlendedImage = [ImageUtils cropImage:poissonBlendedImage withCropRect:cropBackRect];
    return poissonBlendedImage;
    
}

- (Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    Mat cvMat(rows, cols, CV_8UC4);
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data, cols, rows, 8, cvMat.step[0], colorSpace,kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(Mat)cvMat
{
    
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols, cvMat.rows, 8,  8 * cvMat.elemSize(), cvMat.step[0], colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault, provider, NULL, false,kCGRenderingIntentDefault);
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}



-(UIImage *)ReverseUIImageFromCVMat:(Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.rows, cvMat.cols, 8,  8 * cvMat.elemSize(), cvMat.step[0], colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault, provider, NULL, false,kCGRenderingIntentDefault);
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}


- (void)viewDidUnload {
    [self setNavigationTitle:nil];
    [self setShareView:nil];

    [super viewDidUnload];
}

#pragma mark - Touch methods
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [[ event allTouches] anyObject];
    [self showAndHideShareView];
    
}

-(void)showAndHideShareView
{
    if(!isShareViewShown)
    {
        [self showShareView];
    }
    else
    {
        [self hideShareView];
    }
}

-(void)showShareView
{
    isShareViewShown = YES;
    [self.view bringSubviewToFront:self.shareAndDeleteView];

    [self.shareAndDeleteView showViewWithDuration:0.5 option:UIViewAnimationOptionTransitionCrossDissolve];
   
}
-(void)hideShareView
{
    isShareViewShown = NO;
    
    [self.shareAndDeleteView hideViewWithDuration:0.5 option:UIViewAnimationOptionTransitionCrossDissolve];
    
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(isShareViewShown)
    {
    [self hideShareView ];
    }

}
-(void)scrollToPage:(int)pageNo
{
    CGRect pageRect = CGRectMake(pageNo*self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width,  self.scrollView.bounds.size.height);
    [self.scrollView scrollRectToVisible:pageRect animated:NO];
}
- (IBAction)shareButtonClicked:(id)sender
{
    if(isGalleryFullView)
    {
        UIImage *image  = [self fetchImageWithFileName:[galleryImages objectAtIndex:tappedPage]];
        NSString *shareString = @"Baby Maker";
        NSArray* dataToShare = @[image,shareString];  // ...or whatever pieces of data you want to share.
//         NSArray* activities = @[UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypePostToWeibo,UIActivityTypeCopyToPasteboard];
//        FBInstagramActivity *instagram = [[FBInstagramActivity alloc]init];
//        instagram.delegate = self;
//        instagram.presentFromButton = (UIBarButtonItem *)sender;
//        NSArray* activities2 = @[instagram];
         activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                          applicationActivities:nil];
        
//        activityViewController.excludedActivityTypes = activities;
        [self presentViewController:activityViewController animated:YES completion:^{}];

    }
    else
    {
        UIImage *image  = self.processingImageView.image;
        NSString *shareString = @"Baby Maker";
        NSArray* dataToShare = @[image,shareString];  // ...or whatever pieces of data you want to share.
        
        activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                          applicationActivities:nil];
        [self presentViewController:activityViewController animated:YES completion:^{}];

 
    }
     [self showPlayHaven:@"shares_photo"];
    [self showChartboost:@"share_action"];
}


- (IBAction)deleteImage:(id)sender {
    [self showDeleteImageAlert];
   
}

-(void)showDeleteImageAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete image?"
                                                     message:@""
                                                    delegate:self
                                           cancelButtonTitle:@"No"
                                           otherButtonTitles:@"Yes", nil ];
    [alert show];
}

-(void)deleteImage {
    if(tappedPage==[galleryImages count]-1) {
        currentImageIndex--;
    }
    else {
        currentImageIndex= tappedPage;

    }
    if(isGalleryFullView) {
        
        UIImage *image  = [self fetchImageWithFileName:[galleryImages objectAtIndex:tappedPage]];
        UIImage *newImage  = [ImageUtils imageByCropping:image toRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        [self bringDeleteImageToFront:newImage];

        if(galleryImages != nil && galleryImages.count >tappedPage) {
            [ImageUtils deleteImageFromPath:[galleryImages objectAtIndex:tappedPage]];
        }
        
        [self getImagesAndAddtoScrollView];
    } else {
        [ImageUtils deleteImageFromPath:savedImageName];
        [self setWindowSize:YES];
        [[FBAppDelegate application]setWindowSize:NO];
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self hideShareView];
}
-(void)bringDeleteImageToFront:(UIImage *)image {
    [self.processingImageView setImage:image];
    [self.processingImageView setHidden:NO];

    [self.view bringSubviewToFront:self.processingImageView];
    CGPoint dest = CGPointMake(0,0);
    [self.processingImageView trsahAnimation:dest duration:0.5 option:UIViewAnimationOptionTransitionCrossDissolve withSuperView:self.view];

}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        //cancel clicked ...do your action
    }else if (buttonIndex == 1){
        [self deleteImage];
    }
}


- (void)showInstagramShare:(UIDocumentInteractionController* )documentInteractionController {
      [activityViewController dismissViewControllerAnimated:NO completion:nil];
//    [documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
}
-(void)resetWindowSize
{
    [[FBAppDelegate application]setWindowSize:NO];
}
@end
