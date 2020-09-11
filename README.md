# Exim Relay Docker Image

[Exim](http://exim.org/) relay [Docker](https://docker.com/) image based on [Alpine](https://alpinelinux.org/) Linux

## [Docker Run](https://docs.docker.com/engine/reference/run)

Create docker volume for spool folder:

```shell
docker volume create --name=exim-spool
```

Create docker container:

```shell
docker run \
    -d \
    --name exim-relay \
    --restart=always \
    -u exim \
    -p 25:25 \
    -v exim-spool:/var/spool/exim \
    -h mail.example.com \
    -e DKIM_DOMAINS=example.com \
    pristavkin/exim-relay
```

## [Docker Compose](https://docs.docker.com/compose/compose-file)

```yml
version: "2"
services:
  exim-relay:
    restart: always
    image: pristavkin/exim-relay
    user: exim
    ports:
      - "25:25"
    volumes:
      - exim-spool:/var/spool/exim
    hostname: mail.example.com
    environment:
      - RELAY_FROM_HOSTS=10.0.0.0/8:172.16.0.0/12:192.168.0.0/16
volumes:
  smtp-dkim:
    driver: local
```

## Debug

Print a count of the messages in the queue:

```shell
docker exec -it exim-relay exim -bpc
```

Print a listing of the messages in the queue (time queued, size, message-id, sender, recipient):

```shell
docker exec -it exim-relay exim -bp
```

Remove all frozen messages:

```shell
docker exec -it exim-relay exim -bpu | grep frozen | awk {'print $3'} | xargs exim -Mrm
```

Test how exim will route a given address:

```shell
docker exec -it exim-relay exim -bt test@gmail.com
```

```
test@gmail.com
  router = dnslookup, transport = remote_smtp
  host gmail-smtp-in.l.google.com      [64.233.164.27] MX=5
  host alt1.gmail-smtp-in.l.google.com [64.233.187.27] MX=10
  host alt2.gmail-smtp-in.l.google.com [173.194.72.27] MX=20
  host alt3.gmail-smtp-in.l.google.com [74.125.25.27]  MX=30
  host alt4.gmail-smtp-in.l.google.com [74.125.198.27] MX=40
```

Display all of Exim's configuration settings:

```shell
docker exec -it exim-relay exim -bP
```

View a message's headers:

```shell
docker exec -it exim-relay exim -Mvh <message-id>
```

View a message's body:

```shell
docker exec -it exim-relay exim -Mvb <message-id>
```

View a message's logs:

```shell
docker exec -it exim-relay exim -Mar <message-id>
```

Remove a message from the queue:

```shell
docker exec -it exim-relay exim -Mrm <message-id> [ <message-id> ... ]
```

Send a message:

```shell
echo "Test message" | mailx -v -r "sender@example.com" -s "Test subject" -S smtp="localhost:25" recipient@example.com
```

## License

[The MIT License](LICENSE)