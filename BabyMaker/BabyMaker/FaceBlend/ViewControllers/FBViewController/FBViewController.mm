//
//  FBViewController.m
//  FaceBlend
//
//  Created by Akhildas on 7/31/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import "FBViewController.h"
#import "UIImageViewEx.h"
#import "FBBlendImages.h"
#import "Face.h"
#import "ImageUtils.h"
#import "FaceManager.h"
#import "FBAppDelegate.h"
#import "FBMoreAppsViewController.h"
#import "Constants.h"
#import "FBDataBaseUtilities.h"
#import "FBBlendGalleryViewController.h"
#import "UIImage+FixOrientation.h"
#import "MBProgressHUD.h"
#import "Facedetecter.h"

@interface FBViewController ()
{
    UIImageView *currentSelectedImageView;
    UIView *popoverView;
    UIImage *selectedImage;
    UIImage *actualselectedImage;

    CGContextRef context,sourceContext;
    CGRect rects;
    CGPoint startLocation;
    UIImageView *mouthImage, *leftEyeImage, *rightEyeImage, *chinImage;
    NSArray *destImageContents;
    UIImage *imageReference;
    UIImage *imageReference2;
    CIFaceFeature *sourceFeature;
    CGPoint sourceLeftEye, sourceRightEye, sourceMouth, sourceChin;
    CGPoint destLeftEye, destRightEye, destMouth, destChin;
    UIImage *finalSourceImage,*finalSourceImage2,*finalDestinationImage;
    FBBlendImages *objBlend;
    NSMutableArray *faceMomImagesArray, *faceDadImagesArray;
    Face *momFace, *dadFace, *processedFace;
    CGFloat hightOffset;
    BOOL pickerLoaded;
    
    int selectedMomIndex;
    int selectedDadIndex;
    BOOL isSelectedMom;
}
@end

@implementation FBViewController

@synthesize _gridMomView;
@synthesize _gridDadView;

@synthesize fetchedResultsController;
@synthesize managedObjectContext;

