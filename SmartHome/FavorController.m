//
//  FavorController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/31.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "FavorController.h"
#import "Scene.h"
#import "SceneCell.h"
#import "SQLManager.h"
#import "UIImageView+WebCache.h"


@interface FavorController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSArray *scens;
@property (nonatomic,assign )int selectID;
@end

@implementation FavorController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"我的收藏";
    self.splitViewController.presentsWithGesture = NO;
   
    }
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
     self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
    self.scens = [SQLManager getFavorScene];
    [self.collectionView reloadData];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    cell.scenseName.text = scene.sceneName;
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString: scene.picName] placeholderImage:[UIImage imageNamed:@"PL"]];
    
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
    Scene *scene = self.scens[indexPath.row];
    self.selectID = scene.sceneID;
    [self performSegueWithIdentifier:@"favorSegue" sender:self];
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
        id theSegue = segue.destinationViewController;
        
        [theSegue setValue:[NSNumber numberWithInt:self.selectID] forKey:@"sceneID"];
        [theSegue setValue:@"YES" forKey:@"isFavor"];
//        [theSegue setValue:[NSNumber numberWithInt:self.roomID] forKey:@"roomID"];
    
        
    
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
