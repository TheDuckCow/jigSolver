//
//  homeScreen.m
//  jigSolver
//
//  Created by Patrick W. Crawford on 12/4/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import "homeScreen.h"

@interface homeScreen ()
@property (strong, nonatomic) IBOutlet UITableView *mainTable;

@end

@implementation homeScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self prefersStatusBarHidden];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // one section to return
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // number of presentationts (rows) plus extra info row
    return 4;
}

- (UITableViewCell *)tableView :(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *CellIdentifier = @"generalCell";
    if (indexPath.row == 0){
        CellIdentifier = @"firstCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // perhaps add some exception handling?? if invalid number of languages returned e.g...
    UIImageView *cellimg = (UIImageView *)[cell viewWithTag:21];
    cellimg.image = [UIImage imageNamed:@"jigSawlerLogo-02"];
    
    UILabel *lbl = (UILabel *)[cell viewWithTag:42];
    if (indexPath.row == 1){
        lbl.text = @"Solve my puzzle pieces!";
    }
    else if (indexPath.row == 2){
        lbl.text = @"Test iamge functions";
    }
    else if (indexPath.row == 3){
        lbl.text = @"Credits";
    }
    
    // make background transparent
    cell.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.2];
    
    return cell;
}


- (CGFloat)   tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0){
        return 180;
    }
    return 80;
    
    
    /*
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        if(indexPath.row == 0)
            return 140;
        return 70;
    }
    else{
        if(indexPath.row == 0)
            return 90;
        return 50;
    }
     */
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Cell: %i",indexPath.row);
    // segue to the according one.
    if (indexPath.row==1){
        
        UIViewController *nextView =[self.storyboard instantiateViewControllerWithIdentifier:@"navSolvePuzzle"];
        [self presentViewController:nextView animated:YES completion:nil];
        
    }
    else if (indexPath.row==2){
        [self performSegueWithIdentifier:@"Seg2debug" sender:self];
    }

    
}


- (void) viewDidAppear:(BOOL)animated{
    [self.mainTable reloadData];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
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
