//
//  ChatTableViewController.m
//  OrganizeBaiDuPan
//
//  Created by Encoder on 15/10/27.
//  Copyright © 2015年 Ice. All rights reserved.
//

#import "ChatTableViewController.h"
#import "ChatTableViewCellReceive.h"
#import "ChatTableViewCellSend.h"
@interface ChatTableViewController (){
    NSArray *chatDataArray;
    IBOutlet UITableView *chatTableView;
}

@end

@implementation ChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [chatTableView registerNib:[UINib nibWithNibName:@"ChatTableViewCellReceive" bundle:nil] forCellReuseIdentifier:@"ChatTableViewCellReceive"];
    [chatTableView registerNib:[UINib nibWithNibName:@"ChatTableViewCellSend" bundle:nil] forCellReuseIdentifier:@"ChatTableViewCellSend"
     ];
    chatTableView.estimatedRowHeight=22.0;
    chatTableView.rowHeight=UITableViewAutomaticDimension;
    chatDataArray=[NSArray arrayWithObjects:
                   @{@"time":@"123456",@"content":@"123456777",@"isSend":@"1"},
  @{@"time":@"123456",@"content":@"123dsavdddddddddddddddddddddddddddddddddddddddddddfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddddddddddddddddddddd456777123dsavdddddddddddddddddddddddddddddddddddddddddddfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddddddddddddddddddddd456777123dsavdddddddddddddddddddddddddddddddddddddddddddfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddddddddddddddddddddd456777123dsavdddddddddddddddddddddddddddddddddddddddddddfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddddddddddddddddddddd456777123dsavdddddddddddddddddddddddddddddddddddddddddddfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddddddddddddddddddddd456777123dsavdddddddddddddddddddddddddddddddddddddddddddfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddddddddddddddddddddd456777123dsavdddddddddddddddddddddddddddddddddddddddddddfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddddddddddddddddddddd456777",@"isSend":@"0"},
                   @{@"time":@"5612316",@"content":@"The UIButton's contentStretch does also not work properly.How I solved it: I subclassed UIButton and added a UIImageView *backgroundImageView as property and placed it at index 0 as a subview within the UIButton. I then ensure in layoutSubviews that it fits the button entirely and set the highlighted states of the imageView. All you need to do is handover a UIImageView with the correct contentStretch and contentMode applied.",@"isSend":@"1"},
                   nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return chatDataArray.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return UITableViewAutomaticDimension;
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *chatTmpData=[chatDataArray objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    if ([[chatTmpData objectForKey:@"isSend"] boolValue]) {
        cell =(ChatTableViewCellSend *)[tableView dequeueReusableCellWithIdentifier:@"ChatTableViewCellSend" forIndexPath:indexPath];
        ((ChatTableViewCellSend *)cell).chatSendTimeLabel.text=[[chatDataArray objectAtIndex:indexPath.row] objectForKey:@"time"];
        ((ChatTableViewCellSend *)cell).chatSendContentLabel.text=[[chatDataArray objectAtIndex:indexPath.row] objectForKey:@"content"];
    }
    else{
        cell =(ChatTableViewCellReceive *)[tableView dequeueReusableCellWithIdentifier:@"ChatTableViewCellReceive" forIndexPath:indexPath];
        ((ChatTableViewCellReceive *)cell).chatReceiveTimeLabel.text=[[chatDataArray objectAtIndex:indexPath.row] objectForKey:@"time"];
        ((ChatTableViewCellReceive *)cell).chatReceiveContentLabel.text=[[chatDataArray objectAtIndex:indexPath.row] objectForKey:@"content"];
    }

    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
