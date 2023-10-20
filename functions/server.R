library(ggplot2)
library(DT)
library(dplyr)

losing_probs_plot = function(players){
  probs = get_losing_probs(players, as.matrix(history[nrow(history),]))
  return(data.frame(player = players, probs = probs))
}

## server function
server <- function(input, output) {
  #multiselect the players that should be shown
  observe({
    if(input$selectall == 0) return(output$ui_player_choice <- renderUI(
      checkboxGroupInput("player_choice", 
                         label="Player:",
                         colnames(data),
                         selected=colnames(data))
    )) 
    else if (input$selectall%%2 == 0)
    {
      output$ui_player_choice <- renderUI(
        checkboxGroupInput("player_choice", 
                           label="Player:",
                           colnames(data),
                           selected=colnames(data))
      )
    }
    else
    {
      output$ui_player_choice <- renderUI(
        checkboxGroupInput("player_choice", 
                           label="Player:",
                           colnames(data))
      )
    }
  })
  
  #choose the loser in the "Add Match Result" tab
  output$ui_loser_choice <- renderUI(
    radioButtons(inputId="loser_choice", label="Who lost?", 
                 choices=input$player_choice))
  
  #"Add Result" button
  observeEvent(input$add, {
    data = rbind(data, NA)                                      #create new row = new match
    data[nrow(data),input$player_choice] = as.numeric(input$player_choice == input$loser_choice)
    write.csv(data, "../durak.csv", row.names = FALSE, na='')   #overwrite existing file
    temp = calculate_history(data)                              #recalculate the history
    present_table = temp$present_table
    history = temp$history
    showNotification("Result saved", duration = 3)              #give a little notification
  })
  
  # plot depending on the input of player_choice
  output$chart <- renderPlot({
    melt(history ,  id.vars = 'match_id', variable.name = 'name') %>% 
      filter(name %in% input$player_choice)%>%
      ggplot(aes(x = match_id, y = value, color = name)) +
      geom_line()
  })
  
  # results in datatable
  output$table <- renderDT({
    present_table[rownames(present_table)%in%input$player_choice,]%>%
        datatable(style = "bootstrap", options = list(pageLength = 20), colnames= c("Score", "Longest Losing Streak", "Longest Winning Streak",
                                                                                    "Current Winning Streak", "Total Number of Games", 
                                                                                    "Total Number of Losses", "Loss Ratio"))%>%
      formatPercentage(7, 2) %>%
      formatRound(1, digits = 2)
  })
  
  # losing_probabilities
  output$probs <- renderPlot({
    ggplot(losing_probs_plot(input$player_choice), aes(x=player, y=probs)) +
      geom_bar(stat = "identity") +
      geom_text(aes(label=paste(round(100*probs,2), "%")),hjust=1.2) +
      coord_flip()
  })
  
  
}


