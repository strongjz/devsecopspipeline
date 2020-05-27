FROM node:latest

COPY . .

RUN mkdir -p /usr/src/app
RUN apt-get -y update && apt-get -y install runit && cd /usr/src/app && npm install

EXPOSE 8181

CMD ["runsv /usr/src/app"]