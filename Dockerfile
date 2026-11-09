FROM nginx:alpine
LABEL org.opencontainers.image.title="codyssey-mission1-web"
ENV APP_ENV=mission1
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80