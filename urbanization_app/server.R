library("shiny")
library("ggplot2")
library("reshape")
library("scales")

# LOAD DATA
# Urban Population by Major Area, Region and Country, 1950-2050
# POP/DB/WUP/Rev.2011/1/F3 -- Provided by United Nations
# United Nations, Department of Economic and Social Affairs, Population Division (2012). 
# World Urbanization Prospects: The 2011 Revision, CD-ROM Edition.
data.regions <- read.csv("un_worldurbanpop_regions_v2.csv", header=TRUE)
years <- c(1950,1955,1960,1965,1970,1975,1980,1985,1990,1995,2000,2005,2010,2015,2020,2025,2030,2035,2040,2045,2050) 

# function for generating the regional charts
getRegionChart <- function(selectedRegion,selectedYears) {
  data.selected <- data.regions[data.regions$Region==selectedRegion,]
  rownames(data.selected)<- data.selected$Subregion
  
  data.selected$Region <- NULL
  data.selected$Subregion <-NULL
  
  data.selected <- data.selected[-1,]
  
  data.selected <- t(data.selected)
  rownames(data.selected)<- years
  data.selected <- as.data.frame(data.selected)
  data.selected$year <- years
  for(i in nrow(data.selected):1){

    if (data.selected[i,"year"] < selectedYears[1] || data.selected[i,"year"] > selectedYears[2])
    {
      data.selected <- data.selected[-i,]
    }
  }
  
  data.selected.melted <- melt(data.selected, id="year")
  names(data.selected.melted) <- c("year", "region", "urban")
  chart.region <- qplot(data=data.selected.melted, x=year, y=urban, color=region, fill=region, stat="identity", geom=c("area"),position="stack", xlab="", ylab="Urban Population (million)") + theme(legend.position="bottom", legend.title=element_blank()) + guides(color=guide_legend(nrow=2))
  return(chart.region)
  
}

getPercentChanges <- function(columnRange)
{
  dataToReturn <- data.frame(Region = data.regions$Region, Subregion = data.regions$Subregion)

  for(i in columnRange)
  {
    percentChange <- (data.regions[,i] / data.regions[,columnRange[1]] ) - 1
    dataToReturn <- cbind(dataToReturn, percentChange) 
  }
  return(dataToReturn)
}


#Define the server logic required to plot variables
shinyServer(function(input,output, session){
  
  output$title.main <- renderText({paste(c(input$time.range[1]," to ", input$time.range[2],"- Relative Growth in Urban Population"))})
  output$title.region1 <- renderText({input$region1})
  output$title.region2 <- renderText({input$region2})
  
  output$plot.comparison <- renderPlot({
    yearRange <- which(years == input$time.range[1]): which(years==input$time.range[2])
    columnRange <-  (yearRange[1]+2):(yearRange[length(yearRange)]+2)
    data.regions.percentchange <- getPercentChanges(columnRange)
    data.selectedregion1 <- data.regions.percentchange[data.regions.percentchange$Region == input$region1 & data.regions.percentchange$Subregion=="All Subregions",3:ncol(data.regions.percentchange)]
    data.selectedregion2 <- data.regions.percentchange[data.regions.percentchange$Region == input$region2 & data.regions.percentchange$Subregion=="All Subregions",3:ncol(data.regions.percentchange)]
    data.selectedregion1 <- t(data.selectedregion1)
    data.selectedregion2 <- t(data.selectedregion2)
    data.selectedregions <- as.data.frame(cbind(year = years[yearRange],region1 = data.selectedregion1[,1], region2 = data.selectedregion2[,1]))
    names(data.selectedregions) <- c("year",input$region1, input$region2)
    data.selectedregions.melted <- melt(data.selectedregions, id="year")
    chart.compare <- qplot(x=year, y=value,data=data.selectedregions.melted, color=variable, xlab = "", ylab="% increase in urban population", stat="identity", geom=c("line","point")) + geom_line(size=1.5) + geom_point(shape=21, size=5, fill="white") + scale_y_continuous(labels=percent)
    print(chart.compare)
  })
  
  output$plot.region1 <- renderPlot({
    chart.region1 <- getRegionChart(input$region1, input$time.range)
    print(chart.region1)
  })
  
  output$plot.region2 <- renderPlot({
    chart.region2 <- getRegionChart(input$region2,input$time.range)
    print(chart.region2)
  })
  
  
})