//
//  ViewController.m
//  MusicPlay
//
//  Created by LM on 2017/5/4.
//  Copyright © 2017年 ning. All rights reserved.
//

#import "ViewController.h"
#import "XZAllMusicModel.h"
#import "XZMusicPlayViewController.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *mainTable;
    NSMutableArray *dataArr;
    int from;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dataArr = [NSMutableArray new];
    
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    mainTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStylePlain];
    mainTable.delegate = self;
    mainTable.dataSource = self;
    mainTable.tableFooterView = [UIView new];
    [mainTable setSeparatorColor:[UIColor clearColor]];
    

    
    [self.view addSubview:mainTable];
    
    [self loadData];
    
    
    //创建music文件夹
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //music文件夹
    NSString *createPath = [NSString stringWithFormat:@"%@/music", docDirPath];
    
    // 判断文件夹是否存在，如果不存在，则创建
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![[NSFileManager defaultManager] fileExistsAtPath:createPath]) {
        [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
        
    } else {
        //        NSLog(@"FileDir is exists.");
    }
    
    
    
}



- (void)loadData{
    
//    [[HTTPManager defaultManager]requestGETurl:@"/music/allmusic?from=0" params:nil showHUD:YES successBlock:^(id returnData) {
//        //        NSLog(@"----%@",returnData);
//        for (NSMutableDictionary *dic in returnData[@"data"]) {
//            XZAllMusicModel *model = [[XZAllMusicModel alloc]initWithDictionary:dic];
//            [dataArr addObject:model];
//        }
//        [mainTable reloadData];
//    } failureBlock:^(NSError *error) {
//        
//    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        
    }
    
    XZAllMusicModel *model = dataArr[indexPath.row];
    
    UIImageView *headImg = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 40, 40)];
    headImg.layer.cornerRadius = 20;
    headImg.layer.masksToBounds = YES;
//    [headImg sd_setImageWithURL:[NSURL URLWithString:model.img] placeholderImage:placeholderImg];//头像
    [cell addSubview:headImg];
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15+40+15, 20, self.view.frame.size.width-150, 20)];
    titleLab.text = @"点击播放";
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.font = [UIFont systemFontOfSize:18];
    titleLab.textColor = [UIColor blackColor];
    
    [cell addSubview:titleLab];
    
    
    cell.detailTextLabel.text = model.time;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    XZMusicPlayViewController *musicVC = [[XZMusicPlayViewController alloc]init];
    musicVC.currrntCell = indexPath.row;
    musicVC.dataArr = dataArr;
    [self.navigationController pushViewController:musicVC animated:YES];
    
//    //1.创建网络监测者
//    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
//    
//    /*枚举里面四个状态  分别对应 未知 无网络 数据 WiFi
//     typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
//     AFNetworkReachabilityStatusUnknown          = -1,      未知
//     AFNetworkReachabilityStatusNotReachable     = 0,       无网络
//     AFNetworkReachabilityStatusReachableViaWWAN = 1,       蜂窝数据网络
//     AFNetworkReachabilityStatusReachableViaWiFi = 2,       WiFi
//     };
//     */
//    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        //这里是监测到网络改变的block
//        //在里面可以随便写事件
//        switch (status) {
//            case AFNetworkReachabilityStatusUnknown:
//                Log(@"未知网络状态");
//            {
//                UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前为移动数据，是否播放音乐" preferredStyle:UIAlertControllerStyleAlert];
//                
//                UIAlertAction *okAction1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    XZMusicPlayViewController *musicVC = [[XZMusicPlayViewController alloc]init];
//                    musicVC.currrntCell = indexPath.row;
//                    musicVC.dataArr = dataArr;
//                    [self.navigationController pushViewController:musicVC animated:YES];
//                }];
//                
//                UIAlertAction *calac = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                    
//                }];
//                [alertCon addAction:okAction1];
//                [alertCon addAction:calac];
//                [self presentViewController:alertCon animated:YES completion:nil];
//            }
//                break;
//            case AFNetworkReachabilityStatusNotReachable:
//                Log(@"无网络");
//            {
//                UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前为移动数据，是否播放音乐" preferredStyle:UIAlertControllerStyleAlert];
//                
//                UIAlertAction *okAction1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    XZMusicPlayViewController *musicVC = [[XZMusicPlayViewController alloc]init];
//                    musicVC.currrntCell = indexPath.row;
//                    musicVC.dataArr = dataArr;
//                    [self.navigationController pushViewController:musicVC animated:YES];
//                }];
//                
//                UIAlertAction *calac = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                    
//                }];
//                [alertCon addAction:okAction1];
//                [alertCon addAction:calac];
//                [self presentViewController:alertCon animated:YES completion:nil];
//            }
//                break;
//                
//            case AFNetworkReachabilityStatusReachableViaWWAN:
//                Log(@"蜂窝数据网");
//            {
//                UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前为移动数据，是否播放音乐" preferredStyle:UIAlertControllerStyleAlert];
//                
//                UIAlertAction *okAction1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    XZMusicPlayViewController *musicVC = [[XZMusicPlayViewController alloc]init];
//                    musicVC.currrntCell = indexPath.row;
//                    musicVC.dataArr = dataArr;
//                    [self.navigationController pushViewController:musicVC animated:YES];
//                }];
//                
//                UIAlertAction *calac = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                    
//                }];
//                [alertCon addAction:okAction1];
//                [alertCon addAction:calac];
//                [self presentViewController:alertCon animated:YES completion:nil];
//            }
//                break;
//                
//            case AFNetworkReachabilityStatusReachableViaWiFi:
//                Log(@"WiFi网络");
//            {
//                XZMusicPlayViewController *musicVC = [[XZMusicPlayViewController alloc]init];
//                musicVC.currrntCell = indexPath.row;
//                musicVC.dataArr = dataArr;
//                [self.navigationController pushViewController:musicVC animated:YES];
//            }
//                break;
//                
//            default:
//                break;
//        }
//        
//    }] ;
//    
//    [manager startMonitoring];
    
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


@end
