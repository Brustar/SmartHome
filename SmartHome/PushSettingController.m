//
//  PushSettingController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "PushSettingController.h"

@interface PushSettingController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *sectionTitles;
@property (weak, nonatomic) IBOutlet UIView *coverView;

@property (weak, nonatomic) IBOutlet UIView *pushTypeView;
@property (nonatomic,strong) UIButton *selectedBtn;
- (IBAction)selectPsuhTypeBtn:(UIButton *)sender;
@property(nonatomic,strong) NSIndexPath *indexPath;

@end

@implementation PushSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.coverView.hidden = YES;
    self.pushTypeView.hidden = YES;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
        return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(section == 0 || section == 2)
    {
        return 4;
    }else if(section == 1)
    {
        return 6;
    }else {
        return 1;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
       UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pushSettingCell" forIndexPath:indexPath];
    NSString *str;
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                    str = @"陌生人开门";
                    break;
                case 1:
                    str = @"侵入主卧";
                    break;
                case 2:
                    str = @"侵入窗户";
                    break;
                case 3:
                    str = @"侵入阳台";
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
            {
                switch (indexPath.row) {
                    case 0:
                        str = @"温度报警";
                        break;
                    case 1:
                        str = @"漏水";
                        break;
                    case 2:
                        str = @"漏电";
                        break;
                    case 3:
                        str = @"漏气";
                        break;
                    case 4:
                        str = @"中控主机断电";
                        break;

                    case 5:
                        str = @"成员长时间静止某处，需急救状态";
                        break;

                    default:
                        break;
                }
            }
            break;

            case 2:
                {
                    switch (indexPath.row) {
                        case 0:
                            str = @"噪音告警";
                            break;
                        case 1:
                            str = @"推荐新品";
                            break;
                        case 2:
                            str = @"推荐场景";
                            break;
                        case 3:
                            str = @"pm2.5告警";
                            break;
                        default:
                            break;
 
                    }
                }
            break;
            
            
        default:str = @"小朋友回家";
            break;
    }
    cell.textLabel.text = str;
    return cell;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor colorWithRed:241/255.0 green:240/255.0 blue:246/255.0 alpha:1];
        UILabel *titleLabe = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 200, 50)];
        titleLabe.textColor = [UIColor grayColor];
        titleLabe.font = [UIFont systemFontOfSize:18];
        [view addSubview:titleLabe];
        NSString *titleStr;
        if(section == 0)
        {
            titleStr = @"侵入";
        }else if(section == 1)
        {
            titleStr =@"安全";
        }else if(section == 2)
        {
            titleStr = @"普通";
        }else titleStr = @"位置";
        titleLabe.text = titleStr;
        return view;

}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 50;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.indexPath = indexPath;
    self.coverView.hidden = NO;
    self.pushTypeView.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


- (IBAction)selectPsuhTypeBtn:(UIButton *)sender {
    
        self.selectedBtn.selected = NO;
        [self.selectedBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        sender.selected = YES;
        self.selectedBtn = sender;
        [self.selectedBtn setImage:[UIImage imageNamed:@"correct"] forState:UIControlStateSelected];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPath];
        if(sender.tag == 0)
        {
            cell.detailTextLabel.text = @"短信";
        }else if(sender.tag == 1)
        {
            cell.detailTextLabel.text = @"App推送";
        }else{
            cell.detailTextLabel.text = @"不推送";
        }
    
}
- (IBAction)clickSureBtn:(id)sender {
    self.coverView.hidden = YES;
    self.pushTypeView.hidden = YES;
}


- (IBAction)clickRetunBtn:(id)sender {
    [self.view removeFromSuperview];
}



@end
