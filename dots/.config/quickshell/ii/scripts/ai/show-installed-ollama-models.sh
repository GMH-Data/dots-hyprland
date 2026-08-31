#!/usr/bin/env bash

# Wait for Ollama to become ready during system boot (up to 15s)
for i in {1..30}; do
    if curl -s --max-time 1 http://localhost:11434/ > /dev/null; then
        break
    fi
    sleep 0.5
done

curl -s --max-time 5 http://localhost:11434/api/tags | jq -c '[.models[].name]' || echo "[]"
