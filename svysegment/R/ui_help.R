# ui_help.R: the Start here tab, in cards. What the method is and the problem
# it solves, how the analysis runs, how to use the tool, what it cannot do,
# and the prompt behind the segment names. Also the office logo in the header.
#
# The method report is the PDF in www/reports/, which Shiny serves at
# reports/ with no resource path to register.

# Bold text followed by punctuation, without the space HTML would put between.
b_ <- function(x) tags$strong(x, .noWS = "after")

help_ui <- function() {
  tagList(
    help_css(),
    bslib::layout_columns(
      col_widths = c(7, 5),
      bslib::card(
        bslib::card_header("What this tool does"),
        tags$p(
          "Surveys often ask a set of related questions, a ", b_("battery"),
          ", about one subject: trust in institutions, financial worries, views on ",
          "a policy. Reading those answers one question at a time misses the ",
          "patterns in how people answer them together. This tool looks for a ",
          "small number of distinct ", b_("types of respondent"),
          ", called segments, each with its own way of answering the set, places ",
          "every respondent it can in the segment their answers fit best, and ",
          "compares how common each segment is across the groups you care about, ",
          "such as region, age or education."),
        tags$p(
          "The method is ", b_("latent class analysis"), ". It treats ",
          "each person's answers as imperfect signals of a type nobody can observe ",
          "directly, so a segment is described by probabilities, for example ",
          "“members of this segment say they trust the courts a lot 62% of ",
          "the time”, rather than by a fixed rule."),
        tags$p(
          "The problem it solves is the margin of error. Survey samples are not ",
          "drawn one person at a time: people are chosen in clusters, within ",
          "strata, and weighted. Standard software ignores that and can report ",
          "margins that are too narrow, so a difference between groups looks ",
          "firmer than the data support. Here every estimate and every margin is ",
          "computed from the survey's own design, from the segments themselves to ",
          "their shares in each group, and the report says how much the design ",
          "changed them for your survey."),
        tags$p(
          "It is built so that you make the judgement calls, and every one is ",
          "recorded with the evidence you had when you made it. A language model ",
          "can draft names and plain-language readings, but it never sees a ",
          "respondent's answers and never changes a number.")),
      bslib::card(
        bslib::card_header("How it works"),
        help_flowchart())),

    bslib::layout_columns(
      col_widths = c(7, 5),
      bslib::card(
        bslib::card_header("Using the tool"),
        tags$ol(
          tags$li(tags$strong("Project and Design."), " Upload an SPSS or Stata file, ",
                  "or use the demonstration survey, and name the columns that ",
                  "hold the respondent id, stratum, sampling unit and weight."),
          tags$li(tags$strong("Items."), " Describe your survey and write your ",
                  "research question, then choose the battery. These details shape ",
                  "the segment names and lead the report, so they are worth a ",
                  "minute."),
          tags$li(tags$strong("Domains and Review."), " Choose the groups to compare ",
                  "and how their categories combine, then approve the plan."),
          tags$li(tags$strong("Search and Model."), " The tool fits two to ten ",
                  "segments; you choose how many from the evidence, before any ",
                  "interpretation is offered. If the model shows the battery was ",
                  "wrong, you may go back once and remove an item."),
          tags$li(tags$strong("Names."), " Have names drafted, or write them ",
                  "yourself from each segment's profile. Either way, check them ",
                  "against the profiles before you save."),
          tags$li(tags$strong("Scoring, Results and Outputs."), " Every respondent ",
                  "who answered enough is placed, the segments are compared across ",
                  "your groups, and you download the report and your data with ",
                  "the segments added.")),
        tags$p(class = "small text-muted",
               "Closing or refreshing this tab ends the session and deletes its ",
               "work, so download your outputs first. The search on 6. Search ",
               "takes a few minutes; leave the tab open while it runs."),
        tags$h6("Method report"),
        help_reports()),
      bslib::card(
        class = "border-primary",
        bslib::card_header(class = "bg-primary text-white", "What it cannot do"),
        tags$ul(class = "small",
          tags$li(tags$strong("Segments are a simplification."), " Real people ",
                  "do not come in a few clean types. Some sit between two, and ",
                  "placing them in one blurs comparisons; the results correct the ",
                  "group comparisons for that, but a person's segment is a best ",
                  "guess."),
          tags$li(tags$strong("How many segments is a judgement."), " The ",
                  "statistics narrow it down; they do not settle it. A different ",
                  "reasonable choice gives different segments."),
          tags$li(tags$strong("Not every battery has types."), " If people mostly ",
                  "differ in how much they agree with everything, a single scale ",
                  "describes them better, and the segments are only cut points on ",
                  "it. The Model screen checks for this."),
          tags$li(tags$strong("Only as good as the survey."), " The design and ",
                  "weights you supply carry every result to the population. Who ",
                  "was missed or did not respond, and how the questions were ",
                  "worded, are fixed before the tool begins."),
          tags$li(tags$strong("Some respondents cannot be placed."), " Those who ",
                  "answered too few of the questions are counted and reported, not ",
                  "guessed at."),
          tags$li(tags$strong("Names are drafts."), " A name never changes a ",
                  "number, but a wrong one misleads. Read each against its profile."),
          tags$li(tags$strong("Differences are not causes."), " A segment being ",
                  "more common in one group says who is in it, not why."),
          tags$li(tags$strong("Small groups are not reported."), " Group levels ",
                  "with too few respondents are flagged rather than estimated.")))),

    help_prompt_card())
}

