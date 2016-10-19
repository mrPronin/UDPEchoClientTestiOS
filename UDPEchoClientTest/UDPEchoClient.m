#import "UDPEchoClient.h"

//
//  CFSocket imports
//
#import <CoreFoundation/CoreFoundation.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import <netinet/in.h>

static void dataAvailableCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    //
    //  receiving information sent back from the echo server
    //
    UDPEchoClient *       obj;
    
    obj = (__bridge UDPEchoClient *) info;
    CFDataRef dataRef = (CFDataRef)data;
    NSString *responseString = [NSString stringWithFormat:@"%s", CFDataGetBytePtr(dataRef)];
    [obj receiveResponse:responseString];
//    NSLog(@"data recieved (%s) ", CFDataGetBytePtr(dataRef));
}

@interface UDPEchoClient ()

@end

@implementation UDPEchoClient
{
    //
    //  socket for communication
    //
    CFSocketRef cfsocketout;
    
    //
    //  address object to store the host details
    //
    struct sockaddr_in  addr;
}

- (instancetype)initWithHostName:(NSString *)hostName andPort:(NSUInteger)port
{
    self = [super init];
    if (self) {
        
        //
        //  instantiating the CFSocketRef
        //
        const CFSocketContext   context = { 0, (__bridge void *)(self), NULL, NULL, NULL };
        cfsocketout = CFSocketCreate(kCFAllocatorDefault,
                                     PF_INET,
                                     SOCK_DGRAM,
                                     IPPROTO_UDP,
                                     kCFSocketDataCallBack,
                                     dataAvailableCallback,
                                     &context);
        
        memset(&addr, 0, sizeof(addr));
        
        addr.sin_len            = sizeof(addr);
        addr.sin_family         = AF_INET;
        addr.sin_port           = htons(port);
        const char *ip = [hostName cStringUsingEncoding:NSUTF8StringEncoding];
        addr.sin_addr.s_addr    = inet_addr(ip);
        
        //
        // set runloop for data reciever
        //
        CFRunLoopSourceRef rls = CFSocketCreateRunLoopSource(kCFAllocatorDefault, cfsocketout, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopCommonModes);
        CFRelease(rls);
    }
    return self;
}


- (instancetype)init
{
    self = [super init];
    return self;
}


//
//  returns true upon successfull sending
//
- (BOOL)sendData:(const char *)msg
{
    //
    //  checking, is my socket is valid
    //
    if(cfsocketout)
    {
        //
        //  making the data from the address
        //
        CFDataRef addr_data = CFDataCreate(NULL, (const UInt8*)&addr, sizeof(addr));
        
        //
        //  making the data from the message
        //
        CFDataRef msg_data  = CFDataCreate(NULL, (const UInt8*)msg, strlen(msg));
        
        //
        //  actually sending the data & catch the status
        //
        CFSocketError socketErr = CFSocketSendData(cfsocketout,
                                                   addr_data,
                                                   msg_data,
                                                   0);
        
        //
        //  return true/false upon return value of the send function
        //
        return (socketErr == kCFSocketSuccess);
        
    }
    else
    {
        NSLog(@"socket reference is null");
        return false;
    }
}

- (void)receiveResponse:(NSString *)responseString
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(echo:didReceiveResponse:)]) {
        [self.delegate echo:self didReceiveResponse:responseString];
    }
}

@end
