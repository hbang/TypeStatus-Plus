#import "HBTSPlusMusicProvider.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <MediaRemote/MediaRemote.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBMediaController.h>

@implementation HBTSPlusMusicProvider {
	NSString *_lastSongIdentifier;
}

- (instancetype)init {
	self = [super init];

	if (self) {
		if (IN_SPRINGBOARD) {
			_lastSongIdentifier = @"";
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaInfoDidChange:) name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
		}
	}
	
	return self;
}

- (NSString *)name {
	return @"Music";
}

- (void)mediaInfoDidChange:(NSNotification *)notification {
	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
		NSDictionary *dictionary = (__bridge NSDictionary *)result;
		NSString *songName = dictionary[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
		NSString *artistName = dictionary[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
		NSString *albumName = dictionary[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoAlbum];

		SBApplication *nowPlayingApp = ((SBMediaController *)[%c(SBMediaController) sharedInstance]).nowPlayingApplication;
		NSString *bundleIdentifier = nowPlayingApp.bundleIdentifier;

		if (!songName || !bundleIdentifier) {
			return;
		}

		NSString *identifier = [NSString stringWithFormat:@"title = %@, artist = %@, album = %@", songName, artistName, albumName];

		if (![_lastSongIdentifier isEqualToString:identifier]) {
			_lastSongIdentifier = identifier;

			HBTSNotification *notification = [[HBTSNotification alloc] init];
			notification.content = artistName ? [NSString stringWithFormat:@"%@ – %@", songName, artistName] : songName;
			notification.boldRange = NSMakeRange(0, songName.length);
			notification.statusBarIconName = @"TypeStatusPlusMusic";
			notification.sourceBundleID = bundleIdentifier;
			[self showNotification:notification];
		}
	});
}

@end
