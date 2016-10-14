//
//  DeviceOfFixTimerViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/27.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DeviceOfFixTimerViewController.h"
#import "SQLManager.h"
@interface DeviceOfFixTimerViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSArray *deviceNames;
@end

@implementation DeviceOfFixTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //[self.tableView reloadData];
    NSMutableArray *names = [NSMutableArray array];
    NSString *sceneFile = [NSString stringWithFormat:@"%@_0.plist",SCENE_FILE_NAME];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
    NSArray *array = plistDic[@"devices"];
    for(NSDictionary *dic in array)
    {
        NSString *name = [SQLManager deviceNameByDeviceID:[dic[@"deviceID"] intValue]];
        if(name)
        {
            [names addObject:name];

        }
    }
    self.deviceNames = [names copy];
    [self.tableView reloadData];
}
-(CGSize)preferredContentSize
{
    if(self.presentingViewController && self.tableView != nil)
    {
        CGSize tempSize = self.presentingViewController.view.bounds.size;
        tempSize.width = 200;
        CGSize size = [self.tableView sizeThatFits:tempSize];
        return size;
    }else {
        return [super preferredContentSize];
    }
}

-(void)setPreferredContentSize:(CGSize)preferredContentSize
{
    super.preferredContentSize = preferredContentSize;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceNames.count + 1;
       
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if(indexPath.row == 0)
    {
        cell.textLabel.text = @"场景";
    }else{
        cell.textLabel.text = self.deviceNames[indexPath.row - 1];

    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        [self.delegate DeviceOfFixTimerViewController:self  andName:@"场景"];
    }else{
        [self.delegate DeviceOfFixTimerViewController:self andName:self.deviceNames[indexPath.row - 1]];

    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
