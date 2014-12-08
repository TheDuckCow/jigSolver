//
//  JSVDimViewController.h
//  jigSolver
//
//  Created by Timothy Chong on 12/8/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSVDimViewController : UIViewController <UIScrollViewDelegate>

- (IBAction)navNext:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *canvas;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *maskView;
@property (weak, nonatomic) IBOutlet UILabel *rotationLabel;
@property (nonatomic) BOOL scrollStarted;
@property (nonatomic) NSMutableArray * masks;
@property (nonatomic) int checkToRun;
@end
