FROM node:latest

RUN apt-get -y update

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

COPY . .

RUN npm install

EXPOSE 8181

CMD ["node", "/usr/src/app/server.js"]