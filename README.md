[![Build Status](https://travis-ci.org/borxa/docker-liferay7-cluster.svg?branch=7.2.1)](https://travis-ci.org/borxa/docker-liferay7-cluster)
# docker-liferay721-cluster
Docker compose with Liferay 7.2.1 cluster:
  - postgresql
  - elastic search 1
  - elastic search 2
  - liferay 7.2.1 node 1
  - liferay 7.2.1 node 2
  - redis
  - haproxy
  
  # usage
  
  Install docker-compose and run docker with at least 8 GB of memory
  
  docker-compose up -d
  
  - http://localhost:6080 node 1 of liferay
  - http://localhost:7080 node 2 of liferay
  - http://localhost/ load balancer
  - http://localhost:8181 load balancer stats (user: liferay, pass: liferay)
  
  docker-compose down

  # Docker images form repository

  docker pull borxa/liferay-cluster-node:7.2.1