#pragma mark - View methods
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [FBDataBaseUtilities initDataBase];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    [self setTitleForScreens];
    //self.sourceImage.layer.cornerRadius = 6;
    //self.destImage.layer.cornerRadius = 6;
    self.sourceImage.clipsToBounds = YES;
    self.destImage.clipsToBounds = YES;
    isSelectedMom = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"inappPromptRemoved"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appFromBackground:)
                                                 name:@"appFrombackground"
                                               object:nil];

    CGRect newBounds = CGRectMake(self.selectedImageView.frame.origin.x, self.selectedImageView.frame.origin.y, self.selectedImageView.bounds.size.width, ([ImageUtils getHeight]/SCALE)+1);

    self.selectedImageView.frame = newBounds;
    
    self.confirmTitle.font = [UIFont fontWithName:APPLICATION_FONT size:23];
    self.btnBoy.titleLabel.font = [UIFont fontWithName:APPLICATION_FONT size:21];
    self.btnGirl.titleLabel.font = [UIFont fontWithName:APPLICATION_FONT size:21];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    if (pickerLoaded)
    {
        pickerLoaded = NO;
        return;
    }
    else
    {
        self.sourceImage.image = nil;
        self.destImage.image = nil;
        [self animateView:YES];
        [self onMom:nil];
    }

    selectedMomIndex = -1;
    selectedDadIndex = -1;
    momFace = nil;
    dadFace = nil;
    isSelectedMom = YES;
    
    [_gridMomView removeFromSuperview];
    [_gridDadView removeFromSuperview];
    
    _gridMomView = nil;
    _gridDadView = nil;
    
    faceMomImagesArray = [FBDataBaseUtilities getMomFaceDetailsFromDB];
    faceDadImagesArray = [FBDataBaseUtilities getDadFaceDetailsFromDB];
    for (FaceImages *face in faceMomImagesArray)
        debugLog(@"FaceImages %@",face.imageName);
    
    [self setUpGridView];
    _gridMomView.hidden = NO;
    _gridDadView.hidden = YES;
    for (UIView *view in self.view.subviews)
    {
        if (view == self.imageSelecterPopupScreen)
        {
            [self.view bringSubviewToFront:self.imageSelecterPopupScreen];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[FBAppDelegate application] logGoogleAnalytics:@"UI" action:@"ViewSwitch" label:@"HomvView - FBViewController" value:nil];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FIRSTSTARTUP"] == NO)
    {
        [_gridMomView removeFromSuperview];
        [_gridDadView removeFromSuperview];
        
        faceMomImagesArray = [FBDataBaseUtilities getMomFaceDetailsFromDB];
        faceDadImagesArray = [FBDataBaseUtilities getDadFaceDetailsFromDB];
        
        [self setUpGridView];
        _gridMomView.hidden = NO;
        _gridDadView.hidden = YES;
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FIRSTSTARTUP"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)viewDidUnload {
    //    [self setScrollView:nil];
    [self setImageProcessingView:nil];
    [self setFrameView:nil];
    [self setFrameView:nil];
    [self setIndicatorImageView:nil];
    [self setPlaceHolderDest:nil];
    [self setPlaceHolderSource:nil];
    [self setChosePhotoInstructionOne:nil];
    [self setChosePhotoInstructionTwo:nil];
    [self setChosePhotoInstructionThree:nil];
    [self setChosePhotoInstructionFour:nil];
    [super viewDidUnload];
}

#pragma mark -
-(void)setUpGridView
{
    int totalCount = faceMomImagesArray.count;
    NSInteger noOfRows =  totalCount % 4 == 0 ? totalCount / 4 : totalCount / 4 + 1;
    CGRect frame = CGRectMake(self.frameView.frame.origin.x + 4, self.frameView.frame.origin.y,self.frameView.frame.size.width - 4, self.frameView.frame.size.height);
    _gridMomView = [[UzysGridView alloc] initWithFrame:frame numOfRow:noOfRows numOfColumns:4 cellMargin:2];
    _gridMomView.delegate = self;
    _gridMomView.dataSource = self;
    [self.view addSubview:_gridMomView];
    
    totalCount = faceDadImagesArray.count;
    noOfRows =  totalCount % 4 == 0 ? totalCount / 4 : totalCount / 4 + 1;
    _gridDadView = [[UzysGridView alloc] initWithFrame:frame numOfRow:noOfRows numOfColumns:4 cellMargin:2];
    _gridDadView.delegate = self;
    _gridDadView.dataSource = self;
    [self.view addSubview:_gridDadView];
}

-(void)setTitleForScreens
{
    self.adjustMarkersTitle.font = [UIFont fontWithName:APPLICATION_FONT size:18];
    self.chosePhotoInstructionOne.font = [UIFont fontWithName:MYRIADREGULAR_FONT size:14];
    self.chosePhotoInstructionTwo.font = [UIFont fontWithName:MYRIADREGULAR_FONT size:14];
    self.chosePhotoInstructionThree.font = [UIFont fontWithName:MYRIADREGULAR_FONT size:14];
    self.chosePhotoInstructionFour.font = [UIFont fontWithName:MYRIADREGULAR_FONT size:14];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Touch methods
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [[ event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.selectedImageView];
    
    if(touch.view == leftEyeImage)
    {
        leftEyeImage.center = location;
    }
    if(touch.view == rightEyeImage)
    {
        rightEyeImage.center = location;
    }
    if(touch.view == mouthImage)
    {
        mouthImage.center = location;
    }
    if(touch.view == chinImage)
    {
        chinImage.center = location;
    }
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesBegan:touches withEvent:event];
    
}

#pragma mark -
- (IBAction)okButtonPressed:(id)sender
{
    //This is to find the center of the image
    CGImageRef cgImageRef = selectedImage.CGImage;
    float imagviewWidth = CGImageGetWidth(cgImageRef);
    float imagviewHeight = CGImageGetHeight(cgImageRef);
    
    CGPoint centrePositioin = CGPointMake((imagviewWidth/2), (imagviewHeight/2));
    BOOL leftEyeBool = NO;
    BOOL rightEyeBool = NO;
    BOOL mouthBool = NO;
    BOOL chinBool = NO;
    Face *sampleFace = [[Face alloc] init];
    currentSelectedImageView.image = self.selectedImageView.image;
    for (UIImageView *img in self.selectedImageView.subviews)
    {
        if (img == leftEyeImage)
        {
            leftEyeBool = YES;
            CGPoint leftEye = leftEyeImage.center;
            leftEye.y =leftEye.y - hightOffset;
            
            sourceLeftEye = leftEye;
            CGFloat angle = [ImageUtils pointPairToBearingDegrees:centrePositioin secondPoint:leftEye];
            CGFloat dist = [ImageUtils getDistanceBetweenPoint:centrePositioin WitSecondPoint:leftEye];
            sampleFace.leftEyeAngle = angle;
            sampleFace.leftEyeRefDistance = dist;
        }
        if (img == rightEyeImage)
        {
            rightEyeBool = YES;
            CGPoint rightEye = rightEyeImage.center;
            rightEye.y =rightEye.y - hightOffset;
            
            sourceRightEye = rightEye;
            
            CGFloat angle = [ImageUtils pointPairToBearingDegrees:centrePositioin secondPoint:rightEye];
            CGFloat dist = [ImageUtils getDistanceBetweenPoint:centrePositioin WitSecondPoint:rightEye];
            sampleFace.rightEyeAngle = angle;
            sampleFace.rightEyeRefDistance = dist;
        }
        if (img == mouthImage)
        {
            mouthBool = YES;
            
            CGPoint mouth = mouthImage.center;
            mouth.y =mouth.y - hightOffset;
            
            sourceMouth = mouth;
        }
        if (img == chinImage)
        {
            chinBool = YES;
            
            CGPoint chin = chinImage.center;
            chin.y =chin.y - hightOffset;
            sourceChin = chin;
        }
        if (leftEyeBool&&rightEyeBool)
        {
            CGFloat angle = [ImageUtils pointPairToBearingDegrees:sourceRightEye secondPoint:sourceLeftEye];
            
            //Akhildas
            angle = 180 - angle;
            sampleFace.widthBetweenEyes = sourceFeature.bounds.size.width;
            [sampleFace setAngleBetweenEyes:angle];
            
        }
        if (mouthBool&&chinBool)
        {
            
            CGPoint calculatedMouth = CGPointMake((sourceChin.x+sourceMouth.x)/2, (sourceChin.y+sourceMouth.y)/2);
            CGFloat angle = [ImageUtils pointPairToBearingDegrees:centrePositioin secondPoint:calculatedMouth];
            CGFloat dist = [ImageUtils getDistanceBetweenPoint:centrePositioin WitSecondPoint:calculatedMouth];
            sampleFace.mouthAngle = angle;
            sampleFace.mouthRefDistance = dist;
            
        }
        [img removeFromSuperview];
    }
    
    sampleFace.faceImage = actualselectedImage;
    NSArray *faceArray =  [self saveImageToGallery];
    sampleFace.imageName = [faceArray objectAtIndex:0];
    sampleFace.faceImages = [faceArray objectAtIndex:1];
    if (isSelectedMom == YES)
        sampleFace.isMom = YES;
    else
        sampleFace.isMom = NO;
    
    
    if (currentSelectedImageView == self.destImage)
    {
        destLeftEye = sourceLeftEye;
        destRightEye = sourceRightEye;
        destMouth  = sourceMouth;
        destChin = sourceChin;
        dadFace = sampleFace;
        if (momFace == nil)
            [self onMom:nil];
    }
    else
    {
        finalSourceImage = imageReference;
        finalSourceImage2 = imageReference2;
        momFace = sampleFace;
        if (dadFace == nil)
            [self onDad:nil];
    }
    
    [self.imageProcessingView removeFromSuperview];
    processedFace = sampleFace;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    BOOL isProVersion = [settings boolForKey:PRO_UPGRADE_ID];
    if (isProVersion)
    {
        [FBDataBaseUtilities addImageToDataBase:sampleFace];
        if (sampleFace.isMom == YES)
        {
            selectedMomIndex = 0;
            faceMomImagesArray = [FBDataBaseUtilities getMomFaceDetailsFromDB];
            int totalCount = faceMomImagesArray.count;
            int noOfRows = totalCount % 4 == 0 ? totalCount / 4 : totalCount / 4 + 1;
            CGRect frame = CGRectMake(self.frameView.frame.origin.x + 4, self.frameView.frame.origin.y,self.frameView.frame.size.width - 4, self.frameView.frame.size.height);
            _gridMomView = [[UzysGridView alloc] initWithFrame:frame numOfRow:noOfRows numOfColumns:4 cellMargin:2];
            _gridMomView.delegate = self;
            _gridMomView.dataSource = self;
            [self.view addSubview:_gridMomView];
            if (dadFace == nil)
                _gridMomView.hidden = YES;
        }
        else
        {
            selectedDadIndex = 0;
            faceDadImagesArray = [FBDataBaseUtilities getDadFaceDetailsFromDB];
            int totalCount = faceDadImagesArray.count;
            int noOfRows =  totalCount % 4 == 0 ? totalCount / 4 : totalCount / 4 + 1;
            CGRect frame = CGRectMake(self.frameView.frame.origin.x + 4, self.frameView.frame.origin.y,self.frameView.frame.size.width - 4, self.frameView.frame.size.height);
            _gridDadView = [[UzysGridView alloc] initWithFrame:frame numOfRow:noOfRows numOfColumns:4 cellMargin:2];
            _gridDadView.delegate = self;
            _gridDadView.dataSource = self;
            [self.view addSubview:_gridDadView];
            if (momFace == nil)
                _gridDadView.hidden = YES;
        }
    }
    else
    {
//        [[FBAppDelegate application] showPlayHaven:@"store_open"];
        [self showPlayHaven:@"store_open"];
        
//        purchaseManager = [[QBInAppPurchaseManager alloc]initWithNibName:@"QBInAppPurchaseManager" bundle:nil];
//        purchaseManager.delegate = self;
//        purchaseManager.moreAppPage = NO;
//        purchaseManager.view.frame = self.view.frame;
//        [self.view addSubview:purchaseManager.view];
    }
    
    if (momFace != nil && dadFace != nil)
        [self onMerge:nil];
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
    
        PHPublisherContentRequest *request = [PHPublisherContentRequest
                                              requestForApp:@"42b68a73d0c14f1aaf6eb5e76ce3ac5c"
                                              secret:@"e1bf4489b19943e8b6258f1eaa2bcd44" placement:placement delegate:self];
        request.showsOverlayImmediately = YES;
        [request send];
}


- (void)request:(PHPublisherContentRequest *)request makePurchase:(PHPurchase *)purchase
{
    purchaseManager = [[QBInAppPurchaseManager alloc]initWithNibName:@"QBInAppPurchaseManager" bundle:nil];
    purchaseManager.delegate = self;
    purchaseManager.moreAppPage = NO;

    [purchaseManager buyNow:self];
}

- (IBAction)blendImages:(id)sender
{
    [self gotoBlendingView];
}

-(void)gotoBlendingView
{
    [[FBAppDelegate application] showPlayHaven:@"blended_photo"];
    [self showChartboost:@"blended_photo"];
    
    if(self.sourceImage.image != nil && self.destImage.image != nil)
    {
        FaceManager * faceManager = [[FaceManager alloc]init];
        faceManager.backFace = dadFace;
        faceManager.frontFace = momFace;
        PoissonBlendObject * poissonBlendObject = [faceManager getPoissonBlendedObject];
        
        objBlend = [[FBBlendImages alloc]initWithNibName:@"FBBlendImages" bundle:nil];
        objBlend.poissonObj = poissonBlendObject;
        objBlend.isGalleryFullView = NO;

        [self.navigationController pushViewController:objBlend animated:YES];
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Please select two images" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - saving image
-(NSArray *)saveImageToGallery
{
    UIImage *image = actualselectedImage;
    NSString *imageName;
    NSString *lastImageName = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"ImageName"];

    if (lastImageName.length == 0)
    {
        imageName = IMAGE_NAME;
    }
    else
    {
        NSArray *subStrings = [lastImageName componentsSeparatedByString:@"_"]; 
        NSString *lastString = [subStrings objectAtIndex:1];
       
        NSArray *subStrings2 = [lastString componentsSeparatedByString:@"."];
        NSString *finalName = [subStrings2 objectAtIndex:0];
        NSInteger number = finalName.integerValue;
        number++;
        imageName = [NSString stringWithFormat:@"FB_%d.jpg",number];
    }
    [[NSUserDefaults standardUserDefaults] setObject:imageName forKey:@"ImageName"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSString *stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:RESOURCE_FOLDER];
    
    // New Folder is your folder name
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:stringPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:stringPath withIntermediateDirectories:NO attributes:nil error:&error];
    
    NSString *fileName = [stringPath stringByAppendingFormat:@"/%@",imageName];
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    [data writeToFile:fileName atomically:YES];
    NSArray *resultArray = [[NSArray alloc]initWithObjects:imageName,fileName,nil];
    return resultArray;
}

#pragma mark -
- (IBAction)imageSelecterCloseButtonPressed:(id)sender
{
    [self removeImageSelecterPopUpScreen];
}

-(void)removeImageSelecterPopUpScreen
{
    [self.imageSelecterPopupScreen removeFromSuperview];
}

- (IBAction)blendGallerySelected:(id)sender
{
    if(_gridMomView.editable == YES || _gridDadView.editable == YES)
    {
        [self stopWiggling:self];
        return;
    }
    else
    {
        FBBlendGalleryViewController * blendGalleryViewController = [[FBBlendGalleryViewController alloc]initWithNibName:@"FBBlendGalleryViewController" bundle:nil];
        
        [self.navigationController pushViewController:blendGalleryViewController animated:YES];
    }
}
- (IBAction)onMom:(id)sender
{
    if(_gridMomView.editable == YES || _gridDadView.editable == YES)
    {
        [self stopWiggling:self];
        return;
    }
    
    isSelectedMom = YES;
    [self animateView:YES];
    _gridMomView.hidden = NO;
    _gridDadView.hidden = YES;
    
    [self.btnAddPhoto setBackgroundImage:[UIImage imageNamed:@"btn_addmom.png"] forState:UIControlStateNormal];
}

- (IBAction)onDad:(id)sender
{
    if(_gridMomView.editable == YES || _gridDadView.editable == YES)
    {
        [self stopWiggling:self];
        return;
    }
    
    isSelectedMom = NO;
    [self animateView:NO];
    _gridMomView.hidden = YES;
    _gridDadView.hidden = NO;
    
    [self.btnAddPhoto setBackgroundImage:[UIImage imageNamed:@"btn_adddad.png"] forState:UIControlStateNormal];
}

- (IBAction)onMerge:(id)sender
{
    if(_gridMomView.editable == YES || _gridDadView.editable == YES)
    {
        [self stopWiggling:self];
        return;
    }
    
    if (momFace == nil || dadFace == nil)
        return;
    
    [self.view addSubview:self.genderAlertView];
}

- (IBAction)newImageButtonPressed:(id)sender
{
    if(_gridMomView.editable == YES || _gridDadView.editable == YES)
    {
        [self stopWiggling:self];
        return;
    }
    else
    {
        [self.view addSubview:self.imageSelecterPopupScreen];
    }
}

- (IBAction)onAlertClose:(id)sender
{
    [self.genderAlertView removeFromSuperview];
}

- (IBAction)onAlertBoy:(id)sender
{
    [self animateView:NO];
    [_gridMomView reloadData];
    
    [self.genderAlertView removeFromSuperview];
    
    [self gotoBlendingView];
}

- (IBAction)onAlertGirl:(id)sender
{
    Face *tempFace = momFace;
    momFace = dadFace;
    dadFace = tempFace;
    
    [self animateView:NO];
    [_gridDadView reloadData];
    
    [self.genderAlertView removeFromSuperview];
    [self gotoBlendingView];
}

- (IBAction)selectImage:(id)sender
{
    self.selectedImageView.image = nil;
    if (isSelectedMom == YES)
    {
        currentSelectedImageView = self.sourceImage;
    }
    else
    {
        currentSelectedImageView = self.destImage;
    }

    for (UIImageView *img in self.selectedImageView.subviews)
    {
        [img removeFromSuperview];
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    if ([sender tag] == 200)
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        //picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    pickerLoaded = YES;
    
    [[FBAppDelegate application] setWindowSize:YES];

    [self presentViewController:picker animated:NO completion:NULL];
}

- (IBAction)adjustMarkerScreenBackPressed:(id)sender
{
    [self.imageProcessingView removeFromSuperview];
}

-(void)animateView:(BOOL)right
{
    CGRect imageFrame = self.indicatorImageView.frame;
    if (!right)
    {
        imageFrame.origin.x = 226;
    }
    else
    {
        imageFrame.origin.x = 58;
    }
    
    [UIView animateWithDuration:1
                          delay:0.3
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.indicatorImageView.frame = imageFrame;
                     } 
                     completion:^(BOOL finished){
                         if (!right)
                         {
                             self.placeHolderDest.image = [UIImage imageNamed:@"face2"];
                             self.placeHolderSource.image = [UIImage imageNamed:@"face1Nonselect"];
                             [self.btnSelectMom setBackgroundImage:[UIImage imageNamed:@"btn_mom.png"] forState:UIControlStateNormal];
                             [self.btnSelectDad setBackgroundImage:[UIImage imageNamed:@"btn_dad_select.png"] forState:UIControlStateNormal];
                             self.indicatorImageView.image = [UIImage imageNamed:@"Icon-move.png"];
                         }
                         else
                         {
                             self.placeHolderSource.image = [UIImage imageNamed:@"face1"];
                             self.placeHolderDest.image = [UIImage imageNamed:@"face2Nonselect"];
                             [self.btnSelectMom setBackgroundImage:[UIImage imageNamed:@"btn_mom_select.png"] forState:UIControlStateNormal];
                             [self.btnSelectDad setBackgroundImage:[UIImage imageNamed:@"btn_dad.png"] forState:UIControlStateNormal];
                             self.indicatorImageView.image = [UIImage imageNamed:@"Icon-move-revert.png"];
                         }

                     }];
}

#pragma mark image pickercontroller delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    chosenImage = [chosenImage fixOrientation];
    selectedImage = chosenImage;
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];

    //Face detesion
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        selectedImage = [ImageUtils createScaledUIImageWithActualImageIfSmaller:selectedImage];
        
        
        NSArray *features =[Facedetecter getFeaturesFromImage:selectedImage];

        Face * face ;
        
        CGPoint cropCentre;
        if(features != nil && features.count > 0) {
            CIFaceFeature *feature = [features objectAtIndex:0];
            cropCentre = CGPointMake(feature.bounds.origin.x+(feature.bounds.size.width/2),feature.bounds.origin.y+(feature.bounds.size.height/2));
            
            
            cropCentre = [self getCenterFromFaceFeatures:feature WithImage:selectedImage];
            face = [self getFaceObjectFromFaceFeatures:feature WithImage:selectedImage];
            CGPoint cropOrigin = [ImageUtils getCroppingRectOrigin:selectedImage WithCentreWithCentrePosition:cropCentre AndHasCentre:YES];
            
            
            selectedImage = [ImageUtils getCroppedImageFromImage:selectedImage WithCentreWithCentrePosition:cropCentre AndHasCentre:YES];
            float scale = [ImageUtils getScale:selectedImage]/SCALE;
            face.leftEyeCentre= CGPointMake((face.leftEyeCentre.x-cropOrigin.x)*scale,(face.leftEyeCentre.y-cropOrigin.y)*scale);
            face.rightEyeCentre= CGPointMake((face.rightEyeCentre.x-cropOrigin.x)*scale,(face.rightEyeCentre.y-cropOrigin.y)*scale);
            face.mouthCentre= CGPointMake((face.mouthCentre.x-cropOrigin.x)*scale,(face.mouthCentre.y-cropOrigin.y)*scale);
            
        } else {
            cropCentre = CGPointMake(-888,-888);
            selectedImage = [ImageUtils getCroppedImageFromImage:selectedImage WithCentreWithCentrePosition:cropCentre AndHasCentre:NO];
        }
        features = nil;

        [self detectFaceFeatureAndDrawWithImageWithFace:face];
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            [self drawImageAnnotatedWithFeatures:features];
        //        });
        
    });
   

    [picker dismissViewControllerAnimated:NO completion:^{
        [self resetWindowSize];
    }];
    [self removeImageSelecterPopUpScreen];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:NO completion:^{
        [self resetWindowSize];
    }];
}

