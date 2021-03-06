//
//  ViewController.m
//  OrganizeBaiDuPan
//
//  Created by ixdtech on 14/11/6.
//  Copyright (c) 2014年 Ice. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"
#import "FileExplorerTableView.h"
//#import "WaitingView.h"
#import "KuaiPanViewController.h"
#include <CommonCrypto/CommonDigest.h>
#import "ChatTableViewController.h"
#define IsIOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0 ? YES : NO)
#define FileHashDefaultChunkSizeForReadingData 1024*8

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
//    waitView=[[WaitingView alloc]initWithFrame:CGRectMake(10, 10, 100, 100)];
//    [self.view addSubview:waitView];

    _fileManager=[NSFileManager defaultManager];
    _documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _netdiskDBPath=[NSString stringWithFormat:@"%@/%@",_documentDirectory,@"netdisk.sqlite"];
    _dirArray=[NSMutableArray array];
    _fileInfoArray=[NSMutableArray array];
    [self.progressView setProgress:0];
    NSLog(@"_documentDirectory:\n%@",_documentDirectory);
    _fileListArray=[_fileManager contentsOfDirectoryAtPath:_documentDirectory error:nil];
    NSLog(@"%@",[_fileManager subpathsOfDirectoryAtPath:_documentDirectory error:nil]);
    
    //[self GCDTEST];
}

-(void)GCDTEST{
    dispatch_queue_t dispatchQueue = dispatch_queue_create("ted.queue.next", DISPATCH_QUEUE_CONCURRENT);//创建一个并行队列
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_group_async(dispatchGroup, dispatchQueue, ^(){
        for (int i=0; i<100; i++) {
            NSLog(@"dispatch-1");
        }
    });
    dispatch_group_async(dispatchGroup, dispatchQueue, ^(){
        for (int i=0; i<100; i++) {
            NSLog(@"dspatch-2");
        }
    });
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){//群组完成通知
        NSLog(@"end");
    });
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
        NSLog(@"end2");
    });
}

-(void)aBug{
    //    UIButton *accountView = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 35, 35)];
    //    [accountView setImage:[UIImage imageNamed:@"login_account"] forState:UIControlStateNormal];
    //
    //    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 400, 320, 45)];
    //    [textField setBackgroundColor:[UIColor whiteColor]];
    //    textField.leftView = accountView;
    //    textField.leftViewMode = UITextFieldViewModeAlways;
    //    [textField leftViewRectForBounds:CGRectMake(20, 0, 40, 45)];
    //    [self.view addSubview:textField];
    //
    //    UITextField *textFieldTwo = [[UITextField alloc] initWithFrame:CGRectMake(0, 500, 320, 45)];
    //    [textFieldTwo setBackgroundColor:[UIColor whiteColor]];
    //    textFieldTwo.leftView = accountView;
    //    textFieldTwo.leftViewMode = UITextFieldViewModeAlways;
    //    [textFieldTwo leftViewRectForBounds:CGRectMake(20, 0, 40, 45)];
    //    [self.view addSubview:textFieldTwo];
    
    //    UIView *v1=[[UIView alloc]initWithFrame:CGRectMake(0, 100, 100, 100)];
    //    [v1 addSubview:accountView];
    //
    //    UIView *v2=[[UIView alloc]initWithFrame:CGRectMake(0, 300, 100, 100)];
    //    [v2 addSubview:accountView];
    //
    //    [self.view addSubview:v1];
    //    [self.view addSubview:v2];
    //    for (UIView *im in v1.subviews) {
    //        if ([im isKindOfClass:[UIImageView class]]) {
    //            NSLog(@"地址：%p",im);
    //        }
    //    }
    //    for (UIView *im in v2.subviews) {
    //        if ([im isKindOfClass:[UIImageView class]]) {
    //            NSLog(@"地址：%p",im);
    //        }
    //    }
    //    
    //
}

