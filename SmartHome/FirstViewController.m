//
//  FirstViewController.m
//  
//
//  Created by zhaona on 2017/3/17.
//
//

#import "FirstViewController.h"
#import "AppDelegate.h"
#import "IphoneFamilyViewController.h"

@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *SubImageView;
@property (weak, nonatomic) IBOutlet UIView *BtnView;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _SubImageView.layer.cornerRadius = _SubImageView.bounds.size.height/2; //圆角半径
    _SubImageView.layer.masksToBounds = YES; //圆角
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap:)];
    // 允许用户交互
    _SubImageView.userInteractionEnabled = YES;
    
    [_SubImageView addGestureRecognizer:tap];
    [self setupSlideButton];
    [self setBtn];
}
-(void)setBtn
{
    NSArray * arr = @[@"中餐",@"会客",@"回家",@"离家"];
    CGFloat BtnW = self.BtnView.bounds.size.width/4;
    CGFloat BtnH = self.BtnView.bounds.size.height;
    
    for (int i = 0; i < 4; i ++) {
        UIButton * button = [[UIButton alloc] init];
        button.tag = i;
        button.frame = CGRectMake(i*BtnW, self.BtnView.bounds.origin.y, BtnW, BtnH);
        [button setTintColor:[UIColor whiteColor]];
        [button setTitle:arr[i] forState:UIControlStateNormal];
//        [button setBackgroundImage:[UIImage imageNamed:@"button6-14"] forState:UIControlStateNormal];
        [_BtnView addSubview:button];
    }

}
-(void)doTap:(UITapGestureRecognizer *)tap
{
    NSLog(@"09090");
        UIStoryboard *iPhoneStoryBoard  = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
        IphoneFamilyViewController *familyVC = [iPhoneStoryBoard instantiateViewControllerWithIdentifier:@"iphoneFamilyViewController"];
        [self.navigationController pushViewController:familyVC animated:YES];

}
- (void)setupSlideButton {
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 44, 44);
    [menuBtn setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(menuBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
}
- (void)menuBtnAction:(UIButton *)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.LeftSlideVC.closed)
    {
        [appDelegate.LeftSlideVC openLeftView];
    }
    else
    {
        [appDelegate.LeftSlideVC closeLeftView];
    }
}- (void)didReceiveMemoryWarning {
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
