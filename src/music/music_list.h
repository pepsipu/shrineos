#include "raw_frequencies/mario.c"
#include "raw_frequencies/axelf.c"
#include "raw_frequencies/tetris.c"
#include "raw_frequencies/russian_anthem.c"
#include "beep_structure.c"

struct {
    char *song_name;
    char *porter;
    uint32_t song_length;
    struct beep *frequencies;
} songs[] = {
    {
        .frequencies = mario,
        .song_name = "mario",
        .porter = "pepsipu",
        .song_length = sizeof(mario) / sizeof(struct beep)
    },
    {
        .frequencies = russia,
        .song_name = "russian anthem",
        .porter = "ararouge",
        .song_length = sizeof(russia) / sizeof(struct beep)
    },
    {
        .frequencies = axel,
        .song_name = "axel f",
        .porter = "ararouge",
        .song_length = sizeof(russia) / sizeof(struct beep)
    },
    {
        .frequencies = tetris,
        .song_name = "tetris",
        .porter = "ararouge",
        .song_length = sizeof(tetris) / sizeof(struct beep)
    }
};
void play_song(int index) {
    for (uint32_t i = 0; i < songs[index].song_length; i++) {
        struct beep current_beep = songs[index].frequencies[i];
        beep(current_beep.freq, current_beep.len, current_beep.delay);
    }
}
