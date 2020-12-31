//
//  ViewController.m
//  88
//
//  Created by 雷路荣 on 16/2/22.
//  Copyright © 2016年 leilurong. All rights reserved.
//

#import "ViewController.h"
#import "JWT.h"
#import "MF_Base64Additions.h"

@interface ViewController ()

@end

@implementation ViewController

//字典转json格式字符串：
- (NSString*)dictionaryToJson:(NSDictionary *)dic{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"dict str = %@",str);
    return str;
}

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
    NSInteger timeSp = 1609379725;//[[NSString stringWithFormat:@"%.0f",interval] integerValue];//10位
    NSDictionary *payDict = @{
      @"aud": @"https://oauth-login.cloud.huawei.com/oauth2/v3/token",
      @"iss": json[@"sub_account"],
      @"exp": @(timeSp+3600),
      @"iat": @(timeSp)
    };
    NSString *header = [[self dictionaryToJson:headerDict] base64String];
    NSString *pay = [[self dictionaryToJson:payDict] base64String];
    NSString *encodeStr = [NSString stringWithFormat:@"%@.%@",header,pay];
    NSLog(@"encodeStr = %@",encodeStr);
    
    NSData *payloadData = [encodeStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *key = json[@"private_key"];
    NSData *secrectData = [key dataUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"payload = %@",payload);
    //NSLog(@"secrect = %@",secrect);
    
    ///1 用不了
//    JWTAlgorithmRSBase *rs = (JWTAlgorithmRSBase *)[JWTAlgorithmFactory algorithmByName:JWTAlgorithmNameRS256];
//    //rs.privateKeyCertificatePassphrase = @"私钥证书密码";
//    NSData *tokenData = [rs encodePayloadData:payloadData withSecret:secrectData];
//    //NSData *tokenData = [rs encodePayload:encodeStr withSecret:key];
//    NSLog(@"tokenData = %@",tokenData);
//    if(tokenData){
//        NSString *token = [[NSString alloc] initWithData:tokenData encoding:NSUTF8StringEncoding];
//        NSLog(@"token = %@",token);
//    }
    
    ///2  参照简书：https://www.jianshu.com/p/dd15cdcae597 将私钥json[@"private_key"]生成p12文件，密码为123456，
    ///注意：私钥先放到text文件中，除了私钥的开头”-----BEGIN PRIVATE KEY-----“和结尾”-----END PRIVATE KEY-----“单独一行，其他每一行需要每64个字符换一行
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
    NSData *secretData = [NSData dataWithContentsOfFile:filePath];
    JWTBuilder *builder = [JWTBuilder encodePayload: payDict].headers(headerDict).secretData(secretData).algorithmName(JWTAlgorithmNameRS256).privateKeyCertificatePassphrase(@"123456");
    NSString *JWT = builder.encode;
    NSLog(@"JWT = %@ \n error = %@",JWT,builder.jwtError);
    
    
    ///3 用不了
//    NSError *err = nil;
//    token = [JWT encodePayload:payDict withSecret:key withHeaders:headerDict algorithm:[JWTAlgorithmRSBase algorithm256] withError:&err];
//    NSLog(@"token = %@ err = %@",token,err);
    
}

@end






