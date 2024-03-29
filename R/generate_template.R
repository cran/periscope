# TEMPLATE SETUP FUNCTIONS ------

#' Create a new templated framework application
#'
#' Creates ready-to-use templated application files using the periscope
#' framework.  The application can be created either empty (default) or with a
#' sample/documented example application.\cr \cr A running instance of the exact 
#' sample application that will be created is
#' \href{http://periscopeapps.org:3838/periscope_template}{hosted here} if you
#' would like to see the sample application before creating your own copy.
#'
#' @param name name for the new application and directory
#' @param location base path for creation of \code{name}
#' @param sampleapp whether to create a sample shiny application
#' @param resetbutton whether the reset button should be added on the Advanced (left) sidebar.
#' @param rightsidebar parameter to set the right sidebar. It can be TRUE/FALSE or a character 
#' containing the name of a shiny::icon().
#' @param leftsidebar whether the left sidebar should be enabled.
#' @param custom_theme_file location of custom theme settings yaml file. Default value is NULL.
#'
#' @section Name:
#' The \code{name} directory must not exist in \code{location}.  If the code
#' detects that this directory exists it will abort the creation process with
#' a warning and will not create an application template.
#'
#' Use only filesystem-compatible characters in the name (ideally w/o spaces)
#'
#' @section Directory Structure:
#'
#' \preformatted{
#' name
#'  -- www (supporting shiny files)
#'  -- program (user application)
#'  -- -- data (user application data)
#'  -- -- fxn  (user application function)
#'  -- log (log files)
#' }
#'
#' @section File Information:
#'
#' All user application creation and modifications will be done in
#' the \strong{program} directory.  The names & locations
#' of the framework-provided .R files should not be changed or the framework
#' will fail to work as expected. \cr
#' \cr
#' \strong{\emph{name/program}/ui_body.R} :\cr
#' Create body UI elements in this file and register them with the
#' framework using a call to \link[periscope]{add_ui_body} \cr
#' \cr
#' \strong{\emph{name/program}/ui_sidebar.R} :\cr
#' Create sidebar UI elements in this file and register them with the
#' framework using a call to \link[periscope]{add_ui_sidebar_basic} or
#' \link[periscope]{add_ui_sidebar_advanced} \cr
#' \cr
#' \strong{\emph{name/program}/ui_sidebar_right.R} :\cr
#' Create right sidebar UI elements in this file and register them with the
#' framework using a call to \link[periscope]{add_ui_sidebar_right} \cr
#' \cr
#' \strong{\emph{name/program/data}} directory :\cr
#' Use this location for data files.  There is a \strong{.gitignore} file
#' included in this directory to prevent accidental versioning of data\cr
#' \cr
#' \strong{\emph{name/program}/global.R} :\cr
#' Use this location for code that would have previously resided in global.R
#' and for setting application parameters using
#' \link[periscope]{set_app_parameters}.  Anything placed in this file will
#' be accessible across all user sessions as well as within the UI context. \cr
#' \cr
#' \strong{\emph{name/program}/server_global.R} :\cr
#' Use this location for code that would have previously resided in server.R
#' above (i.e. outside of) the call to \code{shinyServer(...)}. Anything placed
#' in this file will be accessible across all user sessions. \cr
#' \cr
#' \strong{\emph{name/program}/server_local.R} :\cr
#' Use this location for code that would have previously resided in server.R
#' inside of the call to \code{shinyServer(...)}.  Anything placed in this
#' file will be accessible only within a single user session.\cr
#' \cr
#' \strong{\emph{name}/www/periscope_style.yaml} :\cr
#' This is the application custom styling yaml file. User can update
#' application different parts style using this file.\cr
#' \cr
#' \cr
#' \strong{Do not modify the following files}: \cr
#' \preformatted{
#' name\\global.R
#' name\\server.R
#' name\\ui.R
#' name\\www\\img\\loader.gif
#' name\\www\\img\\tooltip.png
#' }
#' 
#' @section Right Sidebar:
#'  \preformatted{
#'  value
#'  FALSE   --- no sidebar
#'  TRUE    --- sidebar with default icon ('gears').
#'  "table" --- sidebar with table icon. The character string should be a valid "font-awesome" icon.
#'  }
#'
#'@seealso \link[shiny:icon]{shiny:icon()}
#'@seealso \link[shinydashboard:dashboardPage]{shinydashboard:dashboardPage()}
#'
#'@examples
#' # sample app named 'mytestapp' created in a temp dir
#' create_new_application(name = 'mytestapp', location = tempdir(), sampleapp = TRUE)
#' 
#' # sample app named 'mytestapp' with a right sidebar using a custom icon created in a temp dir
#' create_new_application(name = 'mytestapp', location = tempdir(), sampleapp = TRUE, 
#' rightsidebar = "table")
#' 
#' # blank app named 'myblankapp' created in a temp dir
#' create_new_application(name = 'myblankapp', location = tempdir())
#' # blank app named 'myblankapp' with a green skin created in a temp dir
#' create_new_application(name = 'myblankapp', location = tempdir())
#' # blank app named 'myblankapp' without a left sidebar created in a temp dir
#' create_new_application(name = 'myblankapp', location = tempdir(), leftsidebar = FALSE)
#'
#' @export
create_new_application <- function(name, 
                                   location, 
                                   sampleapp = FALSE,
                                   resetbutton = TRUE,
                                   rightsidebar = FALSE, 
                                   leftsidebar = TRUE, 
                                   custom_theme_file = NULL) {
    usersep <- .Platform$file.sep
    newloc <- paste(location, name, sep = usersep)

    if (dir.exists(newloc)) {
        warning("Framework creation could not proceed, path=<",
                newloc, "> already exists!")
    }
    else if (!(dir.exists(location))) {
        warning("Framework creation could not proceed, location=<",
                location, "> does not exist!")
    }
    else {
        dashboard_plus <- FALSE
        right_sidebar_icon <- NULL
        if (!is.null(rightsidebar)) {
            if ("logical" %in% class(rightsidebar)) {
                if (rightsidebar) { dashboard_plus <- TRUE  }
            } else if ("character" %in% class(rightsidebar)) {
                dashboard_plus <- TRUE
                right_sidebar_icon <- rightsidebar
            } else {
                stop("Framework creation could not proceed, invalid type for rightsidebar, only logical or character allowed")
            }
        }
        
        if (!(.g_sdp_installed) && dashboard_plus) {
            stop('shinyDashboardPlus is not currently installed -- it is required to generate an application with a right sidebar.')
        }
        
        .create_dirs(newloc, usersep)
        if (!is.null(custom_theme_file)) {
            if (any(!is.character(custom_theme_file),
                    length(custom_theme_file) != 1,
                    custom_theme_file == "",
                    !file.exists(custom_theme_file))) {
                warning("'custom_theme_file' must be single character value pointing to valid yaml file location. Using default values.")
                custom_theme_file <- NULL
            }
        }
        .copy_fw_files(newloc, usersep, resetbutton, dashboard_plus, leftsidebar, right_sidebar_icon, custom_theme_file, sampleapp)
        .copy_program_files(newloc, usersep, sampleapp, resetbutton, leftsidebar, dashboard_plus)

        message("Framework creation was successful.")
    }
    invisible(NULL)
}


