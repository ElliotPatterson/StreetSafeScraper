library(rvest)
# install.packages("polite")
library(polite)
library(tidyverse)
library(tidygeocoder)
library(xml2)

url = "https://www.streetsafe.supply/results/"

prefix = "https://www.streetsafe.supply"

css_select= '//*[(@id = "pdp")]//*[(((count(preceding-sibling::*) + 1) = 2) and parent::*)] | //*[contains(concat( " ", @class, " " ), concat( " ", "fadeIn", " " ))]'

# TODO: combine into single function

get_results <- function(suffix, bow = supply_bow, css_select){
  session<-nod(bow = bow, path = paste0(suffix))
  scraped_page<-scrape(session)
  node_result <- html_nodes(scraped_page, xpath=css_select)
  text_result <- html_text(node_result)
  return(text_result[12])
}

get_results2<- function(suffix, bow = supply_bow){
  session<-nod(bow = bow, path = paste0(suffix))
  scraped_page<-scrape(session)
  html_result <- html_element(scraped_page, "ul")
  text_result <- html_text2(html_result)
  return(text_result)
}
