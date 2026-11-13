# Shiny (1.5 and later) sources every file in R/ into an environment of its
#   own before it runs app.R, unless this file is present. app.R sources R/
#   itself, into the global environment, after attaching packages and checking
#   them, so without this file every function is loaded twice and the server
#   runs on the copy app.R never sees. Keep this file, and keep it empty.
