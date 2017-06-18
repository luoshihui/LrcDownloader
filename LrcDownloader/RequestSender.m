//
//  RequestSender.m
//  MusicSeeker
//
//  Created by Martian on 11-6-3.
//  Copyright 2011 Martian. All rights reserved.
//

#import "RequestSender.h"


@implementation RequestSender

+ (NSString*)sendRequest:(NSString*)url
{
	NSString *urlString = url;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"GET"];
    NSString *contentType = [NSString stringWithFormat:@"text/xml"];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSHTTPURLResponse* urlResponse = nil;  
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:NULL];  
	NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300)
		return result;
    
	return @"NULL";
}

+ (NSData*)fetchRequest:(NSString*)url
{
	NSString *urlString = url;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"GET"];
    NSString *contentType = [NSString stringWithFormat:@"text/xml"];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSHTTPURLResponse* urlResponse = nil;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:NULL];
    if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300)
		return responseData;
    
	return nil;
}

@end

