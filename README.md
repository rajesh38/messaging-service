# Messaing System

This service is responsible for managing SMS sending and receiving

# Steps to setup the application:

* Install ruby with the command:
  * rbenv install \<ruby version\>

* Install postgres using brew:
  * brew install postgres

* Create database in postgres with name: **atc_messaging**
  
* Import sql dump into postgres with command:
  * psql atc_messaging \< \<dump file absulute path\>

* Install redis
  * brew install redis

* Go to project directory and then use the following command to install all required libraries/plugins:
  * bundle install

* Start postgres with the command:
  * pg_ctl -D /usr/local/var/postgres start

* Start redis with command:
  * redis-server --daemonize yes

* Start the application with the command:
  * rails s

* Load the following curls in postman to check the APIs
  * Inbound SMS API CURL:
    * curl --location --request POST 'localhost:3000/inbound/sms?from=4924195509198&to=441224980094&text=STOP' \
--header 'username: azr2' \
--header 'password: 54P2EOKQ47' \
--header 'Cookie: V_ID=ultimate.2020-05-06.affdcef1aae6cc09dd7582fe9bcef5e2' \
--data-raw ''

  * Outbound SMS API CURL:
    * curl --location --request POST 'localhost:3000/outbound/sms?from=4924195509198&to=441224980094&text=STOP' \
--header 'username: azr1' \
--header 'password: 20S0KPNOIM' \
--header 'Cookie: V_ID=ultimate.2020-05-06.affdcef1aae6cc09dd7582fe9bcef5e2'

N.B. You can modify the input parameters as per the testcases given in the question statement to check if all the scenarios are covered.