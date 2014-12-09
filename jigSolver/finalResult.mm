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
    for (int i=0; i< [self.imageViews count]; i++){
        [self.imageViews[i] removeFromSuperview];
    }
    // array should be empty now... but do this just in case
    [self.imageViews removeAllObjects];
    
    //do stuff here. for each piece
    for (int i=0; i< [[JSVsingleton sharedObj].pieces count]; i++){
        JSVpuzzlePiece *piece = [JSVsingleton sharedObj].pieces[i];
        
        UIImage *maskImg = [self maskImage: [[JSVsingleton sharedObj] getPieceOriginal:i] withMask:[[JSVsingleton sharedObj] getPieceMaskInverse:i]];
        [self.imageViews addObject: maskImg];
        
        // integers of tiles of the puzzle (number of pieces by number of pieces)
        int x = [JSVsingleton sharedObj].cols;
        int y = [JSVsingleton sharedObj].rows;
        
        // below is the dimensions of the OVERALL peiced un-borken-up image
        CGPoint origDims = [[JSVsingleton sharedObj] getPiecesDims];
        
        // dimensions of the piece
        Mat tmp = piece.mask;
        int px = tmp.cols;
        int py = tmp.rows;
        
        // the factor of scaling overall, factor of less than 1
        float div = self.size.width/origDims.x;
        
        
        // logical addition, to move down the frame if screen is vertical
        int liny = 100;
        if (self.size.width > self.size.height){
            liny = 0;
            div = self.size.height/origDims.y;
            //NSLog(@"here! >>>>>>>>:");
        }
        // don't both with this scenario.
        
        // make the actual object frame
        NSLog(@"div: %f >> %d %d %f", div, px, x, origDims.x);
        CGRect framed = CGRectMake(piece.offset_x*div, piece.offset_y*div + liny, px*div, py*div);
        
        // for future animation, where it currently is .. kinda. not really.
        //NSLog(@" convert: %i %i",i%x,i/x);
        
        UIImageView *pieceBlock = [[UIImageView alloc] initWithFrame:framed];
        pieceBlock.image = maskImg;
        pieceBlock.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.view addSubview:pieceBlock];
        
        
        
        
        // now setup the animation.
        CGRect newFrame = CGRectMake (0,00,px*div,py*div);
        // calcualte where the piece SHOULD be.
        newFrame.origin.x = px*piece.guess_x*div;
        newFrame.origin.y = py*piece.guess_y*div + liny;
        [UIView animateWithDuration:1.5
                              delay: 0.75
                            options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                         animations:^{
                             pieceBlock.frame = newFrame;   // move
                         }
                         completion:nil];  // no completion handler
        
        
        
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