-(void)resetWindowSize
{
    [[FBAppDelegate application]setWindowSize:NO];
}

-(void)detectFaceFeatureAndDrawWithImage {
    
    selectedImage = [ImageUtils createScaledUIImageWithActualImageIfNeeded:selectedImage];
    selectedImage = [ImageUtils createScaledUIImageWithActualImage:selectedImage];
    
    
    
    NSArray *features =[Facedetecter getFeaturesFromImage:selectedImage];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.selectedImageView.image = selectedImage;
        
        [self drawImageAnnotatedWithFeatures:features];
    });
}

-(void)detectFaceFeatureAndDrawWithImageWithFace:(Face*)face {
    
    selectedImage = [ImageUtils createScaledUIImageWithActualImageIfNeeded:selectedImage];
    selectedImage = [ImageUtils createScaledUIImageWithActualImage:selectedImage];
    actualselectedImage = selectedImage;
    selectedImage = [ImageUtils createDoubleScaledUIImageWithActualImage:selectedImage];
    
    NSArray *features =nil;
    features =[Facedetecter getFeaturesFromImage:selectedImage];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:self.imageProcessingView];
        CGRect frame = self.okButton.frame;
        if (isiPhone5)
        {
            frame.origin.y = 459;
        }
        else
        {
            frame.origin.y = 371;
        }
        self.okButton.frame = frame;
        self.selectedImageView.image = selectedImage;
        if(features != nil && features.count>0) {
            [self drawImageAnnotatedWithFeatures:features];
        } else if(face!= nil) {
            [self drawImageAnnotatedWithFeaturesWithFace:face];
        } else {
           Face * newFace = [[Face alloc]init];
            newFace.leftEyeCentre = CGPointMake(100, 300);
            newFace.rightEyeCentre = CGPointMake(220, 300);

            newFace.mouthCentre = CGPointMake(160, 190);

            
            [self drawImageAnnotatedWithFeaturesWithFace:newFace];
            [self showNoFaceDetectedAlert];

        }
    });
}


