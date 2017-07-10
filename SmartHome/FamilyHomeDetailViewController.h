//
//  FamilyHomeDetailViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/18.
//  Copyright © 2017年 Ecloud. All rights reserved.
//

#import "CustomViewController.h"
#import "FamilyHomeDetailSceneCell.h"
#import "SQLManager.h"
#import "UIButton+WebCache.h"
#import "NewLightCell.h"
#import "NewColourCell.h"
#import "FMTableViewCell.h"
#import "AireTableViewCell.h"
#import "CurtainTableViewCell.h"
#import "TVTableViewCell.h"
#import "OtherTableViewCell.h"
#import "ScreenTableViewCell.h"
#import "DVDTableViewCell.h"
#import "ScreenCurtainCell.h"
#import "BjMusicTableViewCell.h"
#import "SceneManager.h"
#import "IphoneEditSceneController.h"
#import "SceneManager.h"
#import "HttpManager.h"
#import "IpadDeviceListViewController.h"
#import "IpadDVDTableViewCell.h"
#import "IpadTVCell.h"
#import "PowerLightCell.h"
#import "LoadMaskHelper.h"

#define SceneCellWidth  (self.sceneListCollectionView.frame.size.width-6.0)/3
#define SceneCellHeight  self.sceneListCollectionView.frame.size.height
#define iPadSceneCellWidth  self.sceneListCollectionView.frame.size.width

#define iPadSceneCellHeight  self.sceneListCollectionView.frame.size.width

#define CollectionCellSpace 0.0
#define minimumLineSpacing 3.0


@interface FamilyHomeDetailViewController : CustomViewController<UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate,UITableViewDataSource, HttpDelegate, SingleMaskViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *softButton;
@property (weak, nonatomic) IBOutlet UIButton *normalButton;
@property (weak, nonatomic) IBOutlet UIButton *brightButton;
@property (weak, nonatomic) IBOutlet UICollectionView *sceneListCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *deviceTableView;

@property (nonatomic, assign) NSInteger roomID;
@property (nonatomic, strong) NSString *roomName;

@property (nonatomic, strong) NSMutableArray *sceneArray;//房间的所有场景
@property (nonatomic, strong) NSMutableArray *deviceIDArray;//该房间的所有设备ID
@property (nonatomic,strong) NSMutableArray * lightArray;//灯光(存储的是设备id)
@property (nonatomic,strong) NSMutableArray * curtainArray;//窗帘
@property (nonatomic,strong) NSMutableArray * environmentArray;//环境
@property (nonatomic,strong) NSMutableArray * multiMediaArray;//影音
@property (nonatomic,strong) NSMutableArray * intelligentArray;//智能单品
@property (nonatomic,strong) NSMutableArray * securityArray;//安防
@property (nonatomic,strong) NSMutableArray * sensorArray;//感应器
@property (nonatomic,strong) NSMutableArray * otherTypeArray;//其他
@property (nonatomic,strong) NSMutableArray * colourLightArr;//调色
@property (nonatomic,strong) NSMutableArray * switchLightArr;//开关
@property (nonatomic,strong) NSMutableArray * lightArr;//调光

@property (nonatomic,assign) NSInteger deviceType_count;//设备种类数量
@property (nonatomic, assign) BOOL isGloom;
@property (nonatomic, assign) BOOL isRomantic;
@property (nonatomic, assign) BOOL isSprightly;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTop;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewFlowLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *softBtnLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *softBtnWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *normalBtnLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *normalBtnWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *brightBtnLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *brightBtnWidth;


- (IBAction)softBtnClicked:(id)sender;
- (IBAction)normalBtnClicked:(id)sender;
- (IBAction)brightBtnClicked:(id)sender;


@end