# One link per method report found in www/reports/.
help_reports <- function() {
  reports = c("survey_lca_report.pdf" =
                "Segmenting a survey population without overstating what the design supports")
  have = reports[file.exists(file.path("www", "reports", names(reports)))]
  if (!length(have))
    return(tags$p(class = "small text-muted", "The method report is not in www/reports/."))
  tags$ul(class = "small", purrr::imap(have, function(txt, f)
    tags$li(tags$a(href = file.path("reports", f), target = "_blank", txt, " (PDF)"),
            ": the full methodology and a worked example on the demonstration survey.")))
}

# ---- the flowchart -----------------------------------------------------------
# Plain HTML boxes and arrows, so it needs no package and follows the theme.

help_step <- function(n, title, ..., you = FALSE)
  div(class = paste("tf-step", if (you) "tf-you"),
      div(class = "tf-num", n),
      div(tags$strong(title), div(class = "small text-muted", ...)))

help_arrow <- function() div(class = "tf-arrow", "↓")

help_flowchart <- function() {
  div(class = "tf",
    help_step(1, "Your survey", "The file, and the columns that describe how the ",
              "sample was drawn.", you = TRUE),
    help_arrow(),
    help_step(2, "The battery and your question", "The related questions to ",
              "analyse, what the survey is, and what you want to know.", you = TRUE),
    help_arrow(),
    help_step(3, "Groups to compare", "Region, age, education: whatever you will ",
              "report by.", you = TRUE),
    help_arrow(),
    help_step(4, "The search", "Two to ten segments are fitted, each from two ",
              "hundred starting points, so the answer does not depend on where ",
              "the fitting began."),
    help_arrow(),
    help_step(5, "How many segments", "You choose, from the evidence.", you = TRUE),
    help_arrow(),
    help_step(6, "Checks and margins", "What the model misses, and a margin of ",
              "error for every segment's profile and size, from the survey design."),
    help_arrow(),
    help_step(7, "Names", "Drafted from each segment's answers and your survey ",
              "details, or written by you; you approve them.", you = TRUE),
    help_arrow(),
    help_step(8, "Results", "Each respondent placed; segments compared across ",
              "your groups, corrected for respondents placed in the wrong one."),
    help_arrow(),
    help_step(9, "Report and data", "One HTML report and your survey file with the ",
              "segments added."),
    div(class = "small text-muted mt-2",
        span(class = "tf-key"), " a decision you make, recorded in the report"))
}

