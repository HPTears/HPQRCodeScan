//
//  XKQRCodeScanViewController.h
//  QRCodeScan
//
//  Created by hupan on 2018/7/24.
//  Copyright © 2018年 hupan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XKQRCodeScanViewController : UIViewController

//二维码或者条形码唯一包含的识别字符串
@property (nonatomic, copy) NSString *identifierStr;

@end