-(void)drawFeaturesFromImage:(UIImage *) actualImage {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CIImage *image = [[CIImage alloc] initWithImage:actualImage];
        //    NSDictionary * opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:CIDetectorImageOrientation];
        
        //    [NSDictionary dictionaryWithObject: [[image properties]valueForKey:[[kCGImagePropertyOrientation
        //                                                                         forKey:CIDetectorImageOrientation]];
        CIContext *context2  =   [CIContext contextWithOptions:nil];
        NSString *accuracy = CIDetectorAccuracyHigh;
        NSDictionary *options = [NSDictionary dictionaryWithObject:accuracy forKey:CIDetectorAccuracy];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:context2 options:options];
        
        NSArray *features = [detector featuresInImage:image];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.selectedImageView.image = selectedImage;
            if(features.count>0) {
                
                [self drawImageAnnotatedWithFeatures:features];
            }
        });
    });
}

-(NSArray *)getFeaturesFromImage:(UIImage *) actualImage {
    
    CIImage *image = [[CIImage alloc] initWithImage:actualImage];
        NSDictionary * opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:CIDetectorImageOrientation];
    
    //    [NSDictionary dictionaryWithObject: [[image properties]valueForKey:[[kCGImagePropertyOrientation
    //                                                                         forKey:CIDetectorImageOrientation]];
    CIContext *context2  =   [CIContext contextWithOptions:opts];
    NSString *accuracy = CIDetectorAccuracyHigh;
    NSDictionary *options = [NSDictionary dictionaryWithObject:accuracy forKey:CIDetectorAccuracy];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:context2 options:options];
    NSArray *features = [detector featuresInImage:image];
 
    return features;
}

