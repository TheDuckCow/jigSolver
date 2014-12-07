//
//  ViewController.m
//  jigSolver
//
//  Created by Patrick W. Crawford on 11/14/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//


#import "JSVopenCV.h"
#import "ViewController.h"
#import "JSVpuzzlePiece.h"
#import "opencv2/highgui/ios.h"
#import <opencv2/opencv.hpp>
#import "JSVOpenCVSIFT.h"

using namespace cv;

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *swer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view, typically from a nib.
    
    // the heavy processing all hapens here.
    NSArray *solutions =@[@"IMG_2774.JPG",@"IMG_2780.JPG"];
    NSArray *scrambledPieces = @[@"IMG_2785.JPG",@"IMG_2784.JPG",@"IMG_2785.JPG",@"IMG_2787.JPG",@"IMG_2788.JPG"];
    NSArray *scrambledRectanlges = @[@"IMG_2773.JPG",@"IMG_2775.JPG",@"IMG_2776.JPG",@"IMG_2778.JPG",@"IMG_2779.JPG",@"IMG_2781.JPG", @"IMG_2781.JPG"];

    
//    self.swer.image = [JSVopenCV solvePuzzle:[UIImage imageNamed:scrambledPieces[0]] withOriginal: [UIImage imageNamed:solutions[0]]];
    
    NSArray * segmentedPieces = [JSVopenCV segmentPiecesFromBackground:[UIImage imageNamed:scrambledRectanlges[2]]];
    
//    [JSVOpenCVSIFT matchPieceWithSolution:segmentedPieces[0] withSolution:[UIImage imageNamed: solutions[0]]];
    
    Mat result;
    
    [JSVOpenCVSIFT matchPieces:segmentedPieces withSolution:[UIImage imageNamed:solutions[0]] col:2 row:2 result:result];
//    UIImage * match = [JSVOpenCVSIFT matchPieceWithSolution:piece withSolution:[UIImage imageNamed:solutions[0]]];
    
    
    Mat finalResult;
    for(int i = 0 ; i < result.rows; i ++ ) {
        Mat rowResult;
        for(int j =0; j < result.cols; j++ ){

            int index = result.at<char>(j, i);
            if (index == -1) continue;
            
            JSVpuzzlePiece * image = segmentedPieces[index];
            Mat temp = image.originalImage.clone();
            if (rowResult.empty()) {
                rowResult = temp.clone();
                NSLog(@"Empty");
        
            } else {
                Mat clone = rowResult.clone();
                [JSVOpenCVSIFT combineImageLeftRight:clone right:temp result:rowResult];
                NSLog(@"not empty");
            }
        }
        if (finalResult.empty()) {
            finalResult = rowResult;
        } else {
            Mat clone = finalResult.clone();
            [JSVOpenCVSIFT combineImageTopBottm:clone bottom:rowResult result:finalResult];
        }
        printf("\n");
    }
    
    UIImage * yo = MatToUIImage(finalResult);
    
    self.swer.image = yo;
//    self.swer.image = match;
    
    //self.swer.image =[UIImage imageNamed:scrambled[0]];
    
    // test process
    //UIImage* img = [UIImage imageNamed:@"lena.png"];
    //self.swer.image = [JSVopenCV testFunction: img];
    
    
}



- (IBAction)pressBack:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
