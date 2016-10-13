//
//  IphoneSceneController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/19.
//  Copyright © 2016年 Brustar. All rights reserved.
//


#define cellWidth self.collectionView.frame.size.width / 2.0 - 10
#define  minSpace 20

#import "IphoneSceneController.h"
#import "RoomManager.h"
#import "Room.h"
#import "SceneCell.h"
#import "SQLManager.h"
#import "Scene.h"
#import "IphoneRoomView.h"
#import "UIImageView+WebCache.h"
#import "SceneManager.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"



@interface IphoneSceneController ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,IphoneRoomViewDelegate,SceneCellDelegate>
@property (strong, nonatomic) IBOutlet IphoneRoomView *roomView;


@property (nonatomic,strong) NSArray *roomList;
@property (nonatomic,strong) UIButton *selectedRoomBtn;
@property (nonatomic,strong) NSArray *scenes;
@property (nonatomic, assign) int roomIndex;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,assign) int selectedSId;
@property (nonatomic ,strong) SceneCell *cell;

@end

@implementation IphoneSceneController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.roomList = [SQLManager getAllRoomsInfo];
    self.title = @"场景";
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
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    Room *room = self.roomList[self.roomIndex];
    self.scenes = [SQLManager getScensByRoomId:room.rId];
    [self.collectionView reloadData];

}


#pragma  mark - UICollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.scenes.count + 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SceneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    
    cell.layer.cornerRadius = 20;
    cell.layer.masksToBounds = YES;
    if(indexPath.row == self.scenes.count)
    {
        cell.scenseName.text = @"添加场景";
    }else{
        Scene *scene = self.scenes[indexPath.row];
        cell.tag = scene.sceneID;
        cell.scenseName.text = scene.sceneName;
        cell.delegate = self;
        [cell useLongPressGesture];
    }
    

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == self.scenes.count)
    {
        [self performSegueWithIdentifier:@"iphoneAddSceneSegue" sender:self];
    }else{
        Scene *scene = self.scenes[indexPath.row];
        self.selectedSId = scene.sceneID;
        SceneCell *cell = (SceneCell*)[collectionView cellForItemAtIndexPath:indexPath];
        
        [cell useLongPressGesture];
        if(cell.deleteBtn.hidden)
        {
            [self performSegueWithIdentifier:@"iphoneEditSegue" sender:self];
            [[SceneManager defaultManager] startScene:scene.sceneID];

        }else{
            cell.deleteBtn.hidden = YES;
        }
    }
    
}
//删除场景
-(void)sceneDeleteAction:(SceneCell *)cell
{
    self.cell = cell;
    cell.deleteBtn.hidden = YES;
    
    [SQLManager deleteScene:(int)cell.tag];
    Scene *scene = [[SceneManager defaultManager] readSceneByID:(int)cell.tag];
    [[SceneManager defaultManager] delScene:scene];
    
    NSString *url = [NSString stringWithFormat:@"%@SceneDelete.aspx",[IOManager httpAddr]];
    NSDictionary *dict = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"SID":[NSNumber numberWithInt:scene.sceneID]};
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    http.tag = 1;
    [http sendPost:url param:dict];
}

-(void)httpHandler:(id) responseObject tag:(int)tag
{
    if((tag = 1))
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
           
            [MBProgressHUD showSuccess:@"场景删除成功"];
            Room *room = self.roomList[self.roomIndex];
            self.scenes = [SQLManager getScensByRoomId:room.rId];
            [self.collectionView reloadData];
           
            
            
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
        
        
    }
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(cellWidth, 80 );
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

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Room *room = self.roomList[self.roomIndex];
    if([segue.identifier isEqualToString:@"iphoneAddSceneSegue"])
    {
        [IOManager removeTempFile];

        id theSegue = segue.destinationViewController;
        [theSegue setValue:[NSNumber numberWithInt:room.rId] forKey:@"roomId"];
    }else if([segue.identifier isEqualToString:@"iphoneEditSegue"]){
        id theSegue = segue.destinationViewController;
        
        [theSegue setValue:[NSNumber numberWithInt:self.selectedSId] forKey:@"sceneID"];
        [theSegue setValue:[NSNumber numberWithInt:room.rId] forKey:@"roomID"];
    }
    
}




@end
