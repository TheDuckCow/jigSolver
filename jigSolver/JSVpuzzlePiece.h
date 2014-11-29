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

@property Mat orignalImage;
@property Mat maskImage;
@property vector<cv::Point> contour;
// make the "JSVedge class", which contains information about each edge
//@property JSVedge *top 
//@property JSVedge *left
//@property JSVedge *bottom
//@property JSVedge *right

@end
