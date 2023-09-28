#!/bin/bash

# needed to get var for cd $test
source /dotfiles/mybash/server/.swarm

cd /website/DOCKER/GLYCAM/PlaceholderTest
bash start.bash test.glycam.org

cd $test
bash ./bin/swarm-stop.sh
git pull
echo "0" > Django/glycam-django/glycamweb/FIXTURE_WARNINGS_LEFT
bash ./bin/initialize.sh -c default -s git
bash ./bin/swarm-start.sh
docker stack rm test-glycam-org
