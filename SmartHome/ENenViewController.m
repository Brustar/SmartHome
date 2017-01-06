//
//  ENenViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/1/5.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "ENenViewController.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "EnenCell.h"

@interface ENenViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray * dateArr;

@end

@implementation ENenViewController
-(NSMutableArray *)dateArr
{
    if (!_dateArr) {
        _dateArr = [NSMutableArray array];
    }
    
    return _dateArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

       [self sendRequestToGetEenrgyWithEqid:self.eqid];
}
-(void)sendRequestToGetEenrgyWithEqid:(int)eqid
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/energy_list.aspx",[IOManager httpAddr]];
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (authorToken) {
        NSDictionary *dic = @{@"token":authorToken,@"optype":[NSNumber numberWithInteger:1],@"eqid":[NSNumber numberWithInt:eqid]};
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag =1;
        [http sendPost:url param:dic];
    }
}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            NSArray *message = responseObject[@"energy_list"];
            //            NSDictionary *overDic = @{@"energy_poor":responseObject[@"energy_poor"]};
            for(NSDictionary *dic in message)
            {
                NSDictionary *energy = @{@"date":dic[@"date"],@"hour_time":dic[@"hour_time"]};
                
                [self.dateArr addObject:energy];
                
            }
            //            [self.enegers addObject:overDic];
            [self.tableView reloadData];
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.dateArr.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   EnenCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    return cell;
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

@end
