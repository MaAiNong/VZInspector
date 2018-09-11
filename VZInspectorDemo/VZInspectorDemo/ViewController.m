//
//  ViewController.m
//  VZInspectorDemo
//
//  Created by moxin on 9/11/18.
//  Copyright © 2018 Tao Xu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) id list;
@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) NSMutableArray* items;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(load)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(memoryPeek)];
    
    self.items = [NSMutableArray new];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-64)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"3d2"]];
    //    imageView.frame = CGRectMake(20, 20, 80, 80);
    //    imageView.clipsToBounds = YES;
    //    [self.view addSubview: imageView];
    
    [self load];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"vzline"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"vzline"];
    }
    
    NSDictionary* info = self.items[indexPath.row];
    
    
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = info[@"text"];
    [cell.textLabel sizeToFit];
    
    return cell;
    
}

- (void)load
{
    [self.items removeAllObjects];
    [self.tableView reloadData];
    self.tableView.tableFooterView = [self loadingFooterView];
    
    NSString* url = @"https://api.app.net/stream/0/posts/stream/global";
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(data){
            
            NSDictionary* JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            for (NSDictionary* dict in JSON[@"data"]) {
                [self.items addObject:dict];
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.tableView.tableFooterView = nil;
                [self.tableView reloadData];
                
            });
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                self.tableView.tableFooterView = nil;
            });
        }
        
        
    }] resume];
    
}

- (void)memoryPeek
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"alloc memory" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
    
    _list = [NSMutableArray new];
    
    for (int i=0; i<999999; i++) {
        
        // @autoreleasepool {
        NSObject* obj = [NSObject new];
        [_list addObject:obj];
        // }
        
        
    }
    
}
- (UIView* )loadingFooterView
{
    UIView* v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds)-20)/2, 11, 20, 20)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [indicator startAnimating];
    [v addSubview:indicator];
    
    return v;
}


@end
