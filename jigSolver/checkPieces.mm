//
//  checkPieces.m
//  jigSolver
//
//  Created by Patrick W. Crawford on 12/6/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import "checkPieces.h"
#include "PageContentViewController.h"
#include "JSVsingleton.h"

@interface checkPieces ()
- (IBAction)navNext:(id)sender;
- (IBAction)startWalkthrough:(id)sender;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

@property int state;
@end

@implementation checkPieces

- (void)viewDidLoad {
    [super viewDidLoad];
    self.state = 0;
    // Do any additional setup after loading the view.
    
    // run the heavy backend stuff... maybe put up temporary image for the start saying "processing"
    
    
}

- (void) viewDidAppear:(BOOL)animated{
    
    // run once, but after view loaded
    if (self.state == 0){
        
        // heavy processing, will take some time
        [[JSVsingleton sharedObj] processPieces];
        
        
        // Create the data model
        _pageTitles = @[@"Over 200 Tips and Tricks", @"Discover Hidden Features", @"Bookmark Favorite Tip", @"Free Regular Update"];
        _pageImages = @[@"IMG_2775.JPG", @"IMG_2775.JPG", @"IMG_2775.JPG", @"IMG_2775.JPG"];
        
        // Create page view controller
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
        self.pageViewController.dataSource = self;
        
        PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
        // Change the size of page view controller
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50);
        
        [self addChildViewController:_pageViewController];
        [self.view addSubview:_pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];
        
        self.state=1;
        
    }
}

- (IBAction)startWalkthrough:(id)sender {
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    //pageContentViewController.pieceImg = [UIImage imageNamed:@"IMG_2775"];
    //pageContentViewController.pieceImgView.image = [UIImage imageNamed:@"IMG_2775"];
    pageContentViewController.pieceImgView.image = [JSVsingleton sharedObj].piecesImg; // change to indivual piece..
    pageContentViewController.pieceImgView.image = [UIImage imageNamed:@"IMG_2775.JPG"];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}



- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    //NSLog(@"SLide: %i",index);
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    //NSLog(@"Slide #: %i",index);
    index++;
    if (index == [[JSVsingleton sharedObj].pieces count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [[JSVsingleton sharedObj].pieces count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}


//////////////////////////////////


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)navNext:(id)sender {
    // set size of puzzle
    // go to next view
    UIViewController *nextView =[self.storyboard instantiateViewControllerWithIdentifier:@"finalResult"];
    [self.navigationController pushViewController:nextView animated:YES];
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
