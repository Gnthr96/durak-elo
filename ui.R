library(shinythemes)

page <-sidebarLayout(
          sidebarPanel(
            actionLink("selectall","(un-)select all"),
            uiOutput("ui_player_choice"),
          ),

          mainPanel(
            tabsetPanel(type = "tabs",
                        tabPanel("History", plotOutput("chart")),
                        tabPanel("Losing Probabilities", plotOutput("probs")),
                        tabPanel("Current Standings", DTOutput("table")),
                        tabPanel("Add match result", uiOutput("ui_loser_choice"), actionButton("add", "Add Result"))
                        )
          )
        )

ui <- navbarPage("DURAK ELO-SCORE",
                 theme = shinytheme("darkly"),
                 page
)
