# Easyship Challenge : Rails Application Docker Setup Guide

This repository contains a rails application code for Easyship challenge. 
Provided below is Docker setup for running Rails application in a Docker container. It allows you to easily package and distribute your Rails application as a Docker image.

## Prerequisites

Make sure you have Docker installed on your system. You can download and install Docker from [here](https://www.docker.com/get-started).

## Getting Started

1. Clone this repository to your local machine:

    ```bash
    git clone https://github.com/kunaldhyani026/easyship-challenge.git
    ```

2. Navigate to the cloned directory:

    ```bash
    cd your-rails-app
    ```

3. Build the Docker image:

    ```bash
    docker build -t 'easyship-challenge' -f Dockerfile .
    ```

4. Build Docker container:

    ```bash
    docker run --expose 3000 -p 3000:3000 --name easyship-challenge -it -v /path/to/local/code:/easyship-challenge -d easyship-challenge
    ```

    Replace `/path/to/local/code` with the actual path to your Rails application directory.

5. Start Container

    ```bash
    docker start easyship-challenge
    ```
6. Log In to Container
   
   ```bash
   docker exec -it easyship-challenge bash
   ```
7. Run Following Commands
   1. ```bundle install```
   2. ```rails db:migrate RAILS_ENV=development```
   3. ```apt-get -y install --no-install-recommends sqlite3``` //optional but helps in visualizing db data
   4. ```rails db:seed``` // optional, to populate developement data
   5. ```rspec``` // optional, to check that all the test cases are passing

8. Run rails server

   ```bash
   rails s -b 0.0.0.0 -p 3000
   ```

9. APIs accessible at: http://localhost:3000/


### Suggestions and Fixes
- Fixed model relationships (belongs_to, has_many) in company.rb [A Company has_many shipments], shipment.rb [Each shipment belongs_to a Company, each shipment has_many shipment_items]
- Added route for already existing index method in shipments_controller.
- We can refactor index.jbuilder to use `json.extract` to have DRY principle implemented.
- Since Datetime is expected in a format where single digit hours are not prefixed with '0', We have used gsub to substitute the extra space.
- While grouping associated shipment_items by description, we are ordering by count when item_order param is 'ascending' or 'descending'.
  - We can put a default sort even in case when item_order param is neither ascending or descending.
  - We can also use a secondary sort by description in case of clashing count.
- It is possible that for a shipment there are no entries in shipment_items table. Does a Shipment like this valid ? If not, then we should not allow a entry in shipment table to exist unless there are corresponding entries in shipment_items table.
- For companies table, name should be not null, unique and non-empty string.
- For shipment_items table, description should be not null and non-empty string.
- We should build Authentication and Authorizations for the APIs.
- If we need to put in complex business logic for APIs, we should think of creating library lib/ for our business use case and let controller only do calling to library methods to get the response.
- We have added a separate validator class which can hold simple-to-complex validation logic, thus providing extensibility and lesser code bulking in controller.
- For tracking, we are using Aftership's tracking_by_id API (because we have fake responses of this API) however Aftership's last_checkpoint API is more relevant as per our required response.
- Aftership Api Key is expected to be added in ENV variable for secuirty. For production grade application, secrets manager like AWS secrets manager can be used.
- We can create a separate logging module which logs errors along with relevant info (like x-request-id) to the log file.
-  We can add a `rescue_from StandardError, with: :render_standard_error` in application_controller, which will ensure that any unexpected errors in api are handled gracefully and user is given a standard 500, Internal Server Error response message, hiding any internal failure info to be sent to user. This method will also log error using logging module along with x-request-id and tracebacks.
- We are using counter_cache for caching the count of Shipment's associated items. The count gets updated everytime we perform rails create/update/destroy of shipment. This space vs time tradeoff helps us in reducing the sql count query call everytime we want to search a shipment by its items size.
