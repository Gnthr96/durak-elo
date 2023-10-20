# install.packages("shiny")
# install.packages("shinythemes")
# install.packages("mvtnorm")
# install.packages("reshape2")
# install.packages("DT")
# install.packages("ggplot2")
# install.packages("dplyr")
# install.packages("shinyscreenshot") #necessary only for screenshot button

library(shiny)
source("functions/elo.R")

data = read.csv("durak.csv")

temp = calculate_history(data)
present_table = temp$present_table
history = temp$history

source("functions/server.R")
source("functions/ui.R")

shinyApp(ui = ui, server = server)