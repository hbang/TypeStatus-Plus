#import "HBTSPlusMusicProvider.h"
#import <Foundation/NSDistributedNotificationCenter.h>

extern CFStringRef kMRMediaRemoteNowPlayingInfoDidChangeNotification;
extern CFStringRef kMRMediaRemoteNowPlayingInfoTitle;
extern CFStringRef kMRMediaRemoteNowPlayingInfoArtist;

@implementation HBTSPlusMusicProvider

- (id)init {
	if (self = [super init]) {
		HBLogDebug(@"Yoooooooo  init caled.");

		self.name = @"Music";
		self.preferencesBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatusPlus.bundle/"];
		self.preferencesClass = @"HBTSPlusMusicProviderListController";

		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(typeStatusPlusMusic_mediaInfoDidChange:) name:(NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
	}
	return self;
}

- (void)typeStatusPlusMusic_mediaInfoDidChange:(NSNotification *)notification {
	HBLogDebug(@"Yoooooooo caled.");
	NSString *songName = notification.userInfo[(NSString *)kMRMediaRemoteNowPlayingInfoTitle];
	NSString *artistName = notification.userInfo[(NSString *)kMRMediaRemoteNowPlayingInfoArtist];
	if (songName && artistName) {
		[self showNotification:[NSString stringWithFormat:@"The song %@ by %@ is now playing!", songName, artistName]];
	}
}

@end