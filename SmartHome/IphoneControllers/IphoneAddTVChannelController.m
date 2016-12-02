//
//  IphoneAddTVChannelController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/24.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneAddTVChannelController.h"
#import "KxMenu.h"
#import "TVIconController.h"
#import "HttpManager.h"
#import "UploadManager.h"
#import "SQLManager.h"
#import "TVController.h"
#import "MBProgressHUD+NJ.h"
@interface IphoneAddTVChannelController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,TVIconControllerDelegate>

@end

@implementation IphoneAddTVChannelController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.eNumber = [SQLManager getENumber:[self.deviceid intValue]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (IBAction)clickTokenImgeBtn:(id)sender {
    UIButton *btn = sender;
    UIView *view = btn.superview;
    CGFloat y = view.frame.origin.y -(view.frame.size.width - btn.frame.size.width);
    [KxMenu showMenuInView:self.view fromRect:CGRectMake(view.frame.origin.x, y , view.frame.size.width, view.frame.size.height) menuItems:@[
                                                                                                                                             [KxMenuItem menuItem:@"预置台标"
                                                                                                                                                            image:nil
                                                                                                                                                           target:self
                                                                                                                                                           action:@selector(Iphonepreset:)],
                                                                                                                                             [KxMenuItem menuItem:@"本地图库"
                                                                                                                                                            image:nil
                                                                                                                                                           target:self
                                                                                                                                                           action:@selector(IphoneSelectPhoto:)],
                                                                                                                                             [KxMenuItem menuItem:@"现在拍摄"
                                                                                                                                                            image:nil
                                                                                                                                                           target:self
                                                                                                                                                           action:@selector(IphoneTakePhoto:)],
                                                                                                                                             ]];

}

-(void)Iphonepreset:(KxMenuItem *)item{
    
    [DeviceInfo defaultManager].isPhotoLibrary = YES;
    [self performSegueWithIdentifier:@"iphoneTvLogoSegue" sender:self];
}

- (void)IphoneSelectPhoto:(KxMenuItem *)item {
    [DeviceInfo defaultManager].isPhotoLibrary = YES;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [picker shouldAutorotate];
    [picker supportedInterfaceOrientations];
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void)IphoneTakePhoto:(KxMenuItem *)item {
    [DeviceInfo defaultManager].isPhotoLibrary = YES;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [picker shouldAutorotate];
    [picker supportedInterfaceOrientations];
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
   
    [self.addBtn setBackgroundImage:info[UIImagePickerControllerEditedImage] forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)tvIconController:(TVIconController *)iconVC withImgName:(NSString *)imgName
{
    self.chooseImgeName = imgName;
    [self.addBtn setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TVIconController *iconVC = segue.destinationViewController;
    iconVC.delegate = self;
}

- (IBAction)finishFavorChannel:(id)sender {
    if(self.chooseImgeName)
    {
        [self sendStoreChannelRequest];
    }else{
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
        
        [self saveImage:self.chooseImage withName:fileName];
        
        NSString *url = [NSString stringWithFormat:@"%@Cloud/store_tv.aspx",[IOManager httpAddr]];
        NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
        NSDictionary *dic = @{@"token":authorToken,@"eqid":self.deviceid,@"cnumber":self.channelNumber.text,@"cname":self.channelName.text,@"imgname":fileName,@"imgdata":@"",@"optype":[NSNumber numberWithInteger:0]};
        
        
        if (self.chooseImage && url && dic && fileName) {
            
            [[UploadManager defaultManager] uploadImage:self.chooseImage url:url dic:dic fileName:fileName completion:^(id responseObject) {
                [self writeTVChannelsConfigDataToSQL:responseObject withParent:@"TV"];
                
            }];
        }else{
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"电视图标要添加" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }

}
-(void)writeTVChannelsConfigDataToSQL:(NSDictionary *)responseObject withParent:(NSString *)parent
{
    FMDatabase *db = [SQLManager connetdb];
    int cNumber = [self.channelNumber.text intValue];
    if([db open])
    {
        
        NSString *sql = [NSString stringWithFormat:@"insert into Channels values(%d,%d,%d,%d,'%@','%@','%@',%d,'%@')",[responseObject[@"cId"] intValue],[self.deviceid intValue],0,cNumber,self.channelName.text,responseObject[@"imgUrl"],parent,1,self.eNumber];
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

-(void)sendStoreChannelRequest
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/store_tv.aspx",[IOManager httpAddr]];
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSDictionary *dic = @{@"token":authorToken,@"eqid":self.deviceid,@"cnumber":self.channelNumber.text,@"cname":self.channelName.text,@"imgname":self.chooseImgeName ,@"imgdata":@"",@"optype":[NSNumber numberWithInteger:0]};
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
            [self writeTVChannelsConfigDataToSQL:responseObject withParent:@"TV"];
            [MBProgressHUD showSuccess:@"收藏成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }
}

-(void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    
    [imageData writeToFile:fullPath atomically:NO];
}
- (IBAction)returnController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