# Create Directories ----------------------------
.create_dirs <- function(newloc, usersep) {
    dir.create(newloc)
    dir.create(paste(newloc, "www", sep = usersep))
    dir.create(paste(newloc, "www", "css", sep = usersep))
    dir.create(paste(newloc, "www", "js", sep = usersep))
    dir.create(paste(newloc, "www", "img", sep = usersep))

    dir.create(paste(newloc, "program", sep = usersep))
    dir.create(paste(newloc, "program", "data", sep = usersep))
    dir.create(paste(newloc, "program", "fxn", sep = usersep))

    dir.create(paste(newloc, "log", sep = usersep))

    #safety for data directory - create .gitignore
    writeLines(c("*", "*/", "!.gitignore"),
               con = paste(newloc, "program", "data", ".gitignore",
                           sep = usersep))

    return()
}

# Create Framework Files ----------------------------
.copy_fw_files <- function(newloc, 
                           usersep,
                           resetbutton = TRUE, 
                           dashboard_plus = FALSE,
                           leftsidebar = TRUE, 
                           right_sidebar_icon = NULL,
                           custom_theme_file,
                           sampleapp = FALSE) {
    files <- c("global.R",
               "server.R")
    if (dashboard_plus) {
        files <- c(files, "ui_plus.R")
    } else {
        files <- c(files, "ui.R")
    }

    for (file in files) {
        writeLines(readLines(
            con = system.file("fw_templ", file, package = "periscope")),
            con = paste(newloc, file, sep = usersep))
    }
    if (dashboard_plus) {
        file.rename(paste(newloc, "ui_plus.R", sep = usersep), paste(newloc, "ui.R", sep = usersep))
        if (!is.null(right_sidebar_icon)) {
            ui_file <- file(paste(newloc, "ui.R", sep = usersep), open = "r+")
            writeLines(gsub("fw_create_header_plus\\(", paste0("fw_create_header_plus\\(sidebar_right_icon = '", right_sidebar_icon, "'"), 
                            readLines(con = ui_file)), 
                       con = ui_file)
            close(ui_file)
        }
    }
    if (leftsidebar) {
        if (!resetbutton) {
            ui_file <- file(paste(newloc, "ui.R", sep = usersep), open = "r+")
            writeLines(gsub("fw_create_sidebar\\(", "fw_create_sidebar\\(resetbutton = FALSE", 
                            readLines(con = ui_file)), 
                       con = ui_file)
            close(ui_file)
        }
    } else {
        ui_file    <- file(paste(newloc, "ui.R", sep = usersep), open = "r")
        ui_content <- readLines(con = ui_file)
        close(ui_file)
        source_positions <- grep("source", ui_content)
        remove_positions <- seq(source_positions[1], source_positions[2] - 1)
        ui_content       <- ui_content[-remove_positions]
        if (resetbutton) {
            ui_content <- gsub("fw_create_sidebar\\(\\)", "fw_create_sidebar\\(showsidebar = FALSE\\)", ui_content)
        } else {
            ui_content <- gsub("fw_create_sidebar\\(\\)", "fw_create_sidebar\\(showsidebar = FALSE, resetbutton = FALSE\\)", ui_content)
        }
        ui_file    <- file(paste(newloc, "ui.R", sep = usersep), open = "w")
        writeLines(ui_content, con = ui_file)
        close(ui_file)
    }
    
    if (sampleapp) {
        ui_file    <- file(paste(newloc, "ui.R", sep = usersep), open = "r")
        ui_content <- readLines(con = ui_file)
        close(ui_file)
        ui_content <- gsub("periscope:::fw_create_body()", 
                           "uiOutput('body')", 
                           ui_content,
                           fixed = TRUE)
        ui_file    <- file(paste(newloc, "ui.R", sep = usersep), open = "w")
        writeLines(ui_content, con = ui_file)
        close(ui_file)
    }

    #subdir copies
    imgs <- c("loader.gif", "tooltip.png")
    for (file in imgs) {
        writeBin(readBin(
            con = system.file("fw_templ", "www", file,
                              package = "periscope"),
            what = "raw", n = 1e6),
            con = paste(newloc, "www", "img", file, sep = usersep))
    }

    if (!is.null(custom_theme_file)) {
        file.copy(custom_theme_file, paste(newloc, "www", "periscope_style.yaml", sep = usersep))
    } else if (sampleapp) {
        file.copy(system.file("fw_templ", "www", "periscope_style.yaml", package = "periscope"),
                  paste(newloc, "www", "periscope_style.yaml", sep = usersep))
    } else {
        create_default_theme_file(paste(newloc, "www", "periscope_style.yaml", sep = usersep))
    }
}

