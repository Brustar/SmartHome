//
//  HostIDSController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/12.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "HostIDSController.h"
#import "HttpManager.h"
@interface HostIDSController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heigthConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *hostIDS;
@end

@implementation HostIDSController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hostIDS = [[NSUserDefaults standardUserDefaults] objectForKey:@"HostIDS"];
    self.heigthConstraint.constant = self.hostIDS.count *44;
    CGFloat maxH = MAX(100, self.heigthConstraint.constant);
    self.preferredContentSize=CGSizeMake(200, maxH);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.hostIDS.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.hostIDS[indexPath.row];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = (int)indexPath.row;
    [self sendRequestToHostWithTag:1 andRow:row];
}
-(void)sendRequestToHostWithTag:(int)tag andRow:(int)row
{
    NSString *url = [NSString stringWithFormat:@"%@UserLoginHost.aspx",[IOManager httpAddr]];
    
    NSDictionary *dict = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"HostID":self.hostIDS[row]};
    [IOManager writeUserdefault:self.hostIDS[row] forKey:@"hostId"];
    
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    http.tag = tag;
    [http sendPost:url param:dict];
}

-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if ([responseObject[@"Result"] intValue]==0)
        {
            //检测版本号，获取配置信息
            
        }
 
    }
}

@end
