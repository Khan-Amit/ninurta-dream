#!/bin/bash
# VERTICAL GAME - Virtual Game Controller
# Ninurta-Dream (c) 2025

GAME_DIR="$HOME/.vertical_game"
CONFIG_FILE="$GAME_DIR/config"
SCORE_FILE="$GAME_DIR/score"
LOG_FILE="$GAME_DIR/game.log"

mkdir -p "$GAME_DIR"

# Initialize new game
init_game() {
    echo "=== VERTICAL GAME ==="
    echo "Initializing new game..."
    echo "CREATED:$(date +%s)" > "$CONFIG_FILE"
    echo "PLAYER:$(hostname)-$$" >> "$CONFIG_FILE"
    echo "SCORE:0" > "$SCORE_FILE"
    echo "Game ready at $GAME_DIR"
    cat "$CONFIG_FILE"
}

# Show current score
show_score() {
    echo "=== VERTICAL GAME ==="
    echo "Player: $(grep PLAYER "$CONFIG_FILE" | cut -d: -f2)"
    echo "Score: $(cat "$SCORE_FILE" 2>/dev/null || echo "0")"
    echo ""
    echo "Last 5 actions:"
    tail -5 "$LOG_FILE" 2>/dev/null || echo "No actions yet"
}

# Process game action (receives points)
process_action() {
    local action_file="$1"
    if [ -f "$action_file" ]; then
        local points=$(wc -l < "$action_file")
        local current=$(cat "$SCORE_FILE" 2>/dev/null || echo "0")
        local new=$((current + points))
        echo "$new" > "$SCORE_FILE"
        echo "$(date +%s),ACTION,+$points" >> "$LOG_FILE"
        echo "Processed $points actions. New score: $new"
        mv "$action_file" "$GAME_DIR/processed_$(date +%s)"
    else
        echo "No actions to process"
    fi
}

# Command interface
case "$1" in
    init)
        init_game
        ;;
    score)
        show_score
        ;;
    process)
        shift
        process_action "$1"
        ;;
    *)
        echo "VERTICAL GAME - Commands:"
        echo "  init           - Start new game"
        echo "  score          - Show current score"
        echo "  process file   - Process action file"
        ;;
esac
