FROM python:3.12.7 AS builder

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
      build-essential \
      cmake \
      git \
      ninja-build && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV PIP_CONSTRAINT=/app/docker/constraints.txt
COPY docker/constraints.txt ./docker/constraints.txt

COPY pyproject.toml setup.py CMakeLists.txt MANIFEST.in README.md ./
COPY src/piper/ ./src/piper/
COPY script/setup script/dev_build script/package ./script/
RUN script/setup --dev
RUN script/dev_build
RUN script/package

# -----------------------------------------------------------------------------

FROM python:3.12.7-slim

ENV PIP_BREAK_SYSTEM_PACKAGES=1

WORKDIR /app
COPY docker/constraints.txt ./docker/constraints.txt
COPY --from=builder /app/dist/piper_tts-*linux*.whl ./dist/
RUN pip3 install --no-cache-dir --constraint ./docker/constraints.txt ./dist/piper_tts-*linux*.whl && \
    pip3 install --no-cache-dir --constraint ./docker/constraints.txt flask==3.0.3

COPY docker/entrypoint.sh /

EXPOSE 5000

ENTRYPOINT ["/entrypoint.sh"]
