//
//  CVWrapper.m
//  Sonor
//
//  Created by Yuwei Ba on 7/4/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "CVWrapper.h"

using namespace cv;

@implementation OpenCVWrapper

+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

+ (UIImage *)mergeUIImages: (NSArray<UIImage *> *)images
{
    NSInteger count = [images count];
    if (count <= 0) return NULL;
    
    double alpha = 1.0/count;
    
    Mat baseMat = [OpenCVWrapper cvMatFromUIImage: images[0]];
    
    for (int i = 1; i < count; i ++) {
        Mat image = [OpenCVWrapper cvMatFromUIImage:images[i]];
        Mat exposed = baseMat.clone();
        addWeighted(exposed, alpha, image, 1.0 - alpha, 0.0, baseMat);
    }
    
    cvtColor(baseMat, baseMat, CV_RGBA2RGB, 30);
    UIImage* result = [OpenCVWrapper UIImageFromCVMat:baseMat];
    return result;
}

+ (Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    Mat cvMat(rows, cols, CV_8UC4);
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data, cols, rows, 8, cvMat.step[0], colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

+(UIImage *)UIImageFromCVMat:(Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols, cvMat.rows, 8, 8 * cvMat.elemSize(), cvMat.step[0], colorSpace, kCGImageAlphaNone | kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
