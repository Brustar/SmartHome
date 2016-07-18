//
//  TVController.m
//  SmartHome
//
//  Created by Brustar on 16/6/7.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "TVController.h"
#import "TV.h"
#import "SceneManager.h"
#import "TVChannel.h"
#import "DVCollectionViewCell.h"
#import "TVLogoCell.h"
#import "MBProgressHUD+NJ.h"
#import "KxMenu.h"
@interface TVController ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,TVLogoCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UISlider *volume;
@property (weak, nonatomic) IBOutlet UIPageControl *pageController;

@property (weak, nonatomic) IBOutlet UICollectionView *tvLogoCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *numbersCollectionView;

@property (nonatomic,strong) NSArray *btnTitles;

@property (nonatomic,strong) NSMutableArray *allFavourTVChannels;
@property (nonatomic,strong) TVLogoCell *cell;
- (IBAction)mute:(id)sender;
//编辑电视属性
@property (weak, nonatomic) IBOutlet UITextField *channelName;
@property (weak, nonatomic) IBOutlet UITextField *channeID;
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIButton *editChannelImgBtn;

- (IBAction)editChannelImgBtn:(UIButton *)sender;

@end

@implementation TVController

-(NSArray *)btnTitles
{
    if(!_btnTitles)
    {
        _btnTitles = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    }
    return _btnTitles;
    
    
    
}
-(NSMutableArray*)allFavourTVChannels
{
    if(!_allFavourTVChannels)
    {
        _allFavourTVChannels = [NSMutableArray array];
        _allFavourTVChannels = [TVChannel getAllChannelForFavoritedForType:@"TV"];
    }
    return _allFavourTVChannels;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"电视";
    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
    
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume start:device];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if ([self.sceneid intValue]>0) {
        
        Scene *scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        for(int i=0;i<[scene.devices count];i++)
        {
            if ([[scene.devices objectAtIndex:i] isKindOfClass:[TV class]]) {
                self.volume.value=((TV*)[scene.devices objectAtIndex:i]).volume/100.0;
            }
        }
    }
    [self setUpPageController];

}


-(IBAction)save:(id)sender
{
    TV *device=[[TV alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setVolume:self.volume.value*100];
    
    Scene *scene=[[Scene alloc] init];
    [scene setSceneID:[self.sceneid intValue]];
    [scene setRoomID:4];
    [scene setHouseID:3];
    [scene setPicID:66];
    [scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:scene withDeivce:device id:device.deviceID];
    [scene setDevices:devices];
    [[SceneManager defaultManager] addScenen:scene withName:@"" withPic:@""];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
}


- (IBAction)mute:(id)sender {
    self.volume.value=0.0;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"volume"])
    {
        DeviceInfo *device=[DeviceInfo defaultManager];
        self.volume.value=[[device valueForKey:@"volume"] floatValue];
        [self save:nil];
    }
}
//设置pageController
-(void)setUpPageController
{
    self.pageController.numberOfPages = [self.tvLogoCollectionView numberOfItemsInSection:0] / 4;
    self.pageController.pageIndicatorTintColor = [UIColor whiteColor];
    self.pageController.currentPageIndicatorTintColor = [UIColor blackColor];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint point = scrollView.contentOffset;
    self.pageController.currentPage = round(point.x/scrollView.bounds.size.width);
}

