Для запустка теста производительности проделайте следующие этапы:
1. cd <project> && bin/setup
1. cd <project> && bundle exec puma -w 2 -b tcp://0.0.0.0:3000 -e production
1. ./loadtester --host http://0.0.0.0:3000 -t1m -u500 -r100

Примеры замеров производительности c моего компьютера лежат в roda.log и sinatra.log
Мой компьютер Dell XPS 7590 c процессором Intel 9750H
