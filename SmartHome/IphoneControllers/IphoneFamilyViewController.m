
//
//  IphoneFamilyViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 2016/11/11.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#define cellWidth self.collectionView.frame.size.width / 2.0 -20
#define  minSpace 20
#define  maxSpace 40

#import "IphoneFamilyViewController.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "FamilyCell.h"
#import "Scene.h"
#import "Room.h"
#import "SQLManager.h"


@interface IphoneFamilyViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic)  IBOutlet UIView *supView;
@property (nonatomic,strong) UIScrollView * scrollView;
@property (nonatomic,strong) UIImageView * supImageView;
@property (nonatomic,strong) NSArray * dataSource;
@property (nonatomic,strong) NSMutableArray * roomIdArrs;//房间数量
@property (nonatomic,strong) NSMutableArray * lightArrs;//
@property (nonatomic,strong) NSMutableArray * curtainArrs;//
@property (nonatomic,strong) NSMutableArray * musicArrs;//
@property (nonatomic,strong) NSMutableArray * dvdArrs;//
@property (nonatomic,strong) NSMutableArray * tvArrs;//
@property (nonatomic,strong) NSMutableArray * tempArrs;
@property (nonatomic,strong) NSMutableArray * humidityArrs;//湿度
@property (nonatomic,strong) NSMutableArray * airconditionArrs;
@property (nonatomic,assign) int selectedSId;
@property (nonatomic,assign) int selected;
@property (nonatomic,strong) NSArray *rooms;

@end

@implementation IphoneFamilyViewController

-(NSMutableArray *)roomIdArrs
{
    if (!_roomIdArrs) {
        _roomIdArrs = [NSMutableArray array];
    }
    
    return _roomIdArrs;

}
-(NSMutableArray *)lightArrs
{
    if (!_lightArrs) {
        _lightArrs = [NSMutableArray array];
    }
    return _lightArrs;
}
-(NSMutableArray *)curtainArrs
{
    if (!_curtainArrs) {
        _curtainArrs = [NSMutableArray array];
    }
    
    return _curtainArrs;

}
-(NSMutableArray *)musicArrs
{
    if (!_musicArrs) {
        _musicArrs =[NSMutableArray array];
    }
    
    return _musicArrs;
}
-(NSMutableArray *)dvdArrs
{
    if (!_dvdArrs) {
        _dvdArrs = [NSMutableArray array];
    }
    
    return _dvdArrs;

}

-(NSMutableArray *)tvArrs
{
    if (!_tvArrs) {
        _tvArrs = [NSMutableArray array];
    }
    
    return _tvArrs;

}
-(NSMutableArray *)tempArrs
{
    if (!_tempArrs) {
        _tempArrs = [NSMutableArray array];
    }
    
    return _tempArrs;

}
-(NSMutableArray *)humidityArrs
{

    if (!_humidityArrs) {
        _humidityArrs = [NSMutableArray array];
    }
    
    return _humidityArrs;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.bounces = NO;
    self.selected = 0;
 
      [self sendRequest];
    
}

