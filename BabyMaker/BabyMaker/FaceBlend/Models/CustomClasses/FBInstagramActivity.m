//
//  FBInstagramActivity.m
//  FaceBlend
//
//  Created by user on 05/09/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import "FBInstagramActivity.h"
#import "ImageUtils.h"

@implementation FBInstagramActivity
@synthesize delegate;


- (NSString *)activityType {
    return @"UIActivityTypePostToInstagram";
}

- (NSString *)activityTitle {
    return @"Instagram";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"instagram.png"];
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if (![[UIApplication sharedApplication] canOpenURL:instagramURL]) return NO; // no instagram.
    
    for (UIActivityItemProvider *item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) {
            if ([self imageIsLargeEnough:(UIImage *)item]) return YES; // has image, of sufficient size.
            else debugLog(@"DMActivityInstagam: image too small %@",item);
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    for (id item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) self.shareImage = item;
        else if ([item isKindOfClass:[NSString class]]) {
            self.shareString = [(self.shareString ? self.shareString : @"") stringByAppendingFormat:@"%@%@",(self.shareString ? @" " : @""),item]; // concat, with space if already exists.
        }
              else debugLog(@"Unknown item type %@", item);
    }
}

- (void)performActivity {
    
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"Image.ig0"];
    self.shareImage = [ImageUtils createDoubleScaledUIImageWithActualImage:self.shareImage];
    self.shareImage = [ImageUtils cropImage:self.shareImage withCropRect:CGRectMake(0, 90, 320, 320)];
    NSData *imageData = UIImageJPEGRepresentation(self.shareImage, 0.8);
    [imageData writeToFile:savedImagePath atomically:YES];
    NSURL *imageUrl = [NSURL fileURLWithPath:savedImagePath];
    
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:imageUrl];
    self.documentController.UTI = @"com.instagram.exclusivegram";
   self.documentController.delegate = self;
    self.documentController.annotation = [NSDictionary dictionaryWithObject:@"Faceblend" forKey:@"InstagramCaption"];
    if(delegate && [delegate respondsToSelector:@selector(showInstagramShare:)]) {
        [delegate showInstagramShare:self.documentController];
    }
}

- (void)performActivityss {
    
    
    
    // no resize, just fire away.
    //UIImageWriteToSavedPhotosAlbum(item.image, nil, nil, nil);
    CGFloat cropVal = (self.shareImage.size.height > self.shareImage.size.width ? self.shareImage.size.width : self.shareImage.size.height);
    
//    cropVal *= [self.shareImage scale];
    
    CGRect cropRect = (CGRect){.size.height = cropVal, .size.width = cropVal};
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.shareImage CGImage], cropRect);
    
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageWithCGImage:imageRef], 1.0);
    CGImageRelease(imageRef);
    
    NSString *writePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"instagram.igo"];
    if (![imageData writeToFile:writePath atomically:YES]) {
        // failure
        debugLog(@"image save failed to path %@", writePath);
        [self activityDidFinish:NO];
        return;
    } else {
        // success.
    }
    
    // send it to instagram.
    NSURL *fileURL = [NSURL fileURLWithPath:writePath];
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    self.documentController.delegate = self;
    
    [self.documentController setUTI:@"com.instagram.exclusivegram"];
    if (self.shareString) [self.documentController setAnnotation:@{@"InstagramCaption" : self.shareString}];
    
    if(delegate && [delegate respondsToSelector:@selector(showInstagramShare:)]) {
        [delegate showInstagramShare:self.documentController];
    }
//    
//    if (![self.documentController presentOpenInMenuFromBarButtonItem:self.presentFromButton animated:YES]) NSLog(@"couldn't present document interaction controller");
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
//    [self activityDidFinish:YES];
}

-(BOOL)imageIsLargeEnough:(UIImage *)image {
    CGSize imageSize = [image size];
    return ((imageSize.height * image.scale) >= 612 && (imageSize.width * image.scale) >= 612);
}

-(BOOL)imageIsSquare:(UIImage *)image {
    CGSize imageSize = image.size;
    return (imageSize.height == imageSize.width);
}



@end
