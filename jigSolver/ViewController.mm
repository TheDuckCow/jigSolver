//
//  ViewController.m
//  jigSolver
//
//  Created by Patrick W. Crawford on 11/14/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//


#import "opencv2/highgui/ios.h"
#import <opencv2/opencv.hpp>
#import "ViewController.h"
using namespace cv;

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *swer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Load image with face
    UIImage* image = [UIImage imageNamed:@"lena.png"];
    Mat faceImage;
    UIImageToMat(image, faceImage);
    
    NSLog(@"channels: %i",faceImage.channels());
    
    // this daoes not work, does not recognize GaussianBlur as a cv function!
    //cv::GaussianBlur(faceImage, faceImage, cv::Size(5, 5), 1.2, 1.2);
    Mat greyMat;
    cv::cvtColor(faceImage, greyMat, CV_BGR2GRAY);
    
    
    Mat binary = Mat::zeros(faceImage.size(), CV_8UC1);
    for (int x=0; x<binary.cols; x++){
        for (int y=0; y< binary.rows; y++){
            // IT NEEDED TO BE Vec4b BECAUSE IT IS READ IN AS FOUR CHANNELS
            if (faceImage.at<Vec4b>(y,x)[0] > 200){
                binary.at<uchar>(y,x) = 255;
            }
        }
    }
    
    
    self.swer.image = MatToUIImage(binary);
    //self.swer.image = MatToUIImage(greyMat);
    //self.swer.image = image;
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
