#!/bin/bash

git config --global user.email "tatsuya.fukata@gmail.com"
git config --global user.name "fukata"

cd web_app &&
  npm install &&
  npm run deploy
