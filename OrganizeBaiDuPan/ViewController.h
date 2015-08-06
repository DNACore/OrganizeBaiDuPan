//
//  ViewController.h
//  OrganizeBaiDuPan
//
//  Created by ixdtech on 14/11/6.
//  Copyright (c) 2014年 Ice. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FMDatabase;
@class FileExplorerTableView;
@class WaitingView;
@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    FMDatabase *_netdiskDB;
    NSFileManager *_fileManager;
    NSString *_documentDirectory;//document路径
    NSString *_netdiskDBPath;//数据库文件路径
    NSMutableArray *_dirArray;//存储从数据库读取的路径
    NSMutableArray *_fileInfoArray;
    NSArray *_fileListArray;//文件列表数组
    WaitingView *waitView;
}
- (IBAction)openDB:(id)sender;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet FileExplorerTableView *fileExplorerTableView;
- (IBAction)dealFile:(id)sender;


@end

