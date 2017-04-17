#!/bin/bash -e

echo "Command: $1"

case $1 in
  shell )
    /bin/bash
    ;;
  h2o )
    /usr/local/h2o
    ;;
  jupyter )
    /usr/local/bin/jupyter notebook --ip="*" --no-browser --port 5000 --allow-root
    ;;
  zeppelin )
    /usr/local/zeppelin/bin/zeppelin.sh
    ;;
  all )
    supervisord -c /supervisor-all.conf
    ;;
  * )
    echo "Unknown command $1, starting shell"
    /bin/bash
    ;;
esac
