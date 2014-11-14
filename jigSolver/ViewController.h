//
//  ViewController.h
//  jigSolver
//
//  Created by Patrick W. Crawford on 11/14/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "opencv2/highgui/ios.h"

@interface ViewController : UIViewController {
    cv::Mat cvImage;
}

@property (nonatomic, weak) IBOutlet UIImageView* imageView;

@end

