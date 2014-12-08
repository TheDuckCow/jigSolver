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
    
    
    self.title = [NSString stringWithFormat: @"Selected Pieces (%i)",[[JSVsingleton sharedObj].pieces count]];
    
    // setup gesture (tap) recognizer
    UITapGestureRecognizer *rec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    [self.view addGestureRecognizer:rec];
    
    
    //[JSVopenCV solvePuzzle:self.imgViewORIG.image withOriginal: self.imgViewSOL.image];
    // pass in the NSMutableArray for pieces and do segmentation and run that part.
    // could do based on a floodfill algorithm on binary image instead of segmenting everything!
    
    
}


-(void)viewDidAppear:(BOOL)animated{
    
    // get B&W of all pieces found, then allow for taps to (de)select pieces
    UIImage *piecesOrig = [JSVsingleton sharedObj].piecesImg;
    self.imgView.image = [JSVopenCV createPiecesFromImage:piecesOrig isSolution:NO];
    self.imgView.alpha = 1;
    self.ready = YES;
    
    // update the title for number of selected pieces
    self.title = [NSString stringWithFormat: @"Selected Pieces (%lu)",(unsigned long)[[JSVsingleton sharedObj].pieces count]];
    
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

- (void)tapRecognized:(UITapGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint point = [recognizer locationInView:recognizer.view];
        // again, point.x and point.y have the coordinates
        NSLog(@"##\nPos %f %f",point.x,point.y);
        // CONVERT POINT:
        point = [self.view convertPoint:point toView:self.imgView];
        NSLog(@"--\nPos %f %f",point.x,point.y);
        
        // run function with that xy input to check which point it overlaps
    }
}


- (IBAction)navNext:(id)sender {
    
    // here do the logic of determining the number of puzzle pieces from input
    [[JSVsingleton sharedObj] determinePuzzleSize];
    
    UIViewController *nextView =[self.storyboard instantiateViewControllerWithIdentifier:@"checkPieces"];
    [self.navigationController pushViewController:nextView animated:YES];
}

@end
