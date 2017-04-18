//
//  FamilyHomeDetailSceneCell.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/18.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FamilyHomeDetailSceneCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *sceneButton;

- (IBAction)sceneBtnClicked:(id)sender;
@end
