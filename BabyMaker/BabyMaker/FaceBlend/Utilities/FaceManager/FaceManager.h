//
//  FaceManager.h
//  CVPoissonBlend
//
//  Created by user on 13/08/13.
//  Copyright (c) 2013 akhiljayaram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Face.h"
#import "PoissonBlendObject.h"

@interface FaceManager : NSObject

{
    PoissonBlendObject * poissonBlendObject;
   
    
}
- (PoissonBlendObject *)getPoissonBlendedObject;

@property (nonatomic, retain) Face * backFace;
@property (nonatomic, retain) Face * frontFace;
@end
