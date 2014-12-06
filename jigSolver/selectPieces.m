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
- (IBAction)navNext:(id)sender;

@end

@implementation selectPieces

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //NSLog(@"Select peices VC");
    self.imgView.image = [JSVsingleton sharedObj].piecesImg;
    
    // INITIALLY attempt to segment all the pieces.
    // maybe start by auto assuming to use all,
    // but can tap to remove them thereafter
    UIImage *piecesOrig = [JSVsingleton sharedObj].piecesImg;
    self.imgView.image = [JSVopenCV segmentFromBackground:piecesOrig];
    
    
    
    //[JSVopenCV solvePuzzle:self.imgViewORIG.image withOriginal: self.imgViewSOL.image];
    // pass in the NSMutableArray for pieces and do segmentation and run that part.
    // could do based on a floodfill algorithm on binary image instead of segmenting everything!
    
    
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