help_css <- function() tags$style(HTML("
.tf { display: flex; flex-direction: column; }
.tf-step { display: flex; gap: .75rem; align-items: flex-start; padding: .45rem .75rem;
  border: 1px solid var(--bs-border-color); border-radius: .5rem;
  background: var(--bs-body-bg); }
.tf-you { border-left: 4px solid var(--bs-primary); }
.tf-num { flex: 0 0 1.6rem; height: 1.6rem; border-radius: 50%;
  background: var(--bs-secondary); color: #fff; font-size: .8rem; font-weight: 600;
  display: flex; align-items: center; justify-content: center; margin-top: .1rem; }
.tf-you .tf-num { background: var(--bs-primary); }
.tf-arrow { text-align: center; color: var(--bs-secondary-color); line-height: 1.1;
  font-size: 1.1rem; }
.tf-key { display: inline-block; width: .9rem; height: .9rem; vertical-align: -2px;
  border: 1px solid var(--bs-border-color); border-left: 4px solid var(--bs-primary);
  border-radius: 2px; }
.tf-pre { white-space: pre-wrap; background: var(--bs-tertiary-bg);
  padding: .75rem; border-radius: .375rem; max-height: 28rem; overflow-y: auto; }
"))

# ---- the naming prompt -------------------------------------------------------
# Built by the same functions the Names screen calls, on two illustrative
#   questions, so what is shown here is what is sent.

help_example_prompt <- function() {
  fit = list(pi = c(0.31, 0.69),
             rho = list(matrix(c(0.08, 0.30, 0.62, 0.55, 0.35, 0.10), 3, 2),
                        matrix(c(0.05, 0.25, 0.70, 0.45, 0.40, 0.15), 3, 2)))
  dict = tibble::tibble(
    item = c("trust_courts", "trust_police"),
    question = c("How much do you trust the courts?",
                 "How much do you trust the police?"),
    responses = list(c("Not at all", "Some", "A lot"), c("Not at all", "Some", "A lot")))
  context = survey_context_text(list(survey = "AmericasBarometer 2023",
                                     population = "Adults living in Ecuador",
                                     topic = "Trust in public institutions"))
  paste0(prompt_segment_label(fit, 1, dict, dict$item, context,
                              "Which groups distrust the justice system?"),
         "\n\n", JSON_QUOTE_RULE)
}

help_prompt_card <- function() {
  bslib::card(
    bslib::card_header("The prompt behind the names"),
    bslib::layout_columns(
      col_widths = c(7, 5),
      tags$div(
        tags$p(class = "small",
               "The segments are found by the statistical model; no language ",
               "model touches that step. With an API key set below, a language ",
               "model drafts a name and a short description for each segment, one ",
               "request per segment. It receives the instructions below, then ",
               "that segment's answer probabilities with the wording of each ",
               "question, and the survey details and research question you entered ",
               "on Items. This example uses two made-up questions."),
        tags$h6("Instructions"),
        tags$pre(class = "small tf-pre", persona_lca),
        tags$h6("One segment, as sent"),
        tags$pre(class = "small mb-0 tf-pre", help_example_prompt())),
      tags$div(
        tags$h6("Why it is written this way"),
        tags$ul(class = "small",
          tags$li(tags$strong("One segment at a time. "),
                  "Each request sees one segment and nothing about the others, so a ",
                  "name describes that segment rather than how it differs from a ",
                  "neighbour the model happened to see."),
          tags$li(tags$strong("Only the evidence shown. "),
                  "The probabilities and the question wording, quoted exactly and ",
                  "never added together. Nothing about any individual respondent."),
          tags$li(tags$strong("Your details shape the wording, not the content. "),
                  "The survey details and research question help choose words your ",
                  "readers will recognise; the rules forbid claiming anything the ",
                  "numbers do not show."),
          tags$li(tags$strong("Short and fixed. "),
                  "A draft name of two to five words and one or two sentences, ",
                  "returned as fields, so drafts are consistent and easy to edit. ",
                  "If two names come back too alike, one more request revises only ",
                  "those."),
          tags$li(tags$strong("You decide. "),
                  "Every name can be edited, or written from scratch without a key, ",
                  "and the report says which was done.")),
        tags$h6("Without a key"),
        tags$p(class = "small mb-0",
               "Everything else works the same. Names are written by you on ",
               "8. Names, and the written readings of the results are left out; ",
               "no number changes."))))
}

# ---- the office logo ---------------------------------------------------------
# The file named in app.R (APP_LOGO), served from www/logo/. Until it exists,
#   a dashed box shows where it goes.
office_logo <- function(file, office = "") {
  logo = if (file.exists(file.path("www", "logo", file)))
    tags$img(src = file.path("logo", file), alt = "Office logo", style = "height:48px;")
  else
    tags$div(style = paste("height:48px; width:160px; border:2px dashed #adb5bd;",
                           "border-radius:4px; color:#6c757d; font-size:12px;",
                           "display:flex; align-items:center; justify-content:center;"),
             "Office logo")
  tags$div(style = "display:flex; align-items:center; gap:12px;",
           logo,
           if (nzchar(office)) tags$span(style = "font-weight:600;", office))
}
