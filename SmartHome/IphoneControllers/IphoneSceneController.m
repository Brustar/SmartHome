//
//  IphoneSceneController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/19.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneSceneController.h"
#import "RoomManager.h"
#import "Room.h"
#import "SceneCell.h"
#import "SQLManager.h"
#import "Scene.h"
#import "IphoneRoomView.h"
#import "UIImageView+WebCache.h"

#define cellWidth self.collectionView.frame.size.width / 2.0 - 10
#define  minSpace 20
@interface IphoneSceneController ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,IphoneRoomViewDelegate>
@property (strong, nonatomic) IBOutlet IphoneRoomView *roomView;


@property (nonatomic,strong) NSArray *roomList;
@property (nonatomic,strong) UIButton *selectedRoomBtn;
@property (nonatomic,strong) NSArray *scenes;
@property (nonatomic, assign) int roomIndex;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation IphoneSceneController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.roomList = [SQLManager getAllRoomsInfo];
    
    [self setUpRoomView];
}

-(void)setUpRoomView
{
    NSMutableArray *roomNames = [NSMutableArray array];
    
    for (Room *room in self.roomList) {
        NSString *roomName = room.rName;
        [roomNames addObject:roomName];
    }
    self.roomView.dataArray = roomNames;
    
    self.roomView.delegate = self;
    
    [self.roomView setSelectButton:0];
    
    [self iphoneRoomView:self.roomView didSelectButton:0];
}

- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index
{
    self.roomIndex = index;
    Room *room = self.roomList[index];
    self.scenes = [SQLManager getScensByRoomId:room.rId];
    [self.collectionView reloadData];
    
}


#pragma  mark - UICollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.scenes.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SceneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    Scene *scene = self.scenes[indexPath.row];
    cell.scenseName.text = scene.sceneName;
    
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString: scene.picName] placeholderImage:[UIImage imageNamed:@"placeholder"]];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(cellWidth, cellWidth );
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
    return minSpace;
}






@end
