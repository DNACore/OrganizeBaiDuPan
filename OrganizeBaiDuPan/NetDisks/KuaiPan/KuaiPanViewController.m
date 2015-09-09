//
//  KuaiPanViewController.m
//  OrganizeBaiDuPan
//
//  Created by Encoder on 15/8/25.
//  Copyright (c) 2015年 Ice. All rights reserved.
//

#import "KuaiPanViewController.h"
#import "FMDB.h"
@interface KuaiPanViewController (){
    FMDatabaseQueue *databaseQueue;//此类使用FMDatabaseQueue来做练习。
    NSFileManager *_fileManager;
    NSString *_documentDirectory;//document路径
    NSString *_netdiskDBPath;//数据库文件路径
    NSMutableArray *fileNameArray;//存储文件名数组
    NSMutableArray *filePathArray;//存储文件路径数组
    NSMutableArray *fileHashArray;//存储文件HASH数组
}

@end

@implementation KuaiPanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _fileManager=[NSFileManager defaultManager];
    _documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _netdiskDBPath=[NSString stringWithFormat:@"%@/%@",_documentDirectory,@"Master.sqlite"];
    databaseQueue = [FMDatabaseQueue databaseQueueWithPath:_netdiskDBPath];
    fileNameArray=[NSMutableArray array];
    filePathArray=[NSMutableArray array];
    fileHashArray = [NSMutableArray array];
    [self getFilePath];
}

- (void)didReceiveMemoryWarning {
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
- (IBAction)dissmissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//从数据库读取本地文件路径
-(void)getFilePath{
    NSMutableArray *mArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result=[db executeQuery:@"select ZTASKID,ZFILEHASH from ZKPDOWNLOADTASKITEMMODEL where ZTRANSFERPROGRESS = 1.0"];
        while ([result next]) {
    [mArray addObject:[result stringForColumn:@"ZTASKID"]];
            [fileHashArray addObject:[result stringForColumn:@"ZFILEHASH"]];
        }
    }];
    [mArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *tmpArray = [obj componentsSeparatedByString:@"/"];
        [fileNameArray addObject:[tmpArray lastObject]];//从数据库获取的路径是个完整路径，路径转换成数组，为的是获取文件名。
        
        NSString *tmpStr=[obj stringByReplacingOccurrencesOfString:[tmpArray lastObject] withString:@""];//将完整路径去除文件名就是文件路径
        [filePathArray addObject:[tmpStr substringFromIndex:1]];//去除路径最前面的“/”符号，便于以后根据路径建立文件夹。若这步不去除，那么下一步建立的时候就需要把_documentDirectory和路径之间的“/”去掉。因为_documentDirectory最后面有个“/”.
        
    }];
    [self createDir];
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
}

@end
