//
//  XKQRCodeScanViewController.m
//  QRCodeScan
//
//  Created by hupan on 2018/7/24.
//  Copyright © 2018年 hupan. All rights reserved.
//

#import "XKQRCodeScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface XKQRCodeScanViewController () <AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) AVCaptureSession        *session;

@end

@implementation XKQRCodeScanViewController

#pragma mark - Lazy load

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    return _session;
}


- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        
        // 获取支持的媒体格式
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        // 判断是否支持需要设置的sourceType
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            
            _imagePickerController = [[UIImagePickerController alloc] init];
            _imagePickerController.delegate = self;
            // _imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;//翻转效果
            _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            _imagePickerController.mediaTypes = @[mediaTypes[0]];
            _imagePickerController.allowsEditing = NO;
        }
    }
    
    return _imagePickerController;
}



#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.session) {
        [self.session startRunning];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *title = @"二维码/条形码";
    
    self.navigationController.navigationItem.title = title;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(screenSize.width - 50, 10, 40, 30)];
    [btn setTitle:@"相册" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(selectPhotoAlbumPhotos) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:btn];
    
    [self createCapture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"%@_dealloc", [self class]);
}


#pragma mark - Private Metheods

- (void)createCapture {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) {
        [self showSureAlertControllerWithTitle:@"温馨提示" message:@"该设备不支持相机功能" popViewController:YES sessionRun:NO];
        
    } else {
        
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        if (!input) {
            
            [self showSureAlertControllerWithTitle:@"温馨提示" message:@"请向XX开放相机权限：手机设置->隐私->相机->XX(打开)" popViewController:YES sessionRun:NO];
            
        } else {
            
            [self.session addInput:input];
            [self.session addOutput:output];
            
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;

            output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
            AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
            layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            layer.frame = CGRectMake(screenSize.width / 6, screenSize.height / 2 - screenSize.width / 3, screenSize.width / 3 * 2, screenSize.width / 3 * 2);
            [self.view.layer insertSublayer:layer atIndex:0];
            [self.session startRunning];
            
            UILabel *tipsLabel = [[UILabel alloc] init];
            tipsLabel.bounds = CGRectMake(0, 0, screenSize.width, 50);
            tipsLabel.center = CGPointMake(screenSize.width / 2, layer.frame.origin.y - 40);
            tipsLabel.numberOfLines = 2;
            tipsLabel.font = [UIFont systemFontOfSize:15.0f];
            tipsLabel.text = @"将取景框对准二维码/条形码，\n即可自动扫描。";
            tipsLabel.textAlignment = NSTextAlignmentCenter;
            tipsLabel.textColor = [UIColor colorWithRed:100 green:100 blue:100 alpha:1];
            [self.view addSubview:tipsLabel];
            
            NSArray *imageArray = @[@[@"report_angleLU", @"report_angleLD"], @[@"report_angleRU", @"report_angleRD"]];
            for (int i = 0; i < 2; i++) {
                for (int j = 0; j < 2; j++) {
                    UIImageView *angleImageView = [[UIImageView alloc] init];
                    angleImageView.frame = CGRectMake(screenSize.width / 2 - layer.bounds.size.width / 2 + (screenSize.width / 3 * 2 - 15) * i, screenSize.height / 2 - layer.bounds.size.height / 2 + (screenSize.width / 3 * 2 - 15) * j , 15, 15);
                    angleImageView.image = [UIImage imageNamed:imageArray[i][j]];
                    [self.view addSubview:angleImageView];
                }
            }
        }
    }
}


- (void)showSureAlertControllerWithTitle:(NSString *)title message:(NSString *)message popViewController:(BOOL)pop sessionRun:(BOOL)sessionRun {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        if (pop) {
            [self.navigationController popViewControllerAnimated:YES];
        } else if (sessionRun) {
            [self.session startRunning];
        }
    }];
    [alertVC addAction:sure];
    [self presentViewController:alertVC animated:YES completion:nil];
}


#pragma mark - Events
- (void)selectPhotoAlbumPhotos {
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

#pragma mark - Delegate
#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects.count > 0) {
        [self.session stopRunning];
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];

        if (metadataObject.stringValue) {
            
            [self showSureAlertControllerWithTitle:nil message:metadataObject.stringValue popViewController:NO sessionRun:YES];

            /*
            //符合
            if([metadataObject.stringValue rangeOfString:self.identifierStr].location != NSNotFound){

            } else {
                NSDictionary *QRDic = [MOUserTool toArrayOrNSDictionary:metadataObject.stringValue];
                [self popAlertWithInfo:@"请选择正确的二维码！"];
            }*/
        }
    }
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // 1.取出选中的图片
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(pickImage);
    
    CIImage *ciImage = [CIImage imageWithData:imageData];
    
    // 2.从选中的图片中读取二维码数据
    // 2.1创建一个探测器 ,使用 CIDetector 处理 图片
    
    //CIDetectorAccuracyHigh  识别精度高，但识别速度慢、性能低
    //CIDetectorAccuracyLow  识别精度低，但识别速度快、性能高
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options: @{CIDetectorAccuracy:CIDetectorAccuracyLow}];
    
    // 2.2利用探测器探测数据
    NSArray *feature = [detector featuresInImage:ciImage];
    
    __block typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        if (feature.count == 0) {
            [weakSelf showSureAlertControllerWithTitle:nil message:@"未识别出数据" popViewController:NO sessionRun:YES];
            return;
        }
        // 2.3取出探测到的数据
        for (CIQRCodeFeature *result in feature) {
            // NSLog(@"%@",result.messageString);
            NSString *str = result.messageString;
//            NSLog(@"\n str=: %@",str);
            if (str) {
                
                [weakSelf showSureAlertControllerWithTitle:nil message:str popViewController:NO sessionRun:YES];
                //符合
//                if([str rangeOfString:weakSelf.identifierStr].location != NSNotFound){
//
//                } else {
//
//                }
            }
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
