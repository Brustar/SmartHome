//
//  WelcomeController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/16.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "WelcomeController.h"
#import "DeviceInfo.h"
#import "SQLManager.h"
#import "AudioManager.h"


@interface WelcomeController ()<UIScrollViewDelegate>


- (IBAction)registerBtn:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *knowView;
@property (weak, nonatomic) IBOutlet UIView *registerView;
@property (nonatomic, strong) UIScrollView *pageScroll;

@end

@implementation WelcomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
   
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
//    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
//    self.view.frame = [[UIScreen mainScreen] bounds];
    
    }
- (IBAction)clickWeKnowBtn:(id)sender {
    
    self.coverView.hidden = YES;
    self.knowView.hidden = YES;
}

- (IBAction)clickloginBtn:(id)sender {
}

- (IBAction)demo:(id)sender {
    DeviceInfo *info=[DeviceInfo defaultManager];
    info.db=@"demoDB";
    [SQLManager initDemoSQlite];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self performSegueWithIdentifier:@"iphoneMainSegue" sender:self];
    }else{
        [self performSegueWithIdentifier:@"gotoMainController" sender:self];
    }

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

-(void)viewDidLayoutSubviews
{
  

}

- (IBAction)IpadRegisterBtn:(id)sender {
    
    self.coverView.hidden = NO;
    self.registerView.hidden = NO;
    
}

- (IBAction)registerBtn:(id)sender {
    
    self.coverView.hidden = NO;
    self.registerView.hidden = NO;
}
@end
