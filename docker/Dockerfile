FROM debian:bookworm

RUN apt-get update && apt-get install -y perl curl make gcc
RUN curl -L https://cpanmin.us | perl - App::cpanminus
RUN cpanm -n -v \
  JSON \
  Log::Log4perl \
  Log::Log4perl::Layout::JSON \
  Readonly

COPY HelloWorld.pl /usr/local/bin/HelloWorld.pl

CMD ["/usr/local/bin/HelloWorld.pl"]
