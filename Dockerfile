FROM debian:stable-slim AS build

RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Fix tar ownership issue in restricted container environments (Render)
RUN mv /usr/bin/tar /usr/bin/tar.real && \
    echo '#!/bin/sh' > /usr/bin/tar && \
    echo '/usr/bin/tar.real --no-same-owner "$@"' >> /usr/bin/tar && \
    chmod +x /usr/bin/tar

RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/bin:${PATH}"

RUN flutter config --enable-web

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web --release --no-wasm-dry-run

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
