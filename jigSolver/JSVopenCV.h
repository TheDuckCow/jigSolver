//
//  JSVopenCV.h
//  jigSolver
//
//  Created by Patrick W. Crawford on 11/17/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JSVopenCV : NSObject

+ (UIImage *)testFunction:(UIImage *)input;
+ (UIImage *)solvePuzzle:(UIImage *)input withOriginal: (UIImage *) original;
+ (NSArray *)segmentPiecesFromBackground :(UIImage *) input;
+ (UIImage *)createPiecesFromImage: (UIImage *) src;

@end
