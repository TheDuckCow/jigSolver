//
//  ViewController.m
//  jigSolver
//
//  Created by Patrick W. Crawford on 11/14/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//


#import "opencv2/highgui/ios.h"
#import <opencv2/opencv.hpp>
#import "JSVopenCV.h"
#import "ViewController.h"
using namespace cv;

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *swer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
    UIImage* img = [UIImage imageNamed:@"lena.png"];
    self.swer.image = [JSVopenCV testFunction: img];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
