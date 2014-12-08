//
//  finalResult.m
//  jigSolver
//
//  Created by Patrick W. Crawford on 12/6/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import "finalResult.h"
#import "JSVsingleton.h"
#import "JSVpuzzlePiece.h"
#import <QuartzCore/QuartzCore.h>
#import "opencv2/highgui/ios.h"
#import <opencv2/opencv.hpp>
using namespace cv;

@interface finalResult ()
- (IBAction)returnHome:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *finalImageBG;
@property (nonatomic) CGSize size;
@property (nonatomic) int state;
@property (strong, nonatomic) NSMutableArray *imageViews;

@end

@implementation finalResult

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // easy way out in case other things don't work.
    //self.finalImageBG.image = [JSVsingleton sharedObj].combinedImg;
    self.imageViews = [[NSMutableArray alloc] init];
    self.size = [UIScreen mainScreen].bounds.size;
    self.state = 0;
    
}


-(void) viewDidAppear:(BOOL)animated{
    
    // first, remove all previously existing image views
    
    //do stuff here. for each piece
    for (int i=0; i< [[JSVsingleton sharedObj].pieces count]; i++){
        //JSVpuzzlePiece *piece = [JSVsingleton sharedObj].pieces[i];
        
        UIImage *maskImg = [self maskImage: [[JSVsingleton sharedObj] getPieceOriginal:i] withMask:[[JSVsingleton sharedObj] getPieceMaskInverse:i]];
        
        int x = [JSVsingleton sharedObj].cols;
        int y = [JSVsingleton sharedObj].rows;
        
        // start by assuming 2x2
        double height = self.size.height*.75/y;
        double width = self.size.width*.75/x;
                                             
        CGRect framed = CGRectMake(self.size.width*.25 - width/2, self.size.height*.25 - height/2, width, height);
        NSLog(@" convert: %i %i",i%x,i/x);
        
        UIImageView *pieceBlock = [[UIImageView alloc] initWithFrame:framed];
        pieceBlock.image = maskImg;
        pieceBlock.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.view addSubview:pieceBlock];
    }
    
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    // called whenever there is a rotation, set width for scene..

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

- (IBAction)returnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
