//
//  IphoneAddFmController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/24.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneAddFmController.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "SQLManager.h"

@interface IphoneAddFmController ()

@property (weak, nonatomic) IBOutlet UITextField *channelName;
@property (nonatomic,strong) NSString *eNumber;
@property (weak, nonatomic) IBOutlet UITextField *channelNumber;
@end

@implementation IphoneAddFmController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *sureBtn = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finishFavor:)];
    self.navigationItem.rightBarButtonItem = sureBtn;
    self.eNumber = [SQLManager getENumber:[self.deviceid intValue]];
    self.channelNumber.text = self.numberOfChannel;
}

-(void)finishFavor:(UIBarButtonItem *)barbutton
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/store_fm.aspx",[IOManager httpAddr]];
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSDictionary *dic = @{@"token":authorToken,@"eqid":self.deviceid,@"cnumber":self.numberOfChannel,@"cname":self.channelName.text,@"imgname":@"store",@"imgdata":@"",@"optype":[NSNumber numberWithInteger:0]};
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 1;
    [http sendPost:url param:dic];
}

-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            //保存成功后存到数据库
            [self writeFMChannelsConfigDataToSQL:responseObject withParent:@"FM"];
            [MBProgressHUD showSuccess:@"收藏成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
            
        else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }
}

-(void)writeFMChannelsConfigDataToSQL:(NSDictionary *)responseObject withParent:(NSString *)parent
{
    FMDatabase *db = [SQLManager connetdb];
    if([db open])
    {
        int cNumber = [self.channelNumber.text intValue];
        NSString *sql = [NSString stringWithFormat:@"insert into Channels values(%d,%d,%d,%d,'%@','%@','%@',%d,'%@')",[responseObject[@"fmId"] intValue],[self.deviceid intValue],0,cNumber,self.channelName.text,responseObject[@"imgUrl"],parent,1,self.eNumber];
        BOOL result = [db executeUpdate:sql];
        if(result)
        {
            NSLog(@"insert 成功");
        }else{
            NSLog(@"insert 失败");
        }
    }
    [db close];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
