//
//  KuaiPanViewController.m
//  OrganizeBaiDuPan
//
//  Created by Encoder on 15/8/25.
//  Copyright (c) 2015年 Ice. All rights reserved.
//

#import "KuaiPanViewController.h"
#import "FMDB.h"
#import <CommonCrypto/CommonDigest.h>
@interface KuaiPanViewController (){
    FMDatabaseQueue *databaseQueue;//此类使用FMDatabaseQueue来做练习。
    NSFileManager *_fileManager;
    NSString *_documentDirectory;//document路径
    NSString *_netdiskDBPath;//数据库文件路径
    NSMutableArray *fileFullPathArray;//存储文件完整路径
    NSMutableArray *fileNameArray;//存储文件名数组
    NSMutableArray *filePathArray;//存储文件路径数组
    NSMutableArray *fileHashArray;//存储文件HASH数组
    __weak IBOutlet UILabel *progressLabel;
    __weak IBOutlet UIProgressView *progressShow;
}

@end

@implementation KuaiPanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _fileManager=[NSFileManager defaultManager];
    _documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _netdiskDBPath=[NSString stringWithFormat:@"%@/%@",_documentDirectory,@"Master.sqlite"];
    
    BOOL isDir=NO;
    if ([_fileManager fileExistsAtPath:_netdiskDBPath isDirectory:&isDir]) {
        
        databaseQueue = [FMDatabaseQueue databaseQueueWithPath:_netdiskDBPath];
        
        fileFullPathArray=[NSMutableArray array];
        fileNameArray=[NSMutableArray array];
        filePathArray=[NSMutableArray array];
        fileHashArray = [NSMutableArray array];
        [self getFilePath];
    }
    else{
        NSLog(@"快盘数据库文件不存在。");
        return;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"%s",__func__);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)dissmissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//从数据库读取本地文件路径
-(void)getFilePath{
    [databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result=[db executeQuery:@"select ZTASKID,ZFILEHASH from ZKPDOWNLOADTASKITEMMODEL where ZTRANSFERPROGRESS = 1.0"];
        while ([result next]) {
    [fileFullPathArray addObject:[result stringForColumn:@"ZTASKID"]];
            [fileHashArray addObject:[result stringForColumn:@"ZFILEHASH"]];
        }
    }];
    [fileFullPathArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *tmpArray = [obj componentsSeparatedByString:@"/"];
        [fileNameArray addObject:[tmpArray lastObject]];//从数据库获取的路径是个完整路径，路径转换成数组，为的是获取文件名。
        
        NSString *tmpStr=[obj stringByReplacingOccurrencesOfString:[tmpArray lastObject] withString:@""];//将完整路径去除文件名就是文件路径
        [filePathArray addObject:[tmpStr substringFromIndex:1]];//去除路径最前面的“/”符号，便于以后根据路径建立文件夹。若这步不去除，那么下一步建立的时候就需要把_documentDirectory和路径之间的“/”去掉。因为_documentDirectory最后面有个“/”.
        
    }];
    [self checkFileSHA1];
}

//开始建立目录
-(void)createDir{
    for (NSString *tmpDirName in filePathArray) {
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
    [self renameAndMoveFileToDir];
}

//重命名文件并且移动到正确的位置
-(void)renameAndMoveFileToDir{
    [fileHashArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //NSFileManager的方法，主要是拼接路径
        [_fileManager moveItemAtPath:[NSString stringWithFormat:@"%@/LocalCache/OriginalFile/%@",_documentDirectory,obj]
                      toPath:[NSString stringWithFormat:@"%@/%@%@",_documentDirectory,[filePathArray objectAtIndex:idx],[fileNameArray objectAtIndex:idx]] error:nil];
    }];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    [_fileManager moveItemAtPath:_netdiskDBPath toPath:[NSString stringWithFormat:@"%@/Master_%@.sqlite",_documentDirectory,[dateFormatter stringFromDate:[NSDate date]]] error:nil];
}

//计算sha1值

- (NSString *) sha1:(NSData *)fileData
{
    //const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    //NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(fileData.bytes, (uint)fileData.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

-(void)checkFileSHA1{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block BOOL isFileHashError = NO;
        NSMutableArray *errorHashArray = [NSMutableArray array];
        [fileHashArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSData *filedata=[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/LocalCache/OriginalFile/%@",_documentDirectory,obj]];
            NSString *sha1sumString=[self sha1:filedata];
            if (![obj isEqualToString:sha1sumString]) {
                isFileHashError = YES;
                NSLog(@"文件标称SHA1与计算SHA1不符：\n标称：%@\n计算：%@",obj,sha1sumString);
                [errorHashArray addObject:obj];
            }
            
            NSUInteger fileCount=fileHashArray.count;
            dispatch_async(dispatch_get_main_queue(), ^{
                progressLabel.text=[NSString stringWithFormat:@"%lu/%lu",idx+1,(unsigned long)fileCount];
                progressShow.progress=((float)(idx+1))/((float)fileCount);
            });
        }];
        if (isFileHashError) {
            NSLog(@"校验出错的文件：%@",errorHashArray);
        }
        else{
            [self createDir];
        }
    });
}

@end