-(void)sendRequest
{
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSString *url = [NSString stringWithFormat:@"%@cloud/RoomStatusList.aspx",[IOManager httpAddr]];
    if (authorToken) {
        NSDictionary *dic = @{@"AuthorToken":authorToken};
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        [http sendPost:url param:dic];
    }
}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if ([responseObject[@"Result"] intValue]==0)
        {
            
            NSArray *dic = responseObject[@"list"];
            
            NSMutableArray * roomidArr = [NSMutableArray array];
            NSMutableArray * lightArr =[NSMutableArray array];
            NSMutableArray * curtainArr = [NSMutableArray array];
            NSMutableArray * musicArr = [NSMutableArray array];
            NSMutableArray * dvdArr = [NSMutableArray array];
            NSMutableArray * tvArr = [NSMutableArray array];
            NSMutableArray * tempArr = [NSMutableArray array];
            NSMutableArray * humidityArr = [NSMutableArray array];
            NSMutableArray * airconditionArr = [NSMutableArray array];
            if ([dic isKindOfClass:[NSArray class]]) {
                for(NSDictionary *dicDetail in dic)
                {
                    if ([dicDetail isKindOfClass:[NSDictionary class]]) {
                        [lightArr addObject:dicDetail[@"light"]];
                        [curtainArr addObject:dicDetail[@"curtain"]];
                        [roomidArr addObject:dicDetail[@"roomid"]];
                        [dvdArr addObject:dicDetail[@"dvd"]];
                        [tvArr addObject:dicDetail[@"tv"]];
                        [musicArr addObject:dicDetail[@"bgmusic"]];
                        [tempArr addObject:dicDetail[@"temperature"]];
                        [humidityArr addObject:dicDetail[@"humidity"]];
                        [airconditionArr addObject:dicDetail[@"aircondition"]];
                     
                    }
                    [self.lightArrs addObject:lightArr];
                    [self.curtainArrs addObject:curtainArr];
                    [self.roomIdArrs addObject:roomidArr];
                    [self.dvdArrs addObject:dvdArr];
                    [self.tvArrs addObject:tvArr];
                    [self.musicArrs addObject:musicArr];
                    [self.tempArrs addObject:tempArr];
                    [self.humidityArrs addObject:humidityArr];
                    [self.airconditionArrs addObject:airconditionArr];
                }
            }
            
            
            
            [self.collectionView reloadData];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }else if(tag == 2)
    {
        if([responseObject[@"Result"] intValue]==0)
        {
            [MBProgressHUD showSuccess:@"删除成功"];
            
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }
    
    
    
    
}


#pragma  mark - UICollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return self.roomIdArrs.count;

}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   FamilyCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    self.rooms = [SQLManager getAllRoomsInfo];
    NSMutableArray *roomNames = [NSMutableArray array];
    
    for (Room *room in self.rooms) {
        NSString *roomName = room.rName;
        [roomNames addObject:roomName];
    }
    cell.layer.masksToBounds = YES;
    cell.supImageView.layer.cornerRadius = cell.supImageView.bounds.size.width / 2.0;
    cell.subImageView.layer.cornerRadius = cell.subImageView.bounds.size.width /2.0;
    cell.lightImageVIew.layer.cornerRadius = cell.lightImageVIew.bounds.size.width /2.0;
    cell.curtainImageView.layer.cornerRadius = cell.curtainImageView.bounds.size.width / 2.0;
    cell.airImageVIew.layer.cornerRadius = cell.airImageVIew.bounds.size.width / 2.0;
    cell.DVDImageView.layer.cornerRadius = cell.DVDImageView.bounds.size.width / 2.0;
    cell.TVImageView.layer.cornerRadius = cell.TVImageView.bounds.size.width / 2.0;
    cell.musicImageVIew.layer.cornerRadius = cell.musicImageVIew.bounds.size.width / 2.0;
    
    cell.nameLabel.text = roomNames[indexPath.row];
    cell.tempLabel.text = [NSString stringWithFormat:@"%@",self.tempArrs[indexPath.row]];
    cell.humidityLabel.text = [NSString stringWithFormat:@"%@",self.humidityArrs[indexPath.row]];

    
    
    if (self.selected == 0) {
        
        cell.lightImageVIew.hidden = YES;
        cell.curtainImageView.hidden = YES;
        cell.airImageVIew.hidden = YES;
        cell.DVDImageView.hidden = YES;
        cell.TVImageView.hidden = YES;
        cell.musicImageVIew.hidden = YES;
        
    }else if (self.selected == 1){
        cell.lightImageVIew.hidden = NO;
        cell.curtainImageView.hidden = NO;
        cell.airImageVIew.hidden = NO;
        cell.DVDImageView.hidden = NO;
        cell.TVImageView.hidden = NO;
        cell.musicImageVIew.hidden = NO;
    }
    
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    Scene *scene = self.roomIdArrs[indexPath.row];
    self.selectedSId = scene.sceneID;
  
   
        [self performSegueWithIdentifier:@"iphoneSceneController" sender:self];
    
        
   

}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(cellWidth, cellWidth);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return minSpace;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return maxSpace;
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
