#include "utils/sound_service.h"
#include <iostream>

#ifdef _WIN32
    #include <windows.h>
#elif __APPLE__
    #include <AudioToolbox/AudioToolbox.h>
#elif __linux__
    #include <stdlib.h>
#endif

void SoundService::playSound(const std::string& filePath) {
#ifdef _WIN32
    PlaySound(filePath.c_str(), NULL, SND_FILENAME | SND_ASYNC);
#elif __APPLE__
    SystemSoundID soundID;
    CFStringRef cfPath = CFStringCreateWithCString(NULL, filePath.c_str(), kCFStringEncodingUTF8);
    CFURLRef soundURL = CFURLCreateWithFileSystemPath(NULL, cfPath, kCFURLPOSIXPathStyle, false);
    AudioServicesCreateSystemSoundID(soundURL, &soundID);
    AudioServicesPlaySystemSound(soundID);
    CFRelease(soundURL);
    CFRelease(cfPath);
#elif __linux__
    std::string command = "aplay " + filePath + " &";
    system(command.c_str());
#else
    std::cerr << "Sound playback not supported on this platform.\n";
#endif
}

void SoundService::setVolume(float level) {
#ifdef _WIN32
    // Windows volume control can be handled via system commands or APIs.
    std::cout << "Adjusting volume to " << level * 100 << "% (Windows users may need external tools).\n";
#elif __APPLE__
    std::string command = "osascript -e 'set volume output volume " + std::to_string(static_cast<int>(level * 100)) + "'";
    system(command.c_str());
#elif __linux__
    std::string command = "amixer set Master " + std::to_string(static_cast<int>(level * 100)) + "%";
    system(command.c_str());
#else
    std::cerr << "Volume control not supported on this platform.\n";
#endif
}

void SoundService::mute(bool state) {
#ifdef _WIN32
    std::cout << (state ? "Muting" : "Unmuting") << " sound (Windows users may need external tools).\n";
#elif __APPLE__
    std::string command = "osascript -e 'set volume output muted " + std::string(state ? "true" : "false") + "'";
    system(command.c_str());
#elif __linux__
    std::string command = "amixer set Master " + std::string(state ? "mute" : "unmute");
    system(command.c_str());
#else
    std::cerr << "Mute/unmute not supported on this platform.\n";
#endif
}

