FROM ubuntu:24.04

RUN apt-get update
RUN apt-get install -y ca-certificates jq wget gpg

RUN wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | gpg --dearmor -o /usr/share/keyrings/cli.cloudfoundry.org.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/cli.cloudfoundry.org.gpg] https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list

RUN apt-get update
RUN apt-get install -y cf8-cli

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
