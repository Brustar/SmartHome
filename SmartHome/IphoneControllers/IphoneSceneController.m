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
#import "ScenseCell.h"
#import "SceneManager.h"
#import "Scene.h"
#import "UIImageView+WebCache.h"

#define cellWidth self.collectionView.frame.size.width / 2.0 - 10
#define  minSpace 20
@interface IphoneSceneController ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollerView;
@property (nonatomic,strong) NSArray *roomList;
@property (nonatomic,strong) UIButton *selectedRoomBtn;
@property (nonatomic,strong) NSArray *scenes;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation IphoneSceneController

-(NSArray *)scenes
{
    if(!_scenes)
    {
        _scenes = [SceneManager getScensByRoomId:(int)self.selectedRoomBtn.tag];
    }
    return _scenes;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.roomList = [RoomManager getAllRoomsInfo];
    
    [self setUpScrollerView];
}

-(void)setUpScrollerView
{
    self.scrollerView.delegate = self;
    self.scrollerView.bounces= NO;
    self.scrollerView.showsHorizontalScrollIndicator = NO;
    self.scrollerView.showsVerticalScrollIndicator = NO;
    self.scrollerView.backgroundColor = [UIColor lightGrayColor];
    CGFloat widthBtn;
    if(self.roomList.count > 4)
    {
        widthBtn = self.scrollerView.frame.size.width / 4.0;
    }else{
        widthBtn = self.scrollerView.frame.size.width / self.roomList.count;
    }
    
    for(int i = 0 ; i < self.roomList.count; i++)
    {
        UIButton *button =  [[UIButton alloc]init];
        button.frame = CGRectMake(widthBtn * i, 0, widthBtn, self.scrollerView.frame.size.height);
        Room *room = self.roomList[i];
        button.tag = room.rId;
        [button setTitle:room.rName forState:UIControlStateNormal];
                [button addTarget:self action:@selector(selectedRoom:) forControlEvents:UIControlEventTouchUpInside];
        if(i == 0)
        {
            button.selected = YES;
            [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            self.selectedRoomBtn = button;
        }
        [self.scrollerView addSubview:button];
    }
    
    self.scrollerView.contentSize = CGSizeMake(widthBtn * self.roomList.count, self.scrollerView.bounds.size.height);
}

-(void)selectedRoom:(UIButton *)btn
{
    self.selectedRoomBtn.selected = NO;
    btn.selected = YES;
    self.selectedRoomBtn = btn;
    [self.selectedRoomBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    self.scenes = [SceneManager getScensByRoomId:(int)btn.tag];
    [self.collectionView reloadData];

}
#pragma  mark - UICollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.scenes.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ScenseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
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

- (IBAction)goToMainController:(id)sender {
    

}




@end
