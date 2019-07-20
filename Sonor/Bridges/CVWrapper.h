//
//  CVWrapper.h
//  Sonor
//
//  Created by Yuwei Ba on 7/4/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

#ifndef CVWrapper_h
#define CVWrapper_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+ (NSString *)openCVVersionString;
+ (UIImage *) mergeLongExposure:(NSArray<UIImage *> *) images;

@end

NS_ASSUME_NONNULL_END

#endif /* CVWrapper_h */
