//
//  FBDataBaseUtilities.m
//  FaceBlend
//
//  Created by Akhildas on 8/21/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import "FBDataBaseUtilities.h"
#import <CoreData/CoreData.h>
#import "FaceImages.h"
#import "ImageUtils.h"
#import "FBAppDelegate.h"

@implementation FBDataBaseUtilities

+(void)initDataBase
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *objectContext = [FBAppDelegate application].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FaceImages"
                                              inManagedObjectContext:objectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [objectContext executeFetchRequest:fetchRequest error:&error];
    for (FaceImages *faceObj in fetchedObjects)
    {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        path = [path stringByAppendingPathComponent:@"/FaceBlendResources"];
        path = [path stringByAppendingPathComponent:faceObj.imageName];
        faceObj.faceImage = path;
        
        if (![objectContext save:&error])
        {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }
}

+(void)addImageToDataBase:(Face *)face
{
    NSManagedObjectContext *objectContext = [FBAppDelegate application].managedObjectContext;
    FaceImages *faceImageObj = [NSEntityDescription
                                insertNewObjectForEntityForName:@"FaceImages"
                                inManagedObjectContext:objectContext];
    
    //        faceImageObj.imageId  = [NSString stringWithFormat:@"%d",i ];
    faceImageObj.imageName  = face.imageName;
    faceImageObj.leftEyeCentre  = NSStringFromCGPoint(face.leftEyeCentre);
    faceImageObj.rightEyeCentre  = NSStringFromCGPoint(face.rightEyeCentre);
    faceImageObj.mouthCentre  = NSStringFromCGPoint(face.mouthCentre);
    faceImageObj.chinCentre  = NSStringFromCGPoint(face.chinCentre);
    faceImageObj.imageCentre  = NSStringFromCGPoint(face.imageCentre);
    faceImageObj.angleBetweenEyes  = [NSNumber numberWithDouble:face.angleBetweenEyes];
    faceImageObj.faceImage  = face.faceImages;
    faceImageObj.widthBetweenEyes  = [NSNumber numberWithDouble:face.widthBetweenEyes];
    faceImageObj.leftEyeRefDistance  = [NSNumber numberWithDouble:face.leftEyeRefDistance];
    faceImageObj.rightEyeRefDistance  = [NSNumber numberWithDouble:face.rightEyeRefDistance];
    faceImageObj.mouthRefDistance  = [NSNumber numberWithDouble:face.mouthRefDistance];
    faceImageObj.leftEyeAngle  = [NSNumber numberWithDouble:face.leftEyeAngle];
    faceImageObj.rightEyeAngle  = [NSNumber numberWithDouble:face.rightEyeAngle];
    faceImageObj.mouthAngle  = [NSNumber numberWithDouble:face.mouthAngle];
    faceImageObj.isMom = [NSNumber numberWithBool:face.isMom];
    NSError *error;
    if (![objectContext save:&error])
    {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    //    [faceImagesArray addObject:faceImageObj];
}

+(NSMutableArray *)getMomFaceDetailsFromDB
{
    NSError *error;
    NSMutableArray *fetchedObjectsArray = [[NSMutableArray alloc]init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *objectContext = [FBAppDelegate application].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FaceImages"
                                              inManagedObjectContext:objectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [objectContext executeFetchRequest:fetchRequest error:&error];
    for (FaceImages *faceObj in fetchedObjects)
    {
        if ([faceObj.isMom boolValue] == YES)
            [fetchedObjectsArray addObject:faceObj];
        debugLog(@"FaceImages: %@", faceObj);
        NSLog(@"FaceImages: %@", faceObj);
    }
    NSMutableArray* reversed = (NSMutableArray *)[[fetchedObjectsArray reverseObjectEnumerator] allObjects];
    return reversed;
}

+(NSMutableArray *)getDadFaceDetailsFromDB
{
    NSError *error;
    NSMutableArray *fetchedObjectsArray = [[NSMutableArray alloc]init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *objectContext = [FBAppDelegate application].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FaceImages"
                                              inManagedObjectContext:objectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [objectContext executeFetchRequest:fetchRequest error:&error];
    for (FaceImages *faceObj in fetchedObjects)
    {
        if ([faceObj.isMom boolValue] == NO)
            [fetchedObjectsArray addObject:faceObj];
        debugLog(@"FaceImages: %@", faceObj);
    }
    NSMutableArray* reversed = (NSMutableArray *)[[fetchedObjectsArray reverseObjectEnumerator] allObjects];
    return reversed;
}

@end