#pragma mark - image size processing
-(UIImage *) createScaledUIImageWithActualImage:(UIImage *)image
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

-(void)showNoFaceDetectedAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No face detected. Please adjust markers."
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil ];
    [alert show];
}

-(float) getScleNeededWithActualImageForImageWidth:(float)width andForImageHeight:(float)height
{
    BOOL isLargerThanRequired = (width>self.selectedImageView.frame.size.width || height>self.selectedImageView.frame.size.height);
    float   hscale ;
    float   vscale ;
    float maxScale;
    if(isLargerThanRequired) {
        hscale = width/self.selectedImageView.frame.size.width;
        vscale = height/self.selectedImageView.frame.size.height;
        maxScale = (hscale>vscale?hscale:vscale);
        maxScale = 1/maxScale;
    } else {
        hscale = self.selectedImageView.frame.size.width/width;
        vscale = self.selectedImageView.frame.size.height/height;
        maxScale = (hscale<vscale?hscale:vscale);
    }
    return maxScale;
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

#pragma mark -
- (void)drawImageAnnotatedWithFeatures:(NSArray *)features {
    
    CGRect sizes = CGRectMake(0, 0, selectedImage.size.width, selectedImage.size.height);
    
	UIImage *faceImage = selectedImage;
    hightOffset = [ImageUtils getHeightOffset:faceImage];
    
    UIGraphicsBeginImageContextWithOptions(selectedImage.size, YES, 0);
    [faceImage drawInRect:sizes];
    leftEyeImage.userInteractionEnabled = YES;
    rightEyeImage.userInteractionEnabled = YES;
    mouthImage.userInteractionEnabled = YES;
    //    UIView *sample = [[UIView alloc]initWithFrame:CGRectMake(116, 165, 40, 40)];
    //    sample.backgroundColor = [UIColor blackColor];
    //    [self.selectedImageView addSubview:sample];
    //    sourceImageContents =  [[NSMutableArray alloc]init];
    
    // Get image context reference
    context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform, 0, - selectedImage.size.height);
    
    // Flip Context
    CGContextTranslateCTM(context, 0, selectedImage.size.height);
    //    [self drawImageAnnotatedWithFeatures:features];
    
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    if (scale > 1.0) {
        // Loaded 2x image, scale context to 50%
        CGContextScaleCTM(context, 0.5, 0.5);
    }
    
    for (CIFaceFeature *feature in features) {
        sourceFeature = feature;
        //        CGPoint featurep = CGPointApplyAffineTransform(feature.bounds.origin, transform);
        //        featurep.y = featurep.y+hightOffset;
        //
        //      UIView * rectv  = [[UIView alloc]initWithFrame:CGRectMake(featurep.x,featurep.y-feature.bounds.size.height, feature.bounds.size.width, feature.bounds.size.height)];
        //        [rectv setTransform:CGAffineTransformMakeScale(-1, -1)];
        //
        //        rectv.layer.borderColor = [[UIColor blackColor]CGColor];
        //        rectv.layer.borderWidth = 1;
        //
        //
        //
        //        [self.selectedImageView addSubview:rectv];
        
        
        if (feature.hasLeftEyePosition) {
            CGPoint leftEye = CGPointApplyAffineTransform(feature.leftEyePosition, transform);
            leftEye.y = leftEye.y+hightOffset;
            
            leftEyeImage = [[UIImageView alloc]initWithFrame:CGRectMake(leftEye.x,leftEye.y, 40, 40)];
            leftEyeImage.center = leftEye;
            [leftEyeImage setTransform:CGAffineTransformMakeScale(-1, -1)];
            leftEyeImage.image = [UIImage imageNamed:@"aimpoint"];
            [self.selectedImageView addSubview:leftEyeImage];
            //            [sourceImageContents addObject:[NSValue valueWithCGPoint:leftEye]];
        }
        
        if (feature.hasRightEyePosition) {
            CGPoint rightEye = CGPointApplyAffineTransform(feature.rightEyePosition, transform);
            rightEye.y = rightEye.y+hightOffset;
            
            rightEyeImage = [[UIImageView alloc]initWithFrame:CGRectMake(rightEye.x,rightEye.y, 40, 40)];
            rightEyeImage.center = rightEye;
            [rightEyeImage setTransform:CGAffineTransformMakeScale(-1, -1)];
            rightEyeImage.image = [UIImage imageNamed:@"aimpoint"];
            [self.selectedImageView addSubview:rightEyeImage];
            //            [sourceImageContents addObject:[NSValue valueWithCGPoint:rightEye]];
            
        }
        if (feature.hasMouthPosition) {
            CGPoint mouth = CGPointApplyAffineTransform(feature.mouthPosition, transform);
            mouth.y = mouth.y+hightOffset;
            
            mouthImage = [[UIImageView alloc]initWithFrame:CGRectMake(mouth.x,mouth.y, 40, 40)];
            mouthImage.center = mouth;
            [mouthImage setTransform:CGAffineTransformMakeScale(-1, -1)];
            mouthImage.image = [UIImage imageNamed:@"aimpoint"];
            [self.selectedImageView addSubview:mouthImage];
            //            [sourceImageContents addObject:[NSValue valueWithCGPoint:mouth]];
            
            CGPoint chinOrigin = CGPointMake(mouth.x,mouth.y);
            CGFloat angle = [ImageUtils pointPairToBearingDegrees:rightEyeImage.center secondPoint:leftEyeImage.center];
            angle = 270+angle;
            chinOrigin = [ImageUtils getRotatedPoint:mouth WithAngle:angle WithDistance:abs(rightEyeImage.center.x -leftEyeImage.center.x )*0.7];
            chinImage = [[UIImageView alloc]initWithFrame:CGRectMake(chinOrigin.x,chinOrigin.y, 40, 40)];
            chinImage.center = chinOrigin;
            
            
            //            chinImage.center.x = mouth;
            [chinImage setTransform:CGAffineTransformMakeScale(-1, -1)];
            chinImage.image = [UIImage imageNamed:@"aimpoint"];
            [self.selectedImageView addSubview:chinImage];
            
        }
        [mouthImage setUserInteractionEnabled:YES];
        [leftEyeImage setUserInteractionEnabled:YES];
        [rightEyeImage setUserInteractionEnabled:YES];
        [chinImage setUserInteractionEnabled:YES];
        
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sourceFeature = feature;
        //        [self drawPolygonFeatureInContext:context atPoint:feature];
        //});
        CGContextSaveGState(context);
        self.selectedImageView.image = UIGraphicsGetImageFromCurrentImageContext();
        if (currentSelectedImageView == self.destImage)
        {
            finalDestinationImage = self.selectedImageView.image;
        }
        break;
    }
    UIGraphicsEndImageContext();

    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
}

