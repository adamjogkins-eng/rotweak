#import <UIKit/UIKit.h>
#include <fstream>
#include <string>

// This function writes the hidden Fast Flags to Roblox's folder
void applyRobloxTweaks() {
    // Locate the internal sandbox folder where Roblox stores its data
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *settingsPath = [libraryPath stringByAppendingPathComponent:@"Application Support/ClientSettings"];
    NSString *fileLocation = [settingsPath stringByAppendingPathComponent:@"ClientAppSettings.json"];

    // Ensure the ClientSettings folder exists
    [[NSFileManager defaultManager] createDirectoryAtPath:settingsPath withIntermediateDirectories:YES attributes:nil error:nil];

    // THE CONFIG:
    // DFIntTaskSchedulerTargetFps: Unlocks FPS (120 is great for iPhone)
    // FIntRenderShadowIntensity: Set to 0 to delete shadows (Massive Lag Reduction)
    // FIntDebugTextureManagerSkipPBR: 1 = Use basic textures (Low Lag)
    std::string configJson = "{"
        "\"DFIntTaskSchedulerTargetFps\": 120,"
        "\"FIntRenderShadowIntensity\": 0,"
        "\"FIntDebugTextureManagerSkipPBR\": 1"
    "}";

    // Write the file to the app's internal memory
    std::ofstream settingsFile([fileLocation UTF8String]);
    settingsFile << configJson;
    settingsFile.close();
}

// This runs automatically as soon as the app is opened
__attribute__((constructor))
static void initialize() {
    // Wait 1 second to ensure the app is fully loaded before writing
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        applyRobloxTweaks();
    });
}
