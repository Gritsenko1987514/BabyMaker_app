//
//  FBDataBaseUtilities.h
//  FaceBlend
//
//  Created by Akhildas on 8/21/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Face.h"

@interface FBDataBaseUtilities : NSObject

+(void)initDataBase;
+(void)addImageToDataBase:(Face *)face;
+(NSMutableArray *)getMomFaceDetailsFromDB;
+(NSMutableArray *)getDadFaceDetailsFromDB;

@end
