//
//  JSVOpenCVSIFT.h
//  jigSolver
//
//  Created by Timothy Chong on 11/30/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>

@class JSVpuzzlePiece;
@interface JSVOpenCVSIFT : NSObject

+(void) matchPieces:(NSArray *) pieces withSolution: (UIImage *) solution col: (int) col row:(int) row result:(cv::Mat &) finalResult;

+(void) combineImageLeftRight:(cv::Mat &) left right: (cv::Mat &) right result:(cv::Mat &) result;
+(void) combineImageTopBottm: (cv::Mat &) top bottom: (cv::Mat &) bottom result:(cv::Mat &) result;

@end
