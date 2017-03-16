//
//  IphoneNewEditSceneController.m
//  SmartHome
//
//  Created by zhaona on 2017/3/20.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IphoneNewEditSceneController.h"

@interface IphoneNewEditSceneController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *SoftButton;
@property (weak, nonatomic) IBOutlet UIButton *normalBtn;
@property (weak, nonatomic) IBOutlet UIButton *brightBtn;

@end

@implementation IphoneNewEditSceneController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    return cell;

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
