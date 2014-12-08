//
//  JSVpuzzlePiece.h
//  jigSolver
//
//  Created by Patrick W. Crawford on 11/29/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#ifndef __CV__
#import <opencv2/opencv.hpp>
#endif


@interface JSVpuzzlePiece : NSObject

@property (nonatomic) cv::Mat originalImage;
@property (nonatomic) cv::Mat mask;
@property (nonatomic) cv::vector<cv::Point> contour;
@property (nonatomic) int guess_x;
@property (nonatomic) int guess_y;
@property (nonatomic) double guess_rotation;
@property (nonatomic) int offset_x;
@property (nonatomic) int offset_y;

@end