- (void)drawImageAnnotatedWithFeaturesWithFace:(Face *)face {
    
    CGRect sizes = CGRectMake(0, 0, selectedImage.size.width, selectedImage.size.height);
    
	UIImage *faceImage = selectedImage;
    hightOffset = [ImageUtils getHeightOffset:faceImage];
    
    UIGraphicsBeginImageContextWithOptions(selectedImage.size, YES, 0);
    [faceImage drawInRect:sizes];
    leftEyeImage.userInteractionEnabled = YES;
    rightEyeImage.userInteractionEnabled = YES;
    mouthImage.userInteractionEnabled = YES;
    //    UIView *sample = [[UIView alloc]initWithFrame:CGRectMake(116, 165, 40, 40)];
    //    sample.backgroundColor = [UIColor blackColor];
    //    [self.selectedImageView addSubview:sample];
    //    sourceImageContents =  [[NSMutableArray alloc]init];
    
    // Get image context reference
    context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform, 0, - selectedImage.size.height);
    
    // Flip Context
    CGContextTranslateCTM(context, 0, selectedImage.size.height);
    //    [self drawImageAnnotatedWithFeatures:features];
    
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    if (scale > 1.0) {
        // Loaded 2x image, scale context to 50%
        CGContextScaleCTM(context, 0.5, 0.5);
    }
    
    
    //        CGPoint featurep = CGPointApplyAffineTransform(feature.bounds.origin, transform);
    //        featurep.y = featurep.y+hightOffset;
    //
    //      UIView * rectv  = [[UIView alloc]initWithFrame:CGRectMake(featurep.x,featurep.y-feature.bounds.size.height, feature.bounds.size.width, feature.bounds.size.height)];
    //        [rectv setTransform:CGAffineTransformMakeScale(-1, -1)];
    //
    //        rectv.layer.borderColor = [[UIColor blackColor]CGColor];
    //        rectv.layer.borderWidth = 1;
    //
    //
    //
    //        [self.selectedImageView addSubview:rectv];
    
    
    CGPoint leftEye = CGPointApplyAffineTransform(face.leftEyeCentre,transform);
    leftEye.y = leftEye.y+hightOffset;
    
    leftEyeImage = [[UIImageView alloc]initWithFrame:CGRectMake(leftEye.x,leftEye.y, 40, 40)];
    leftEyeImage.center = leftEye;
    leftEyeImage.image = [UIImage imageNamed:@"aimpoint"];
    [self.selectedImageView addSubview:leftEyeImage];
    //            [sourceImageContents addObject:[NSValue valueWithCGPoint:leftEye]];
    
    CGPoint rightEye = CGPointApplyAffineTransform(face.rightEyeCentre,transform);
    rightEye.y = rightEye.y+hightOffset;
    
    rightEyeImage = [[UIImageView alloc]initWithFrame:CGRectMake(rightEye.x,rightEye.y, 40, 40)];
    rightEyeImage.center = rightEye;
    rightEyeImage.image = [UIImage imageNamed:@"aimpoint"];
    [self.selectedImageView addSubview:rightEyeImage];
    //            [sourceImageContents addObject:[NSValue valueWithCGPoint:rightEye]];
    
    CGPoint mouth =CGPointApplyAffineTransform(face.mouthCentre,transform);
    mouth.y = mouth.y+hightOffset;
    
    mouthImage = [[UIImageView alloc]initWithFrame:CGRectMake(mouth.x,mouth.y, 40, 40)];
    mouthImage.center = mouth;
    mouthImage.image = [UIImage imageNamed:@"aimpoint"];
    [self.selectedImageView addSubview:mouthImage];
    //            [sourceImageContents addObject:[NSValue valueWithCGPoint:mouth]];
    
    CGPoint chinOrigin = CGPointMake(mouth.x,mouth.y);
    CGFloat angle = [ImageUtils pointPairToBearingDegrees:rightEyeImage.center secondPoint:leftEyeImage.center];
    angle = 270+angle;
    chinOrigin = [ImageUtils getRotatedPoint:mouth WithAngle:angle WithDistance:abs(rightEyeImage.center.x -leftEyeImage.center.x )*0.7];
    chinImage = [[UIImageView alloc]initWithFrame:CGRectMake(chinOrigin.x,chinOrigin.y, 40, 40)];
    chinImage.center = chinOrigin;

    //            chinImage.center.x = mouth;
    [chinImage setTransform:CGAffineTransformMakeScale(-1, -1)];
    chinImage.image = [UIImage imageNamed:@"aimpoint"];
    [self.selectedImageView addSubview:chinImage];
    
    
    [mouthImage setUserInteractionEnabled:YES];
    [leftEyeImage setUserInteractionEnabled:YES];
    [rightEyeImage setUserInteractionEnabled:YES];
    [chinImage setUserInteractionEnabled:YES];
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //        [self drawPolygonFeatureInContext:context atPoint:feature];
    //});
    CGContextSaveGState(context);
    self.selectedImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    if (currentSelectedImageView == self.destImage)
    {
        finalDestinationImage = self.selectedImageView.image;
    }
    //        UIGraphicsEndImageContext();
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];

}

-(CGPoint)getCenterFromFaceFeatures:(CIFaceFeature *)feature WithImage:(UIImage *) image
{
    CGImageRef cgImageRef = image.CGImage;
    //:TODO:Akhildas
//    int imageWidth = CGImageGetWidth(cgImageRef) ;
    int imageHeight = CGImageGetHeight(cgImageRef) ;
    if(feature.hasLeftEyePosition && feature.hasRightEyePosition && feature.hasMouthPosition) {
        
        CGFloat leftMin = MIN(feature.leftEyePosition.x, feature.rightEyePosition.x);
        leftMin= MIN(leftMin, feature.mouthPosition.x);
        CGFloat rightMax = MAX(feature.leftEyePosition.x, feature.rightEyePosition.x);
        rightMax= MAX(rightMax, feature.mouthPosition.x);
        CGFloat centreX = ((leftMin+rightMax)/2);
        
        CGFloat topMin = MIN((imageHeight-feature.leftEyePosition.y), (imageHeight-feature.rightEyePosition.y));
        CGFloat tr = (imageHeight-feature.mouthPosition.y);
        topMin= MIN(topMin, tr);
        CGFloat bottomMax = MAX((imageHeight-feature.leftEyePosition.y), (imageHeight-feature.rightEyePosition.y));
        bottomMax= MAX(bottomMax, tr);
        
        //            bottomMax = bottomMax + ((bottomMax-topMin)*0.5);
        CGFloat centreY= (topMin+bottomMax)/2;
        
        return CGPointMake(centreX, centreY);
        
    }
    return CGPointMake(0, 0);
    
}

