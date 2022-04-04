FROM ubuntu:focal

WORKDIR /opt
COPY ./app.sh .
COPY ./version .

RUN chmod +x app.sh


CMD ["./app.sh"]