//
//  ViewController.m
//  UDPEchoClientTest
//
//  Created by Aleksandr Pronin on 10/19/16.
//  Copyright © 2016 Aleksandr Pronin. All rights reserved.
//

#import "ViewController.h"
#import "UDPEchoClient.h"

@interface ViewController () <UDPEchoDelegate>

@property(strong, nonatomic) UDPEchoClient *echo;
@property (nonatomic, strong, readwrite) NSTimer *sendTimer;
@property (strong, nonatomic) NSMutableString *logString;
@property (assign, nonatomic) NSUInteger lineNumber;

- (void)runClientWithHost:(NSString *)host port:(NSUInteger)port;

@property (weak, nonatomic) IBOutlet UITextField *hostNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;

- (IBAction)startTestAction:(id)sender;
- (IBAction)stopTestAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hostNameTextField.text = @"127.0.0.1";
    self.portTextField.text = @"41234";
    self.lineNumber = 0;
    self.messageTextField.text = @"Hello from iOS-client";
    [self.resultTextView setText:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.sendTimer invalidate];
}

- (void)sendPacket
{
    NSString *message = self.messageTextField.text;
    self.lineNumber += 1;
    [self.logString appendString:[NSString stringWithFormat:@"\n[%@] %lu. Data sent: %@", [NSDate date], (unsigned long)self.lineNumber, message]];
    [self.resultTextView setText:self.logString];
    const char *cStringMessage = [message cStringUsingEncoding:NSUTF8StringEncoding];
    [self.echo sendData:cStringMessage];
}

- (void)runClientWithHost:(NSString *)host port:(NSUInteger)port
{
    self.echo = [[UDPEchoClient alloc] initWithHostName:host andPort:port];
    self.echo.delegate = self;
    self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendPacket) userInfo:nil repeats:YES];
}

#pragma mark - UDPEchoDelegate

- (void)echo:(UDPEchoClient *)echo didReceiveResponse:(NSString *)responseString
{
    [self.logString appendString:[NSString stringWithFormat:@"\n[%@] Data recieved: %@\n", [NSDate date], responseString]];
    [self.resultTextView setText:self.logString];
//    NSLog(@"data recieved (%@) ", responseString);
}

#pragma mark - Actions

- (IBAction)startTestAction:(id)sender {
    [self.resultTextView setText:@""];
    self.lineNumber = 0;
    self.logString = [NSMutableString string];
    NSString *hostName = self.hostNameTextField.text;
    NSUInteger port = [self.portTextField.text integerValue];
    [self runClientWithHost:hostName port:port];
}

- (IBAction)stopTestAction:(id)sender {
    [self.sendTimer invalidate];
    self.echo = nil;
}

@end
