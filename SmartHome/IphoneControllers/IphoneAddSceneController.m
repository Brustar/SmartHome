//
//  IphoneAddSceneController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneAddSceneController.h"
#import "SQLManager.h"

@interface IphoneAddSceneController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *devices;
@end

@implementation IphoneAddSceneController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
     self.automaticallyAdjustsScrollViewInsets = NO;
    self.devices = [self deviceAdded];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

- (IBAction)addDeviceAction:(id)sender {
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"gotoDeviceSegue"])
    {
        id theSegue = segue.destinationViewController;
        [theSegue setValue:[NSNumber numberWithInt:self.roomId] forKey:@"roomId"];
    }
    

}

-(NSArray *)deviceAdded
{
    NSString *sceneFile = [NSString stringWithFormat:@"%@_0.plist",SCENE_FILE_NAME];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
    NSMutableArray *deviceName = [NSMutableArray array];
    for(NSDictionary *dic in plistDic)
    {
        //dic[@"deviceID"];
        NSString *name = [SQLManager deviceNameByDeviceID:[dic[@"deviceID"] intValue]];
        [deviceName addObject:name];
    }
    return [deviceName copy];

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.devices.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    return cell;
}

@end
