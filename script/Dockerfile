FROM java:8
MAINTAINER Sophea MAK<sopheamak@gmail.com>
RUN apt-get update && apt-get install netcat-openbsd -y
VOLUME /tmp
ADD ./jar/demo.jar demo.jar
ADD wrapper.sh wrapper.sh
RUN bash -c 'chmod +x /wrapper.sh'
RUN bash -c 'touch /demo.jar'
ENTRYPOINT ["/bin/bash", "/wrapper.sh"]


