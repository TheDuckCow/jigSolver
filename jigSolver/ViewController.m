//
//  ViewController.m
//  jigSolver
//
//  Created by Patrick W. Crawford on 11/14/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//


#import "JSVopenCV.h"
#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *swer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // the heavy processing all hapens here.
    NSArray *solutions =@[@"IMG_2774.JPG",@"IMG_2780.JPG"];
    NSArray *scrambled = @[@"IMG_2785.JPG"];

    
    self.swer.image = [JSVopenCV solvePuzzle:[UIImage imageNamed:scrambled[0]] withOriginal: [UIImage imageNamed:solutions[0]]];
    
    //self.swer.image =[UIImage imageNamed:scrambled[0]];
    
    // test process
    //UIImage* img = [UIImage imageNamed:@"lena.png"];
    //self.swer.image = [JSVopenCV testFunction: img];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
