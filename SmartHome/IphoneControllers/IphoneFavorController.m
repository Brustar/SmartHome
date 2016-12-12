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
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"


@interface IphoneFavorController ()<UICollectionViewDelegate,UICollectionViewDataSource,SceneCellDelegate>
@property (weak, nonatomic)  IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSArray *scens;
@property (nonatomic,assign) int selectID;
@property (nonatomic,strong) NSMutableArray * image_urlArrs;
@property (nonatomic,strong) NSMutableArray * nameArrs;
@property (nonatomic,strong) NSMutableArray * scence_idArrs;
@end

@implementation IphoneFavorController
-(NSMutableArray *)scence_idArrs
{
    if (!_scence_idArrs) {
        _scence_idArrs = [NSMutableArray array];
    }

    return _scence_idArrs;
}
-(NSMutableArray *)nameArrs
{
    if (!_nameArrs) {
        _nameArrs = [NSMutableArray array];
    }

    return _nameArrs;
}

-(NSMutableArray *)image_urlArrs
{
    if (!_image_urlArrs) {
        _image_urlArrs = [NSMutableArray array];
    }

    return _image_urlArrs;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"我的收藏";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
//     [self sendRequest];
    self.scens = [SQLManager getFavorScene];
    [self.collectionView reloadData];
  
}
//获得所有设置请求
-(void)sendRequest
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/store_scene.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
        NSDictionary *dict = @{@"token":auothorToken,@"optype":[NSNumber numberWithInt:0]};
        HttpManager *http=[HttpManager defaultManager];
        http.tag = 1;
        http.delegate = self;
        [http sendPost:url param:dict];
    }
}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    NSMutableArray * nameArr = [NSMutableArray array];
    NSMutableArray * image_urlArr = [NSMutableArray array];
    NSMutableArray * scence_idArr = [NSMutableArray array];
    if(tag == 1)
    {
        if ([responseObject[@"result"] intValue]==0){
            NSArray *messageInfo = responseObject[@"store_scence_list"];
            for (NSDictionary * dic in messageInfo) {
                [nameArr addObject:dic[@"name"]];
                [image_urlArr addObject:dic[@"image_url"]];
                [scence_idArr addObject:dic[@"scence_id"]];
            }
            
            [self.nameArrs addObjectsFromArray:nameArr];
            [self.image_urlArrs addObjectsFromArray:image_urlArr];
            [self.scence_idArrs addObjectsFromArray:scence_idArr];
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
            
        }
    }
    
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.scens.count;
//    return self.nameArrs.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    SceneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    Scene *scene = self.scens[indexPath.row];
    cell.tag = scene.sceneID;
    cell.scenseName.text = scene.sceneName;
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString: scene.picName] placeholderImage:[UIImage imageNamed:@"PL"]];
    
//    cell.tag = (int)self.scence_idArrs[indexPath.row];
//    cell.scenseName.text = self.nameArrs[indexPath.row];
//    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self.image_urlArrs[indexPath.row]] placeholderImage:[UIImage imageNamed:@"PL"]];
    cell.delegate = self;
    [cell useLongPressGesture];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Scene *scene = self.scens[indexPath.row];
    self.selectID = scene.sceneID;
//    self.selectID = (int)self.scence_idArrs[indexPath.row];
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
