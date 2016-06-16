//
//  DVDController.m
//  SmartHome
//
//  Created by Brustar on 16/6/7.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DVDController.h"
#import "DetailViewController.h"
#import "DVD.h"
#import "SceneManager.h"
#import "DVCollectionViewCell.h"

#define size 437
@interface DVDController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UISlider *volume;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewHight;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic,strong) NSArray *dvImages;

@end

@implementation DVDController

-(NSArray *)dvImages
{
    if(!_dvImages)
    {
        _dvImages = @[@"rewind",@"broadcast",@"fastForward",@"last",@"pause",@"next",@"stop",@"up",@"house"];
    }
    return _dvImages;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Do any additional setup after loading the view.
    self.title = @"DVD";
    
    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
    
    self.beacon=[[IBeacon alloc] init];
    [self.beacon addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume start:self.beacon];
    
   }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    self.rightViewHight.constant = size;
    self.rightViewWidth.constant = size;
}

-(IBAction)save:(id)sender
{
    DVD *device=[[DVD alloc] init];
    [device setDeviceID:4];
    [device setVolume:self.volume.value*100];
    
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

#pragma mark - UICollectionViewDelegate
-(NSInteger )collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 9;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *collectionCellID = @"collectionCell";
    DVCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellID forIndexPath:indexPath];

    NSString *imageName = [NSString stringWithFormat:@"%@",self.dvImages[indexPath.row]];
    [cell.btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    return cell;
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
