//
//  PageContentViewController.m
//  jigSolver
//
//  Created by Patrick W. Crawford on 12/7/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import "PageContentViewController.h"
#import "JSVsingleton.h"

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
    
    NSLog(@"FROM PAGE VIEW: %i", self.pageIndex);
    self.pieceImgView.image = [[JSVsingleton sharedObj] getPieceMask:self.pageIndex];
    //[UIImage imageNamed:@"IMG_2775.JPG"];
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
