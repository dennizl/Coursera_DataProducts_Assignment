library("shiny")

#Define UI for Urbanization Statistics application
shinyUI(pageWithSidebar(
  
  #Application title
  headerPanel(h2("World Urbanization Dashboard", style="color:#5BADFF")),
  
  sidebarPanel(
    img(src="un-logo.png"),
    h4("INTRODUCTION", style="color:#5BADFF"),    
    helpText("Welcome to the World Urbanization Dashboard. This interactive dashboard enables you to explore regional urbanization trends using authoritative statistics provided by the United Nations."),
    br(),
    h4("CONTROL PANEL", style="color:#5BADFF"), 
    selectInput("region1", "Select Region 1:", choices=c("World", "Africa","Asia","Europe","Latin America and the Caribbean", "Northern America","Oceania"), selected="World"),
    selectInput("region2", "Select Region 2:", choices=c("World", "Africa","Asia","Europe","Latin America and the Caribbean", "Northern America","Oceania"), selected="Africa"),
    sliderInput("time.range","Time Range:", min=1950, max=2050, value=c(1950, 2050), step=5, format="####"),
    br(),
    h4("HOW TO USE", style="color:#5BADFF"),
    helpText("To get started, simply select two world regions from the drop downs above to compare their urbanization trends. You can also narrow the timeframe across which you want to analyze the data by adjusting the time range slider."),
    h4("HOW TO READ", style="color:#5BADFF"),
    helpText("The chart on the top will display the relative growth in urban population for the two regions. The two figures below this chart show the total urban population over time in these two regions broken down by their sub regions.")
  ),
  
  mainPanel(
    h3(textOutput("title.main"), align="center", style="color:#5BADFF"),
    plotOutput("plot.comparison"),
    h3("Urban Population Breakdown by Sub-region", align="center", style="color:#5BADFF"),
    column(5, h4(textOutput("title.region1"), align="center", style="color:#787878")),
    column(5, h4(textOutput("title.region2"), align="center", style="color:#787878"),offset=1),
    column(5, plotOutput("plot.region1")),
    column(5, plotOutput("plot.region2"),offset=1)
  )
))