//
//  IphoneFavorController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/10/12.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#define cellWidth self.collectionView.frame.size.width / 2.0 - 10
#define  minSpace 20


#import "IphoneFavorController.h"
#import "SQLManager.h"
#import "SceneCell.h"
#import "SceneManager.h"
#import "UIImageView+WebCache.h"


@interface IphoneFavorController ()<UICollectionViewDelegate,UICollectionViewDataSource,SceneCellDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSArray *scens;
@property (nonatomic,assign )int selectID;
@end

@implementation IphoneFavorController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"我的收藏";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
   
    self.scens = [SQLManager getFavorScene];
    [self.collectionView reloadData];
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.scens.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    SceneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    Scene *scene = self.scens[indexPath.row];
    cell.tag = scene.sceneID;
    cell.scenseName.text = scene.sceneName;
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString: scene.picName] placeholderImage:[UIImage imageNamed:@"PL"]];
    
    cell.delegate = self;
    [cell useLongPressGesture];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    Scene *scene = self.scens[indexPath.row];
    
    self.selectID = scene.sceneID;
    SceneCell *cell = (SceneCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [cell useLongPressGesture];
    if(cell.deleteBtn.hidden)
    {
        [self performSegueWithIdentifier:@"editSceneSegue" sender:self];
    }else{
        cell.deleteBtn.hidden = YES;
    }
    
    
}

-(void)sceneDeleteAction:(SceneCell *)cell
{
    Scene *scene = [[SceneManager defaultManager] readSceneByID:(int)cell.tag];
    [[SceneManager defaultManager] deleteFavoriteScene:scene withName:scene.sceneName];
    self.scens = [SQLManager getFavorScene];
    [self.collectionView reloadData];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(cellWidth, 130);
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id theSegue = segue.destinationViewController;
    
    [theSegue setValue:[NSNumber numberWithInt:self.selectID] forKey:@"sceneID"];
    [theSegue setValue:@"YES" forKey:@"isFavor"];
}

@end
