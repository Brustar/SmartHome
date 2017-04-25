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
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.hostIDS[indexPath.row]];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = (int)indexPath.row;
    [self sendRequestToHostWithTag:1 andRow:row];
}

-(void)sendRequestToHostWithTag:(int)tag andRow:(int)row
{
    NSString *url = [NSString stringWithFormat:@"%@login/login_host.aspx",[IOManager httpAddr]];
    
    NSDictionary *dict = @{@"token":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"hostid":self.hostIDS[row]};
    [IOManager writeUserdefault:self.hostIDS[row] forKey:@"HostID"];
    
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    http.tag = tag;
    [http sendGet:url param:dict];
}


#pragma - mark http delegate
-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if ([responseObject[@"result"] intValue]==0)
        {
            //更新token
            [IOManager writeUserdefault:responseObject[@"token"] forKey:@"AuthorToken"];
        }
 
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectHostID)]) {
        [_delegate didSelectHostID];
    }
}

@end
