//
//  FamilyHomeDetailViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/18.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "FamilyHomeDetailViewController.h"

@interface FamilyHomeDetailViewController ()

@end

@implementation FamilyHomeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.softButton setBackgroundImage:[UIImage imageNamed:@"btn_pressed"] forState:UIControlStateSelected];
    [self.normalButton setBackgroundImage:[UIImage imageNamed:@"btn_pressed"] forState:UIControlStateSelected];
    [self.brightButton setBackgroundImage:[UIImage imageNamed:@"btn_pressed"] forState:UIControlStateSelected];
    [self setNaviBarTitle:self.roomName];
    
    [self getAllScenes];
}

- (void)getAllScenes {
    NSArray *sceneArray = [SQLManager getAllSceneWithRoomID:(int)self.roomID];
    _sceneArray = [NSMutableArray array];
    if (sceneArray) {
        [_sceneArray addObjectsFromArray:sceneArray];
    }
    
    [self.sceneListCollectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)softBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        btn.selected = NO;
    }else {
        btn.selected = YES;
        self.normalButton.selected = NO;
        self.brightButton.selected = NO;
    }
}

- (IBAction)normalBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        btn.selected = NO;
    }else {
        btn.selected = YES;
        self.softButton.selected = NO;
        self.brightButton.selected = NO;
    }
}

- (IBAction)brightBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        btn.selected = NO;
    }else {
        btn.selected = YES;
        self.softButton.selected = NO;
        self.normalButton.selected = NO;
    }
}

#pragma  mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.sceneArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FamilyHomeDetailSceneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"familySceneCell" forIndexPath:indexPath];
    
    Scene *scene = self.sceneArray[indexPath.row];
    [cell.sceneButton sd_setBackgroundImageWithURL:[NSURL URLWithString:scene.picName] forState:UIControlStateNormal];
    [cell.sceneButton setTitle:scene.sceneName forState:UIControlStateNormal];
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    
    
    /*UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
    FamilyHomeDetailViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"familyHomeDetailVC"];
    RoomStatus *roomInfo = self.roomArray[indexPath.row];
    vc.roomID = roomInfo.roomId;
    vc.roomName = roomInfo.roomName;
    [self.navigationController pushViewController:vc animated:YES];*/
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(SceneCellWidth, SceneCellHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return CollectionCellSpace;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return minimumLineSpacing;
}

@end
