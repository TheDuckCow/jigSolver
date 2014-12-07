//
//  JSVsingleton.h
//  jigSolver
//
//  Created by Patrick W. Crawford on 12/6/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JSVsingleton : NSObject

@property (nonatomic, strong) NSString *testString;
@property (nonatomic, strong) UIImage *solutionImg;
@property (nonatomic, strong) UIImage *piecesImg;
@property (nonatomic, strong) NSMutableArray *pieces;



+ (JSVsingleton *) sharedObj;

- (UIImage *) getPieceMask: (int) index;

@end