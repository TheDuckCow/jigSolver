//
//  JSVsingleton.h
//  jigSolver
//
//  Created by Patrick W. Crawford on 12/6/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class JSVpuzzlePiece;

@interface JSVsingleton : NSObject


@property (nonatomic, strong) NSString *testString;
@property (nonatomic, strong) UIImage *solutionImg;
@property (nonatomic, strong) UIImage *piecesImg;
@property (nonatomic, strong) UIImage *combinedImg;
@property (nonatomic, strong) NSMutableArray *pieces;
@property (nonatomic, strong) JSVpuzzlePiece * solution;
@property (nonatomic, strong) NSMutableArray *resultPositions;
@property (nonatomic) int rows;
@property (nonatomic) int cols;



+ (JSVsingleton *) sharedObj;

- (UIImage *) getPieceMask: (int) index;
- (UIImage *) getPieceMaskInverse: (int) index;
- (UIImage *) getPieceOriginal: (int) index;
- (void) determinePuzzleSize;
- (void) processPieces;

@end