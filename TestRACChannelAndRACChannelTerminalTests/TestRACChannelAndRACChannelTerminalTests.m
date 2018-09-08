//
//  TestRACChannelAndRACChannelTerminalTests.m
//  TestRACChannelAndRACChannelTerminalTests
//
//  Created by ys on 2018/8/27.
//  Copyright © 2018年 ys. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <ReactiveCocoa.h>

@interface TestRACChannelAndRACChannelTerminalTests : XCTestCase

@end

@interface Model : NSObject

@property (nonatomic, copy) NSString *name;

@end

@implementation Model

@end

@interface View : NSObject

@property (nonatomic, copy) NSString *labelText;

@end

@implementation View

@end

@implementation TestRACChannelAndRACChannelTerminalTests

- (void)test_channel1
{
    RACChannel *channel = [[RACChannel alloc] init];
    
    [channel.leadingTerminal subscribeNext:^(id x) {
        NSLog(@"channel -- leading -- %@", x);
    } error:^(NSError *error) {
        NSLog(@"channel -- leading -- error");
    } completed:^{
        NSLog(@"channel -- leading -- completed");
    }];
    
    [channel.followingTerminal subscribeNext:^(id x) {
        NSLog(@"channel -- following -- %@", x);
    } error:^(NSError *error) {
        NSLog(@"channel -- following -- error");
    } completed:^{
        NSLog(@"channel -- following -- completed");
    }];
    
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(1)];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(2)];
        [subscriber sendError:nil];
        
        return nil;
    }];
    
    [signal1 subscribe:channel.leadingTerminal];
    [signal2 subscribe:channel.followingTerminal];
    
    // 打印日志：
    /*
     2018-08-27 17:57:20.531682+0800 TestRACChannelAndRACChannelTerminal[2721:4239128] channel -- following -- 1
     2018-08-27 17:57:20.532169+0800 TestRACChannelAndRACChannelTerminal[2721:4239128] channel -- leading -- completed
     2018-08-27 17:57:20.532710+0800 TestRACChannelAndRACChannelTerminal[2721:4239128] channel -- following -- completed
     */
}

- (void)test_channel2
{
    RACChannel *channel = [[RACChannel alloc] init];
    
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(1)];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(2)];
        [subscriber sendError:nil];
        
        return nil;
    }];
    
    [signal1 subscribe:channel.leadingTerminal];
    
    [channel.leadingTerminal subscribeNext:^(id x) {
        NSLog(@"channel -- leading -- %@", x);
    } error:^(NSError *error) {
        NSLog(@"channel -- leading -- error");
    } completed:^{
        NSLog(@"channel -- leading -- completed");
    }];
    
    [channel.followingTerminal subscribeNext:^(id x) {
        NSLog(@"channel -- following -- %@", x);
    } error:^(NSError *error) {
        NSLog(@"channel -- following -- error");
    } completed:^{
        NSLog(@"channel -- following -- completed");
    }];
    
    [signal2 subscribe:channel.followingTerminal];
    
    // 打印日志：
    /*
     2018-08-27 17:58:31.369902+0800 TestRACChannelAndRACChannelTerminal[2783:4242954] channel -- leading -- completed
     2018-08-27 17:58:31.370140+0800 TestRACChannelAndRACChannelTerminal[2783:4242954] channel -- following -- 1
     2018-08-27 17:58:31.370276+0800 TestRACChannelAndRACChannelTerminal[2783:4242954] channel -- following -- completed
     */
}

- (void)test_channel3
{
    RACChannel *channel = [[RACChannel alloc] init];
    
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(1)];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(2)];
        [subscriber sendError:nil];
        
        return nil;
    }];
    
    [signal1 subscribe:channel.leadingTerminal];
    
    [signal2 subscribe:channel.followingTerminal];
    
    [channel.leadingTerminal subscribeNext:^(id x) {
        NSLog(@"channel -- leading -- %@", x);
    } error:^(NSError *error) {
        NSLog(@"channel -- leading -- error");
    } completed:^{
        NSLog(@"channel -- leading -- completed");
    }];
    
    [channel.followingTerminal subscribeNext:^(id x) {
        NSLog(@"channel -- following -- %@", x);
    } error:^(NSError *error) {
        NSLog(@"channel -- following -- error");
    } completed:^{
        NSLog(@"channel -- following -- completed");
    }];
    
    // 打印日志：
    /*
     2018-08-27 18:02:56.176628+0800 TestRACChannelAndRACChannelTerminal[2962:4256112] channel -- leading -- completed
     2018-08-27 18:02:56.176879+0800 TestRACChannelAndRACChannelTerminal[2962:4256112] channel -- following -- 1
     2018-08-27 18:02:56.177093+0800 TestRACChannelAndRACChannelTerminal[2962:4256112] channel -- following -- completed
     */
}

