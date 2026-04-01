#!/bin/bash
cd "$(dirname "$0")/www" && python -m http.server 8080
