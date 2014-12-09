//
//  DebugImageViewController.m
//  jigSolver
//
//  Created by Timothy Chong on 12/8/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import "DebugImageViewController.h"
#import "JSVsingleton.h"

@interface DebugImageViewController ()

@end

@implementation DebugImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

-(void) viewDidAppear:(BOOL) animated {
    [super viewDidAppear:animated];
    
    [JSVsingleton sharedObj].piecesImg = [UIImage imageNamed:@"IMG_2785.JPG"];
    [JSVsingleton sharedObj].solutionImg = [UIImage imageNamed:@"IMG_2774.JPG"];
    
    [[JSVsingleton sharedObj ]processPieces];
    NSLog(@"Done");
    [self updateImage:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)updateImage:(id)sender {
    self.debugImage.image = [JSVsingleton sharedObj].debugImage;
}
@end
