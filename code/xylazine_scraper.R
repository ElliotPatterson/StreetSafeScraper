source("code/00_libraries_constants.R")

# get suffixes for page scrapes
page <- read_html(url)

hrefs <- html_nodes(page, "a") %>%
  map(xml_attrs) %>%
  map_df(~as.list(.))

results <- hrefs %>% filter(str_detect(href, "/p/"))

# polite
# https://www.rostrum.blog/2019/03/04/polite-webscrape/

supply_bow <- bow(prefix, force=TRUE)
print(supply_bow)
# crawl delay 5 sec

test_result<- get_results(results$href[32], bow=supply_bow, css_select=css_select)
# works

result_names<-set_names(results$href)

results_df <- map_df(
  result_names,
  ~get_results(.x, css_select=css_select)) %>% 
  gather("href", "text")
# now we have list of page suffix + page text

# text cleanup
results_df$text <- results_df$text %>% 
  #str_replace("CarolinaAssumed", "Carolina Assumed") 
  str_replace("Assumed", " Assumed") %>%
  str_replace("Only", "") %>%
  str_replace("Unclear", " Assumed unclear")%>%
  str_repalce("Ashevillie", "Asheville")

# for each href in href,: paste0 (url, href),  get_html, select <ul>, cbind

# test_page<- read_html(paste0(prefix, results_df$href[3]))
# test_result<-html_element(test_page, "ul") %>% html_text2
# test_result

results_df2 <- map_df(
  result_names,
  ~get_results2(.x)) %>% 
  gather("href", "results")
# page suffix + drug results

# left join
results_df <- results_df %>% left_join(results_df2)


# more text cleanup
results_df <- results_df %>% 
  mutate(location = str_extract(text,"(?<=From )(.*?)(?= on)")) %>%
  mutate(date = str_extract(text, "(?<=on )(.*?)(?=Assume)")) %>%
  mutate(assumed = str_extract(text, "(?<=Assumed to be )(.*?)(?=\\d)"))
# regex: between "From" and "on", .*? is lazy select (stop at first "on")

results_df <- results_df %>% 
  separate(assumed, c("assumed", "second"), sep="This") %>%
  select(-second)

results_df<-results_df %>%
  separate(assumed, c("assumed", "second"), sep="Sorry")%>%
  select(-second)

results_df<-results_df %>%
  separate(results, c("results", "second"), sep="How ") %>%
  select(-second)

# separate results
# TODO: this isn't great but I want separated text for Tableau viz
nmax <- max(stringr::str_count(results_df$results,"\\n"))
results_df<-separate(results_df, results, paste0("result", seq_len(nmax)), sep = "\\n", fill = "right")

# separate "assumed"
nmax<- max(stringr::str_count(results_df$assumed, ","), na.rm=TRUE) # ignore NA
results_df<-separate(results_df, assumed, paste0("assumed", seq_len(nmax)), sep=",", fill="right")

# write.csv(results_df, "streetsafesupply.csv", quote = TRUE)
write_csv(results_df, "outputs/streetsafesupply.csv")



