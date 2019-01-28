/**
 * Created by Weex.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the Apache Licence 2.0.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import "MTDemoViewController.h"
#import <WeexSDK/WeexSDK.h>

@interface MTDemoViewController ()

/** weex 渲染的实例对象 */
@property (nonatomic, strong) WXSDKInstance *instance;
/** weex 渲染展示的视图 */
@property (nonatomic, strong) UIView *weexView;
/** js源地址 */
@property (nonatomic, strong) NSURL *sourceURL;

@end

@implementation MTDemoViewController

- (void)dealloc {
    // 切记在viewController的销毁的同时，将weex实例一并销毁，否则会出现内存泄露
    [_instance destroyInstance];
}

- (instancetype)initWithSourceURL:(NSURL *)sourceURL {
    if ((self = [super init])) {
        self.sourceURL = sourceURL;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if ([self.navigationController isKindOfClass:[WXRootViewController class]]) {
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        frame.size.height = [UIScreen mainScreen].bounds.size.height;
        self.view.frame = frame;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //渲染weex页面
    [self renderWithURL:self.sourceURL];
}

#pragma mark - 生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - render渲染
- (void)renderWithURL:(NSURL *)sourceURL {
    
    if (!sourceURL) return;

    //创建渲染实例对象
    _instance = [[WXSDKInstance alloc] init];
    _instance.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height);
    _instance.pageObject = self;
    _instance.pageName = sourceURL.absoluteString;
    _instance.viewController = self;  //设置渲染控制器
    
    // 为了避免循环引用，声明一个弱指针
    __weak typeof(self) weakSelf = self;
    
    // 设置 WXSDKInstance 创建完的回调
    // _instance.onCreate：weex页面最外层body渲染完成后的回调,
    // 在此回调中，weex渲染所得的rootView已确定，可以输出并添加到父容器中。
    _instance.onCreate = ^(UIView *view) {
        [weakSelf.weexView removeFromSuperview];
        weakSelf.weexView = view;
        [weakSelf.view addSubview:weakSelf.weexView];
    };
    
    // 设置 WXSDKInstance 出错时的回调
    _instance.onFailed = ^(NSError *error) {
        NSLog(@"处理失败:%@", error);
    };
    
    // 设置 WXSDKInstance 渲染完成时的回调
    // _instance.renderFinish：和onCreate不同，renderFinish表示所有weex的页面元素都已渲染完毕，整个渲染过程至此结束。
    _instance.renderFinish = ^(UIView *view) {
         NSLog(@"渲染完成!!!");
    };
    
    /* desc 设置 WXSDKInstance 用于渲染js的url路径
     @param url参数: 是从weex 编译运行后出来的app.js或app.weex.js 文件, 可以放在远程服务器上, 也可以直接拖进项目工程里.
     @param options参数，表示开发者可以通过WeexSDK向 前端 透传的参数，如bundleUrl,
     @param data参数，表示向weex的模板注入的页面数据,它一般来源于native的数据请求，当然也可以在前端逻辑中完成请求后将数据注入
     */
    [_instance renderWithURL:self.sourceURL options:@{@"bundleUrl":[self.sourceURL absoluteString]} data:nil];
}

@end
