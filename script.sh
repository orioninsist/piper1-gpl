#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${PIPER_DOCKER_IMAGE:-piper1-gpl:local}"
VOICE="${PIPER_VOICE:-en_US-lessac-medium}"
VOICE_VERSION="${PIPER_VOICE_VERSION:-v1.0.0}"
VOICE_DIR="${PIPER_VOICE_DIR:-$HOME/.cache/piper1-gpl/voices}"
DOCKER_NETWORK="${PIPER_DOCKER_NETWORK:-host}"

usage() {
  printf 'Usage: %s "English text" [output.wav] [voice]\n' "$0"
  printf 'Default voice: %s\n' "$VOICE"
  printf 'Suggested voices: en_US-lessac-medium, en_US-amy-medium, en_US-libritts-high, en_GB-alan-medium\n'
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -lt 1 ]]; then
  usage
  exit 0
fi

TEXT="$1"
OUTPUT_FILE="${2:-piper.wav}"
VOICE="${3:-$VOICE}"

if [[ "$OUTPUT_FILE" != *.wav ]]; then
  OUTPUT_FILE="${OUTPUT_FILE}.wav"
fi

mkdir -p "$VOICE_DIR"

if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  docker build --network="$DOCKER_NETWORK" -t "$IMAGE_NAME" "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

voice_base="https://huggingface.co/rhasspy/piper-voices/resolve/${VOICE_VERSION}"
voice_lang_family="${VOICE%%_*}"
voice_after_region="${VOICE#*_}"
voice_region="${voice_after_region%%-*}"
voice_tail="${VOICE#*-}"
voice_name="${voice_tail%-*}"
voice_quality="${VOICE##*-}"
voice_lang_code="${voice_lang_family}_${voice_region}"
voice_path="${voice_lang_family}/${voice_lang_code}/${voice_name}/${voice_quality}"

if [[ ! -s "$VOICE_DIR/${VOICE}.onnx" || ! -s "$VOICE_DIR/${VOICE}.onnx.json" ]]; then
  curl -fL --retry 3 -o "$VOICE_DIR/${VOICE}.onnx" \
    "${voice_base}/${voice_path}/${VOICE}.onnx"
  curl -fL --retry 3 -o "$VOICE_DIR/${VOICE}.onnx.json" \
    "${voice_base}/${voice_path}/${VOICE}.onnx.json"
fi

docker run --rm \
  --network="$DOCKER_NETWORK" \
  -u "$(id -u):$(id -g)" \
  -v "$VOICE_DIR:/data:ro" \
  -v "$PWD:/work" \
  -w /work \
  "$IMAGE_NAME" \
  speak -m "$VOICE" -f "/work/$OUTPUT_FILE" -- "$TEXT"

printf 'Wrote %s\n' "$PWD/$OUTPUT_FILE"
