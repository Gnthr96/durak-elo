# install.packages("shiny")
# install.packages("shinythemes")
# install.packages("mvtnorm")
# install.packages("reshpae2")
# install.packages("DT")
# install.packages("ggplot2")
# install.packages("dplyr")

library(shiny)
source("functions/elo.R")

data = read.csv("durak.csv")

temp = calculate_history(data)
present_table = temp$present_table
history = temp$history

source("server.R")
source("ui.R")

shinyApp(ui = ui, server = server)