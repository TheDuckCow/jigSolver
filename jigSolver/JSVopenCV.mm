//
//  JSVopenCV.m
//  jigSolver
//
//  Created by Patrick W. Crawford on 11/17/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import "JSVopenCV.h"
#import "opencv2/highgui/ios.h"
#import <opencv2/opencv.hpp>
using namespace cv;

@implementation JSVopenCV

+ (UIImage *) testFunction: (UIImage *) input{
    
    //Load image with face
    Mat faceImage;
    UIImageToMat(input, faceImage);
    
    NSLog(@"channels: %i",faceImage.channels());
    
    // this daoes not work, does not recognize GaussianBlur as a cv function!
    cv::GaussianBlur(faceImage, faceImage, cv::Size(5, 5), 1.2, 1.2);
    Mat greyMat;
    cv::cvtColor(faceImage, greyMat, CV_BGR2GRAY);
    
    
    Mat binary = Mat::zeros(faceImage.size(), CV_8UC1);
    for (int x=0; x<binary.cols; x++){
        for (int y=0; y< binary.rows; y++){
            // IT NEEDED TO BE Vec4b BECAUSE IT IS READ IN AS FOUR CHANNELS
            if (faceImage.at<Vec4b>(y,x)[0] > 200){
                binary.at<uchar>(y,x) = 255;
            }
        }
    }

    UIImage *output = MatToUIImage(binary);
    
    return output;
}

- (void) segmentFromBackground: (Mat *) src withDest: (Mat *) dst{
    
    // at first assume the background is one consistent color
    // later, we can try to detect this color.
    
    // haven't figure dout how to make clone work.. which would be useful
    //dst = src->Mat::clone();
    //dst = src.clone();

}


@end
