# docker-datascience
## Build
```
docker build -t docker-datascience .
```

## Run in background
```
docker run -b -p 5022:22 -p 5040:4040 -p 5000:5000 -p 5080:8080  docker-datascience <command>
```

## Run in interactive mode
```
docker run -it -p 5022:22 -p 5040:4040 -p 5000:5000 -p 5080:8080  -p 5321:54321  docker-datascience <command>
```

Where command is one of:
* `shell` (default) - run bash
* `h2o` - run h2o in foreground (available on port `5321`)
* `jupyter` - run jupyter in foreground (available on port `5000`)
* `zeppelin` - run zeppelin in foreground (available on port `5080`, Spark UI on port `5040`)
* `all` - run all with supervisor (available `h2o`, `jupyter` & `zeppelin` as well as sshd on port `5022`)
