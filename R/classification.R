# The classification marking shown above every screen.

# The text comes from the environment or an option rather than being written
#   into the code, because it will not stay "UNCLASSIFIED": the marking is a
#   deployment decision and has to change without anyone editing R/.

# The environment variable is checked first, and that ordering is the point on
#   a server. Posit Connect lets whoever publishes the app set environment
#   variables from its own interface; it has no way to set an R option short
#   of shipping an .Rprofile inside the bundle. A compliance control that can
#   only be changed by editing and redeploying source is the wrong shape.
#     DRSVYR_CLASSIFICATION=YOUR MARKING      (server)
#     options(drsvyr.classification = "...")  (laptop)
# Unset, it falls back to UNCLASSIFIED rather than to nothing, so a deployment
#   that forgets shows a marking that is visibly wrong instead of no marking.
classification_text <- function() {
  e = Sys.getenv("DRSVYR_CLASSIFICATION", "")
  if (nzchar(e)) e else getOption("drsvyr.classification", "UNCLASSIFIED")
}

classification_banner <- function() {
  tags$div(
    style = paste("background:#b40404; color:#fff; text-align:center;",
                  "font-weight:700; letter-spacing:0.06em;",
                  "padding:5px 0; font-size:13px;"),
    classification_text())
}
