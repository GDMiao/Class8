

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MediaCollection.h"

//typedef void(^MediaCallBack_audio)(SInt16 * audioBuffer ,UInt32 len);
//typedef void(^MediaCallBack_video)(UInt8 * videoBuffer, size_t vWidth, size_t vHeight);

@interface SourMedia : NSObject
{
     MediaCollection *media;
}

- (void) MediaStart:(MediaCallBack_video) pvideocall  audioCallback: (MediaCallBack_audio) paudiocall ;
- (void) MeidaEnd;

- (void)initSourMedia:(int) nfps sampleRate:(int)nSampleRate channel:(int) nChannel handle:(void*)Handle;

-(MediaCollection *) getMediaCollection;
@end