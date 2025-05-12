#ifndef SOUND_SERVICE_H
#define SOUND_SERVICE_H

#include <string>

class SoundService {
public:
    // Play a sound from the given file path
    static void playSound(const std::string& filePath);

    // Adjust volume level (0.0 to 1.0)
    static void setVolume(float level);

    // Mute or unmute sound
    static void mute(bool state);
};

#endif // SOUND_SERVICE_H

