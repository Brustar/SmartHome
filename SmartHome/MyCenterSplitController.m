//
//  MyCenterSplitController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "MyCenterSplitController.h"
#import "ProfileListController.h"
#import "ServiceRecordViewController.h"
#import "ProfieFaultsViewController.h"
#import "FavorController.h"
#import "MySettingViewController.h"
#import "EnergyOfDeviceController.h"
#import "MSGController.h"

@interface MyCenterSplitController ()<ProfileListControllerDelegate>
@property (nonatomic, strong) UINavigationController *detailNavigation;
@end

@implementation MyCenterSplitController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UINavigationController *centerListNav = [self.childViewControllers firstObject];
    ProfileListController *centerListVC = [centerListNav.childViewControllers firstObject];
    
    centerListVC.delegate = self;
    self.detailNavigation = [self.childViewControllers lastObject];
    self.presentsWithGesture = NO;
}



-(void)ProfileListController:(ProfileListController *)centerListVC selected:(NSInteger)row
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    switch (row) {
        case 0:{
            ProfieFaultsViewController *faultVC = [story instantiateViewControllerWithIdentifier:@"MyDefaultViewController"];
            [self.detailNavigation setViewControllers:@[faultVC] animated:NO];
        }
            break;
        case 1:{
            ServiceRecordViewController  *serviceVC = [story instantiateViewControllerWithIdentifier:@"ServiceRecordViewController"];
            [self.detailNavigation setViewControllers:@[serviceVC] animated:NO];

        }
            break;
        case 2:{
            EnergyOfDeviceController *enegryVC = [story instantiateViewControllerWithIdentifier:@"MyEnergyViewController"];
            [self.detailNavigation setViewControllers:@[enegryVC] animated:NO];

        }
            break;
        case 3:{
            FavorController  *favorVC = [story instantiateViewControllerWithIdentifier:@"FavorController"];
            [self.detailNavigation setViewControllers:@[favorVC] animated:NO];
        }
            break;
        case 4:{
             MSGController  *msgVC = [story instantiateViewControllerWithIdentifier:@"MSGController"];
             [self.detailNavigation setViewControllers:@[msgVC] animated:NO];
        }
           break;
        case 5:{
            MySettingViewController *setVC = [story instantiateViewControllerWithIdentifier:@"MySettingViewController"];
            [self.detailNavigation setViewControllers:@[setVC] animated:NO];
        }
            break;
        default:
            break;
           
       

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

@end
