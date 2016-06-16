//
//  FMController.m
//  SmartHome
//
//  Created by Brustar on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "FMController.h"
#import "FMCollectionViewCell.h"
#import "TVChannel.h"
#import "TXHRrettyRuler.h"
@interface FMController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,TXHRrettyRulerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollerContentViewWidth;
@property (nonatomic,strong) NSArray *allFavouriteChannels;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UILabel *numberOfChannel;
@property (weak, nonatomic) IBOutlet UIView *fmView;

@end

@implementation FMController

-(NSArray *)allFavouriteChannels
{
    if(!_allFavouriteChannels)
    {
        _allFavouriteChannels = [TVChannel getAllChannelForFavoritedForType:@"FM"];
        
    }
    return _allFavouriteChannels;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    long  count = self.allFavouriteChannels.count;
    self.pageControl.numberOfPages = count % 4 == 0 ? count / 4 :count /4 + 1;
    
    [self setRuleForFMChannel];
    
    // Do any additional setup after loading the view.
}
-(void)setRuleForFMChannel
{
    TXHRrettyRuler *ruler = [[TXHRrettyRuler alloc] initWithFrame:CGRectMake(20, 150, self.fmView.bounds.size.width - 20 * 2, 150)];
    ruler.rulerDeletate = self;
    [ruler showRulerScrollViewWithCount:205 average:[NSNumber numberWithFloat:0.1] currentValue:16.5f smallMode:YES];
    [self.fmView addSubview:ruler];

}
- (void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView {
    self.numberOfChannel.text = [NSString stringWithFormat:@" %.1f",rulerScrollView.rulerValue];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allFavouriteChannels.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FMCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [[FMCollectionViewCell alloc]init];
    }
    TVChannel *channel = self.allFavouriteChannels[indexPath.row];
    [cell.numberBtn setTitle:[NSString stringWithFormat:@"%ld",channel.channel_id] forState:UIControlStateNormal];
    [cell.nameBtn setTitle:[NSString stringWithFormat:@"%@",channel.channel_name] forState:UIControlStateNormal];
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = [self.collectionView contentOffset];
    self.pageControl.currentPage =round(point.x /self.collectionView.bounds.size.width);
    
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
