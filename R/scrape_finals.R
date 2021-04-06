library(rvest)

url <- "https://www.ncaa.com/news/basketball-men/mml-official-bracket/2021-04-05/2021-ncaa-bracket-printable-march-madness-bracket-pdf"
webpage <- read_html(url)

rank_data_html <- html_nodes(webpage,'.embedded-entity a')

rank_data_html %>% 
  html_text(trim = TRUE) %>% 
  html_table()

links <- rank_data_html %>% 
  html_attr("href")

links



url <- "https://www.ncaa.com/march-madness-live/game/208?cid=mml2021_editorial_gamecenter"
webpage <- read_html(url)

score_getter <- function (link) {
  webpage <- read_html(link)
  rank_data_html <- html_nodes(webpage,'.color_lvl_5')
  teams <- html_nodes(webpage,'.h4')
  
  teams <- teams %>% 
    html_text(trim = TRUE)
  
  raw <- rank_data_html %>% 
    html_text(trim = TRUE)
  team <- raw[1:2]
  team2 <- raw[5:6]
  output <- c(raw, teams)
  return(output)
    
}

links <- subset(links, grepl("https://www.ncaa.com/game/", links) )

lapply(links, score_getter)

score_getter(links[1])


# this works the best -----------------------------------------------------


url <- "https://www.ncaa.com/march-madness-live/scores"
webpage <- read_html(url)

rank_data_html <- html_nodes(webpage,'.lvp')

data <- rank_data_html %>% 
  html_text(trim = TRUE)

tibble::tibble(data[12:277])
