//
//  selectPieces.m
//  jigSolver
//
//  Created by Patrick W. Crawford on 12/6/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import "selectPieces.h"

@interface selectPieces ()
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property BOOL ready;
- (IBAction)navNext:(id)sender;

@end

@implementation selectPieces

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // slightly fade out and initial set the background iamge... preparing to run segmentation
    // possibly put a loading sign/animation of some sort until it's ready (ani: run in background)
    self.imgView.image = [JSVsingleton sharedObj].piecesImg;
    self.imgView.alpha = 0.25;
    self.ready = NO;
    
    
    //[JSVopenCV solvePuzzle:self.imgViewORIG.image withOriginal: self.imgViewSOL.image];
    // pass in the NSMutableArray for pieces and do segmentation and run that part.
    // could do based on a floodfill algorithm on binary image instead of segmenting everything!
    
    
}


-(void)viewDidAppear:(BOOL)animated{
    
    // get B&W of all pieces found, then allow for taps to (de)select pieces
    UIImage *piecesOrig = [JSVsingleton sharedObj].piecesImg;
    self.imgView.image = [JSVopenCV segmentFromBackground:piecesOrig];
    self.imgView.alpha = 1;
    self.ready = YES;

    
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
    
    UIViewController *nextView =[self.storyboard instantiateViewControllerWithIdentifier:@"checkPieces"];
    [self.navigationController pushViewController:nextView animated:YES];
}
@end
