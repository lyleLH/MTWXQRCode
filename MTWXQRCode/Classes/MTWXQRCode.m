//
//  VKWXQRCode.m
//  Pods-VKWXQRCode_Example
//
//  Created by 刘浩 on 2018/12/4.
//

#import "MTWXQRCode.h"
#import <SGQRCode/SGQRCode.h>
#import "MTWXQRCodeScanViewController.h"
#import <SDWebImage/SDWebImageManager.h>
#define PathDocuments       [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define PathLibrary         [NSHomeDirectory() stringByAppendingPathComponent:@"Library"]
#define PathTemp            [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
#define PathPreferences     [PathLibrary stringByAppendingPathComponent:@"Preferences"]
#define PathCaches          [PathLibrary stringByAppendingPathComponent:@"Caches"]

static NSString *const kImgPickerDir = @"com.vanke.VKWXQRCode";



@interface VKWXQRCode ()

@end


@implementation VKWXQRCode

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(scanQRCode:))
WX_EXPORT_METHOD(@selector(createQRCode:callback:))



- (void)scanQRCode:(WXModuleCallback)callback {
    NSLog(@"scan  test");
  
    
    [self QRCodeScanVcCallback:^(id result) {
        callback(result);
    }];
}


/**
 生成二维码
 @param param 参数字典，data-> 字符串，size ->图片尺寸
 '{"width":"300","height":"300","content":"二维码内容"}';
 
 */

- (void)createQRCode:(NSDictionary*)param callback:(WXModuleCallback)callback {
    NSLog(@"generateCode test");
    float size = [param[@"width"] floatValue];
    UIImage * qrcodeImage = [SGQRCodeObtain generateQRCodeWithData:param[@"content"] size:size];
    CIContext *context = [CIContext new];
    CGImageRef img = [context createCGImage:qrcodeImage.CIImage fromRect:[qrcodeImage.CIImage extent]];
    UIImage * imageToSave = [UIImage imageWithCGImage:img];
    [self saveImage:imageToSave callback:callback];
    
}

- (void)QRCodeScanVcCallback:(WXModuleCallback)callback {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        __weak __typeof__(weexInstance) weakInstance = weexInstance;
        switch (status) {
            case AVAuthorizationStatusNotDetermined: {
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        if (granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                if([[NSThread currentThread] isMainThread]){
                                    MTWXQRCodeScanViewController*scanVc  = [[MTWXQRCodeScanViewController alloc] init];
                                    scanVc.callback = ^(id result) {
                                        callback(result);
                                    };
                                    [weakInstance.viewController.navigationController pushViewController:scanVc animated:YES];
                                }
                            });
                            
                            NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
                        } else {
                            NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                        }
                    }];
                });
                break;
            }
            case AVAuthorizationStatusAuthorized: {
                
                MTWXQRCodeScanViewController*scanVc  = [[MTWXQRCodeScanViewController alloc] init];
                scanVc.callback = ^(id result) {
                    callback(result);
                };
                [weexInstance.viewController.navigationController pushViewController:scanVc animated:YES];
                break;
            }
            case AVAuthorizationStatusDenied: {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 隐私 - 相机 - SGQRCodeExample] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                [alertC addAction:alertA];
                [[self getCurrentVC] presentViewController:alertC animated:YES completion:nil];
                break;
            }
            case AVAuthorizationStatusRestricted: {
                NSLog(@"因为系统原因, 无法访问相册");
                break;
            }
                
            default:
                break;
        }
        return;
    }
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertC addAction:alertA];
    [[self getCurrentVC] presentViewController:alertC animated:YES completion:nil];
}





- (void)saveImage:(UIImage *)image callback:(WXModuleCallback)callback  {
    //压缩图片
    NSData * imageData = UIImageJPEGRepresentation(image, 1);
    if(imageData.length / 1024.0 / 1024.0 >= 0.4)
    {
        imageData = UIImageJPEGRepresentation(image, 0.3);
    }
    if(imageData.length / 1024.0 / 1024.0 >= 0.4)
    {
        imageData = UIImageJPEGRepresentation(image, 0.1);
    }
    NSLog(@"size:%f",imageData.length / 1024.0 / 1024.0);
    
    //保存到一个指定目录
    NSError *error;
    NSFileManager *fmanager = [NSFileManager defaultManager];
    NSString *createPath = [self creatSaveImgPath];
    if (![fmanager fileExistsAtPath:createPath])
    {
        [fmanager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *imagePath = [createPath stringByAppendingPathComponent:[self fileName]];
    if([fmanager fileExistsAtPath:imagePath])
    {
        [fmanager removeItemAtPath:imagePath error:&error];
    }
    
    if([imageData writeToFile:imagePath atomically:YES])
    {
        if (callback) {
            callback(@{@"status":@"0",@"result":imagePath});
        }
    }
    else
    {
        if (callback) {
            callback(@{@"status":@"1000",@"result":@"生成二维码失败！"});
        }
    }
}

//创建存储路径
- (NSString *)creatSaveImgPath
{
    NSString *createPath = [NSString stringWithFormat:@"%@/%@/", PathCaches,kImgPickerDir];
    
    return createPath;
}

//文件名
-  (NSString *)fileName
{
    NSString *string = @"";
    for (int i = 0; i < 10; i++) {
        int number = arc4random() % 36;
        if (number < 10)
        {
            int figure = arc4random() % 10;
            NSString *tempString = [NSString stringWithFormat:@"%d", figure];
            string = [string stringByAppendingString:tempString];
        }
        else
        {
            int figure = (arc4random() % 26) + 97;
            char character = figure;
            NSString *tempString = [NSString stringWithFormat:@"%c", character];
            string = [string stringByAppendingString:tempString];
        }
    }
    
    return [NSString stringWithFormat:@"%@.jpg", string];
}


- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]){
        result = nextResponder;
    }
    else{
        result = window.rootViewController;
    }
    return result;
}

#pragma mark -- 实现图片加载协议
- (id<WXImageOperationProtocol>)downloadImageWithURL:(NSString *)url imageFrame:(CGRect)imageFrame userInfo:(NSDictionary *)userInfo completed:(void(^)(UIImage *image,  NSError *error, BOOL finished))completedBlock {
    
    if ([url hasPrefix:@"//"]) {
        url = [@"http:" stringByAppendingString:url];
    }
    
    return (id<WXImageOperationProtocol>)[[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        
        if (completedBlock) {
            completedBlock(image, error, finished);
        }
    }];
}

@end