- (void)test_channel11
{
    RACChannel *channel = [[RACChannel alloc] init];
    
    [channel.leadingTerminal subscribeNext:^(id x) {
        NSLog(@"channel -- leading -- %@", x);
    } error:^(NSError *error) {
        NSLog(@"channel -- leading -- error");
    } completed:^{
        NSLog(@"channel -- leading -- completed");
    }];
    
    [channel.followingTerminal subscribeNext:^(id x) {
        NSLog(@"channel -- following -- %@", x);
    } error:^(NSError *error) {
        NSLog(@"channel -- following -- error");
    } completed:^{
        NSLog(@"channel -- following -- completed");
    }];
    
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(1)];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(2)];
        [subscriber sendError:nil];
        
        return nil;
    }];
    
    [signal2 subscribe:channel.followingTerminal];
    [signal1 subscribe:channel.leadingTerminal];
    
    // 打印日志：
    /*
     2018-08-27 18:04:01.792470+0800 TestRACChannelAndRACChannelTerminal[3019:4259803] channel -- leading -- 2
     2018-08-27 18:04:01.792733+0800 TestRACChannelAndRACChannelTerminal[3019:4259803] channel -- following -- error
     2018-08-27 18:04:01.792859+0800 TestRACChannelAndRACChannelTerminal[3019:4259803] channel -- leading -- error
     */
}

- (void)test_channel12
{
    RACChannel *channel = [[RACChannel alloc] init];
    
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(1)];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(2)];
        [subscriber sendError:nil];
        
        return nil;
    }];
    
    [signal2 subscribe:channel.followingTerminal];
    
    [channel.leadingTerminal subscribeNext:^(id x) {
        NSLog(@"channel -- leading -- %@", x);
    } error:^(NSError *error) {
        NSLog(@"channel -- leading -- error");
    } completed:^{
        NSLog(@"channel -- leading -- completed");
    }];
    
    [channel.followingTerminal subscribeNext:^(id x) {
        NSLog(@"channel -- following -- %@", x);
    } error:^(NSError *error) {
        NSLog(@"channel -- following -- error");
    } completed:^{
        NSLog(@"channel -- following -- completed");
    }];
    
    [signal1 subscribe:channel.leadingTerminal];
    
    // 打印日志：
    /*
     2018-08-27 18:08:08.847385+0800 TestRACChannelAndRACChannelTerminal[3191:4272163] channel -- leading -- error
     2018-08-27 18:08:08.847591+0800 TestRACChannelAndRACChannelTerminal[3191:4272163] channel -- following -- error
     */
}

- (void)test_channel13
{
    RACChannel *channel = [[RACChannel alloc] init];
    
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(1)];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(2)];
        [subscriber sendError:nil];
        
        return nil;
    }];
    
    [signal2 subscribe:channel.followingTerminal];
    [signal1 subscribe:channel.leadingTerminal];
    
    [channel.leadingTerminal subscribeNext:^(id x) {
        NSLog(@"channel -- leading -- %@", x);
    } error:^(NSError *error) {
        NSLog(@"channel -- leading -- error");
    } completed:^{
        NSLog(@"channel -- leading -- completed");
    }];
    
    [channel.followingTerminal subscribeNext:^(id x) {
        NSLog(@"channel -- following -- %@", x);
    } error:^(NSError *error) {
        NSLog(@"channel -- following -- error");
    } completed:^{
        NSLog(@"channel -- following -- completed");
    }];
    
    // 打印日志：
    /*
     2018-08-27 18:08:59.462893+0800 TestRACChannelAndRACChannelTerminal[3236:4274939] channel -- leading -- error
     2018-08-27 18:08:59.466973+0800 TestRACChannelAndRACChannelTerminal[3236:4274939] channel -- following -- error
     */
}

- (void)test_model_view
{
    Model *model = [[Model alloc] init];
    model.name = @"model";
    View *view = [[View alloc] init];
    view.labelText = @"view";
    
    RACChannel *channel = [[RACChannel alloc] init];
    [RACObserve(model, name) subscribe:channel.leadingTerminal];
    [RACObserve(view, labelText) subscribe:channel.followingTerminal];
    
    [channel.leadingTerminal subscribeNext:^(id x) {
        NSLog(@"model_view -- leading -- %@", x);
    } error:^(NSError *error) {
        NSLog(@"model_view -- leading -- error");
    } completed:^{
        NSLog(@"model_view -- leading -- completed");
    }];
    
    [channel.followingTerminal subscribeNext:^(id x) {
        NSLog(@"model_view -- following -- %@", x);
    } error:^(NSError *error) {
        NSLog(@"model_view -- following -- error");
    } completed:^{
        NSLog(@"model_view -- following -- completed");
    }];
    
    // 打印日志：
    /*
     2018-09-08 18:30:09.141433+0800 TestRACChannelAndRACChannelTerminal[56945:12269466] model_view -- following -- model
     2018-09-08 18:30:09.141923+0800 TestRACChannelAndRACChannelTerminal[56945:12269466] model_view -- following -- completed
     2018-09-08 18:30:09.142076+0800 TestRACChannelAndRACChannelTerminal[56945:12269466] model_view -- leading -- completed
     */
}

@end
