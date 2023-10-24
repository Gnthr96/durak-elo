library(ggplot2)
library(DT)
library(dplyr)
library(shinyscreenshot)
library(reshape2)



## server function
server <- function(input, output) {
  #variables need to be reactive to be changeable
  values = reactiveValues(data = data, history = history, present_table = present_table)
  
  losing_probs_plot = function(players){
    probs = get_losing_probs(players, as.matrix(values$history[nrow(values$history),]))
    return(data.frame(player = players, probs = probs))
  }
  
  #multiselect the players that should be shown
  observe({
    if(input$selectall == 0) return(output$ui_player_choice <- renderUI(
      checkboxGroupInput("player_choice", 
                         label="Player:",
                         colnames(values$data),
                         selected=colnames(values$data))
    )) 
    else if (input$selectall%%2 == 0)
    {
      output$ui_player_choice <- renderUI(
        checkboxGroupInput("player_choice", 
                           label="Player:",
                           colnames(values$data),
                           selected=colnames(values$data))
      )
    }
    else
    {
      output$ui_player_choice <- renderUI(
        checkboxGroupInput("player_choice", 
                           label="Player:",
                           colnames(values$data))
      )
    }
  })
  
  #choose the loser in the "Add Match Result" tab
  output$ui_loser_choice <- renderUI(
    radioButtons(inputId="loser_choice", label="Who lost?", 
                 choices=input$player_choice))
  
  #"Add Result" button
  observeEvent(input$add, {
    values$data = rbind(values$data, NA)                                  #create new row = new match
    values$data[nrow(values$data),input$player_choice] = as.numeric(input$player_choice == input$loser_choice)
    write.csv(values$data, "durak.csv", row.names = FALSE, na='')  #overwrite existing file
    temp = calculate_history(values$data)                          #recalculate the values$history
    values$present_table = temp$present_table
    values$history = temp$history
    showNotification("Result saved", duration = 3)          #give a little notification
  })
  
  # plot depending on the input of player_choice
  output$chart <- renderPlot({
    melt(values$history ,  id.vars = 'match_id', variable.name = 'name') %>% 
      filter(name %in% input$player_choice)%>%
      ggplot(aes(x = match_id, y = value, color = name)) +
      geom_line()
  })
  
  # results in values$datatable
  output$table <- renderDT({
    values$present_table[rownames(values$present_table)%in%input$player_choice,]%>%
        datatable(style = "bootstrap", options = list(pageLength = 20), colnames= c("Score", "Longest Losing Streak", "Longest Winning Streak",
                                                                                    "Current Winning Streak", "Total Number of Games", 
                                                                                    "Total Number of Losses", "Loss Ratio"))%>%
      formatPercentage(7, 2) %>%
      formatRound(1, digits = 2)
  })
  
  # download button for saving the table to an image
  observeEvent(input$screenshot, {
    screenshot(filename = "results")
  })
  
  # losing_probabilities
  output$probs <- renderPlot({
    ggplot(losing_probs_plot(input$player_choice), aes(x=player, y=probs)) +
      geom_bar(stat = "identity") +
      geom_text(aes(label=paste(round(100*probs,2), "%")),hjust=1.2) +
      coord_flip()
  })
  
  
}


