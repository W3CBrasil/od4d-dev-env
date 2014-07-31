# OD4D - Development Environment

This repository has everything that is needed to start contributing to the OD4D – Open Data for Development Network project.

For more information about the project go to the main repository at [OD4D](https://github.com/W3CBrasil/OD4D)

## Get started

### Requirements:

* Git
* [VirtualBox](https://www.virtualbox.org)
* [Vagrant](http://www.vagrantup.com/)

### Set up the development environment:

* Clone this repository

		$ git clone git@github.com:W3CBrasil/od4d-dev-env.git	

* Execute the script to prepare your environment

		$ cd od4d-dev-env
		$ ./go.sh
		
	This script will perform the following tasks:
	1. Clone all relevant git repositories to the "repositories" directory
	1. Install required vagrant plugins
	1. Create one virtual machine for development and one virtual machine for testing
	
* Log in to the development virtual machine

		$ vagrant ssh
	
	You will be able to find the git repositories in the "/projects" directory
	
* Deploy localy the semantic repository and the rss-to-turtle converter

		$ cd /project/semantic-repository
		$ rake deploy:local
		$ cd /project/rss-to-turtle
		$ rake deploy:local
		
* Load data into semantic repository using rss-to-turtle converter

		$ insert_static_datasets
		$ fetch-and-load-articles
		
* Start the web app in development mode

		$ cd /project/od4d.org
		$ rails server
		
* Now you will be able to access the web app in your browser using the url [http://localhost:3000](http://localhost:3000)


### Set up the test environment:

In the set up of the development environment two virtual machines were create. One of the machines is the test environment. The goal of the test environment is to have an environment that simulates staging/production locally.

To set up the test environment for the first time follow the steps below:

	$ vagrant ssh # if you are not logged in the development machine yet
	$ cd /project/sematic-repository
	$ rake deploy:test
	$ cd /project/rss-to-turtle
	$ rake deploy:test
	$ cd /project/od4d.org
	$ rake deploy:test
	
Now you will be able to access the web app in your browser using the url [http://10.0.0.3](http://10.0.0.3)

### Set up a new server:

To create a new server for staging or production you just need to follow these steps:

* Provision your hardware, cloud instance or virtual machine

* Install [Ubuntu Server 14.04 LTS](http://www.ubuntu.com/download/server)

* Copy the directory app-server-scripts to '/tmp' in the server

* Execute the commands from the server:

		$ cd /tmp/app-server-scripts
		$ export APP_ENV="{replace-this-with-the-environment-name}"
		$ export KEY_TO_AUTHORIZE="{replace-this-with-the-public-key-of-the-key-pair-that-will-be-used-for-deployment}"
		$ ./bootstrap.sh

* Set in your deploy machine the environment variable 'OD4D_STAGING_SERVER' (or 'OD4D_PROD_SERVER') and deploy the app components:

		$ cd semantic-repository
		$ rake deploy:{replace-this-with-the-environment-name}
		$ cd rss-to-turtle
		$ rake deploy:{replace-this-with-the-environment-name}
		$ cd od4d.org
		$ rake deploy:{replace-this-with-the-environment-name}


## Licence

MIT License Copyright (c) 2014  

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

****************************************************************************
