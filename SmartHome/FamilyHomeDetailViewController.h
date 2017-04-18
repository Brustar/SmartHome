//
//  FamilyHomeDetailViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/18.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "CustomViewController.h"
#import "FamilyHomeDetailSceneCell.h"
#import "SQLManager.h"
#import "UIButton+WebCache.h"
#import "LightCell.h"
#import "AireTableViewCell.h"
#import "CurtainTableViewCell.h"
#import "TVTableViewCell.h"
#import "OtherTableViewCell.h"
#import "ScreenTableViewCell.h"
#import "DVDTableViewCell.h"
#import "ScreenCurtainCell.h"
#import "BjMusicTableViewCell.h"

#define SceneCellWidth  (self.sceneListCollectionView.frame.size.width-6.0)/3
#define SceneCellHeight  self.sceneListCollectionView.frame.size.height
#define CollectionCellSpace 0.0
#define minimumLineSpacing 3.0


@interface FamilyHomeDetailViewController : CustomViewController<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *softButton;
@property (weak, nonatomic) IBOutlet UIButton *normalButton;
@property (weak, nonatomic) IBOutlet UIButton *brightButton;
@property (weak, nonatomic) IBOutlet UICollectionView *sceneListCollectionView;

@property (nonatomic, assign) NSInteger roomID;
@property (nonatomic, strong) NSString *roomName;

@property (nonatomic, strong) NSMutableArray *sceneArray;//房间的所有场景

- (IBAction)softBtnClicked:(id)sender;
- (IBAction)normalBtnClicked:(id)sender;
- (IBAction)brightBtnClicked:(id)sender;


@end
