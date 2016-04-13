//
//  FBBlendGalleryViewController.h
//  FaceBlend
//
//  Created by akhiljayaram on 22/08/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UzysGridView.h"
#import "QBInAppPurchaseManager.h"

@interface FBBlendGalleryViewController : UIViewController <UzysGridViewDelegate,UzysGridViewDataSource, QBInAppPurchaseDelegate, UIAlertViewDelegate>
{
    QBInAppPurchaseManager *purchaseManager;
}
@property (weak, nonatomic) IBOutlet UILabel *viewTitle;
@property (weak, nonatomic) IBOutlet UILabel *noGalleryImageLabel;
@property (weak, nonatomic) IBOutlet UIView *galleryViewFrame;
@property (weak, nonatomic) IBOutlet UIButton *proButton;
@property (strong, nonatomic) UzysGridView *galleryView;;


- (IBAction)newButtonPressed:(id)sender;
- (IBAction)moreButtonPressed:(id)sender;
- (IBAction)proButtonPressed:(id)sender;
@end
