//
//  OCUnitTestTests.m
//  OCUnitTestTests
//
//  Created by yleaf on 2021/7/24.
//

#import <XCTest/XCTest.h>

@interface Downloader : NSObject
@property (nonatomic,assign)NSInteger count;
- (void)download:(NSURL *)url completionHandler:(void (^)(BOOL success, NSURLResponse *response, NSError * error))completionHandler;

@end

@implementation Downloader


- (void)download:(NSURL *)url completionHandler:(void (^)(BOOL success, NSURLResponse *response, NSError * error))completionHandler {
    


    
    self.count++;

    NSInteger temp = self.count;
    
    // 2.创建请求 并：设置缓存策略为每次都从网络加载 超时时间30秒
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];

    // 3.采用苹果提供的共享session
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    
    // 4.由系统直接返回一个dataTask任务
    NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 网络请求完成之后就会执行，NSURLSession自动实现多线程
        NSLog(@"%@",[NSThread currentThread]);
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        
            if (temp == self->_count) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                NSInteger statusCode = httpResponse.statusCode;
                
                if (statusCode >= 200 && statusCode <= 206) {
                    completionHandler(true,response,nil);
                }
                else {
                    completionHandler(false,response,error);
                }
            }
            
        }
        else {
            
        }

    }];
    
    // 5.每一个任务默认都是挂起的，需要调用 resume 方法
    [dataTask resume];
}

@end

@interface OCUnitTestTests : XCTestCase
@property (nonnull, strong) Downloader *d;
@end


@implementation OCUnitTestTests

static NSTimeInterval kWaitTime = 30;

- (void)setUp {
    self.d = [[Downloader alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testDownload {
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
    
    
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/users"];
    [self.d download:url completionHandler:^(BOOL success, NSURLResponse *response, NSError *error) {
        if (success) {
            [expectation fulfill];
        } else {
            XCTFail("");
        }
    }];
    
    [self waitForExpectationsWithTimeout:kWaitTime handler:^(NSError * _Nullable error) {
            
    }];
}


- (void)testDownloadFail {
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
    
    
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/user"];
    [self.d download:url completionHandler:^(BOOL success, NSURLResponse *response, NSError *error) {
        if (!success) {
            [expectation fulfill];
        } else {
            XCTFail("");
        }
    }];
    
    [self waitForExpectationsWithTimeout:kWaitTime handler:^(NSError * _Nullable error) {
            
    }];
}

- (void)testDownloadFailTwo {
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
    
    
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/user1111"];
    [self.d download:url completionHandler:^(BOOL success, NSURLResponse *response, NSError *error) {
        if (!success) {
            [expectation fulfill];
        } else {
            XCTFail("");
        }
    }];
    
    [self waitForExpectationsWithTimeout:kWaitTime handler:^(NSError * _Nullable error) {
            
    }];
}

- (void)testRemovePreviousDownload {
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
    
    
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/users"];
    
    int count = arc4random_uniform(10);
    
    for (int i = 0; i < count; i++) {
        [self.d download:url completionHandler:^(BOOL success, NSURLResponse *response, NSError *error) {
            XCTFail("");
        }];
    }
    
    [self.d download:url completionHandler:^(BOOL success, NSURLResponse *response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [expectation fulfill];
        });
    }];
    
    [self waitForExpectationsWithTimeout:kWaitTime handler:^(NSError * _Nullable error) {
            
    }];
}

@end