-(Face *)getFaceObjectFromFaceFeatures:(CIFaceFeature *)feature WithImage:(UIImage *) image
{
    //:TODO:Akhildas
//    CGImageRef cgImageRef = image.CGImage;
//    int imageWidth = CGImageGetWidth(cgImageRef) ;
    
//        int imageHeight = CGImageGetHeight(cgImageRef) ;
    Face * face;
    if(feature.hasLeftEyePosition && feature.hasRightEyePosition && feature.hasMouthPosition) {
        face = [[Face alloc]init];
        CGFloat leftMin = MIN(feature.leftEyePosition.x, feature.rightEyePosition.x);
        leftMin= MIN(leftMin, feature.mouthPosition.x);
        CGFloat rightMax = MAX(feature.leftEyePosition.x, feature.rightEyePosition.x);
        rightMax= MAX(rightMax, feature.mouthPosition.x);
        //:TODO:Akhildas
//        CGFloat centreX = ((leftMin+rightMax)/2);
        
        CGFloat topMin = MIN((feature.leftEyePosition.y), (feature.rightEyePosition.y));
        CGFloat tr = (feature.mouthPosition.y);
        topMin= MIN(topMin, tr);
        CGFloat bottomMax = MAX((feature.leftEyePosition.y), (feature.rightEyePosition.y));
        bottomMax= MAX(bottomMax, tr);
        
        //            bottomMax = bottomMax + ((bottomMax-topMin)*0.5);
        //:TODO:Akhildas
//        CGFloat centreY= (topMin+bottomMax)/2;
        face.leftEyeCentre = feature.leftEyePosition;
        face.rightEyeCentre = feature.rightEyePosition;
        face.mouthCentre = feature.mouthPosition;
        
//        face.leftEyeCentre= CGPointMake(face.leftEyeCentre.x,imageHeight-face.leftEyeCentre.y);
//        
//        face.rightEyeCentre= CGPointMake(face.rightEyeCentre.x,imageHeight-face.rightEyeCentre.y);
//
//        face.mouthCentre= CGPointMake(face.mouthCentre.x,imageHeight-face.mouthCentre.y);

        
    }
    return face;
    
}

// This is to crop the image
- (UIImage *)eyeImage:(UIImage *)oldImage leftEye:(CGPoint)leftEye rightEye:(CGPoint)rightEye mouth:(CGPoint)mouth
{
    UIImage *newImage = self.selectedImageView.image;
    CGRect frameEye;
    frameEye.origin.x = (leftEye.x - 25)*2;
    frameEye.origin.y = (leftEye.y - 40)*2;
    frameEye.size.width = ((rightEye.x - leftEye.x)+50)*2;
    frameEye.size.height = (leftEye.y+50 - leftEye.y)*2;
    //    frame.size.height = leftEye.y > rightEye.y ? ((mouth.y - leftEye.y)+10)*2 : ((mouth.y - rightEye.y)+10)*2;
    
    CGSize eyesSize = CGSizeMake(frameEye.size.width, frameEye.size.height);
    UIGraphicsBeginImageContext(eyesSize);
    
    CGImageRef imageRefEye = CGImageCreateWithImageInRect([newImage CGImage], frameEye);
    // or use the UIImage wherever you like
    newImage = [UIImage imageWithCGImage:imageRefEye];
    CGImageRelease(imageRefEye);
    self.sourceImage.image = newImage;
    return newImage;
}

- (UIImage *)mouthImage:(UIImage *)oldImage leftEye:(CGPoint)leftEye rightEye:(CGPoint)rightEye mouth:(CGPoint)mouth chin:(CGPoint)chin
{
    UIImage *newImage = self.selectedImageView.image;
    CGRect frameMouth;
    frameMouth.origin.x = (leftEye.x-5)*2;
    frameMouth.origin.y = (leftEye.y + 20)*2;
    frameMouth.size.width = (rightEye.x+10 - leftEye.x)*2;
    frameMouth.size.height = leftEye.y + 20 > rightEye.y + 20 ? ((mouth.y + chin.y)/2 - leftEye.y-20)*2 : ((mouth.y + chin.y)/2 - rightEye.y-20)*2;
    
    CGSize mouthSize = CGSizeMake(frameMouth.size.width, frameMouth.size.height);
    UIGraphicsBeginImageContext(mouthSize);
    
    CGImageRef imageRefMouth = CGImageCreateWithImageInRect([newImage CGImage], frameMouth);
    // or use the UIImage wherever you like
    newImage = [UIImage imageWithCGImage:imageRefMouth];
    CGImageRelease(imageRefMouth);
    //    self.sourceImage.image = newImage;
    return newImage;
}

-(UIImage *)changeWhiteColorTransparent: (UIImage *)image
{
    CGImageRef rawImageRef=image.CGImage;
    
    const float colorMasking[6] = {222, 255, 222, 255, 222, 255};
    
    UIGraphicsBeginImageContext(image.size);
    CGImageRef maskedImageRef=CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    {
        //if in iphone
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    }
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();
    return result;
}

#pragma mark- UzysGridViewDataSource


-(NSInteger) numberOfCellsInGridView:(UzysGridView *)gridview
{
    if (gridview == _gridMomView)
        return faceMomImagesArray.count;
    else
        return faceDadImagesArray.count;
}

-(UzysGridViewCell *)gridView:(UzysGridView *)gridview cellAtIndex:(NSUInteger)index
{
    UzysGridViewCustomCell *cell = [[UzysGridViewCustomCell alloc] initWithFrame:CGRectNull];
    
    FaceImages *face = nil;
    if (gridview == _gridMomView)
        face = [faceMomImagesArray objectAtIndex:index];
    else
        face = [faceDadImagesArray objectAtIndex:index];
    NSString *faceImageName = face.faceImage;
    
    UIImage * thumbImage = [UIImage imageWithContentsOfFile:faceImageName];
    CGSize size = CGSizeMake(160, 240);
    thumbImage = [thumbImage imageWithImage:thumbImage cornerRadius:8 withSize:size];
    cell.backGroundImageView.image = thumbImage;
    if(index == selectedMomIndex || index == selectedDadIndex) {
        cell.deletable = NO;
    } else {
       cell.deletable = YES;
    }
    
    //:TODO:Akhildas
    thumbImage = nil;

    [cell.backGroundImageView setHighlighted:NO];
    
    return cell;
}

- (void)gridView:(UzysGridView *)gridview moveAtIndex:(NSUInteger)fromindex toIndex:(NSUInteger)toIndex
{
    if (gridview == _gridMomView)
    {
        NSMutableDictionary *Temp = [faceMomImagesArray objectAtIndex:fromindex];
        
        [faceMomImagesArray removeObjectAtIndex:fromindex];
        [faceMomImagesArray insertObject:Temp atIndex:toIndex];
    }
    else
    {
        NSMutableDictionary *Temp = [faceDadImagesArray objectAtIndex:fromindex];
        
        [faceDadImagesArray removeObjectAtIndex:fromindex];
        [faceDadImagesArray insertObject:Temp atIndex:toIndex];
    }
}

