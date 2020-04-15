//
//  ViewController.m
//  TYRZDemo
//
//  Created by 承启通 on 2020/4/13.
//  Copyright © 2020 承启通. All rights reserved.
//

#import "ViewController.h"
#import <TYRZSDK/TYRZSDK.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * myTableview;
    NSArray * dataSourceArr;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.title = @"统一认证";
    [self CreatUI];
    // Do any additional setup after loading the view.
}
-(void)CreatUI{
    dataSourceArr = [[NSArray alloc] initWithObjects:@"获取网络类型和运营商信息", @"预取号", @"获取token并授权", @"本机号码校验", @"删除phoneScrip", @"自定义请求超时设置", @"", @"",nil];
    myTableview = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    myTableview.delegate = self;
    myTableview.dataSource = self;
    [self.view addSubview:myTableview];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"cellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = dataSourceArr[indexPath.row];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataSourceArr.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            NSDictionary * netInfo=[self getNetInfo];
            NSLog(@"%@",netInfo);
            [self showInfo:netInfo];
        }
            break;
        case 1:
        {
            [self getPhoneNumber];
        }
            break;
        case 2:
        {
            [self getAuthorization];
        }
            break;
        case 3:
        {
            [self mobileAuth];
        }
            break;
        case 4:
        {
            BOOL isDelete= [self delectScrip];
            if (isDelete) {
                NSLog(@"删除成功");
                [self showInfoWith:@"删除成功"];
            }else{
                NSLog(@"删除失败");
                [self showInfoWith:@"删除失败"];

            }
        }
            break;
        case 5:
        {
            [self setTimeoutInterval:5000];
        }
            break;
            
        default:
            break;
    }
}
/*
 获取网络类型
 本方法用于获取用户当前的网络环境和运营商（双卡下，获取上网卡的运营商）
 */
-(NSDictionary *)getNetInfo{
    return [UASDKLogin.shareLogin networkInfo];
}
/*
 预取号
 本方法用于发起取号请求，SDK完成网络判断、蜂窝数据网络切换等操作并缓存凭证scrip。
 */
-(void)getPhoneNumber{
    [UASDKLogin.shareLogin getPhoneNumberCompletion:^(NSDictionary * _Nonnull sender) {
        NSString *resultCode = sender[@"resultCode"];
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:sender];
        if ([resultCode isEqualToString:@"103000"]) {
            NSLog(@"预取号成功");
        } else {
            NSLog(@"预取号失败");
        }
        NSLog(@"%@", result);
        [self showInfo:result];

    }];
}
/*
 获取token拉起授权页面
 应用调用本方法时，SDK将拉起用户授权页面，用户确认授权后，SDK将返回token给应用客户端。可通过返回码200087监听授权页是否成功拉起。
 */
-(void)getAuthorization{
    
    UACustomModel * model = [[UACustomModel alloc] init];
    model.currentVC = self;
//    model.authPageBackgroundImage = [UIImage imageNamed:@"IMG_2924"];
    [UASDKLogin.shareLogin getAuthorizationWithModel:model complete:^(id  _Nonnull sender) {
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:sender];
        NSLog(@"%@", result);
        NSString *resultCode = sender[@"resultCode"];

        if ([resultCode isEqualToString:@"200087"]) {
            NSLog(@"拉起授权页面");
        }else if ([resultCode isEqualToString:@"103000"]) {
            NSLog(@"授权完毕");
            //一下两种方法都可行
            //系统原方法
//            [self dismissViewControllerAnimated:YES completion:nil];
            //SDK提供的方法
            [UASDKLogin.shareLogin ua_dismissViewControllerAnimated:YES completion:nil];

        }else{
            [self showInfo:result];
        }
        
    }];
}
/*
 本机号码校验
 开发者可以在应用内部任意页面调用本方法，获取本机号码校验的接口调用凭证（token）
 */
-(void)mobileAuth{
    [UASDKLogin.shareLogin mobileAuthCompletion:^(NSDictionary * _Nonnull result) {
        NSLog(@"%@", result);
        NSString *resultCode = result[@"resultCode"];
        if ([resultCode isEqualToString:@"103000"]) {
            NSLog(@"校验成功");
        }else{
            NSLog(@"校验失败：resultCode：%@",resultCode);
        }
        [self showInfo:result];
    }];
}
/*
 删除临时取号凭证
 本方法用于删除取号方法getPhoneNumberCompletion成功后返回的取号凭证scrip
 */
-(BOOL)delectScrip{
    return  [UASDKLogin.shareLogin delectScrip];
}
/*
 自定义请求超时设置
 本方法用于设置取号、一键登录、本机号码校验请求的超时时间（默认8000，单位毫秒）
 */
- (void)setTimeoutInterval:(NSTimeInterval)timeout{
    [UASDKLogin.shareLogin setTimeoutInterval:timeout];
}
#pragma 转换消息
- (NSString *)changeShowInfo:(id)sender {
    NSString *message = @"";
    for (id key in [sender allKeys]) {
        id value = sender[key];
        BOOL isDict = [value isKindOfClass:NSDictionary.class];
        message = isDict ? [message stringByAppendingFormat:@"\n%@ = %@",key, [self changeShowInfo:value]] : [message stringByAppendingFormat:@"\n%@ = \"%@\"",key,sender[key]];
    }
    
    return message;
}
- (void)showInfo:(NSDictionary *)sender {
    NSString *message = [self changeShowInfo:sender];
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertView addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertView animated:YES completion:nil];
}
- (void)showInfoWith:(NSString *)sender {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提示" message:sender preferredStyle:UIAlertControllerStyleAlert];
    [alertView addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertView animated:YES completion:nil];
}
@end
