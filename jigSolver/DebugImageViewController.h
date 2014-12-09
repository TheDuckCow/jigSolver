//
//  DebugImageViewController.h
//  jigSolver
//
//  Created by Timothy Chong on 12/8/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DebugImageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *debugImage;
- (IBAction)updateImage:(id)sender;

@end