-(void) gridView:(UzysGridView *)gridview deleteAtIndex:(NSUInteger)index
{
    if(index != selectedMomIndex && index != selectedDadIndex)
    {
        NSError *error;
        FaceImages *face;
        if (gridview == _gridMomView)
        {
            face = [faceMomImagesArray objectAtIndex:index];
            [[NSFileManager defaultManager] removeItemAtPath:face.faceImage  error: &error];
            
            [faceMomImagesArray removeObjectAtIndex:index];
            if ([faceMomImagesArray count] == 0)
            {
                _gridMomView.editable = NO;
                [_gridMomView removeFromSuperview];
                [self reConstructDatabase];
            }
        }
        else
        {
            face = [faceDadImagesArray objectAtIndex:index];
            [[NSFileManager defaultManager] removeItemAtPath:face.faceImage  error: &error];
            
            [faceDadImagesArray removeObjectAtIndex:index];
            if ([faceDadImagesArray count] == 0)
            {
                _gridDadView.editable = NO;
                [_gridDadView removeFromSuperview];
                [self reConstructDatabase];
            }
        }
    }
}

#pragma mark- UzysGridViewDelegate
-(void) gridView:(UzysGridView *)gridView changedPageIndex:(NSUInteger)index
{
    debugLog(@"Page : %d",index);
}

-(void) gridView:(UzysGridView *)gridView didSelectCell:(UzysGridViewCell *)cell atIndex:(NSUInteger)index
{
    debugLog(@"Cell index %d",index);
    if(isSelectedMom == YES)
    {
        selectedMomIndex = index;
        FaceImages *face = [faceMomImagesArray objectAtIndex:index];
        momFace = [self getFaceDetails:face];
        NSString *faceImageName = face.faceImage;
        self.sourceImage.image = [UIImage imageWithContentsOfFile:faceImageName];
        if (dadFace == nil)
            [self onDad:nil];
    }
    else
    {
        selectedDadIndex = index;
        FaceImages *face = [faceDadImagesArray objectAtIndex:index];
        dadFace = [self getFaceDetails:face];
        NSString *faceImageName = face.faceImage;
        self.destImage.image = [UIImage imageWithContentsOfFile:faceImageName];
        if (momFace == nil)
            [self onMom:nil];
    }
    
    if (momFace != nil && dadFace != nil)
        [self onMerge:nil];
}

-(Face *)getFaceDetails:(FaceImages *)faceImages
{
    Face *face = [[Face alloc]init];
    face.imageId = faceImages.imageId;
    face.imageName = faceImages.imageName;
    face.leftEyeCentre = CGPointFromString(faceImages.leftEyeCentre);
    face.rightEyeCentre = CGPointFromString(faceImages.rightEyeCentre);
    face.mouthCentre = CGPointFromString(faceImages.mouthCentre);
    face.chinCentre = CGPointFromString(faceImages.chinCentre);
    face.imageCentre = CGPointFromString(faceImages.imageCentre);
    face.angleBetweenEyes = [faceImages.angleBetweenEyes doubleValue];
    face.widthBetweenEyes = [faceImages.widthBetweenEyes doubleValue];
    face.faceImage = [UIImage imageWithContentsOfFile:faceImages.faceImage];
    face.faceImages = faceImages.faceImage;
    face.leftEyeRefDistance = [faceImages.leftEyeRefDistance doubleValue];
    face.rightEyeRefDistance = [faceImages.rightEyeRefDistance doubleValue];
    face.mouthRefDistance = [faceImages.mouthRefDistance doubleValue];
    face.leftEyeAngle = [faceImages.leftEyeAngle doubleValue];
    face.rightEyeAngle = [faceImages.rightEyeAngle doubleValue];
    face.mouthAngle = [faceImages.mouthAngle doubleValue];
    face.isMom = [faceImages.isMom boolValue];
    return face;
}

- (IBAction)stopWiggling:(id)sender
{
    if(_gridMomView.editable == YES)
    {
        _gridMomView.editable = NO;
        [_gridMomView stopWiggling];
        [self reConstructDatabase];
        faceMomImagesArray = [FBDataBaseUtilities getMomFaceDetailsFromDB];
        [_gridMomView removeFromSuperview];
        [self setUpGridView];
        _gridDadView.hidden = YES;
    }
    else if (_gridDadView.editable == YES)
    {
        _gridDadView.editable = NO;
        [_gridDadView stopWiggling];
        [self reConstructDatabase];
        faceDadImagesArray = [FBDataBaseUtilities getDadFaceDetailsFromDB];
        [_gridDadView removeFromSuperview];
        [self setUpGridView];
        _gridMomView.hidden = YES;
    }
}

-(void)reConstructDatabase
{
    NSFetchRequest * fetch = [[NSFetchRequest alloc] init] ;
    [fetch setEntity:[NSEntityDescription entityForName:@"FaceImages" inManagedObjectContext:[FBAppDelegate application].managedObjectContext]];
    NSArray * result = [[FBAppDelegate application].managedObjectContext executeFetchRequest:fetch error:nil];
    for (id obj in result)
        [[FBAppDelegate application].managedObjectContext deleteObject:obj];
    
    debugLog(@"faceMomImagesArray %@",faceMomImagesArray);
    
    NSMutableArray *faceImagesArrayCopy = [[NSMutableArray alloc] init];
    for (FaceImages *face in faceMomImagesArray)
    {
        Face *newface = [self getFaceDetails:face];
        [faceImagesArrayCopy addObject:newface];
        debugLog(@"sampleArray %@",faceMomImagesArray);
    }
    for (FaceImages *face in faceDadImagesArray)
    {
        Face *newface = [self getFaceDetails:face];
        [faceImagesArrayCopy addObject:newface];
        debugLog(@"sampleArray %@",faceDadImagesArray);
    }
    
    NSMutableArray* reversed = (NSMutableArray *)[[faceImagesArrayCopy reverseObjectEnumerator] allObjects];

    for (Face *face in reversed)
        [FBDataBaseUtilities addImageToDataBase:face];

    faceMomImagesArray = [FBDataBaseUtilities getMomFaceDetailsFromDB];
    faceDadImagesArray = [FBDataBaseUtilities getDadFaceDetailsFromDB];
    debugLog(@"faceMomImagesArray %@",faceMomImagesArray);
}

#pragma mark - notification methods

-(void)receiveNotification:(NSNotification *)notification
{
    if (momFace != nil && dadFace != nil)
    {
        pickerLoaded = NO;
        [self onMerge:nil];
    }
}

-(void)purchaseCompletedSuccessfully
{
    [FBDataBaseUtilities addImageToDataBase:processedFace];
    faceMomImagesArray = [FBDataBaseUtilities getMomFaceDetailsFromDB];
    faceDadImagesArray = [FBDataBaseUtilities getDadFaceDetailsFromDB];
    [_gridMomView reloadData];
    [_gridDadView reloadData];
}

- (void)productRequestCompleted
{
}

-(void)appFromBackground:(NSNotification *)notification
{
    [self stopWiggling:self];
}

-(void)showCannotDeleteAlert
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image currently in use and cannot be deleted"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil ];
    [alert show];
}

@end
