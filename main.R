library(tidyverse)
library(yaml)
library(httr)
library(mongolite)


# Helper Function ---------------------------------------------------------

est_mongo_conn <- function(conn) {
    
    # make sure file exists
    if (!file.exists("dbconfig.yaml")) {
        stop("Database credential not found.")
    }
    
    # read config
    d <- yaml::read_yaml("dbconfig.yaml")
    
    # check if db is specified
    if( "db" %in% names(d[[conn]]) ){
        db = d[[conn]][['db']]
    }else{
        db = conn
    }
    
    # check if the credentials are specified
    if(!all(c("host", "port", "collection") %in% names(d[[conn]]))){
        stop("One or more database parameters is incorrect.")
    }
    
    # est conn
    c <- mongo(
        collection = d[[conn]][["collection"]],
        url = with(d[[conn]], 
                   # mongodb://username:password@host:port
                   sprintf("mongodb://%s:%s@%s:%d/", user, password, host, port)),
        db = d[[conn]][["db"]]
    )
    
    # return connection
    c
    
}


# Configuration -----------------------------------------------------------

read_api_config <- function(which_api){
    
    # make sure file exists
    if(!file.exists("apiconfig.yaml")){
        stop("Require config file - apiconfig.yaml")
    }
    
    # read config
    d <- read_yaml("apiconfig.yaml")
    
    # check if the credentials are specified
    if(!all(c("host", "port", "swagger") %in% names(d[[which_api]]))){
        stop(paste("One or more parameter in", which_api, "is missing."))
    }
    
    # return endpoint
    endpoint = with(d[[which_api]], paste0(host, ":", port, "/", swagger))
    
}


# Main --------------------------------------------------------------------


# API cofig goes here
pwd_generator <- read_api_config("Generator-N")

# generate testing samples


# send request
res <- pwd_generator %>% 
    GET() %>% 
    content()

# write to database
mg <- est_mongo_conn("Some-Mongo")

# insert result here


