#!/bin/bash
# NINURTA-FULL - Game Engine (Background Process)
# Virtual game score generator

GAME_DIR="$1"
DESIRE_DOMAIN="$HOME/.desire_domain"
mkdir -p "$DESIRE_DOMAIN"

# Simple hash for game points
simple_hash() {
    local input="$1"
    local hash=0
    for (( i=0; i<${#input}; i++ )); do
        char=$(printf "%d" "'${input:$i:1}")
        hash=$(( (hash * 31 + char) % 1000000 ))
    done
    echo $hash
}

# Generate game points
generate_points() {
    local nonce=0
    local target=50000  # Difficulty (lower = harder)
    local generated=0
    
    while true; do
        nonce=$((nonce + 1))
        test_val=$(echo "$(date +%s)$nonce" | sha256sum | cut -c1-8)
        val=$(printf "%d" "0x$test_val" 2>/dev/null || echo "0")
        
        if [ $val -lt $target ]; then
            echo "$(date +%s),$nonce,$test_val" >> "$DESIRE_DOMAIN/points.cir"
            generated=$((generated + 1))
            echo "[$(date +%H:%M:%S)] Points generated: $generated"
            
            # Auto-sync to game if game dir exists
            if [ -n "$GAME_DIR" ] && [ -d "$GAME_DIR" ]; then
                echo "$test_val" >> "$GAME_DIR/incoming_actions"
            fi
        fi
        
        # Show speed every 1000 tries
        if [ $((nonce % 1000)) -eq 0 ]; then
            echo -ne "\rTries: $nonce | Points: $generated   "
        fi
    done
}

# Main
echo "NINURTA-FULL Game Engine"
echo "Points will be saved to: $DESIRE_DOMAIN"
echo "Press Ctrl+C to stop"
echo ""
generate_points
