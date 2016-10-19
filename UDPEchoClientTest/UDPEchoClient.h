#import <Foundation/Foundation.h>

@protocol UDPEchoDelegate;

@interface UDPEchoClient : NSObject

@property (nonatomic, weak,   readwrite) id<UDPEchoDelegate>    delegate;

- (instancetype)initWithHostName:(NSString *)hostName andPort:(NSUInteger)port;
- (BOOL) sendData:(const char *)msg;
- (void)receiveResponse:(NSString *)responseString;

@end

@protocol UDPEchoDelegate <NSObject>

@optional

- (void)echo:(UDPEchoClient *)echo didReceiveResponse:(NSString *)responseString;

@end
