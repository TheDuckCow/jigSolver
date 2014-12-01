//
//  JSVOpenCVSIFT.h
//  jigSolver
//
//  Created by Timothy Chong on 11/30/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class JSVpuzzlePiece;
@interface JSVOpenCVSIFT : NSObject
//Subject to change
+(UIImage *) matchPieceWithSolution:(JSVpuzzlePiece *) piece withSolution: (UIImage *) solution;
+(JSVpuzzlePiece *) largestPuzzlePieceInPieces:(NSArray *) pieces;

@end
