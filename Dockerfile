FROM ruby:2.6.10

RUN mkdir /easyship-challenge
WORKDIR /easyship-challenge

RUN apt-get update

# BUILD DOCKER IMAGE easyship-challenge
# docker build -t 'easyship-challenge' -f /path/to/local/code/Dockerfile .

# BUILD CONTAINER easyship-challenge
# docker run --expose 3000 -p 3000:3000 --name easyship-challenge -it -v /path/to/local/code:/easyship-challenge -d easyship-challenge

# START CONTAINER easyship-challenge
# docker start easyship-challenge

# LOG IN TO CONTAINER easyship-challenge
# docker exec -it easyship-challenge bash

# RUN FOLLOWING COMMANDS
#   - bundle install
#   - rails db:migrate RAILS_ENV=development
#   - apt-get -y install --no-install-recommends sqlite3 //optional but helps in visualizing db data
#   - rails db:seed // optional, to populate developement data
#   - rspec // optional, to check that all test cases are passing

# RUN rails server
# rails s -b 0.0.0.0 -p 3000

# APIs accessible at: http://localhost:3000/