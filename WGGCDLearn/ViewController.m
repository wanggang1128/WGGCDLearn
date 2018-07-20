//
//  ViewController.m
//  WGGCDLearn
//
//  Created by wanggang on 2018/7/13.
//  Copyright © 2018年 wanggang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"GCD";
    
    [self atomic];
    
}

- (void)atomic{
    _number = 0;
    NSLock *lock = [[NSLock alloc] init];
    dispatch_apply(10000, dispatch_get_global_queue(0, 0), ^(size_t index) {
        [lock lock];
        self->_number ++;
        [lock unlock];
    });
    NSLog(@"_number:%d", _number);
}

#pragma mark - dispatch_semaphore_t
- (void)nonatomic{
    for (NSInteger i = 0; i < 10000; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self.name = [NSString stringWithFormat:@"name:%ld", i];
        });
    }
}

#pragma mark - dispatch_semaphore_t
/*
 信号量:控制我们的线程并发数
 */
- (void)semaphore{
    //线程并发数设为1,只有一个线程在走
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_queue_t queue = dispatch_queue_create("com.wanggang", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"1111");
        sleep(2);
        NSLog(@"2222");
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"3333");
        sleep(2);
        NSLog(@"4444");
        dispatch_semaphore_signal(semaphore);
    });
    NSLog(@"5555");
}

#pragma mark - synchronized
- (void)synchronized{
    dispatch_queue_t queue = dispatch_queue_create("com.wanggang", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        @synchronized (self){
            NSLog(@"1111");
            sleep(2);
            NSLog(@"2222");
        }
    });
    dispatch_async(queue, ^{
        @synchronized (self){
            NSLog(@"3333");
            sleep(2);
            NSLog(@"4444");
        }
    });
    NSLog(@"5555");
}

#pragma mark - dispatch_group_t
- (void)group{
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"1111");
            dispatch_group_leave(group);
        });
    });
    
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"2222");
        });
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"3333");
            dispatch_group_leave(group);
        });
    });
    
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"4444");
    });
    NSLog(@"5555");
}

#pragma mark - //dispatch_apply
- (void)apply{
    dispatch_queue_t queue = dispatch_queue_create("com.wanggang", DISPATCH_QUEUE_CONCURRENT);
    dispatch_apply(20, queue, ^(size_t index) {
        dispatch_async(queue, ^{
            NSLog(@"index=%ld线程:%@", index, [NSThread currentThread]);
        });
    });
    NSLog(@"end");
}

#pragma mark - //主队列中添加同步任务:死锁
- (void)main1{
    //任务1
    NSLog(@"1111");
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue, ^{
        //任务2
        NSLog(@"2222");
    });
    NSLog(@"3333");
}

#pragma mark - //主队列中添加异步任务
- (void)main{
    NSLog(@"1111");
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        NSLog(@"2222");
    });
    sleep(2);
    NSLog(@"3333");
}

#pragma mark - //异步串行嵌套同步任务:死锁
- (void)asyncSerialSync{
    NSLog(@"1111");
    dispatch_queue_t queue = dispatch_queue_create("com.wanggang", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        //block1:任务1
        NSLog(@"2222");
        dispatch_sync(queue, ^{
            //block2:任务2
            NSLog(@"3333");
        });
        NSLog(@"4444");
    });
    NSLog(@"5555");
}

#pragma mark - //同步串行嵌套异步任务
- (void)syncSerialAsync{
    NSLog(@"1111");
    dispatch_queue_t queue = dispatch_queue_create("com.wanggang", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(queue, ^{
        //block1:任务1
        NSLog(@"2222");
        dispatch_async(queue, ^{
            //block2:任务2
            NSLog(@"3333");
        });
        sleep(2);
        NSLog(@"4444");
    });
    sleep(2);
    NSLog(@"5555");
}


#pragma mark - //同步并行嵌套异步任务
- (void)syncConcurrentAsync{
    NSLog(@"1111");
    dispatch_queue_t queue = dispatch_queue_create("com.wanggang", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(queue, ^{
        NSLog(@"2222");
        dispatch_async(queue, ^{
            sleep(2);
            NSLog(@"3333");
        });
        NSLog(@"4444");
    });
    NSLog(@"5555");
}

#pragma mark - //同步并行
- (void)syncConcurrent{
    NSLog(@"1111");
    dispatch_queue_t queue = dispatch_queue_create("com.wanggang", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(queue, ^{
        NSLog(@"2222");
    });
    dispatch_sync(queue, ^{
        NSLog(@"3333");
    });
    dispatch_sync(queue, ^{
        NSLog(@"4444");
    });
    NSLog(@"5555");
}

#pragma mark - //异步并行
- (void)asyncConcurrent{
    NSLog(@"1111");
    dispatch_queue_t queue = dispatch_queue_create("com.wanggang", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"2222");
    });
    dispatch_async(queue, ^{
        NSLog(@"3333");
    });
    dispatch_async(queue, ^{
        NSLog(@"4444");
    });
    NSLog(@"5555");
}

#pragma mark - //异步串行
/*
 异步: 要想到的是不会阻塞当前线程,且具备开启线程的能力(不一定会创建子线程,例如在串行队列中,只会创建一条子线程)
 */
- (void)asyncSerial{
    NSLog(@"1111");
    dispatch_queue_t queue = dispatch_queue_create("com.wanggang", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        NSLog(@"2222");
    });
    dispatch_async(queue, ^{
        NSLog(@"3333");
    });
    dispatch_async(queue, ^{
        NSLog(@"4444");
    });
    NSLog(@"5555");
}

#pragma mark - //同步串行
/*
 同步: 看到这两个字首先想到的是不会开启子线程,而且会阻塞当前线程
 */

- (void)syncSerial{
    NSLog(@"1111");
    dispatch_queue_t queue = dispatch_queue_create("wanggang", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(queue, ^{
        NSLog(@"2222");
    });
    dispatch_sync(queue, ^{
        NSLog(@"3333");
    });
    dispatch_sync(queue, ^{
        NSLog(@"4444");
    });
    NSLog(@"5555");
}


@end
