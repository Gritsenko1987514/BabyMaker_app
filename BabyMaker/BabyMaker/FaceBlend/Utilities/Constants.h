//
//  Constants.h
//  FaceBlend
//
//  Created by Akhildas on 8/13/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//


#define PRO_UPGRADE_ID @"babymakerpro"


#ifndef FaceBlend_Constants_h
#define FaceBlend_Constants_h
#define SCALE 1.2f

#define IMAGE_WIDTH 384.0f
#define IMAGE_HEIGHT_FIVE_INCH 491
#define IMAGE_HEIGHT_FOUR_INCH 403.0f


#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

//#ifdef isiPhone5
//#define IMAGE_HEIGHT  418
//#else
//#define IMAGE_HEIGHT 410
//#endif

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


#define REMOVE_AND_SET_NIL_IF_EXIST(variableName) if (variableName) {[variableName removeAllObjects]; \
variableName = nil;}

#define EYE_POINT_SIZE    0.05
#define MOUTH_POINT_SIZE     0.1 
#endif

//#define APPLICATION_FONT @"SFActionMan"
#define APPLICATION_FONT @"Marker Felt"
#define MYRIADREGULAR_FONT @"MyriadPro-Regular"
#define RESOURCE_FOLDER @"FaceBlendResources"
#define IMAGE_NAME @"FB_13.jpg"

#define RESULT_FOLDER @"FaceBlendResults"
#define RESULT_THUMBS_FOLDER @"FaceBlendResultsThumbs"
#define RESULT_IMAGE_NAME_PREFIX @"FBRESULT_"
#define RESULT_IMAGE_THUMB_NAME_PREFIX @"FBRESULTThumb_"

