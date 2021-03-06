# Interactive Shiny App that allows the user to select multiple PanelApp panels using 
# the PanelApp API.  Network analysis is then performed to identify candidates.
source("chooser.R")
source("webGestaltAPI.R")

# Get required packages
GetPackages <- function(required.packages) {
  packages.not.installed <- required.packages[!(required.packages %in% installed.packages()[, "Package"])]
  if(length(packages.not.installed)){install.packages(packages.not.installed, dependencies = T)}
  suppressMessages(lapply(required.packages, require, character.only = T))
}

GetPackages(c("BiocManager", "shiny", "tidyverse", "jsonlite", "ggplot2", 
              "plotly", "igraph", "WebGestaltR", "RCy3", "waiter", "png"))

# One package needed from BiocManager
if (!requireNamespace("RCy3", quietly = T)) {
  install.packages("RCy3")
}

# Test if Cytoscape has successfully loaded
test.message <- cytoscapePing ()
if(test.message == "You are connected to Cytoscape!"){
  print("You are connected to Cytoscape!")
} else {
  print("Connection failed - make sure Cytoscape is open locally")
}

# List of CytoScape apps to install
installApp(c("clustermaker2", "enrichmentmap", "autoannotate", "wordcloud", "stringapp", "aMatReader"))

# Define functions
getPanelAppList <- function() {
  api_query <- "https://panelapp.genomicsengland.co.uk/WebServices/list_panels/?format=json"
  json_data <- fromJSON(api_query, flatten = T)
  panelApp_panels <- tibble(panel_name = json_data$result$Name,
                            panel_id = json_data$result$Panel_Id,
                            num_of_gene = json_data$result$Number_of_Genes,
                            version = json_data$result$CurrentVersion
                            )
  return(panelApp_panels)
}

panel_list <- getPanelAppList()


# This needs to be passed from the PanelApp list
# panel.genes <- read.csv(file = "../../Documents/genelist_example.csv")

StringGeneExpansion <- function(panel.genes){
  # This determines the query sent to String to expand the gene list
  string_interaction_cmd <- paste('string protein query taxonID=9606 limit=1000 cutoff=0.8 query="',
                                  paste(panel.genes, collapse = ","), '"', sep = "")
  commandsGET(string_interaction_cmd)
  node.attribute.table <- getTableColumns(table="node")
  return(node.attribute.table)
}

# Create force directed layout
NetworkImage <- function(){
  layoutNetwork('force-directed')
  getLayoutPropertyNames(layout.name = 'force-directed')
  layoutNetwork('force-directed defaultSpringCoefficient=0.0000008 defaultSpringLength=70')
}

getPanelGenes <- function(panel_id){
  api_query <- paste0("https://panelapp.genomicsengland.co.uk/WebServices/get_panel/",
                      panel_id,
                      "/?format=json")
  json_data <- fromJSON(api_query, flatten = T)
  panel_genes <- tibble(gene_symbol = json_data$result$Genes$GeneSymbol,
                        evidence = json_data$result$Genes$LevelOfConfidence)  
  
  return(panel_genes)
}

ui <- navbarPage(
  "PanelApp Pathway Analysis",
  tabPanel(
    "Select Panels",
    titlePanel("Select Panels"),
    chooserInput(
      "mychooser",
      "Available PanelApp Panels",
      "Selected PanelApp Panels",
      panel_list$panel_name,
      c(),
      size = 10,
      multiple = T
    ),
    actionButton("runAll", label="Run Analysis"),
    p("Click the button to analyze panels")
  ),
  tabPanel("Available PanelApp Panels",
           titlePanel("Available Panels"),
           DT::dataTableOutput("panel_table")
  ),
  tabPanel("Imported genes",
           titlePanel("Genes Selected for Analysis"),
           DT::dataTableOutput("gene_table"),
           DT::dataTableOutput("expanded_gene_table")
  ),
  tabPanel("Network Analysis",
           titlePanel("Network Analysis for selected PanelApp gene panel"),
           # DT::dataTableOutput("network_analysis"),
           imageOutput("network_analysis_image"),
           "Place html help file here"
  ),
  tabPanel("WebGestaltAPI",
           "Place html help file here"
  ),
  tabPanel("WebGestalt Table",
           titlePanel("WebGestalt Output"),
           DT::dataTableOutput("wg_table")
  ),
  tabPanel("HPO Analysis",
           "Place html help file here"
  ),
  tabPanel("GTex Analysis",
           "Place html help file here"
  ),
  tabPanel("Panel Candidates",
           "Place html help file here"
  ),
  tabPanel("Help",
           "Place html help file here"
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  # Render selected panel
  #output$selection <- renderPrint({
  #  input$mychooser[1]
  #})
  
  # Display selected genes in table
  output$panel_table <- DT::renderDataTable({
    DT::datatable(as.data.frame(panel_list))
  })

  # Display selected genes in table
  output$gene_table <- DT::renderDataTable({

    selected_panels <- panel_list[panel_list$panel_name %in% unlist(input$mychooser[2]),]
    # Use panel_id from selected panels to get panel genes
    selected_genes <- lapply(selected_panels$panel_id, getPanelGenes)
    # getPanelGenes(panel)
    DT::datatable(as.data.frame(selected_genes))
  })  
    
  # Display WebGestalt output in table
  output$wg_table <- DT::renderDataTable({
    
    selected_panels <- panel_list[panel_list$panel_name %in% unlist(input$mychooser[2]),]
    # Use panel_id from selected panels to get panel genes
    selected_genes <- lapply(selected_panels$panel_id, getPanelGenes)
    outputDirectory <- getwd()
    DT::datatable(callWebGestalt(unlist(selected_genes), outputDirectory))
  })  

}

# Currently hardcoded output directory (file written over every time app is run)
html_temp_file <- paste0(outputDirectory, "/Documents/ProteinNet/Project_temp_webGestalt/Report_temp_webGestalt.html")

paste0(outputDirectory, "/Documents/ProteinNet/Project_temp_webGestalt/Report_temp_webGestalt.html")

# Run the application 
shinyApp(ui = ui, server = server)
