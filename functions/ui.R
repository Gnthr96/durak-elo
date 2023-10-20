library(shinythemes)

page <-sidebarLayout(
          sidebarPanel(
            actionButton("selectall","(un-)select all", icon = icon("square-check")),
            uiOutput("ui_player_choice"),
            actionButton("screenshot", "Take a Screenshot", icon = icon("camera")),
          ),

          mainPanel(
            tabsetPanel(type = "tabs",
                        tabPanel("History", plotOutput("chart")),
                        tabPanel("Losing Probabilities", plotOutput("probs")),
                        tabPanel(id = "standings", "Current Standings", DTOutput("table")),
                        tabPanel("Add match result", uiOutput("ui_loser_choice"), actionButton("add", " Add Result", icon = icon("save")))
                        )
          )
        )

ui <- navbarPage("DURAK ELO-SCORE",
                 theme = shinytheme("darkly"),
                 page
)
