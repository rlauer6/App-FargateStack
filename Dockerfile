FROM debian:bookworm

RUN apt-get update && apt-get install -y perl curl make gcc
RUN curl -L https://cpanmin.us | perl - App::cpanminus
RUN cpanm -n -v JSON
COPY HelloWorld.pl /usr/local/bin/HelloWorld.pl

CMD ["/usr/local/bin/HelloWorld.pl"]