#pragma mark - UICollectionViewDelgate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(collectionView == self.tvLogoCollectionView)
    {
        if(self.allFavourTVChannels.count % 4 == 0)
        {
            return self.allFavourTVChannels.count;
        }else{
            int i = 4 - self.allFavourTVChannels.count % 4;
            return  self.allFavourTVChannels.count + i;

        }
    }
    return self.btnTitles.count + 1;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView  == self.tvLogoCollectionView)
    {
        TVLogoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tvLogoCell" forIndexPath:indexPath];
        cell.delegate = self;
        [cell hiddenEditBtnAndDeleteBtn];
        if(indexPath.row > self.allFavourTVChannels.count -1)
        {
            cell.imgView.image = [UIImage imageNamed:@""];
            [cell unUseLongPressGesture];
        }else{
            TVChannel *channel = self.allFavourTVChannels[indexPath.row];
            cell.imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",channel.channel_pic]];
            [cell useLongPressGesture];
            
            
        }
        
        return cell;
        
    }
    DVCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    if(indexPath.row == self.btnTitles.count)
    {
        [cell.btn setImage:[UIImage imageNamed:@"quiet"] forState:UIControlStateNormal];
        
    }else{
        [cell.btn setTitle:[NSString stringWithFormat:@"%@",self.btnTitles[indexPath.row]] forState:UIControlStateNormal];
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == self.tvLogoCollectionView)
    {
        TVLogoCell *cell =(TVLogoCell*)[collectionView cellForItemAtIndexPath:indexPath];
        [cell hiddenEditBtnAndDeleteBtn];
        [cell unUseLongPressGesture];
    }
}

#pragma mark -- TVLogoCellDelegate
-(void)tvDeleteAction:(TVLogoCell *)cell
{
    
    self.cell = cell;
    NSIndexPath *indexPath = [self.tvLogoCollectionView indexPathForCell:cell];
    TVChannel *channel = self.allFavourTVChannels[indexPath.row];
    BOOL isSuccess = [TVChannel deleteChannelForChannelID:channel.channel_id];
    if(!isSuccess)
    {
        [MBProgressHUD showError:@"删除失败，请稍后再试"];
        return;
    }
    [self.allFavourTVChannels removeObject:channel];
    [self.tvLogoCollectionView reloadData];
    
}
-(void)tvEditAction:(TVLogoCell *)cell
{
    NSIndexPath *indexPath = [self.tvLogoCollectionView indexPathForCell:cell];
    TVChannel *channel = self.allFavourTVChannels[indexPath.row];
    [self.editChannelImgBtn setBackgroundImage:cell.imgView.image forState:UIControlStateNormal];
    self.channelName.text = channel.channel_name;
    self.channeID.text = [NSString stringWithFormat:@"%ld",channel.channel_id];
    [self showCoverView];
}

-(void)showCoverView
{
    self.coverView.hidden = NO;
    self.editView.hidden = NO;
}
-(void)hiddenCoverView{
    self.coverView.hidden = YES;
    self.editView.hidden = YES;
}

#pragma mark -编辑电视频道
//编辑完成后上传频道
- (IBAction)clickSureBtnAfterEdited:(id)sender {
    [self hiddenCoverView];
    
}
- (IBAction)cancelEdit:(id)sender {
    [self hiddenCoverView];
   
    
}




- (IBAction)editChannelImgBtn:(UIButton *)sender {
    UIButton *btn = sender;
    UIView *view = btn.superview;
    CGFloat y = view.frame.origin.y -(view.frame.size.width - btn.frame.size.width);
    [KxMenu showMenuInView:self.view fromRect:CGRectMake(view.frame.origin.x, y , view.frame.size.width, view.frame.size.height) menuItems:@[
                                                                      [KxMenuItem menuItem:@"预置台标"
                                                                                     image:nil
                                                                                    target:self
                                                                                    action:@selector(preset:)],
                                                                      [KxMenuItem menuItem:@"本地图库"
                                                                                     image:nil
                                                                                    target:self
                                                                                    action:@selector(selectPhoto:)],
                                                                      [KxMenuItem menuItem:@"现在拍摄"
                                                                                     image:nil
                                                                                    target:self
                                                                                    action:@selector(takePhoto:)],
                                                                      ]];

                                                                      
                                        
    
}
-(void)preset:(KxMenuItem *)item{
    
}
- (void)selectPhoto:(KxMenuItem *)item {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)takePhoto:(KxMenuItem *)item {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *chooseImg = info[UIImagePickerControllerEditedImage];
    [self.editChannelImgBtn setBackgroundImage:chooseImg forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc
{
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device removeObserver:self forKeyPath:@"volume" context:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