# Create Program Files ----------------------------
.copy_program_files <- function(newloc, usersep, sampleapp, resetbutton = TRUE, leftsidebar = TRUE, dashboard_plus = FALSE) {
    files <- list("global.R"        = "global.R",
                  "server_global.R" = "server_global.R",
                  "server_local.R"  = "server_local.R",
                  "ui_body.R"       = "ui_body.R")
    
    if (leftsidebar) {
        files["ui_sidebar.R"] <- "ui_sidebar.R"
    }
    if (dashboard_plus) {
        files["ui_sidebar_right.R"] <- "ui_sidebar_right.R"
    }
    if (sampleapp) {
        if (dashboard_plus) {
            if (leftsidebar) {
                names(files)[grepl("server_local.R", names(files))] <- "server_local_plus.R"
            } else {
                names(files)[grepl("server_local.R", names(files))] <- "server_local_plus_no_left.R"
            }
        } else if (!dashboard_plus && !leftsidebar) {
            names(files)[grepl("server_local.R", names(files))] <- "server_local_no_left.R"
        }
        if (leftsidebar && !resetbutton) {
            names(files)[grepl("ui_sidebar.R", names(files))] <- "ui_sidebar_no_reset.R"
        }
    }
    
    targetdir <- paste(newloc, "program", sep = usersep)
    sourcedir <- paste("fw_templ",
                       ifelse(sampleapp, "p_example", "p_blank"),
                       sep = usersep)

    for (file in names(files)) {
        writeLines(readLines(
            con = system.file(sourcedir, file, package = "periscope")),
            con = paste(targetdir, files[[file]], sep = usersep))
    }

    #subdir copies for sampleapp
    if (sampleapp) {
        supporting_files <- list("example.csv"       = "data",
                                 "program_helpers.R" = "fxn",
                                 "plots.R"           = "fxn")
        for (file in names(supporting_files)) {
            writeLines(readLines(
                con = system.file(sourcedir, file,
                                  package = "periscope")),
                con = paste(targetdir, unlist(supporting_files[file], use.names = F), file, sep = usersep))
        }
    }
}

