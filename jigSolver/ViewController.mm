//
//  ViewController.m
//  jigSolver
//
//  Created by Patrick W. Crawford on 11/14/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//


#import "opencv2/highgui/ios.h"
#import "ViewController.h"
using namespace cv;

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *swer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    Mat thing = Mat::zeros(100,100,CV_8UC1);
    
    // Create file handle
    // Read content of the file
    
    
    //Load image with face
    UIImage* image = [UIImage imageNamed:@"lena.png"];
    cv::Mat faceImage;
    UIImageToMat(image, faceImage);
    
    Mat binary = Mat::zeros(100,100, CV_8UC1);
    
    
    self.swer.image = MatToUIImage(binary);
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
