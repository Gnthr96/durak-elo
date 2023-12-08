library(shinythemes)

page <-sidebarLayout(
          sidebarPanel(
            actionButton("selectall","(un-)select all", icon = icon("square-check")),
            actionButton("select_regular","select regular players", icon = icon("square-check")),
            uiOutput("ui_player_choice"),
            sliderInput("K", "K", min = 1, max = 50, value = K),
            sliderInput("sigma", "sigma:", min = 1, max = 1000, value = sigma),
            actionButton("recalculate","recalculate", icon = icon("calculator")),
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
