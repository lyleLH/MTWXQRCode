//
//  VKWXQRCodeScanViewController.m
//  Pods-VKWXQRCode_Example
//
//  Created by 刘浩 on 2018/12/4.
//

#import "MTWXQRCodeScanViewController.h"
#import "SGQRCode.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface MTWXQRCodeScanViewController (){
    SGQRCodeObtain *obtain;
}

@property (nonatomic, strong) SGQRCodeScanView *scanView;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, assign) BOOL stop;
@end

@implementation MTWXQRCodeScanViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_stop) {
        [obtain startRunningWithBefore:nil completion:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanView addTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanView removeTimer];
}

- (void)dealloc {
    NSLog(@"WBQRCodeVC - dealloc");
    [self removeScanningView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    obtain = [SGQRCodeObtain QRCodeObtain];
  
    [self setupNavigationBar];
    [self setupQRCodeScan];
  
    [self.view addSubview:self.scanView];
    [self.view addSubview:self.promptLabel];
}

- (void)setupQRCodeScan {
    __weak typeof(self) weakSelf = self;
    
    SGQRCodeObtainConfigure *configure = [SGQRCodeObtainConfigure QRCodeObtainConfigure];
    configure.openLog = YES;
    configure.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
    // 这里只是提供了几种作为参考（共：13）；需什么类型添加什么类型即可
    NSArray *arr = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    configure.metadataObjectTypes = arr;
    
    [obtain establishQRCodeObtainScanWithController:self configure:configure];

    [obtain startRunningWithBefore:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        });
    } completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        });
    }];
    
    [obtain setBlockWithQRCodeObtainScanResult:^(SGQRCodeObtain *obtain, NSString *result) {
            if (result) {
                [obtain stopRunning];
                weakSelf.stop = YES;
                [obtain playSoundName:@"SGQRCode.bundle/sound.caf"];
                
                if(weakSelf.callback){
                    weakSelf.callback(@{@"status":@"0",@"result":result});
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:NO];
                    });
            }
    }];
}

- (void)setupNavigationBar {
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"扫一扫";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:(UIBarButtonItemStyleDone) target:self action:@selector(rightBarButtonItenAction)];
}

- (void)rightBarButtonItenAction {
    __weak typeof(self) weakSelf = self;
    
    [obtain establishAuthorizationQRCodeObtainAlbumWithController:nil];
    if (obtain.isPHAuthorization == YES) {
        [self.scanView removeTimer];
    }
    [obtain setBlockWithQRCodeObtainAlbumDidCancelImagePickerController:^(SGQRCodeObtain *obtain) {
        [weakSelf.view addSubview:weakSelf.scanView];
    }];
    [obtain setBlockWithQRCodeObtainAlbumResult:^(SGQRCodeObtain *obtain, NSString *result) {
        if (result == nil) {
            NSLog(@"暂未识别出二维码");
            if(weakSelf.callback){
                weakSelf.callback(@{@"status":@"1000",@"result":result});
            }
            
        } else {
            if(weakSelf.callback){
                weakSelf.callback(@{@"status":@"0",@"result":result});
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }];
}

- (SGQRCodeScanView *)scanView {
    if (!_scanView) {
        _scanView = [[SGQRCodeScanView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        // 静态库加载 bundle 里面的资源使用 SGQRCode.bundle/QRCodeScanLineGrid
        // 动态库加载直接使用 QRCodeScanLineGrid
        _scanView.scanImageName = @"SGQRCode.bundle/QRCodeScanLineGrid";
        _scanView.scanAnimationStyle = ScanAnimationStyleGrid;
        _scanView.cornerLocation = CornerLoactionOutside;
        _scanView.cornerColor = [UIColor orangeColor];
    }
    return _scanView;
}
- (void)removeScanningView {
    [self.scanView removeTimer];
    [self.scanView removeFromSuperview];
    self.scanView = nil;
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.backgroundColor = [UIColor clearColor];
        CGFloat promptLabelX = 0;
        CGFloat promptLabelY = 0.73 * self.view.frame.size.height;
        CGFloat promptLabelW = self.view.frame.size.width;
        CGFloat promptLabelH = 25;
        _promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
        _promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _promptLabel.text = @"将二维码/条码放入框内, 即可自动扫描";
    }
    return _promptLabel;
}


@end
