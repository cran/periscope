% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ui_helpers.R
\name{add_ui_sidebar_right}
\alias{add_ui_sidebar_right}
\title{Add UI Elements to the Right Sidebar}
\usage{
add_ui_sidebar_right(elementlist = NULL, append = FALSE)
}
\arguments{
\item{elementlist}{list of UI elements to add to the sidebar tab}

\item{append}{whether to append the \code{elementlist} to the currently
registered elements or replace the currently registered elements completely}
}
\description{
This function registers UI elements at the right dashboard sidebar. 
The UI elements to be added depend on the version of shinydashboardPlus in use.
}
\section{Shiny Usage}{

Call this function after creating elements in \code{program/ui_sidebar_right.R} to register
them to the application framework and show them on the right dashboard sidebar
}

\examples{
\dontrun{
require(shiny)
require(shinydashboardPlus)

# shinydashboardPlus changed significantly in version 2.0 and has 
# different syntax for the element content, here is an example for each

# shinydashboardPlus < 2.0
s1 <- rightSidebarTabContent(id = 1, icon = "desktop", title = "Tab 1 - Plots", active = TRUE, 
                             div(helpText(align = "center", "Sample UI Text"),
                                 selectInput("sample1", "A Select", c("A", "B", "C")) ))

# shinydasboardPlus >= 2.0
s1 <- controlbarMenu(id = 1, selected = "Tab 1 - Plots",
                     controlbarItem(icon = icon("desktop"), title = "Tab 1 - Plots",
                                    div(helpText(align = "center", "Sample UI Text"),
                                    selectInput("sample1", "A Select", c("A", "B", "C")) )))
                                    
# add the above content to the sidebar (periscope functionality)
add_ui_sidebar_right(list(s1), append = FALSE)
}

}
\seealso{
\link[periscope]{add_ui_sidebar_basic}

\link[periscope]{add_ui_body}

\link[shinydashboardPlus]{shinydashboardPlusGallery}
}
