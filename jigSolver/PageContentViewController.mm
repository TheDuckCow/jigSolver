//
//  PageContentViewController.m
//  jigSolver
//
//  Created by Patrick W. Crawford on 12/7/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import "PageContentViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JSVsingleton.h"
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

@interface PageContentViewController ()



@end

@implementation PageContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //NSLog(@"FROM PAGE VIEW: %i", self.pageIndex);
    self.imgMask.image = [[JSVsingleton sharedObj] getPieceMaskInverse:(int)self.pageIndex];
    self.pieceImgView.image = [[JSVsingleton sharedObj] getPieceOriginal:(int)self.pageIndex];
    self.source.image = [JSVsingleton sharedObj].solutionImg;
    
    
}

-(void) viewDidAppear:(BOOL)animated{
    UIImage *maskImg = [self maskImage: self.pieceImgView.image withMask:self.imgMask.image];
    self.overlayPiece.image = maskImg;
    
    
    
    CGRect newFrame = self.overlayPiece.frame;
    newFrame.origin.x -= 100;    // shift right by 500pts
    newFrame.origin.y -= 100;
    [UIView animateWithDuration:1.0
                          delay: 0.5
                        options: UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
                         self.overlayPiece.frame = newFrame;   // move
                     }
                     completion:nil];  // no completion handler
    
}

- (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    return [UIImage imageWithCGImage:masked];
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

@end
