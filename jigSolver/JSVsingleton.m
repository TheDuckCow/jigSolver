//
//  JSVsingleton.m
//  jigSolver
//
//  Created by Patrick W. Crawford on 12/6/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import "JSVsingleton.h"

@implementation JSVsingleton


@synthesize testString;
@synthesize solutionImg;
@synthesize piecesImg;
@synthesize pieces;

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
    
    });
    
    return shared;
}

@end
