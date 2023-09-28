#!/bin/bash

glycam=/website/DOCKER/GLYCAM

# current actual location where builds are stored


echo "Please choose what site you are moving to:"
echo "1. dev"
echo "2. actual"

read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        echo "You selected dev as the site you are moving to"
	cd /website/DOCKER/GLYCAM/PlaceholderTest
	bash start.bash test.glycam.org
	cd /website/DOCKER/GLYCAM/PlaceholderDev
	bash start.bash dev.glycam.org
	movingto=dev
        ;;
    2)
        echo "You selected actual as the site you are moving to"
	cd /website/DOCKER/GLYCAM/PlaceholderDev
	bash start.bash dev.glycam.org
	cd /website/DOCKER/GLYCAM/PlaceholderActual
	bash start.bash glycam.org
	movingto=actual
        ;;
    *)
        echo "Invalid choice. Please enter 1 or 2."
        ;;
esac

read -p "Please input the deployment name for current actual or test depending on if you are moving to actual or dev site aimless-abbott: " CurrentSite
if [ -n "$CurrentSite" ]; then
   
    cd /website/DOCKER/GLYCAM/$CurrentSite/V_2
    bash bin/swarm-stop.sh
else
    echo "no current site given skipping swarm stop."
fi
    
read -p "Please input the deployment name you are moving like aimless-abbott: " deployment
cd /website/DOCKER/GLYCAM/$deployment/V_2
bash bin/swarm-stop.sh

# Create file LocalEnvirnonment.bash which tells where to store builds
if $choice eq 2; then
echo "#!/bin/bash

USERDATA_DIRECTORY_NAME='userdata-start-aimless-abbott'" > LocalEnvironment.bash

echo "LocalEnvironment.bash has been created"
fi


# run git ops must be done before all of this.
cd $glycam

cd /website/DOCKER/GLYCAM/$deployment/V_2
case $choice in
    1)
	sed -i 's/test.glycam.org/dev.glycam.org/g' LIVE_SWARM
        ;;
    2)
	sed -i 's/dev.glycam.org/glycam.org/g' LIVE_SWARM
        ;;
    *)
        echo "Invalid choice. Please enter 1 or 2."
        ;;
esac

# disable prompt for django
echo "0" > Django/glycam-django/glycamweb/FIXTURE_WARNINGS_LEFT

bash bin/set-environment.sh
bash bin/compile.sh
bash bin/setup.sh

declare -a initlist=(
    "Django"
    "Slurm"
    "GRPC"
)

for dir in "${initlist[@]}"; do
    cd $dir && bash bin/initialize.sh && cd ..
    echo "Initialized $dir"
done

bash bin/set-versions.sh
bash bin/swarm-start.sh

case $choice in
    1)
	docker stack rm dev-glycam-org
        ;;
    2)
	docker stack rm glycam-org
        ;;
    *)
        echo "Invalid choice. Please enter 1 or 2."
        ;;
esac

cd $glycam

case $choice in
    1)
	rm -f LiveTest
	rm -f LiveDev
	ln -s $deployment LiveDev
        ;;
    2)
	rm -f Actual
	rm -f LiveDev
	ln -s $deployment Actual
        ;;
    *)
        echo "Invalid choice. Please enter 1 or 2."
        ;;
esac
