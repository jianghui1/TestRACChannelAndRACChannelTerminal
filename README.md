##### `RACChannelTerminal`作为`RACSignal`的子类，同时也遵守了`RACSubscriber`协议。但是，该类是放在`RACChannel`文件中的，所以与`RACChannel`关系密切。所以接下来会分别对这两个类同时分析。

***

首先，分析`RACChannelTerminal`类，打开`RACChannel.h`文件：

    /// Represents one end of a RACChannel.
    ///
    /// An terminal is similar to a socket or pipe -- it represents one end of
    /// a connection (the RACChannel, in this case). Values sent to this terminal
    /// will _not_ be received by its subscribers. Instead, the values will be sent
    /// to the subscribers of the RACChannel's _other_ terminal.
    ///
    /// For example, when using the `followingTerminal`, _sent_ values can only be
    /// _received_ from the `leadingTerminal`, and vice versa.
    ///
    /// To make it easy to terminate a RACChannel, `error` and `completed` events
    /// sent to either terminal will be received by the subscribers of _both_
    /// terminals.
    ///
    /// Do not instantiate this class directly. Create a RACChannel instead.
    @interface RACChannelTerminal : RACSignal <RACSubscriber>
    
    - (id)init __attribute__((unavailable("Instantiate a RACChannel instead")));
    
    @end
可以看到，不应该直接实例化该类，而是通过`RACChannel`生成`RACChannelTerminal`对象。

而且，该类的注释很长，翻译如下：

    代表一个`RACChannel`的端点。
    
    一个`RACChannelTerminal`对象就像一个`socket` or `pipe` ---- 它代表一个连接的端点（这里，就是`RACChannel`的端点）。一个`RACChannelTerminal`的信号值不会被它的订阅者接收到，而是被`RACChannel`的其他`RACChannelTerminal`对象的订阅者接收到。
    
    例如，对于`RACChannel`，当使用`followingTerminal`时发送的信号值是从`leadingTerminal`得到的。反过来也是一样。
    
    为了简单的结束一个`RACChannel`，任何一个`RACChannelTerminal`的错误事件或者完成事件都会被`RACChannel`所有的`RACChannelTerminal`的订阅者接收到。
    
    不要直接初始化这个类，而应该通过`RACChannel`来创建。

接着，看下`.m`文件：

    @interface RACChannelTerminal ()
    
    // The values for this terminal.
    @property (nonatomic, strong, readonly) RACSignal *values;
    
    // A subscriber will will send values to the other terminal.
    @property (nonatomic, strong, readonly) id<RACSubscriber> otherTerminal;
    
    - (id)initWithValues:(RACSignal *)values otherTerminal:(id<RACSubscriber>)otherTerminal;
    
    @end
* 属性`values`代表该对象用于被订阅者订阅的信号。
* 属性`otherTerminal`代表另外一个遵守`RACSubscriber`协议的对象，该对象向其他端点对象发送信号值。
* 私有方法，用于初始化该类的一个对象。

        - (id)initWithValues:(RACSignal *)values otherTerminal:(id<RACSubscriber>)otherTerminal {
        	NSCParameterAssert(values != nil);
        	NSCParameterAssert(otherTerminal != nil);
        
        	self = [super init];
        	if (self == nil) return nil;
        
        	_values = values;
        	_otherTerminal = otherTerminal;
        
        	return self;
        }
