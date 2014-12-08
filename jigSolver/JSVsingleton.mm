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
#import "JSVopenCV.h"
using namespace cv;

@implementation JSVsingleton


@synthesize testString;
@synthesize solutionImg;
@synthesize piecesImg;
@synthesize combinedImg;
@synthesize pieces;
@synthesize resultPositions;
@synthesize rows;
@synthesize cols;

+ (JSVsingleton *) sharedObj{
    
    
    static dispatch_once_t pred;
    static JSVsingleton *shared = nil;
    
    // instance the class only the first time
    dispatch_once(&pred, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}


-(id) init{
    if (self = [super init]) {
        self.testString = [[NSString alloc] init];
        self.solutionImg = [[UIImage alloc] init];
        self.piecesImg = [[UIImage alloc] init];
        self.pieces = [[NSMutableArray alloc] init];
        self.resultPositions = [[NSMutableArray alloc] init];
        self.combinedImg = [[UIImage alloc] init];
        self.rows = 2;
        self.cols = 2;  // default 2x2 puzzle
    }
    return self;
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
    
    [JSVopenCV createPiecesFromImage: [JSVsingleton sharedObj].piecesImg isSolution:NO];
    [JSVOpenCVSIFT matchPieces:self.pieces withSolution:self.solutionImg col:self.cols row:self.rows result:result];
    
    // now convert result into the result
    Mat finalResult;
    
    [JSVOpenCVSIFT combineResul:self.pieces withFinalMatches:result result:finalResult];
    self.combinedImg = MatToUIImage(finalResult);
    
}

- (void) determinePuzzleSize{
    // determine the rows and columns of the puzzle based on input pieces
    // defautl elsewhere is set to be 2x2 (when initialized)
    int number = (int)[self.pieces count];
    if (number == 4){
        self.cols = 2;
        self.rows = 2;
    }
    else if(number == 9){
        self.rows = 3;
        self.cols = 3;
    }
    else if (number == 16){
        self.rows = 4;
        self.cols = 4;
    }
    else if (number == 2){
        self.rows = 1;
        self.cols = 2;
    }
    else if (number == 1){
        self.rows = 1;
        self.cols = 1;
    }
    else{
        // is this really the best assumption/default case?
        self.rows = 2;
        self.cols = 2;
    }
    
    NSLog(@" PUZZLE SIZE? %i %i",self.cols, self.rows);
    
}


// creates methods: getPieceMask: withIndex
// getPieceOriginal: withIndex

@end
