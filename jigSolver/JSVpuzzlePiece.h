//
//  JSVpuzzlePiece.h
//  jigSolver
//
//  Created by Patrick W. Crawford on 11/29/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "opencv2/highgui/ios.h"
#import <opencv2/opencv.hpp>
using namespace cv;

@interface JSVpuzzlePiece : NSObject

@property (nonatomic) Mat originalImage;
@property (nonatomic) Mat mask;
@property (nonatomic) vector<cv::Point> contour;
@property (nonatomic) int guess_x;
@property (nonatomic) int guess_y;
@property (nonatomic) double guess_rotation;

@end
