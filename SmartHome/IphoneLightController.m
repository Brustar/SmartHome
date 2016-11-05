//
//  IphoneLightController.m
//  SmartHome
//
//  Created by 逸云科技 on 2016/11/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneLightController.h"
#import "PackManager.h"
#import "SocketManager.h"
#import "SQLManager.h"
#import "Device.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"

@interface IphoneLightController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,assign) CGFloat brightValue;

@property (nonatomic,strong) NSMutableArray *lIDs;
@property (nonatomic,strong) NSMutableArray *lNames;
@property (weak, nonatomic) IBOutlet UITableView *LightTable;
@property (weak, nonatomic) IBOutlet UITableView *SubLightTableView;

@end

@implementation IphoneLightController
-(NSMutableArray *)lIDs
{
    if(!_lIDs)
    {
        _lIDs = [NSMutableArray array];
        
        if(self.sceneid > 0 && !self.isAddDevice)
        {
            
            NSArray *lightArr = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i <lightArr.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[lightArr[i] intValue]];
                if([typeName isEqualToString:@"灯光"])
                {
                    [_lIDs addObject:lightArr[i]];
                }
            }
            
            
        }else if(self.roomID > 0){
            [_lIDs addObjectsFromArray:[SQLManager getDeviceByTypeName:@"开关灯" andRoomID:self.roomID]];
            [_lIDs addObjectsFromArray:[SQLManager getDeviceByTypeName:@"调光灯" andRoomID:self.roomID]];
            [_lIDs addObjectsFromArray:[SQLManager getDeviceByTypeName:@"调色灯" andRoomID:self.roomID]];
            
        }else{
            [_lIDs addObject:self.deviceid];
        }
        
    }
    return _lIDs;
}

-(NSMutableArray *)lNames
{
    if(!_lNames)
    {
        _lNames = [NSMutableArray array];
        for(int i = 0; i < self.lIDs.count; i++)
        {
            int lID = [self.lIDs[i] intValue];
            NSString *name = [SQLManager deviceNameByDeviceID:lID];
            [_lNames addObject:name];
        }
    }
    return _lNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpConstraints];
    self.detailCell = [[[NSBundle mainBundle] loadNibNamed:@"DetailTableViewCell" owner:self options:nil] lastObject];
    self.detailCell.bright.continuous = NO;
    [self.detailCell.bright addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
    
    [self.detailCell.power addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
    self.cell = [[[NSBundle mainBundle] loadNibNamed:@"ColourTableViewCell" owner:self options:nil] lastObject];
    
//    [self setupSegmentLight];
    
    self.scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
    if ([self.sceneid intValue]>0) {
        _favButt.enabled=YES;
        
        [self syncUI];
    }
    
    self.SubLightTableView.scrollEnabled = NO;
    self.SubLightTableView.delegate = self;
    self.SubLightTableView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncLight:) name:@"light" object:nil];
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
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
