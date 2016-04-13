//
//  FBInstagramActivity.h
//  FaceBlend
//
//  Created by user on 05/09/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InstagramShareDelegate;


@interface FBInstagramActivity : UIActivity <UIDocumentInteractionControllerDelegate>



@property (nonatomic, strong) UIImage *shareImage;
@property (nonatomic, strong) NSString *shareString;
@property (readwrite) BOOL includeURL;


@property (nonatomic, strong) UIBarButtonItem *presentFromButton;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;


@property (nonatomic, assign) id <InstagramShareDelegate> delegate;

@end
@protocol InstagramShareDelegate <NSObject>

- (void)showInstagramShare:(UIDocumentInteractionController* )documentInteractionController;

@end