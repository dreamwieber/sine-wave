//
//  ViewController.m
//  SineWave
//
//  Created by Gregory Wieber on 1/26/14.
//  Copyright (c) 2014 Apposite. All rights reserved.
//

#import "ViewController.h"
#import <TheAmazingAudioEngine.h>

@interface ViewController () {
    @public
    float _frequency;
    float _sineBuffer[4096];
}

@property (nonatomic, strong) AEAudioController *audioController; // The Amazing Audio Engine
@property (nonatomic, strong) AEBlockChannel *sineChannel; // our sine 'generator'
@property (nonatomic, readwrite) float frequency; // sine wave's pitch

- (IBAction)frequencySliderChanged:(UISlider *)slider;

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    AudioStreamBasicDescription audioFormat = [AEAudioController nonInterleavedFloatStereoAudioDescription];
    
    // Setup the Amazing Audio Engine:
    self.audioController = [[AEAudioController alloc] initWithAudioDescription:audioFormat];
    
    float __block angle = 0;
    self.frequency = 440.0;
    
    __weak ViewController *weakSelf = self;
    AEBlockChannel *sineChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
        
        ViewController *strongSelf = weakSelf;
        
        UInt32 numberOfBuffers = audio->mNumberBuffers;
        
        float increment = ((M_PI * 2) / 44100.f) * strongSelf->_frequency;
        
        // write 'frames' worth of sine wave to scratch buffer
        for (int i = 0; i < frames; i++) {
            strongSelf->_sineBuffer[i] = sinf(angle);
            angle+=increment;
            if (angle > (M_PI * 2)) {
                angle-= (M_PI * 2);
            }
        }

        // copy the sine wave from the scratch buffer to the output buffers
        for (int i = 0; i < numberOfBuffers; i++) {
            audio->mBuffers[i].mDataByteSize = frames * sizeof(float);

            float *output = (float *)audio->mBuffers[i].mData;
            
            memcpy(output, strongSelf->_sineBuffer, frames * sizeof(float));
        }
    }];
    
    [sineChannel setVolume:.35];
    
    // Add the channel to the audio controller
    [self.audioController addChannels:@[sineChannel]];
    
    // Hold onto the noiseChannel
    self.sineChannel = sineChannel;
    
    // Turn on the audio controller
    NSError *error = NULL;
    [self.audioController start:&error];
    
    if (error) {
        NSLog(@"There was an error starting the controller: %@", error);
    }
}

- (IBAction)frequencySliderChanged:(UISlider *)slider
{
    self.frequency = 20 + (4000 * slider.value);
}

@end
