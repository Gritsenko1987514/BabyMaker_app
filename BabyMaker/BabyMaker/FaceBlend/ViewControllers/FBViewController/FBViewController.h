//
//  FBViewController.h
//  FaceBlend
//
//  Created by Akhildas on 7/31/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceImages.h"
#import "UzysGridView.h"
#import "UzysGridViewCustomCell.h"
#import "UIImageViewEx.h"
#import "QBInAppPurchaseManager.h"
#import <QuartzCore/QuartzCore.h>
#import "PlayHavenSDK.h"

@interface FBViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,NSFetchedResultsControllerDelegate,UzysGridViewDelegate,UzysGridViewDataSource,QBInAppPurchaseDelegate, PHPublisherContentRequestDelegate, PHAPIRequestDelegate>

{
    QBInAppPurchaseManager *purchaseManager;
}

- (IBAction)adjustMarkerScreenBackPressed:(id)sender;
- (IBAction)newImageButtonPressed:(id)sender;
- (IBAction)imageSelecterCloseButtonPressed:(id)sender;
- (IBAction)blendGallerySelected:(id)sender;

- (IBAction)onMom:(id)sender;
- (IBAction)onDad:(id)sender;
- (IBAction)onMerge:(id)sender;

@property (strong, nonatomic) IBOutlet UIImageView *sourceImage;
@property (strong, nonatomic) IBOutlet UIImageView *destImage;
@property (strong, nonatomic) IBOutlet UIButton *blendButton;
@property (strong, nonatomic) IBOutlet UIImageViewEx *selectedImageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *imageProcessingView;
@property (strong, nonatomic) IBOutlet UIView *imageProcessorView;
@property (strong, nonatomic) IBOutlet UIView *imageSelecterPopupScreen;
@property (strong, nonatomic) IBOutlet UIView *frameView;
@property (strong, nonatomic) IBOutlet UIView *genderAlertView;
@property (strong, nonatomic) IBOutlet UIButton *btnAddPhoto;
@property (strong, nonatomic) IBOutlet UIButton *btnSelectMom;
@property (strong, nonatomic) IBOutlet UIButton *btnSelectDad;

- (IBAction)onAlertClose:(id)sender;
- (IBAction)onAlertBoy:(id)sender;
- (IBAction)onAlertGirl:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *chosePhotoInstructionOne;
@property (weak, nonatomic) IBOutlet UILabel *chosePhotoInstructionTwo;
@property (weak, nonatomic) IBOutlet UILabel *chosePhotoInstructionThree;
@property (weak, nonatomic) IBOutlet UILabel *chosePhotoInstructionFour;
@property (weak, nonatomic) IBOutlet UIView *addViewToAddPlot;
@property (strong, nonatomic) IBOutlet UIButton *stopWiggleBtn;
@property (strong, nonatomic) IBOutlet UIButton *stopWiggleBtn2;

@property (strong, nonatomic) IBOutlet UIImageView *indicatorImageView;
@property (strong, nonatomic) IBOutlet UIImageView *placeHolderDest;
@property (strong, nonatomic) IBOutlet UIImageView *placeHolderSource;
@property (strong, nonatomic) IBOutlet UIButton *okButton;

@property (strong, nonatomic) UzysGridView *_gridMomView;
@property (strong, nonatomic) UzysGridView *_gridDadView;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) IBOutlet UILabel *adjustMarkersTitle;

- (IBAction)blendImages:(id)sender;
- (IBAction)okButtonPressed:(id)sender;
- (IBAction)selectImage:(id)sender;
- (IBAction)stopWiggling:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *confirmTitle;
@property (strong, nonatomic) IBOutlet UIButton *btnBoy;
@property (strong, nonatomic) IBOutlet UIButton *btnGirl;

@end
