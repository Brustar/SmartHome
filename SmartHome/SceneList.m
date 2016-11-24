//
//  SceneList.m
//  SmartHome
//
//  Created by Brustar on 16/5/17.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SceneList.h"

@implementation SceneList

-(void) viewDidLoad
{
    [super viewDidLoad];
    self.scenes=[NSArray arrayWithObjects:@"清晨" ,@"睡眠" ,@"约会" ,@"用餐" ,@"派对" ,@"影院" ,@"欢迎" ,@"离家" ,nil];
    self.tableView.rowHeight=44;
}

-(IBAction)framework:(id)sender
{
    [self performSegueWithIdentifier:@"framework" sender:self];
}

-(IBAction)addScene:(id)sender
{
    [self performSegueWithIdentifier:@"newScene" sender:self];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.scenes count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text=[self.scenes objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"newScene" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"newScene"])
    {
        id theSegue = segue.destinationViewController;
//        NSInteger row = self.tableView.indexPathForSelectedRow.row;
        [theSegue setValue:@"2" forKey:@"sceneid"];
//        [theSegue setValue:[NSString stringWithFormat:@"%@",self.scenes[row]] forKey:@"title"];
    }
}

@end
