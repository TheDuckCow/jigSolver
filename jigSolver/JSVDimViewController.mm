//
//  JSVDimViewController.m
//  jigSolver
//
//  Created by Timothy Chong on 12/8/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import "JSVopenCV.h"

#import "JSVDimViewController.h"
#import "JSVsingleton.h"
#import <opencv2/opencv.hpp>
#import "JSVOpenCVSIFT.h"
#import "JSVpuzzlePiece.h"
#import "opencv2/highgui/ios.h"
#import <opencv2/core/core.hpp>
#import <opencv2/imgproc/imgproc.hpp>
#import <QuartzCore/QuartzCore.h>

using namespace cv;

#define delta 400

@interface JSVDimViewController ()

@end

@implementation JSVDimViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.masks = [NSMutableArray new];
    
}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

//    NSArray *solutions =@[@"IMG_2774.JPG",@"IMG_2780.JPG"];
//    NSArray *scrambledPieces = @[@"IMG_2785.png",@"IMG_2784.JPG",@"IMG_2785.JPG",@"IMG_2787.JPG",@"IMG_2788.JPG"];

//    [JSVsingleton sharedObj].piecesImg = [UIImage imageNamed:@"IMG_2773.png"];

//    [JSVopenCV createPiecesFromImage: [JSVsingleton sharedObj].piecesImg isSolution:NO];
    
//    Mat result;
//    [JSVOpenCVSIFT matchPieces:[JSVsingleton sharedObj].pieces withSolution:[UIImage imageNamed:solutions[0]] col:2 row:2 result:result];
//    NSLog(@"DONE");
    [[JSVsingleton sharedObj] processPieces];
    
    self.canvas.image = MatToUIImage([JSVsingleton sharedObj].solution.originalImage.clone());
    
    double piece_width = [JSVsingleton sharedObj].solution.originalImage.cols / (double)2;
    double piece_height = [JSVsingleton sharedObj].solution.originalImage.rows / (double)2;
    Mat black = Mat::zeros([JSVsingleton sharedObj].solution.originalImage.rows, [JSVsingleton sharedObj].solution.originalImage.cols, CV_8UC4);
    UIImage *blackImage = MatToUIImage(black);
    
    
    int height = 300;
    int width = 0;
    
    for (JSVpuzzlePiece * piece in [JSVsingleton sharedObj].pieces) {
        UIImage * image = MatToUIImage(piece.originalImage.clone());
        Mat invert;
        bitwise_not(piece.mask, invert);
        UIImage * aMask = MatToUIImage(invert.clone());
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(width, 0, delta, height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UIImage *masked = [self maskImage:image withMask:aMask];
        imageView.image = masked;
        [self.scrollView addSubview:imageView];
        width += delta;
        Mat originalImage = [JSVsingleton  sharedObj].solution.originalImage.clone();
        Mat zero = Mat::zeros(originalImage.rows, originalImage.cols, CV_8UC1);
        int x = piece.guess_x;
        int y = piece.guess_y;
        NSLog(@"%d %d", x, y);
        for(int i = x * piece_width; i < (x + 1) * piece_width; i++){
            for (int j = y * piece_height; j < (y + 1) * piece_height; j++){
                    zero.at<uchar>(j,i) = 255;
            }
        }
        Mat blurred;
        GaussianBlur(zero, blurred, cv::Size(), 50);
        UIImage * maskImage = MatToUIImage(blurred);
        UIImage * finalMasked = [self maskImage:blackImage withMask:maskImage];
        [self.masks addObject: finalMasked];
    }
    [self.scrollView setContentSize:CGSizeMake(width, height)];
    self.scrollView.clipsToBounds = YES;
    self.scrollView.pagingEnabled = YES;
    
    [self startAnimatingMaskWithIndex:0];
    
}


-(void) startAnimatingMaskWithIndex:(int) index {
    self.maskView.image = self.masks[index];
    
    [UIView animateWithDuration:.5 animations:^{
        self.maskView.alpha = 0.5;
    }];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.scrollStarted) {
        return;
    }
    [UIView animateWithDuration:.2 animations:^{
        self.maskView.alpha = 0;
    }];
    self.scrollStarted = YES;
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x / delta;
    [self startAnimatingMaskWithIndex:index];
    self.scrollStarted = NO;
    JSVpuzzlePiece * currentPiece = [JSVsingleton sharedObj].pieces[index];
    self.rotationLabel.text = [NSString stringWithFormat:@"Swipe piece left/right to see others.\nEstimate of this piece's roation: %f°", currentPiece.guess_rotation / M_PI * 180];
}


- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    
    CGImageRelease(mask);
    CGImageRelease(maskedImageRef);
    
    // returns new image with mask applied
    return maskedImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)navNext:(id)sender {
    UIViewController *nextView =[self.storyboard instantiateViewControllerWithIdentifier:@"finalResult"];
    [self.navigationController pushViewController:nextView animated:YES];
}
@end
