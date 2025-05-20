```bash
docker build -t xrdp .


docker run -d -p 3389:3389 -v xrdp-root-home:/root --name xrdp-root-wine-audio xrdp
