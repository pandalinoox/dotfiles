#!/usr/bin/env python3
import subprocess
import json
import time

MAX_WORDS = 3
SCROLL_SPEED = 0.2
PAUSE_TIME = 10


def max_length_from_words(text, max_words=MAX_WORDS):
    words = text.split()
    if len(words) <= max_words:
        return len(text)
    return len(" ".join(words[:max_words]))


def state_class(status):
    if status == "Playing":
        return "playing"
    if status == "Paused":
        return "paused"
    return "stopped"


def get_spotify_data():
    try:
        status = (
            subprocess.check_output(
                ["playerctl", "-p", "spotify", "status"], stderr=subprocess.DEVNULL
            )
            .decode("utf-8")
            .strip()
        )
        title = (
            subprocess.check_output(
                ["playerctl", "-p", "spotify", "metadata", "title"],
                stderr=subprocess.DEVNULL,
            )
            .decode("utf-8")
            .strip()
        )
        if title.lower() == "advertisement" or not title:
            return "", status
        return title, status
    except Exception:
        return "", "Stopped"


def main():
    last_song = ""
    scroll_index = 0
    just_changed = False

    while True:
        current_song, status = get_spotify_data()
        css_class = state_class(status)

        if not current_song or status == "Stopped":
            print(json.dumps({"text": "", "class": "stopped"}), flush=True)
            time.sleep(2)
            continue

        if current_song != last_song:
            scroll_index = 0
            last_song = current_song
            just_changed = True

        dynamic_max_length = max_length_from_words(current_song)

        if len(current_song) > dynamic_max_length:
            display_text = current_song + " | "
            text_len = len(display_text)

            if scroll_index == 0 and status == "Playing" and not just_changed:
                content = (display_text * 2)[:dynamic_max_length]
                print(
                    json.dumps(
                        {
                            "text": f" {content}",
                            "tooltip": current_song,
                            "class": css_class,
                        }
                    ),
                    flush=True,
                )

                for _ in range(PAUSE_TIME):
                    check_song, _ = get_spotify_data()
                    if check_song != last_song:
                        break
                    time.sleep(1)

                scroll_index += 1
                continue

            content = (display_text * 2)[
                scroll_index : scroll_index + dynamic_max_length
            ]
            print(
                json.dumps(
                    {
                        "text": f" {content}",
                        "tooltip": current_song,
                        "class": css_class,
                    }
                ),
                flush=True,
            )

            if status == "Playing":
                scroll_index = (scroll_index + 1) % text_len
                just_changed = False
                time.sleep(SCROLL_SPEED)
            else:
                time.sleep(1)
        else:
            print(
                json.dumps(
                    {
                        "text": f" {current_song}",
                        "tooltip": current_song,
                        "class": css_class,
                    }
                ),
                flush=True,
            )
            time.sleep(1)


if __name__ == "__main__":
    main()
