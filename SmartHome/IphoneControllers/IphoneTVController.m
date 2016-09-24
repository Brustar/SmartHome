//
//  IphoneTVController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneTVController.h"
#import "IphoneRoomView.h"
#import "ChannelManager.h"
#import "TVChannel.h"
#import "TVLogoCell.h"
#import "UIImageView+WebCache.h"
#import "SQLManager.h"
#import "MBProgressHUD+NJ.h"
#import "HttpManager.h"
#import "IphoneAddTVChannelController.h"

@interface IphoneTVController ()<UICollectionViewDelegate,UICollectionViewDataSource,TVLogoCellDelegate>
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIImageView *voiceStrongImg;

@property (weak, nonatomic) IBOutlet UIImageView *voiceWeakImg;

@property (weak, nonatomic) IBOutlet UIButton *lastBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (nonatomic,strong) NSMutableArray *allFavourTVChannels;
@property (weak, nonatomic) IBOutlet UICollectionView *tvLogoCollectionView;

@property (weak, nonatomic) IBOutlet UIView *touchpad;
@property (nonatomic,strong) TVLogoCell *cell;

@end

@implementation IphoneTVController

-(NSMutableArray*)allFavourTVChannels
{
    if(!_allFavourTVChannels)
    {
        _allFavourTVChannels = [NSMutableArray array];
        _allFavourTVChannels = [ChannelManager getAllChannelForFavoritedForType:@"TV" deviceID:[self.deviceid intValue]];
        if(_allFavourTVChannels == nil || _allFavourTVChannels.count == 0)
        {
            
        }
    }
    return _allFavourTVChannels;
}
-(void)setRoomID:(int)roomID
{
    _roomID = roomID;
    if(roomID){
        self.deviceid = [SQLManager deviceIDWithRoomID:self.roomID withType:@"网络电视"];
        if(self.sceneid > 0)
        {
            NSArray *tvArr = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i <tvArr.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[tvArr[i] intValue]];
                if([typeName isEqualToString:@"网络电视"])
                {
                    self.deviceid = tvArr[i];
                }
            }
            
        }
        
    }
  
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.volumeSlider.transform = CGAffineTransformMakeRotation(M_PI/2);
    self.voiceWeakImg.transform = CGAffineTransformMakeRotation(M_PI/2);
    self.voiceStrongImg.transform = CGAffineTransformMakeRotation(M_PI/2);
    self.tvLogoCollectionView.bounces = NO;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allFavourTVChannels.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TVLogoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TVLogoCell" forIndexPath:indexPath];
    TVChannel *channel = self.allFavourTVChannels[indexPath.row];
    cell.delegate = self;
    [cell hiddenEditBtnAndDeleteBtn];
    cell.label.text = channel.channel_name;
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:channel.channel_pic] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    [cell useLongPressGesture];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TVLogoCell *cell =(TVLogoCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [cell hiddenEditBtnAndDeleteBtn];
    [cell useLongPressGesture];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}


-(void)tvDeleteAction:(TVLogoCell *)cell
{
    self.cell = cell;
    NSIndexPath *indexPath = [self.tvLogoCollectionView indexPathForCell:cell];
    TVChannel *channel = self.allFavourTVChannels[indexPath.row];
    

    //发送删除频道请求
    NSString *url = [NSString stringWithFormat:@"%@TVChannelRemove.aspx",[IOManager httpAddr]];
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSDictionary *dic = @{@"AuthorToken":authorToken,@"RecordID":[NSNumber numberWithInteger:channel.channel_id]};
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 1;
    [http sendPost:url param:dic];
    
    
}
-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            NSIndexPath *indexPath = [self.tvLogoCollectionView indexPathForCell:self.cell];
            TVChannel *channel = self.allFavourTVChannels[indexPath.row];
            
            //从数据库中删除数据
            BOOL isSuccess = [ChannelManager deleteChannelForChannelID:channel.channel_id];
            if(!isSuccess)
            {
                [MBProgressHUD showError:@"删除失败，请稍后再试"];
                return;
            }
            [self.allFavourTVChannels removeObject:channel];
            [self.tvLogoCollectionView reloadData];
            

        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }

}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    IphoneAddTVChannelController *addVC = segue.destinationViewController;
    addVC.deviceid = self.deviceid;
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
