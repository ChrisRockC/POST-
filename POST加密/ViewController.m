//
//  ViewController.m
//  POST加密
//
//  Created by mac on 15/6/26.
//  Copyright (c) 2015年 CC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // 1. data
    NSString *path = [[NSBundle mainBundle] pathForResource:@"001.png" ofType:nil];
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    
    [self uploadFile:fileData fieldName:@"userfile" fileName:@"xxx.png"];
}

#define boundary @"cc-upload"

- (void)uploadFile:(NSData *)fileData fieldName:(NSString *)fieldName fileName:(NSString *)fileName {
    // 1. url － 负责上传文件的脚本
    NSURL *url = [NSURL URLWithString:@"http://192.168.13.85/post/upload.php"];
    
    // 2. request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 2.1 设置 content-type
    NSString *type = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:type forHTTPHeaderField:@"Content-Type"];
    
    // 2.2 设置数据体
    request.HTTPBody = [self formData:fileData fieldName:fieldName fileName:fileName];
    
    // 3. connection
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]);
    }];
}

/**
 --随便\r\n
 Content-Disposition: form-data; name="userfile"; filename="111.txt"\r\n
 Content-Type: application/octet-stream\r\n\r\n
 
 要上传文件的二进制数据
 \r\n
 --随便--
 */
- (NSData *)formData:(NSData *)fileData fieldName:(NSString *)fieldName fileName:(NSString *)fileName {
    NSMutableData *dataM = [NSMutableData data];
    
    NSMutableString *strM = [NSMutableString string];
    
    [strM appendFormat:@"--%@\r\n", boundary];
    [strM appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, fileName];
    [strM appendString:@"Content-Type: application/octet-stream\r\n\r\n"];
    
    // 先插入 strM
    [dataM appendData:[strM dataUsingEncoding:NSUTF8StringEncoding]];
    // 插入文件数据
    [dataM appendData:fileData];
    
    NSString *tail = [NSString stringWithFormat:@"\r\n--%@--", boundary];
    [dataM appendData:[tail dataUsingEncoding:NSUTF8StringEncoding]];
    
    return dataM.copy;
}

@end
