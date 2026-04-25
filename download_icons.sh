#!/bin/bash
# FocusFlow Icon Downloader
# Downloads icons from Iconify's public API
# Usage: ./download_icons.sh

BASE_URL="https://api.iconify.design"
ASSETS_DIR="lib/assets/icons"

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  FocusFlow Icon Downloader${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Function to download icon
download_icon() {
    local prefix=$1
    local name=$2
    local filepath=$3

    # Create directory if not exists
    local dir=$(dirname "$filepath")
    mkdir -p "$dir"

    # Download if not exists or force
    if [ ! -f "$filepath" ] || [ "$FORCE" = "true" ]; then
        curl -s -L "${BASE_URL}/${prefix}/${name}.svg" -o "$filepath"
        if [ -f "$filepath" ] && [ -s "$filepath" ]; then
            echo -e "  ${GREEN}✓${NC} Downloaded: $filepath"
            return 0
        else
            echo -e "  ${YELLOW}✗${NC} Failed: $filepath"
            return 1
        fi
    else
        echo -e "  ${YELLOW}○${NC} Skipped (exists): $filepath"
        return 0
    fi
}

echo -e "${YELLOW}Downloading Core Action Icons...${NC}"
# Core Actions
download_icon "lucide" "plus" "$ASSETS_DIR/core/add.svg"
download_icon "lucide" "x" "$ASSETS_DIR/core/close.svg"
download_icon "lucide" "check" "$ASSETS_DIR/core/check.svg"
download_icon "lucide" "check-circle" "$ASSETS_DIR/core/check_circle.svg"
download_icon "lucide" "trash-2" "$ASSETS_DIR/core/delete.svg"
download_icon "lucide" "trash" "$ASSETS_DIR/core/delete_forever.svg"
download_icon "lucide" "star" "$ASSETS_DIR/core/star_filled.svg"
download_icon "lucide" "star-outline" "$ASSETS_DIR/core/star_outline.svg"
download_icon "lucide" "chevron-right" "$ASSETS_DIR/core/chevron_right.svg"
download_icon "lucide" "chevron-up" "$ASSETS_DIR/core/chevron_up.svg"
download_icon "lucide" "chevron-down" "$ASSETS_DIR/core/chevron_down.svg"
download_icon "lucide" "play" "$ASSETS_DIR/core/play.svg"
download_icon "lucide" "pause" "$ASSETS_DIR/core/pause.svg"
download_icon "lucide" "square" "$ASSETS_DIR/core/stop.svg"
download_icon "lucide" "settings" "$ASSETS_DIR/core/settings.svg"
download_icon "lucide" "search" "$ASSETS_DIR/core/search.svg"
download_icon "lucide" "inbox" "$ASSETS_DIR/core/inbox.svg"
download_icon "lucide" "share-2" "$ASSETS_DIR/core/share.svg"
download_icon "lucide" "external-link" "$ASSETS_DIR/core/external_link.svg"
download_icon "lucide" "refresh-cw" "$ASSETS_DIR/core/refresh.svg"
download_icon "lucide" "copy" "$ASSETS_DIR/core/copy.svg"
download_icon "lucide" "pen-tool" "$ASSETS_DIR/core/edit.svg"
download_icon "lucide" "download" "$ASSETS_DIR/core/download.svg"
download_icon "lucide" "upload" "$ASSETS_DIR/core/upload.svg"
download_icon "lucide" "heart" "$ASSETS_DIR/core/heart.svg"
download_icon "lucide" "lock" "$ASSETS_DIR/core/lock.svg"
download_icon "lucide" "mic" "$ASSETS_DIR/core/mic.svg"
download_icon "lucide" "celebration" "$ASSETS_DIR/core/celebration.svg"
download_icon "lucide" "arrow-right" "$ASSETS_DIR/core/arrow_right.svg"
download_icon "lucide" "arrow-left" "$ASSETS_DIR/core/arrow_left.svg"
download_icon "lucide" "maximize-2" "$ASSETS_DIR/core/fullscreen.svg"
download_icon "lucide" "minimize-2" "$ASSETS_DIR/core/exit_fullscreen.svg"
download_icon "lucide" "circle" "$ASSETS_DIR/core/circle.svg"
download_icon "lucide" "target" "$ASSETS_DIR/core/target.svg"

echo ""
echo -e "${YELLOW}Downloading Energy Icons...${NC}"
# Energy Icons (using Tabler for lightning/brain)
download_icon "tabler" "bolt" "$ASSETS_DIR/energy/energy_quick.svg"
download_icon "tabler" "brain" "$ASSETS_DIR/energy/energy_deep.svg"
download_icon "tabler" "battery-low" "$ASSETS_DIR/energy/energy_low.svg"
download_icon "tabler" "battery-charging" "$ASSETS_DIR/energy/battery_charging.svg"

echo ""
echo -e "${YELLOW}Downloading Time Zone Icons...${NC}"
# Zone Icons
download_icon "tabler" "sunrise" "$ASSETS_DIR/zones/zone_morning.svg"
download_icon "tabler" "sun" "$ASSETS_DIR/zones/zone_afternoon.svg"
download_icon "tabler" "moon" "$ASSETS_DIR/zones/zone_evening.svg"
download_icon "tabler" "infinity" "$ASSETS_DIR/zones/zone_anytime.svg"

echo ""
echo -e "${YELLOW}Downloading Session Icons...${NC}"
# Session Icons
download_icon "tabler" "bolt" "$ASSETS_DIR/sessions/session_quick.svg"
download_icon "ph" "tomato" "$ASSETS_DIR/sessions/session_pomodoro.svg"
download_icon "tabler" "brain" "$ASSETS_DIR/sessions/session_deep.svg"
download_icon "tabler" "player-play" "$ASSETS_DIR/sessions/play_circle.svg"
download_icon "tabler" "gps" "$ASSETS_DIR/sessions/focus_mode.svg"

echo ""
echo -e "${YELLOW}Downloading Rest/Break Icons...${NC}"
# Rest Icons
download_icon "tabler" "lung" "$ASSETS_DIR/rest/breathing.svg"
download_icon "tabler" "moon-stars" "$ASSETS_DIR/rest/wind_down.svg"
download_icon "tabler" "volume" "$ASSETS_DIR/rest/volume.svg"
download_icon "tabler" "coffee" "$ASSETS_DIR/rest/micro_coffee.svg"
download_icon "tabler" "walk" "$ASSETS_DIR/rest/micro_walk.svg"
download_icon "tabler" "eye-off" "$ASSETS_DIR/rest/micro_look_away.svg"
download_icon "tabler" "stretching" "$ASSETS_DIR/rest/micro_stretch.svg"
download_icon "tabler" "droplet" "$ASSETS_DIR/rest/micro_hydrate.svg"
download_icon "tabler" "flower" "$ASSETS_DIR/rest/micro_relax.svg"

echo ""
echo -e "${YELLOW}Downloading Sound Mixer Icons...${NC}"
# Sound Mixer
download_icon "tabler" "cloud-rain" "$ASSETS_DIR/sounds/sound_rain.svg"
download_icon "tabler" "flame" "$ASSETS_DIR/sounds/sound_fire.svg"
download_icon "tabler" "coffee" "$ASSETS_DIR/sounds/sound_cafe.svg"
download_icon "tabler" "waves" "$ASSETS_DIR/sounds/sound_ocean.svg"
download_icon "tabler" "leaf" "$ASSETS_DIR/sounds/sound_noise.svg"
download_icon "tabler" "tree" "$ASSETS_DIR/sounds/sound_forest.svg"
download_icon "tabler" "music" "$ASSETS_DIR/sounds/sound_lofi.svg"
download_icon "tabler" "player-pause" "$ASSETS_DIR/sounds/pause_circle.svg"
download_icon "tabler" "speaker" "$ASSETS_DIR/sounds/speaker.svg"

echo ""
echo -e "${YELLOW}Downloading Library Icons...${NC}"
# Library Icons
download_icon "tabler" "flame" "$ASSETS_DIR/library/streak.svg"
download_icon "tabler" "moon" "$ASSETS_DIR/library/sleeping.svg"
download_icon "tabler" "shuffle-right" "$ASSETS_DIR/library/shuffle.svg"
download_icon "tabler" "trophy" "$ASSETS_DIR/library/trophy.svg"
download_icon "tabler" "anchor" "$ASSETS_DIR/library/anchor.svg"
download_icon "tabler" "history" "$ASSETS_DIR/library/empty_history.svg"
download_icon "tabler" "copy" "$ASSETS_DIR/library/empty_templates.svg"
download_icon "tabler" "star" "$ASSETS_DIR/library/empty_star.svg"
download_icon "tabler" "file-text" "$ASSETS_DIR/library/empty_notes.svg"
download_icon "tabler" "archive" "$ASSETS_DIR/library/empty_archive.svg"
download_icon "tabler" "link" "$ASSETS_DIR/library/empty_resources.svg"
download_icon "tabler" "mood-emoji" "$ASSETS_DIR/library/mood_emoji.svg"
download_icon "tabler" "file" "$ASSETS_DIR/library/category_article.svg"
download_icon "tabler" "tool" "$ASSETS_DIR/library/category_tool.svg"
download_icon "tabler" "video" "$ASSETS_DIR/library/category_video.svg"
download_icon "tabler" "book" "$ASSETS_DIR/library/category_course.svg"
download_icon "tabler" "link" "$ASSETS_DIR/library/category_link.svg"
download_icon "tabler" "bookmark" "$ASSETS_DIR/library/bookmark.svg"
download_icon "tabler" "sparkles" "$ASSETS_DIR/library/sparkles.svg"
download_icon "tabler" "megaphone" "$ASSETS_DIR/library/brag.svg"
download_icon "tabler" "archive" "$ASSETS_DIR/library/archive.svg"
download_icon "tabler" "clock" "$ASSETS_DIR/library/clock_small.svg"
download_icon "tabler" "template" "$ASSETS_DIR/library/template.svg"

echo ""
echo -e "${YELLOW}Downloading Settings Icons...${NC}"
# Settings Icons
download_icon "tabler" "palette" "$ASSETS_DIR/settings/appearance.svg"
download_icon "tabler" "bell" "$ASSETS_DIR/settings/notifications.svg"
download_icon "tabler" "moon" "$ASSETS_DIR/settings/dnd.svg"
download_icon "tabler" "chart-bar" "$ASSETS_DIR/settings/statistics.svg"
download_icon "tabler" "info-circle" "$ASSETS_DIR/settings/about.svg"
download_icon "tabler" "moon" "$ASSETS_DIR/settings/dark_mode.svg"
download_icon "tabler" "volume" "$ASSETS_DIR/settings/sound.svg"
download_icon "tabler" "target" "$ASSETS_DIR/settings/stats_sessions.svg"
download_icon "tabler" "flame" "$ASSETS_DIR/settings/stats_streak.svg"
download_icon "tabler" "check" "$ASSETS_DIR/settings/stats_tasks.svg"
download_icon "tabler" "clock" "$ASSETS_DIR/settings/stats_focus.svg"

echo ""
echo -e "${YELLOW}Downloading Onboarding Icons...${NC}"
# Onboarding
download_icon "tabler" "wave" "$ASSETS_DIR/onboarding/wave.svg"
download_icon "tabler" "sunrise" "$ASSETS_DIR/onboarding/tomorrow.svg"
download_icon "tabler" "device-mobile" "$ASSETS_DIR/onboarding/phone_off.svg"
download_icon "tabler" "timer" "$ASSETS_DIR/onboarding/timer.svg"
download_icon "tabler" "flag" "$ASSETS_DIR/onboarding/flexible.svg"

echo ""
echo -e "${YELLOW}Downloading Task Icons...${NC}"
# Tasks
download_icon "tabler" "checkbox" "$ASSETS_DIR/tasks/checkbox_empty.svg"
download_icon "tabler" "checkbox-checked" "$ASSETS_DIR/tasks/checkbox_checked.svg"
download_icon "tabler" "circle-dot" "$ASSETS_DIR/tasks/circle_pending.svg"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Download Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Icons saved to: $ASSETS_DIR"
echo ""
echo "Next steps:"
echo "1. Move icons from lib/assets/icons to focus_flow/assets/icons/"
echo "2. Add to pubspec.yaml:"
echo "   flutter:"
echo "     assets:"
echo "       - assets/icons/"
echo "3. Run flutter pub get"
