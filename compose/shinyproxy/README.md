### Steps

- Source: [shinyproxy-config-examples - 02-containerized-docker-engine](https://github.com/openanalytics/shinyproxy-config-examples/tree/master/02-containerized-docker-engine)
- Volume mapping is used rather than building a custom docker image
    * steps in `Dockerfile` is converted into docker-compose config.

```bash
docker pull openanalytics/shinyproxy-demo

# cd ./compose/shinyproxy
docker-compose up -d
```

Login with credentials in `application.yml`.