create_default_theme_file <- function(theme_file) {
    lines <- c("### primary_color",
               "# Sets the primary status color that affects the color of the header, valueBox, infoBox and box.",
               "# Valid values are names of the color or hex-decimal value of the color (i.e,: \"blue\", \"#086A87\").",
               "# Blank/empty value will use default value",
               "primary_color: \n\n",
               
               
               "# Sidebar variables: change the default sidebar width, colors:",
               "### sidebar_width",
               "# Width is to be specified as a numeric value in pixels. Must be greater than 0 and include numbers only.",
               "# Valid possible value are 200, 350, 425, ...",
               "# Blank/empty value will use default value",
               "sidebar_width: \n",
               
               "### sidebar_background_color",
               "# Valid values are names of the color or hex-decimal value of the color (i.e,: \"blue\", \"#086A87\").",
               "# Blank/empty value will use default value",
               "sidebar_background_color: \n",
               
               "### sidebar_hover_color",
               "# The color of sidebar menu item upon hovring with mouse.",
               "# Valid values are names of the color or hex-decimal value of the color (i.e,: \"blue\", \"#086A87\").",
               "# Blank/empty value will use default value",
               "sidebar_hover_color: \n",
               
               "### sidebar_text_color",
               "# Valid values are names of the color or hex-decimal value of the color (i.e,: \"blue\", \"#086A87\").",
               "# Blank/empty value will use default value",
               "sidebar_text_color: \n\n",
               
               "# body variables",
               "### body_background_color",
               "# Valid values are names of the color or hex-decimal value of the color (i.e,: \"blue\", \"#086A87\").",
               "# Blank/empty value will use default value",
               "body_background_color: \n",
               
               "# boxes variables",
               "### box_color",
               "# Valid values are names of the color or hex-decimal value of the color (i.e,: \"blue\", \"#086A87\").",
               "# Blank/empty value will use default value",
               "box_color: \n",
               
               "### infobox_color",
               "# Valid values are names of the color or hex-decimal value of the color (i.e,: \"blue\", \"#086A87\").",
               "# Blank/empty value will use default value",
               "infobox_color: \n")
    writeLines(lines, theme_file) 
}
