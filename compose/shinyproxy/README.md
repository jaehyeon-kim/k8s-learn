### Steps

- Source: [shinyproxy-config-examples - 02-containerized-docker-engine](https://github.com/openanalytics/shinyproxy-config-examples/tree/master/02-containerized-docker-engine)
- Volume mapping is used rather than building a custom docker image

```bash
docker pull openanalytics/shinyproxy-demo

# cd ./compose/shinyproxy
docker-compose up -d
```

Login with users in `application.yml`.