-(void)test{
    UIView *vi=[[UIView alloc]initWithFrame:CGRectMake(200, 200, 200, 200)];
    vi.backgroundColor=[UIColor blueColor];
    
    CABasicAnimation *routate=[CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    routate.duration=2.5;
    routate.repeatCount=HUGE_VALF;
    routate.fromValue=[NSNumber numberWithFloat:0.0];
    routate.toValue=[NSNumber numberWithFloat:2*M_PI];
    [vi.layer addAnimation:routate forKey:@"rotate-layer"];
    [self.view addSubview:vi];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//打开数据库
- (IBAction)openDB:(id)sender {
    BOOL isDir=NO;
    if ([_fileManager fileExistsAtPath:_netdiskDBPath isDirectory:&isDir]) {
        _netdiskDB=[FMDatabase databaseWithPath:_netdiskDBPath];
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"错误"
                                                     message:@"数据库文件不存在"
                                                    delegate:nil cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [alert show];
    }
    if (![_netdiskDB open]) {
        NSLog(@"无法打开数据库:%@",[_netdiskDB lastErrorMessage]);
    }
    else{
        [self getDir];
    }    
}

-(void)getDir{
    //从数据库获取目录并且建立
    [_dirArray removeAllObjects];
    FMResultSet *result=[_netdiskDB executeQuery:@"select local_path from transfilelist where trans_status = 1 group by local_path"];
    while ([result next]) {
        [_dirArray addObject:[result stringForColumn:@"local_path"]];
    }
    [result close];
    NSLog(@"获取的目录结构：\n%@",_dirArray);
    [self createDir];
}

//开始建立目录
-(void)createDir{
    for (NSString *tmpDirName in _dirArray) {
        BOOL isDir=NO;
        NSString *dirFullPath=[NSString stringWithFormat:@"%@/%@",_documentDirectory,tmpDirName];
        BOOL exsited=[_fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",_documentDirectory,tmpDirName] isDirectory:&isDir];
        if (!(isDir==YES&&exsited==YES)) {
            NSError *error;
            [_fileManager createDirectoryAtPath:dirFullPath withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                NSLog(@"建立目录error:%@",error);
            }
        }
    }
    [self getFileList];
}

//获取本地已下载的文件列表
-(void)getFileList{
    [_fileInfoArray removeAllObjects];
    FMResultSet *result=[_netdiskDB executeQuery:@"SELECT file_name,local_path,blocklistmd5  FROM transfilelist WHERE isdir=0"];
    while ([result next]) {
        [_fileInfoArray addObject:@{@"file_name":[result stringForColumn:@"file_name"],
                                    @"local_path":[result stringForColumn:@"local_path"],
                                    @"blocklistmd5":[result stringForColumn:@"blocklistmd5"],
                                    @"externName":[[[result stringForColumn:@"file_name"] componentsSeparatedByString:@"."] lastObject]}];
    }
    [result close];
    [self checkFileHash];
}

//检查文件MD5是否与标称 MD5(文件名)相符
-(void)checkFileHash{
    __block BOOL isAllRight = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block float fileCount=(float)_fileInfoArray.count;
        [_fileInfoArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![[self getFileMD5WithPath:[NSString stringWithFormat:@"%@/%@.%@",_documentDirectory,[obj objectForKey:@"blocklistmd5"],[obj objectForKey:@"externName"]]] isEqualToString:[obj objectForKey:@"blocklistmd5"]]) {
                NSLog(@"MD5校验不符：%@",obj);
                isAllRight =NO;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_progressView setProgress:((float)idx+1)/fileCount animated:NO];
            });
        }];
    });
    if (isAllRight) {
        [self renameAndMoveFileToDir];
    }
}

//重命名文件并且移动到正确的位置
-(void)renameAndMoveFileToDir{
    __block float progress=0;
    [_fileInfoArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //NSFileManager的方法，主要是拼接路径
        [_fileManager moveItemAtPath:[NSString stringWithFormat:@"%@/%@.%@",_documentDirectory,[obj objectForKey:@"blocklistmd5"],[obj objectForKey:@"externName"]] toPath:[NSString stringWithFormat:@"%@%@%@",_documentDirectory,[obj objectForKey:@"local_path"],[obj objectForKey:@"file_name"]] error:nil];
        [_progressView setProgress:((++progress)/_fileInfoArray.count) animated:YES];
    }];
    if (!IsIOS7) {
        UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"完成" message:[NSString stringWithFormat:@"共处理%i个文件",(int)_fileInfoArray.count] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"完成"
                                                     message:[NSString stringWithFormat:@"共处理%i个文件",(int)_fileInfoArray.count]
                                                    delegate:nil cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [alert show];
    }
    //[_fileManager removeItemAtPath:_netdiskDBPath error:nil];
    
    //重新载入文件列表
    _fileListArray=[_fileManager contentsOfDirectoryAtPath:_documentDirectory error:nil];
    [self.fileExplorerTableView reloadData];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    [_fileManager moveItemAtPath:_netdiskDBPath toPath:[NSString stringWithFormat:@"%@/netdisk_%@.sqlite",_documentDirectory,[dateFormatter stringFromDate:[NSDate date]]] error:nil];
}


-(void)showAlertWithTitle:(NSString *)title message:(NSString *)message{
    
}
- (IBAction)goToKuaiPanAction:(id)sender {
    KuaiPanViewController *vc=[[KuaiPanViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)openChat:(id)sender {
    ChatTableViewController *vc=[[ChatTableViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - 表格数据源
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"identifier";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text=[_fileListArray objectAtIndex:indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fileListArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        [self dealFile:nil];
    }
}

- (IBAction)dealFile:(id)sender{
    system("open /Users/Encoder/Library/Developer/CoreSimulator/");
}

#pragma mark - 校验文件MD5方法
-(NSString*)getFileMD5WithPath:(NSString*)path

{
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
}



CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    
    // Declare needed variables
    
    CFStringRef result = NULL;
    
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    
    CFURLRef fileURL =
    
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  
                                  (CFStringRef)filePath,
                                  
                                  kCFURLPOSIXPathStyle,
                                  
                                  (Boolean)false);
    
    if (!fileURL) goto done;
    
    // Create and open the read stream
    
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            
                                            (CFURLRef)fileURL);
    
    if (!readStream) goto done;
    
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    
    CC_MD5_CTX hashObject;
    
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    
    if (!chunkSizeForReadingData) {
        
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
        
    }
    
    // Feed the data to the hash object
    
    bool hasMoreData = true;
    
    while (hasMoreData) {
        
        uint8_t buffer[chunkSizeForReadingData];
        
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        
        if (readBytesCount == -1) break;
        
        if (readBytesCount == 0) {
            
            hasMoreData = false;
            
            continue;
            
        }
        
        CC_MD5_Update(&hashObject,
                      (const void *)buffer,
                      (CC_LONG)readBytesCount);
        
    }
    
    // Check if the read operation succeeded
    
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    
    if (!didSucceed) goto done;
    
    // Compute the string result
    
    char hash[2 * sizeof(digest) + 1];
    
    for (size_t i = 0; i < sizeof(digest); ++i) {
        
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
        
    }
    
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
    
    
done:
    
    if (readStream) {
        
        CFReadStreamClose(readStream);
        
        CFRelease(readStream);
        
    }
    
    if (fileURL) {
        
        CFRelease(fileURL);
        
    }
    
    return result;
    
}
@end
