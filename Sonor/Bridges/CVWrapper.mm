//
//  CVWrapper.m
//  Sonor
//
//  Created by Yuwei Ba on 7/4/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "CVWrapper.h"

@implementation OpenCVWrapper

+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

@end
