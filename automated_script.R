# load libraries    
library(tidyverse)
library(rvest)
library(RSelenium)
library(V8)
library(htmlunit)
library(cronR)
library(emayili)
library(magrittr)
library(lubridate)
# load data frame gym_checker
load(file = "~/projects/gym_checker/gym_prices.RData")
# define urls as objects
url1 <- "https://www.nuffieldhealth.com/gyms/sheffield"
url3 <- "https://www.puregym.com/gyms/sheffield-city-centre-south/"
url4 <- "https://www.sheffield.ac.uk/alumni/benefits/sports-discount"
url6 <- "https://www.fitnessunlimited.co.uk/venues/Heeley-Pool"
# read urls as html objects
h1 <- read_html(url1)
h3 <- read_html(url3)
h4 <- read_html(url4)
h6 <- read_html(url6)
# extract nodes from html objects 
p1 <- h1 %>% html_node(".gym-hero__package-button:nth-child(1)") %>% html_text()
p3 <- h3 %>% html_nodes("title") %>% html_text()
p4 <- h4 %>% html_nodes("p") %>% html_text()
p6 <- h6 %>% html_nodes("p") %>% html_text()
# wrangle html text strings into numeric price objects
nuffield <- as.numeric(str_extract(p1,"\\d\\d.\\d\\d"))
puregym <- as.numeric(str_extract(p3,"\\d\\d.\\d\\d"))
sportsheffield <- as.numeric(substring(p4[6], 37,38))
heeleypool <- as.numeric(substring(p6[34], 42,43))
# add a row with the scraped data to df gym_prices  
gym_prices <- add_row(gym_prices,"nuffield" = nuffield, "puregym" = puregym, "sportsheffield" = sportsheffield, "heeleypool" = heeleypool, "date" = today())
# save newly acquired data in the gym_prices object
save(gym_prices, file = "~/projects/gym_checker/gym_prices.RData")
# test whether the latest prices are different from previous prices
x <- nrow(gym_prices)
a <- all.equal(gym_prices$nuffield[x], gym_prices$nuffield[(x-1)])
b <- all.equal(gym_prices$puregym[x], gym_prices$puregym[(x-1)])
c <- all.equal(gym_prices$sportsheffield[x], gym_prices$sportsheffield[(x-1)])
d <- all.equal(gym_prices$heeleypool[x], gym_prices$heeleypool[(x-1)])
y <- all(c(a,b,c,d))
z <- print(gym_prices)
# set up of email_eric
email_eric <- envelope()
email_eric <- email_eric %>% from("oedipusatcolonussheffield@gmail.com") %>% to("eric210bohun@gmail.com")
email_eric <- email_eric %>% subject("The prices have changed or the wesites have- Can I alter this script to email an attachment plot of recent prices?")
email_eric <- email_eric %>% text("The prices or websites have changed - check out the attachment and look at the RStudio log")
email_eric <- email_eric %>% attachment("/home/eric/projects/gym_checker/gym_prices.RData")
smtp <- server(host = "smtp.gmail.com",
               port = 465,
               username = "oedipusatcolonussheffield@gmail.com",
               password = "FD5neta6bhSGVhZ")
# run email_eric if the prices have changed 
if(is.na(y)==TRUE){smtp(email_eric, verbose = TRUE)}