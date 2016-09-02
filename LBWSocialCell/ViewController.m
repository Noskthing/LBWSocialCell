//
//  ViewController.m
//  LBWSocialCell
//
//  Created by ml on 16/7/22.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "ViewController.h"
#import "LBWSocialTableViewCell.h"


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    LBWSocialTableViewModel * _model;
}
@property (nonatomic,strong)UITableView * tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _model = [[LBWSocialTableViewModel alloc] init];
    _model.nickName = @"简单的测试";
    _model.source = @"2小时前 来自LBWSocialCell";
    _model.iconUrl = @"http://tva1.sinaimg.cn/crop.0.0.2048.2048.50/c0894007jw8eo090gvai2j21kw1kwgox.jpg";
    _model.content = @"今天是公元2016年[不开心][不开心][不开心][不开心]七十风为@李侧女 发送http://weibo.com/tva1sinaimgcn/crop50/c0894007jw8eo090gvai2j21kw1kwgoxjpg12342我今天公元2016年[不开心]七十发送我今天是公元风为[不开心]的艾[不开心]七十风打我我发是";
    _model.contentSize = [_model.content textSizeWithConstrainedOfMaxSize:CGSizeMake(self.view.frame.size.width - 20, CGFLOAT_MAX) font:[UIFont systemFontOfSize:15] lineSpace:2 lineBreakMode:kCTLineBreakByCharWrapping];
    _model.repostContent = @"@momoyao:今天是公元2016年[不开心][不开心][不开心][不开心]七十风为@李侧女 发送http://weibo.com/tva1sinaimgcn/crop50/c0894007jw8eo090gvai2j21kw1kwgoxjpg12342我今天公元2016年[不开心]七十发送我今天是公元风为[不开心]的艾[不开心]七十风打我我发是";
    _model.repostContentSize = [_model.repostContent textSizeWithConstrainedOfMaxSize:CGSizeMake(self.view.frame.size.width - 20, CGFLOAT_MAX) font:[UIFont systemFontOfSize:15] lineSpace:2 lineBreakMode:kCTLineBreakByCharWrapping];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 40) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 300;

    [_tableView registerClass:[LBWSocialTableViewCell class] forCellReuseIdentifier:@"test"];
    [self.view addSubview:_tableView];
    
//    UIImageView * view = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
//    UIImage * image = [UIImage imageNamed:@"wheel"];
//    view.image = [image filterImageWithColor:[UIColor grayColor]];
//    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -tableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LBWSocialTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"test" forIndexPath:indexPath];
//    if (_model)
//    {
        [cell drawContentWithModel:_model];
//    }
    return cell;
}
@end
