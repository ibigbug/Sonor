//
//  CVWrapper.m
//  Sonor
//
//  Created by Yuwei Ba on 7/4/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "CVWrapper.h"

using namespace std;
using namespace cv;

@implementation OpenCVWrapper

+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

+ (UIImage *)mergeLongExposure: (NSArray<UIImage *> *)images
{
    NSInteger count = [images count];
    if (count <= 0) return NULL;
    
    Mat baseMat = [OpenCVWrapper cvMatFromUIImage: images[0]];
    Mat baseMatFloat;
    baseMat.convertTo(baseMatFloat, CV_32F);
    baseMat.release();

    vector<Mat> bgrChannel;
    split(baseMatFloat, bgrChannel);
    baseMatFloat.release();
    
    Mat bAvg = bgrChannel[0], gAvg = bgrChannel[1], rAvg = bgrChannel[2];
    
    for (int i = 1; i < count; i ++) {
        Mat image = [OpenCVWrapper cvMatFromUIImage:images[i]];
        Mat imageFloat;
        image.convertTo(imageFloat, CV_32F);
        image.release();
        
        vector<Mat> imageChannel;
        split(imageFloat, imageChannel);
        imageFloat.release();
        
        Mat rCh = imageChannel[2], gCh = imageChannel[1], bCh = imageChannel[0];
        rAvg = ((i * rAvg) + (1 * rCh)) / (i + 1.0);
        gAvg = ((i * gAvg) + (1 * gCh)) / (i + 1.0);
        bAvg = ((i * bAvg) + (1 * bCh)) / (i + 1.0);
    }
    
    Mat finalMatFloat;
    vector<Mat> channels;
    channels.push_back(bAvg);
    channels.push_back(gAvg);
    channels.push_back(rAvg);
    merge(channels, finalMatFloat);
    
    Mat finalMat;
    finalMatFloat.convertTo(finalMat, CV_8U);
    finalMatFloat.release();

    UIImage* result = [OpenCVWrapper UIImageFromCVMat:finalMat];
    finalMat.release();
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
