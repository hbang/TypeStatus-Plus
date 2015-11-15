/*%hook NSNotificationCenter

- (void)postNotificationName:(NSString *)notificationName
                      object:(id)notificationSender
                    userInfo:(NSDictionary *)userInfo {
                    	if ([notificationName rangeOfString:@"UI"].location == NSNotFound && [notificationName rangeOfString:@"NS"].location == NSNotFound) {
                    		
                    	HBLogDebug(@"%@", notificationName);
                    
                    }}

%end*/