# Dockerfile for OnMyShelf web interface

FROM nginx:mainline

# nginx configuration
RUN sed -i '/index.html/a try_files $uri $uri\/ \/index.html\;' \
    /etc/nginx/conf.d/default.conf && \
    sed -i 's/\/50x.html\;$/index.html\;/; s/^\}.*/    location \/api\/ \{\n        proxy_pass http:\/\/api;\n    \}\n    location \/media\/ \{\n        proxy_pass http:\/\/api;\n    \}\n\}/' \
    /etc/nginx/conf.d/default.conf

# Copy sources
COPY src/dist/ /usr/share/nginx/html
