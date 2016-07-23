//
//  MSGController.m
//  SmartHome
//
//  Created by Brustar on 16/7/4.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "MSGController.h"
#import "IOManager.h"
#import "MsgCell.h"
#import "HttpManager.h"
@interface MSGController ()<HttpDelegate>
@property(nonatomic,strong) NSMutableArray *msgArr;
@property(nonatomic,strong) NSMutableArray *timesArr;
@end

@implementation MSGController
-(NSMutableArray *)msgArr
{
    if(!_msgArr)
    {
        _msgArr = [NSMutableArray array];
        
    }
    return _msgArr;
}
-(NSMutableArray *)timesArr
{
    if(!_timesArr)
    {
        _timesArr = [NSMutableArray array];
    }
    return _timesArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self sendRequest];
    
   
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //[self sendRequest];
}
-(void)sendRequest
{
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
    NSString *url = [NSString stringWithFormat:@"%@GetNotifyMessage.aspx",[IOManager httpAddr]];
    NSDictionary *dic = @{@"AuthorToken":authorToken,@"UserID":userID};
    HttpManager *http=[HttpManager defaultManager];
    http.delegate = self;
    [http sendPost:url param:dic];

}
-(void)httpHandler:(id)responseObject
{
    NSDictionary *dic = responseObject[@"messageInfo"];
    NSArray *msgList = dic[@"messageList"];
    for(NSDictionary *dicDetail in msgList)
    {
        NSString *description = dicDetail[@"description"];
        NSString *createDate = dicDetail[@"createDate"];
        [self.msgArr addObject:description];
        [self.timesArr addObject:createDate];
       
    }
     [self.tableView reloadData];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.msgArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"msgCell";
    MsgCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.title.text = self.msgArr[indexPath.row];
    cell.timeLable.text = self.timesArr[indexPath.row];
    return cell;
}

@end
