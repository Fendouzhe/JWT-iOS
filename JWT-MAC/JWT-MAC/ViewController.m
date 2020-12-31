//
//  ViewController.m
//  JWT-MAC
//
//  Created by 雷路荣 on 2020/12/31.
//  Copyright © 2020 leilurong. All rights reserved.
//

#import "ViewController.h"
#import "JWT.h"
#import "MF_Base64Additions.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"private.json" ofType:nil]];
    NSError *error;
    NSDictionary *json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    //NSLog(@"json = %@",json);
    NSDictionary *headerDict = @{
      @"kid": json[@"key_id"],
      @"typ": @"JWT",
      @"alg": @"RS256"
    };
    NSDate *datenow = [NSDate date];
    NSTimeInterval interval = [datenow timeIntervalSince1970];
    //10位
    NSInteger timeSp = [[NSString stringWithFormat:@"%.0f",interval] integerValue];
    NSDictionary *payDict = @{
      @"aud": @"https://oauth-login.cloud.huawei.com/oauth2/v3/token",
      @"iss": json[@"sub_account"],
      @"exp": @(timeSp+3600),
      @"iat": @(timeSp)
    };
    
    ///2  参照简书：https://www.jianshu.com/p/dd15cdcae597 将私钥json[@"private_key"]生成p12文件，密码为123456，
    ///注意：私钥先放到text文件中，除了私钥的开头”-----BEGIN PRIVATE KEY-----“和结尾”-----END PRIVATE KEY-----“单独一行，其他每一行需要每64个字符换一行
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
    NSData *secretData = [NSData dataWithContentsOfFile:filePath];
    JWTBuilder *builder = [JWTBuilder encodePayload: payDict].headers(headerDict).secretData(secretData).algorithmName(JWTAlgorithmNameRS256).privateKeyCertificatePassphrase(@"123456");
    NSString *JWT = builder.encode;
    NSLog(@"JWT = %@ \n error = %@",JWT,builder.jwtError);
}


@end
