# Prefect single container example

The setup of this runner container may look a bit un-intuitive but the main idea is to allow a container with 2 folders visible from the host side to allow for easy exploration of the tool, the folders are intended as follows:
- sharing_area: this has a few examples of code to run with prefect, you can write any code on your local machine and save into this folder and the code will be available to run inside the container.
- virtualenvs: this folder was made transparent to allow for introspection into the packages installed, mainly if you want to open the code of any package running in the environment used inside the container.

## Setup:

- Clone this repo

        git clone git@github.com:madetech/prefect_exploration_toy_example.git

- Change your dir to the newly cloned repo

        cd prefect_exploration_toy_example

- Build the container

    docker build -t new_prefect_img .

- Start a installation container (this will just be used to be able to mirror an internal folder in the host)

    docker run -it --name installation_container new_prefect_img

- Your terminal will now be inside the container, keep that terminal running and open one more terminal window so that the second one is not inside the container.

- On the terminal that is not inside the container make sure you are inside the dir 'digital-land-docker-pipeline-runner' that was created when you cloned the repo. Now, we need to copy 2 folders from inside the container to your local for transparancy, so we can see them inside the docker when we run cod inside it:

    docker cp installation_container:/root/.local/share/virtualenvs/. ./virtualenvs
    docker cp installation_container:/src/sharing_area/. ./sharing_area

- Go back to first terminal and exit to bring down the installation container:
    
    exit

- You can delete installation container as you won't need it anymore

    docker container rm installation_container

- To create a prefect container:

    docker run -it --name prefect_runner_container -p 4200:4200 -v `pwd`/sharing_area:/src/sharing_area -v `pwd`/virtualenvs:/root/.local/share/virtualenvs/ new_prefect_img
    
- To re-use a container created before

    docker start -ai prefect_runner_container

- To open a second terminal of same container

    docker exec -it prefect_runner_container bash

# Some useful commands 

All commands below are used inside the container and also inside the virtual env of the folder sharing_area. To use them make sure you have your prefect_runner_container running, then:
    
    cd /src/sharing_area 
    pipenv shell


To start a the API, the server and the UI instance:

    prefect orion start --host "0.0.0.0"
    # Note: we set host to 0.0.0.0 inside the container so that it is accessible in localhost outside of container

To check deployments (deployed flows/pipelines):

    prefect deployment ls
    
To manually create a run of deployment (this are usually created by the scheduler), a deployment named log-flow/log-simple should exist for this example to work, to create it you can run the python code on sharing_area/deployment_example/deployment.py:
    
    prefect deployment run 'log-flow/log-simple'
    
To start an agent that will execute the run (note that "test" is the name of the queue in which we created the run, so the agent has to know which queue it will work on):

    prefect agent start -q 'test'

    Note: this will run with the agent but display an ephemeral warning

When you take the orion API url and add it to the agent environment, with:

    prefect config set PREFECT_API_URL=http://127.0.0.1:4200/api

Then run the agent again after it:

    prefect agent start -q 'test'

 The ephemeral warning will not show.
