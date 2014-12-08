//
//  JSVsingleton.m
//  jigSolver
//
//  Created by Patrick W. Crawford on 12/6/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import "JSVsingleton.h"
#import "JSVpuzzlePiece.h"
#import "JSVOpenCVSIFT.h"
#import "opencv2/highgui/ios.h"
#import <opencv2/opencv.hpp>
using namespace cv;

@implementation JSVsingleton


@synthesize testString;
@synthesize solutionImg;
@synthesize piecesImg;
@synthesize combinedImg;
@synthesize pieces;
@synthesize resultPositions;

+ (JSVsingleton *) sharedObj{
    
    
    static dispatch_once_t pred;
    static JSVsingleton *shared = nil;
    
    // instance the class only the first time
    dispatch_once(&pred, ^{
        shared = [[JSVsingleton alloc] init];
        
        shared.testString = [[NSString alloc] init];
        shared.solutionImg = [[UIImage alloc] init];
        shared.piecesImg = [[UIImage alloc] init];
        shared.pieces = [[NSMutableArray alloc] init];
        shared.resultPositions = [[NSMutableArray alloc] init];
        shared.combinedImg = [[UIImage alloc] init];
    
    });
    
    return shared;
}

- (UIImage *) getPieceMask: (int) index{
    JSVpuzzlePiece *piece = self.pieces[index];
    return MatToUIImage(piece.mask.clone());;
}

- (UIImage *) getPieceMaskInverse: (int) index{
    JSVpuzzlePiece *piece = self.pieces[index];
    Mat tmp = piece.mask.clone();
    bitwise_not(tmp,tmp);
    return MatToUIImage(tmp);
}

- (UIImage *) getPieceOriginal: (int) index{
    JSVpuzzlePiece *piece = self.pieces[index];
    return MatToUIImage(piece.originalImage.clone());;
}

- (void) processPieces{
    
    Mat result;
    [JSVOpenCVSIFT matchPieces:self.pieces withSolution:self.solutionImg col:2 row:2 result:result];
    
    // now convert result into the result
    Mat finalResult;
    [JSVOpenCVSIFT combineResul:self.pieces withFinalMatches:result result:finalResult];
    self.combinedImg = MatToUIImage(finalResult);
    
    
}



// creates methods: getPieceMask: withIndex
// getPieceOriginal: withIndex

@end
