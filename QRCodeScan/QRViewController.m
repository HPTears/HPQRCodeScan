//
//  QRViewController.m
//  QRCodeScan
//
//  Created by hupan on 2018/7/24.
//  Copyright © 2018年 hupan. All rights reserved.
//

#import "QRViewController.h"
#import "XKQRCodeScanViewController.h"
#import "XKQRCodeView.h"


@interface QRViewController ()

@property (nonatomic, strong) XKQRCodeView *qrView;

@end

@implementation QRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 40)];
    [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
    
    
    self.qrView = [[XKQRCodeView alloc] initWithFrame:CGRectMake(100, 250, 100, 100)];
    [self.view addSubview:self.qrView];
    
    [self.qrView createQRImageWithQRString:@"text"];
    
    
}


- (void)btnClicked:(UIButton *)sender {
    
    XKQRCodeScanViewController *vc =[[XKQRCodeScanViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
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