实例化一个对象，并将参数`values` `otherTerminal`保存到实例变量当中。

    - (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber {
    	return [self.values subscribe:subscriber];
    }
重写`subscribe:`方法。注意，这里其实是对`self.values`的订阅，并不是自身的订阅。

    - (void)sendNext:(id)value {
    	[self.otherTerminal sendNext:value];
    }
通过`self.otherTerminal`发送信号值。

    - (void)sendError:(NSError *)error {
    	[self.otherTerminal sendError:error];
    }
通过`self.otherTerminal`发送信号的错误信息。

    - (void)sendCompleted {
    	[self.otherTerminal sendCompleted];
    }
通过`self.otherTerminal`发送信号的完成信息。

    - (void)didSubscribeWithDisposable:(RACCompoundDisposable *)disposable {
    	[self.otherTerminal didSubscribeWithDisposable:disposable];
    }
通过`self.otherTerminal`将`disposable`添加到`otherTerminal`的清理对象当中。

所以，当该类被订阅的时候，其实是订阅的其他信号。当该类发送信号信息时，其实是使用`otherTerminal`发送信号信息。

***

既然`RACChannelTerminal`通过`RACChannel`初始化的，那么就看看`RACChannel`类的代码。打开`RACChannel.h`文件：

    /// A two-way channel.
    ///
    /// Conceptually, RACChannel can be thought of as a bidirectional connection,
    /// composed of two controllable signals that work in parallel.
    ///
    /// For example, when connecting between a view and a model:
    ///
    ///        Model                      View
    ///  `leadingTerminal` ------> `followingTerminal`
    ///  `leadingTerminal` <------ `followingTerminal`
    ///
    /// The initial value of the model and all future changes to it are _sent on_ the
    /// `leadingTerminal`, and _received by_ subscribers of the `followingTerminal`.
    ///
    /// Likewise, whenever the user changes the value of the view, that value is sent
    /// on the `followingTerminal`, and received in the model from the
    /// `leadingTerminal`. However, the initial value of the view is not received
    /// from the `leadingTerminal` (only future changes).
    @interface RACChannel : NSObject
    
    /// The terminal which "leads" the channel, by sending its latest value
    /// immediately to new subscribers of the `followingTerminal`.
    ///
    /// New subscribers to this terminal will not receive a starting value, but will
    /// receive all future values that are sent to the `followingTerminal`.
    @property (nonatomic, strong, readonly) RACChannelTerminal *leadingTerminal;
    
    /// The terminal which "follows" the lead of the other terminal, only sending
    /// _future_ values to the subscribers of the `leadingTerminal`.
    ///
    /// The latest value sent to the `leadingTerminal` (if any) will be sent
    /// immediately to new subscribers of this terminal, and then all future values
    /// as well.
    @property (nonatomic, strong, readonly) RACChannelTerminal *followingTerminal;
    
    @end
该类其实有两个实例变量`leadingTerminal` `followingTerminal`，他们都是`RACChannelTerminal`类型的。注释中介绍了很多信息，翻译一下：

    一个双通道。
    
    一般来说，`RACChannel`可以被当做一个 双向的连接。有两个平行工作的信号组成。
    
    例如，在 一个`view` 和 一个`modal` 的连接过程当中，
          Model                      View
      `leadingTerminal` ------> `followingTerminal`
      `leadingTerminal` <------ `followingTerminal`
     
    这个`modal`的初始值以及以后所有的变化值都会由`leadingTerminal`发送，并且由`followingTerminal`的订阅者接收。
    
    同样的，无论什么时候用户改变了`view`的值，这些值将会由`followingTerminal`发送，并且发送的值通过`leadingTerminal`传递给`model`。然而，`view`的初始值不会从`leadingTerminal`收到，仅仅会收到`view`以后的变化值。
    
`leadingTerminal`的注释翻译如下：
    
    这个对象是`channel`对象的头，通过立即发送最新的值给`followingTerminal`的订阅者。
    
    这个对象新的订阅者不会收到已经开始的值。但是会收到`followingTerminal`以后发送的所有值。

`followingTerminal`的注释翻译如下：
    
    这个对象跟随着 `RACChannelTerminal`对象的头。仅仅发送将来的值给`leadingTerminal`的订阅者。
    
    `leadingTerminal`已经发送的最新值将会被立即发送给`followingTerminal`的新的订阅者，以后的值也会同样发送。

接着看下`.m`文件：

    - (id)init {
    	self = [super init];
    	if (self == nil) return nil;
    
    	// We don't want any starting value from the leadingSubject, but we do want
    	// error and completion to be replayed.
    	RACReplaySubject *leadingSubject = [[RACReplaySubject replaySubjectWithCapacity:0] setNameWithFormat:@"leadingSubject"];
    	RACReplaySubject *followingSubject = [[RACReplaySubject replaySubjectWithCapacity:1] setNameWithFormat:@"followingSubject"];
    
    	// Propagate errors and completion to everything.
    	[[leadingSubject ignoreValues] subscribe:followingSubject];
    	[[followingSubject ignoreValues] subscribe:leadingSubject];
    
    	_leadingTerminal = [[[RACChannelTerminal alloc] initWithValues:leadingSubject otherTerminal:followingSubject] setNameWithFormat:@"leadingTerminal"];
    	_followingTerminal = [[[RACChannelTerminal alloc] initWithValues:followingSubject otherTerminal:leadingSubject] setNameWithFormat:@"followingTerminal"];
    
    	return self;
    }
重写`init`方法，分步骤分析如下：
1. 创建两个`RACReplaySubject`对象，注意，`leadingSubject`的`capacity`是0，而`followingSubject`的是1。为什么要这样子做呢？注释说：
    
        我们不想要`leadingSubject`的任何开始的值，但是我们想要获得`error` `completion`信息。
通过之前文章对`RACSubject`的分析，可以知道只有`RACReplaySubject`能够保证`error` `completed` 的重复订阅，所以这里创建了两个`RACReplaySubject`对象。既然不想要`leadingSuject`的订阅者收到之前的值，这里才设置其`capacity`为0。而`followingSubject`的`capacity`设置为1，这样他的订阅者就可以收到之前发送的最后一个值。

2. 接着`followingSubject`订阅`leadingSubject`，而`leadingSubject`订阅`followingSubject`。同时，调用`ignoreValues`忽略信号所有的值。也正如注释所说，只订阅`errors`和`completion`。那么，这里为什么要让这两个对象相互订阅呢？其实是为了保证两者同时结束。假如`leadingSubject`发送`error`or`completed`，由于`followingSubject`订阅了它，所以`followingSubject`也会发送`error`or`completed`。但是，这样并不会造成循环调用，因为虽然`followingSubject`订阅了`leadingSubject`，但是`leadingSubject`持有的其实是`RACPassthroughSubscriber`对象，而且其对应的方法是这样子的：

        - (void)sendError:(NSError *)error {
        	if (self.disposable.disposed) return;
        
        	if (RACSIGNAL_ERROR_ENABLED()) {
        		RACSIGNAL_ERROR(cleanedSignalDescription(self.signal), cleanedDTraceString(self.innerSubscriber.description), cleanedDTraceString(error.description));
        	}
        
        	[self.innerSubscriber sendError:error];
        }
        
        - (void)sendCompleted {
        	if (self.disposable.disposed) return;
        
        	if (RACSIGNAL_COMPLETED_ENABLED()) {
        		RACSIGNAL_COMPLETED(cleanedSignalDescription(self.signal), cleanedDTraceString(self.innerSubscriber.description));
        	}
        
        	[self.innerSubscriber sendCompleted];
        }
可以看到，当清理对象做了清理工作时，就不会继续发送事件了。所以这里并不会造成循环调用。

3. 下面就是通过`leadingSubject`和`followingSubject`创建了`_leadingTerminal`和`_followingTerminal`。到此，完成了该类的初始化。

完整测试用例在[这里](https://github.com/jianghui1/TestRACChannelAndRACChannelTerminal)。
    
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


其实`RACChannel`还有个子类`RACKVOChannel`，接下来会分析。
