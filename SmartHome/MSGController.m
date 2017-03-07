//
//  MSGController.m
//  SmartHome
//
//  Created by Brustar on 16/7/4.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "MSGController.h"
#import "MsgCell.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "DetailMSGViewController.h"


@interface MSGController ()<HttpDelegate>
@property (nonatomic,strong) NSMutableArray * itemIdArrs;
@property (nonatomic,strong) NSMutableArray * actcodeArrs;
@property (nonatomic,strong) NSMutableArray * itemNameArrs;
@property (nonatomic,strong) NSMutableArray * unreadcountArr;
@property (weak, nonatomic) IBOutlet UIView *footView;
@property (nonatomic,assign) NSInteger unreadcount;
@property (nonatomic,strong) NSString * type;

@end

@implementation MSGController

-(NSMutableArray *)unreadcountArr
{
    if (!_unreadcountArr) {
        _unreadcountArr = [NSMutableArray array];
    }

    return _unreadcountArr;
}

- (NSMutableArray *)actcodeArrs
{
    if (!_actcodeArrs) {
        _actcodeArrs = [NSMutableArray array];
    }
    return _actcodeArrs;
}

-(NSMutableArray *)itemIdArrs
{
    if (!_itemIdArrs) {
        _itemIdArrs = [NSMutableArray array];
    }

    return _itemIdArrs;
}
-(NSMutableArray *)itemNameArrs
{
    if (!_itemNameArrs) {
        _itemNameArrs = [NSMutableArray array];
    }

    return _itemNameArrs;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
     DeviceInfo *device = [DeviceInfo defaultManager];
    if ([device.db isEqualToString:SMART_DB]) {
        [self.itemIdArrs removeAllObjects];
        [self.itemNameArrs removeAllObjects];
        [self.unreadcountArr removeAllObjects];
        [self creatItemID];
    }

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [MBProgressHUD hideHUD];
    self.title = @"我的消息";
    
    DeviceInfo *device = [DeviceInfo defaultManager];
    if ([device.db isEqualToString:SMART_DB]) {
//        [self creatItemID];
    }else {
        NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"msgTypeList" ofType:@"plist"]];
        NSArray *arr = plistDict[@"notify_type_list"];
        if ([arr isKindOfClass:[NSArray class]]) {
            for(NSDictionary *dicDetail in arr)
            {
                [self.itemIdArrs addObject:dicDetail[@"item_id"]];
                [self.actcodeArrs addObject:dicDetail[@"actcode"]];
                [self.itemNameArrs addObject:dicDetail[@"item_name"]];
                [self.unreadcountArr addObject:dicDetail[@"unreadcount"]];
            }
        }
        [self.tableView reloadData];
    }
    
}
-(void)creatItemID
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/notify.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
        NSDictionary *dict = @{@"token":auothorToken,@"optype":[NSNumber numberWithInteger:2]};
        HttpManager *http=[HttpManager defaultManager];
        http.tag = 1;
        http.delegate = self;
        [http sendPost:url param:dict];
    }
}

-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if ([responseObject[@"result"] intValue]==0)
        {
            
            NSArray *dic = responseObject[@"notify_type_list"];
            
            if ([dic isKindOfClass:[NSArray class]]) {
                for(NSDictionary *dicDetail in dic)
                {
                    [self.itemIdArrs addObject:dicDetail[@"item_id"]];
                    [self.itemNameArrs addObject:dicDetail[@"item_name"]];
                    [self.unreadcountArr addObject:dicDetail[@"unreadcount"]];
                }
            }
            
            [self.tableView reloadData];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source


//每组有多少cell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
 return self.itemIdArrs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"msgCell";
    MsgCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.title.text = self.itemNameArrs[indexPath.row];
    if (cell.countLabel.text) {
        cell.countLabel.text = [NSString stringWithFormat:@"%ld",(long)[self.unreadcountArr[indexPath.row] integerValue]];
    }
  
    self.unreadcount = [self.unreadcountArr[indexPath.row] integerValue];
    if (self.unreadcount == 0) {
        cell.unreadcountImage.hidden = YES;
        cell.countLabel.hidden       = YES;
    }else{
        cell.unreadcountImage.hidden = NO;
        cell.countLabel.hidden       = NO;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];    
    UIStoryboard * oneStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DetailMSGViewController * MSGVC = [oneStoryBoard instantiateViewControllerWithIdentifier:@"DetailMSGViewController"];
    NSString *itemid = self.itemIdArrs[indexPath.row];
    MSGVC.itemID = itemid;
//    MSGVC.actcode = self.actcodeArrs[indexPath.row];
    [self.navigationController pushViewController:MSGVC animated:YES];
}

//编辑操作
-(void)startEdit:(UIBarButtonItem *)btn
{
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = YES;
    self.footView.hidden = NO;
    [self.tableView reloadData];
}


@end
