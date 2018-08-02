library(tidyverse)
library(yaml)
library(httr)
library(mongolite)
library(cli)

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
    
    # return 
    endpoint
}


# Main --------------------------------------------------------------------


# API cofig goes here
pwd_generator <- read_api_config("Generator-N")


# main tester function goes here
fetch_password <- function(endpoint, n_password) {
    
    # -- start time --
    start = Sys.time()
    
    # retrive password
    pwds <- paste0(endpoint, "?n=", n_password) %>% GET() %>% content()
    
    # -- end time --
    end <- Sys.time()
    
    # report status
    sprintf("Get n password; n = %s", n_password) %>% cat_rule()
    
    # return
    list(
        x = n_password,
        # if lenght of result is correct
        status = ( length(pwds) == n_password ),
        # time spent
        total_time = ( end - start )
    )
}

cat_rule("Ready to send requests.", col = "lightblue")

# does the result length increase response time?
temp <- map(1:10, fetch_password, endpoint = pwd_generator)

cat_rule("Ready to export result", col = "lightblue")

# write to database
mg <- est_mongo_conn("Some-Mongo")

# insert result here
temp %>% 
    bind_rows() %>% 
    # Mongo does not recognise S3 difftime object
    mutate(total_time = as.numeric(total_time), ts = Sys.time()) %>% 
    mg$insert()

cat_rule("Exported result.", col = "lightblue")

# trigger validator
#read_api_config("Validator") %>% GET()
    
cat_rule("Mission complete.", col = "green")    


