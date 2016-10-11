
#import "SourMedia.h"

@implementation SourMedia

- (void)dealloc {
    CSLog(@"SourMedia dealoc");
}

- (void)initSourMedia:(int) nfps sampleRate:(int)nSampleRate channel:(int) nChannel handle:(void*)Handle
{
    media = [[MediaCollection alloc] initWithVideoFPS:nfps audioRate:nSampleRate audioChannel:nChannel];
    [media videoPreview:(__bridge UIView *)Handle];
}

- (void) MediaStart:(MediaCallBack_video) pvideocall  audioCallback: (MediaCallBack_audio) paudiocall
{
    //音频数据
    [media setAudioCallBack:paudiocall];
    
    //视频
    [media setVideoCallBack:pvideocall];
    
    if ([media hasStartMediaColllection]) {
        [media startMediaCollection];
    }
    
}

- (void) MeidaEnd
{
    [media stopMediaCollection];
}

-(MediaCollection *) getMediaCollection
{
    return media;
}

@end