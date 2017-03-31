library('RSelenium')

#SET UP THE SELENIUM SERVER
#java -jar selenium-server-standalone-3.0.1.jar
#Launch the browser
remDr <- remoteDriver(browserName="firefox", port=4444)
remDr$open()
addr <- "130 S 18TH ST"
unit <- "2201"

#Import the csv file
condos <- as.matrix(read.csv("D:/study/MUSA620/MUSA-620-Week-3/rittenhouse-condos.csv", sep=","))
head(condos)

#run the loop function, add the number of row in variable to check the result in looping
scrapeCondoData <- function(addr,unit,number) {
  
  #search the webside
  remDr$navigate("http://property.phila.gov/")
  
  #Select the address and unit search box and put value in them
  AddrField <- remDr$findElement("xpath","//*[@id='search-address']")
  AddrField$sendKeysToElement(list(addr, ''))
  unitField <- remDr$findElement("xpath","//*[@id='search-unit']")
  unitField$sendKeysToElement(list(unit, ''))  
  
  #select the run button and run
  unitField$sendKeysToElement(list(key = 'enter'))
 
  Sys.sleep(3)
  #scrape the price tabular element
  oprice <- remDr$findElements("class", "tablesaw-cell-content")
  
  #select the latest price
  price <- oprice[[2]]$getElementText()
  
  #clean the price string into the number
  b <- as.numeric(gsub("[^0-9]","",unlist(price)))
  #b
  #select the css selector in the price in html
  
  #table > tbody > tr:nth-child(1) > td:nth-child(2)
  #body > table:nth-child(2)
  #oprice <- remDr$findElements("css selector, "table > tbody > tr:nth-child(1) > td:nth-child(2)")
  #oprice <- remDr$findElements("css selector, "body > table:nth-child(2)")
  
  #scrape the area element and clean the string into number
  area <- remDr$findElement("xpath","//*[@id='maincontent']/div[3]/div[2]/div[2]/div[6]/div[2]/strong")
  A <- area$getElementText()
  a <- as.numeric(gsub("[^0-9]","",unlist(A)))
  #a

  #head(condos[,3])
  scrapedData <- c(b,a)

  #print out the procession when running the loop
  print(paste(b,a,number))
  
  return (scrapedData)
  
}
#the function accidently failed in looping the 231th row so I have
#loop twice to get the result
#temp <- condos[1:231,c(1:3)]
#results <- mapply(scrapeCondoData, temp[,1],temp[,2],temp[,3] )

results <- mapply(scrapeCondoData, condos[,1],condos[,2],condos[,3] )

#reverse the column and row of result and store in data frame
#t(result200)
#t(result900)
#t(result500)
#r200 <- t(result200)
#r500 <- t(result500)
#r900 <- t(result900)
total <- rbind(r200,r500, r900)
total <- data.frame(total)
total

#add a column to calculate the price per square foot for these homes
total$"X3" <- total$X1 / total$X2
#total$b <-NA
#total <- subset( total, select = -b )

#check the average price per square foot for these homes
summary(total$X3)
#Mean number is 510.6
print("the price per square foot for these homes is 510.6")
# save as a csv file
setwd("D:/study/MUSA620/MUSA-620-Week-3")
write.csv(total,file = "result.csv")




                         