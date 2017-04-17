# docker-datascience
## Build
```
docker build -t docker-datascience .
```

## Run in background
```
docker run -b -p 5000:5000 -p 5022:22 -p 5080:8080  docker-datascience <command>
```

## Run in interactive mode
```
docker run -it -p 5000:5000 -p 5022:22 -p 5080:8080  docker-datascience <command>
```

Where command is one of:
* `shell` (default) - run bash
* `jupyter` - run jupyter in foreground (available on port `5000`)
* `zeppelin` - run zeppelin in foreground (available on port `5080`)
* `all` - run all with supervisor (available both jupyter & zeppelin as well as sshd on port `5022`)
