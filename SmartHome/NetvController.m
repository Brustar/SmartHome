//
//  NetvController.m
//  SmartHome
//
//  Created by Brustar on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "NetvController.h"
#import "Netv.h"
#import "DetailViewController.h"
#import "SceneManager.h"
#import "DVCollectionViewCell.h"

@interface NetvController ()<UICollectionViewDelegate,UICollectionViewDataSource>


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *netTvRightViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *netTvRightViewWidth;
@property (nonatomic,strong) NSArray  *netTVImages;

@end

@implementation NetvController

-(NSArray *)netTVImages
{
    if(!_netTVImages)
    {
        _netTVImages =  @[@"rewind",@"broadcast",@"fastForward",@"last",@"pause",@"next",@"stop",@"left",@"house",@"quiet"];
    }
    return _netTVImages;
}


-(void)updateViewConstraints
{
    [super updateViewConstraints];
    self.netTvRightViewWidth.constant = 400;
    self.netTvRightViewHeight.constant = self.netTvRightViewWidth.constant;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"机顶盒";
    
    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
    
    self.beacon=[[IBeacon alloc] init];
    [self.beacon addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume start:self.beacon];
    if ([self.sceneid intValue]>0) {
        
        Scene *scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        for(int i=0;i<[scene.devices count];i++)
        {
            if ([[scene.devices objectAtIndex:i] isKindOfClass:[Netv class]]) {
                self.volume.value=((Netv*)[scene.devices objectAtIndex:i]).nvolume/100.0;
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)save:(id)sender
{
    Netv *device=[[Netv alloc] init];
    [device setDeviceID:5];
    [device setNvolume:self.volume.value*100];
    
    Scene *scene=[[Scene alloc] init];
    [scene setSceneID:2];
    [scene setRoomID:4];
    [scene setHouseID:3];
    [scene setPicID:66];
    [scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:scene withDeivce:device id:device.deviceID];
    [scene setDevices:devices];
    [[SceneManager defaultManager] addScenen:scene withName:@"" withPic:@""];
}

- (IBAction)detail:(id)sender {
    DetailViewController *detailVC = [[DetailViewController alloc]init];
    detailVC.deviceID = 4;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"volume"])
    {
        self.volume.value=[[self.beacon valueForKey:@"volume"] floatValue];
    }
}




#pragma mark - UICollectionDelegate
-(NSInteger )collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *collectionCellID = @"collectionCell";
    DVCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellID forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[DVCollectionViewCell alloc]init];
    }
    NSString *imageName = [NSString stringWithFormat:@"%@",self.netTVImages[indexPath.row]];
    [cell.btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    return cell;
}

-(void)dealloc
{
    [self.beacon removeObserver:self forKeyPath:@"volume" context:nil];
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
