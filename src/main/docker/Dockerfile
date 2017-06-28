FROM java:8
RUN apt-get update && apt-get install netcat-openbsd -y
VOLUME /tmp
ADD demo.jar demo.jar
ADD wrapper.sh wrapper.sh
RUN bash -c 'chmod +x /wrapper.sh'
RUN bash -c 'touch /demo.jar'
ENTRYPOINT ["/bin/bash", "/wrapper.sh"]



