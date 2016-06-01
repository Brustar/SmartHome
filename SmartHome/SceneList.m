//
//  SceneList.m
//  SmartHome
//
//  Created by Brustar on 16/5/17.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SceneList.h"
#import "AddScene.h"

@implementation SceneList

-(void) viewDidLoad
{
    
    self.scenes=[NSArray arrayWithObjects:@"清晨" ,@"睡眠" ,@"约会" ,@"用餐" ,@"派对" ,@"影院" ,@"欢迎" ,@"离家" ,nil];
    self.title=@"场景列表";
    self.tableView.rowHeight=44;
    
    UISegmentedControl *button = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"new", nil]];
    button.momentary = YES;
    [button addTarget:self action:@selector(addScene:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.rightBarButtonItem = menuButton;
    
    UISegmentedControl *but = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"framework", nil]];
    but.momentary = YES;
    [but addTarget:self action:@selector(framework:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *frameworkButton = [[UIBarButtonItem alloc] initWithCustomView:but];
    
    self.navigationItem.leftBarButtonItem = frameworkButton;
    
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
    [self performSegueWithIdentifier:@"editScene" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"editScene"])
    {
        id theSegue = segue.destinationViewController;
        [theSegue setValue:@"2" forKey:@"sceneid"];
    }
}

@end
