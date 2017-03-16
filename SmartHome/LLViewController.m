#import "UIImageView+WebCache.h"
#import "LLViewController.h"
#import "Cell.h"

@implementation LLViewController

-(void)viewDidLoad
{
    [self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"IMG_CELL"];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return SCROLL_SIZE;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"IMG_CELL" forIndexPath:indexPath];
    [cell.pic sd_setImageWithURL:[NSURL URLWithString:[self.imgURLs objectAtIndex:(indexPath.item % self.imgURLs.count)]] placeholderImage:self.placeholder options:SDWebImageRetryFailed];
    return cell;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

@end

