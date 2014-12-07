//
//  PageContentViewController.h
//  jigSolver
//
//  Created by Patrick W. Crawford on 12/7/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImage *pieceImg;
@property (strong, nonatomic) IBOutlet UIImageView *pieceImgView;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@end
