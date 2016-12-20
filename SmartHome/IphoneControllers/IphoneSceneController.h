//
//  IphoneSceneController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/9/19.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IphoneSceneController : UIViewController

@property (nonatomic,strong) NSString * shortcutName;
@property (nonatomic,strong) Scene *scene;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end
