#!/usr/bin/env python3
import json
import subprocess
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
                ["playerctl", "-p", "spotify", "status"],
                stderr=subprocess.DEVNULL,
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
    pause_until = 0

    while True:
        current_song, status = get_spotify_data()
        css_class = state_class(status)

        if not current_song or status == "Stopped":
            print(json.dumps({"text": "", "class": "stopped"}), flush=True)
            last_song = ""
            scroll_index = 0
            just_changed = False
            pause_until = 0
            time.sleep(1)
            continue

        if current_song != last_song:
            last_song = current_song
            scroll_index = 0
            just_changed = True
            pause_until = 0

        dynamic_max_length = max_length_from_words(current_song)
        display_text = current_song + " | "
        text_len = len(display_text)

        if len(current_song) > dynamic_max_length:
            scroll_index %= text_len

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

            if status == "Paused":
                pause_until += 0.5
                time.sleep(0.5)
                continue

            now = time.monotonic()

            if just_changed:
                just_changed = False
                pause_until = now + PAUSE_TIME
                time.sleep(0.2)
                continue

            if now < pause_until:
                time.sleep(min(0.2, pause_until - now))
                continue

            scroll_index = (scroll_index + 1) % text_len

            if scroll_index == 0:
                pause_until = time.monotonic() + PAUSE_TIME

            time.sleep(SCROLL_SPEED)

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
            time.sleep(0.5)


if __name__ == "__main__":
    main()
