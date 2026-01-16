#import <UIKit/UIKit.h>
#include <fstream>
#include <string>

// --- THE LOGIC: MODIFIES ROBLOX ENGINE SETTINGS ---
void applyRobloxOptimization() {
    // 1. Get the path to Roblox's internal folders
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *settingsDir = [libPath stringByAppendingPathComponent:@"Application Support/ClientSettings"];
    NSString *filePath = [settingsDir stringByAppendingPathComponent:@"ClientAppSettings.json"];

    // 2. Create the ClientSettings folder if it doesn't exist
    [[NSFileManager defaultManager] createDirectoryAtPath:settingsDir withIntermediateDirectories:YES attributes:nil error:nil];

    // 3. The "Fast Flags" (JSON config)
    // 120 FPS, No Shadows, No PBR Textures
    std::string settingsJson = "{"
        "\"DFIntTaskSchedulerTargetFps\": 120,"
        "\"FIntRenderShadowIntensity\": 0,"
        "\"FIntDebugTextureManagerSkipPBR\": 1"
    "}";

    // 4. Write to the file
    std::ofstream file([filePath UTF8String]);
    file << settingsJson;
    file.close();
    
    NSLog(@"[Optimizer] Config applied to: %@", filePath);
}

// --- THE TRIGGER: RUNS WHEN APP STARTS ---
__attribute__((constructor))
static void initialize() {
    // We wait 1 second to make sure Roblox has finished setting up its file system
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        applyRobloxOptimization();
    });
}
