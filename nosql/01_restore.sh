#!/bin/bash
mongorestore --username sa --password sa /docker-entrypoint-initdb.d/mongodump
