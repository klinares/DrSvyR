# Night task 02, Part A: three files of invented data the app has never seen, to rehearse on. No real data: every value is drawn here, seeded.
#   Run from inside chaRt/:   Rscript --no-init-file tests/make_rehearsal.R
# Writes, under tests/data/ (git-ignored: made again by this script):
#   survey.csv            1,200 respondents: id, region (6), age group (5, ordered), education (4, ordered), sex, ten attitude items on a 1 to 5 agree
#                         scale (q10_trust_government ...), two items coded 1 = yes, 2 = no, missing-value codes -9, 98 and 99 as numbers on several items,
#                         household income in bands, an interview date over 6 weeks, and the design columns weight (positive, mean 1, right-skewed),
#                         stratum and psu.
#   indicators_wide.xlsx  40 countries in rows, a region column, one column per year 2015 to 2024 holding an indicator; a title in row 1 and the
#                         header in row 3 of the first sheet; a second sheet of notes.
#   tickets.csv           8,000 support tickets: opened and closed timestamps to the second, a priority (ordered), a team (one with only 3 rows),
#                         a free-text subject, a customer id, a cost written as text ("$1,240.50"), a satisfaction score 1 to 10 with a third missing.
stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
dir.create(file.path("tests", "data"), showWarnings = FALSE)
pick <- function(n, x, p = NULL) sample(x, n, replace = TRUE, prob = p)

# ---- survey.csv ----------------------------------------------------------------------------------------------------------------------------
make_survey <- function(path, n = 1200L) {
  set.seed(20261126)
  region = pick(n, c("North", "South", "East", "West", "Central", "Coast"), c(0.2, 0.2, 0.15, 0.15, 0.18, 0.12))
  age_group = pick(n, c("18-29", "30-44", "45-59", "60-74", "75 or older"), c(0.2, 0.27, 0.26, 0.19, 0.08))
  education = pick(n, c("Less than high school", "High school", "Some college", "Bachelor's or higher"), c(0.1, 0.3, 0.3, 0.3))
  sex = pick(n, c("Female", "Male"), c(0.52, 0.48))
  # a latent outlook that differs by region and education, so the items differ between groups and go together
  edu_i = match(education, c("Less than high school", "High school", "Some college", "Bachelor's or higher"))
  latent = stats::rnorm(n) + 0.25 * (edu_i - 2.5) + c(North = 0.2, South = -0.2, East = 0, West = 0.3, Central = -0.1, Coast = 0.1)[region]
  item = function(shift, load = 0.8) pmin(5L, pmax(1L, as.integer(round(3 + shift + load * latent + stats::rnorm(n, sd = 0.9)))))
  items = list(q10_trust_government = item(-0.6), q11_trust_courts = item(-0.1), q12_trust_police = item(0.3), q13_trust_media = item(-0.9),
               q14_satisfied_life = item(0.5, 0.5), q15_satisfied_job = item(0.3, 0.4), q16_feel_safe = item(0.4, 0.6), q17_neighbours_help = item(0.2, 0.3),
               q18_economy_better = item(-0.4, 0.7), q19_vote_matters = item(0.1, 0.5))
  yes_no = function(p) ifelse(stats::runif(n) < p, 1L, 2L)
  voted = yes_no(stats::plogis(0.6 + 0.5 * latent))
  volunteered = yes_no(stats::plogis(-0.9 + 0.3 * latent))
  # the codes for a missing answer, as numbers in the data: -9 not asked, 98 don't know, 99 refused, on several items
  code = function(x, rates) { u = stats::runif(n); x[u < rates[1]] = -9L; x[u >= rates[1] & u < sum(rates[1:2])] = 98L; x[u >= sum(rates[1:2]) & u < sum(rates)] = 99L; x }
  items$q10_trust_government = code(items$q10_trust_government, c(0.02, 0.05, 0.02))
  items$q13_trust_media = code(items$q13_trust_media, c(0.01, 0.07, 0.03))
  items$q18_economy_better = code(items$q18_economy_better, c(0.03, 0.06, 0.01))
  items$q19_vote_matters = code(items$q19_vote_matters, c(0, 0.04, 0.02))
  voted = code(voted, c(0, 0, 0.04))
  income = pick(n, c("Under $25,000", "$25,000 to $49,999", "$50,000 to $74,999", "$75,000 to $99,999", "$100,000 or more"), c(0.2, 0.25, 0.22, 0.15, 0.18))
  income[stats::runif(n) < 0.06] = "Refused"
  interview_date = format(as.Date("2026-03-02") + sample(0:41, n, replace = TRUE))
  stratum = pick(n, 1:12)
  psu = (stratum - 1L) * 5L + pick(n, 1:5)
  w = stats::rlnorm(n, 0, 0.55)
  df = data.frame(respondent_id = sprintf("R%05d", sample(10000:99999, n)), region = region, age_group = age_group, education = education, sex = sex,
                  items, q20_voted = voted, q21_volunteered = volunteered, household_income = income, interview_date = interview_date,
                  weight = round(w / mean(w), 4), stratum = stratum, psu = psu, check.names = FALSE, stringsAsFactors = FALSE)
  readr::write_csv(df, path, na = "")
  path
}

# ---- indicators_wide.xlsx ------------------------------------------------------------------------------------------------------------------
make_wide <- function(path) {
  set.seed(20261127)
  syll = c("ar", "bel", "cor", "dan", "el", "fer", "gal", "hor", "is", "jun", "kal", "lor", "mar", "nor", "or", "pel", "quin", "ros", "sal", "tor", "ul", "ver")
  names_ = unique(purrr::map_chr(seq_len(80), function(i) { s = paste0(sample(syll, sample(2:3, 1)), collapse = ""); paste0(toupper(substring(s, 1, 1)), substring(s, 2), "ia") }))[1:40]
  region = pick(40L, c("Northern", "Southern", "Eastern", "Western", "Island states"), c(0.25, 0.25, 0.2, 0.2, 0.1))
  start = stats::runif(40, 8, 70)
  growth = stats::runif(40, 0.5, 6)
  years = 2015:2024
  values = purrr::map(seq_along(years) - 1L, function(k) round(pmin(98, start + growth * k + stats::rnorm(40, sd = 1.5)), 1))
  values = purrr::map(values, function(v) { v[sample(40, 2)] = NA; v })
  df = stats::setNames(data.frame(names_, region, values, stringsAsFactors = FALSE), c("Country", "Region", as.character(years)))
  wb = openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "Internet use")
  openxlsx::writeData(wb, "Internet use", "Internet users per 100 people, 2015 to 2024 (invented data)", startRow = 1, startCol = 1)
  openxlsx::writeData(wb, "Internet use", df, startRow = 3, startCol = 1)
  openxlsx::addWorksheet(wb, "Notes")
  openxlsx::writeData(wb, "Notes", data.frame(Note = c("Values are internet users per 100 people.", "A blank cell is a year with no estimate.",
                                                       "All values are invented for testing chaRt.", "Source: chaRt tests/make_rehearsal.R")), startRow = 1)
  openxlsx::saveWorkbook(wb, path, overwrite = TRUE)
  path
}

# ---- tickets.csv ---------------------------------------------------------------------------------------------------------------------------
make_tickets <- function(path, n = 8000L) {
  set.seed(20261128)
  team = c(pick(n - 3L, c("Billing", "Accounts", "Technical", "Shipping", "Returns"), c(0.22, 0.18, 0.3, 0.18, 0.12)), rep("Escalations", 3L))
  team = sample(team)
  priority = pick(n, c("Low", "Medium", "High", "Urgent"), c(0.35, 0.4, 0.18, 0.07))
  opened = as.POSIXct("2025-01-01 00:00:00", tz = "UTC") + sort(stats::runif(n, 0, 365 * 86400))
  hours = stats::rexp(n, 1 / c(Low = 60, Medium = 36, High = 14, Urgent = 5)[priority]) * c(Billing = 1, Accounts = 0.8, Technical = 1.4, Shipping = 1.1, Returns = 1.2, Escalations = 2)[team]
  closed = opened + round(hours * 3600 + stats::runif(n, 60, 600))
  closed[stats::runif(n) < 0.04] = NA      # still open
  subjects = c("Cannot log in to the portal", "Invoice shows the wrong amount", "Parcel has not arrived", "Refund not received", "App crashes on start",
               "Change the address on my account", "Charged twice this month", "Item arrived damaged", "Password reset email never came", "Question about my plan")
  customer = sprintf("CUST-%05d", sample(10000:99999, 2600))
  cust = pick(n, customer)
  subject = paste0(pick(n, subjects), ifelse(stats::runif(n) < 0.3, paste0(" (order ", sample(100000:999999, n, replace = TRUE), ")"), ""))
  cost = round(stats::rlnorm(n, 4.2, 1.1), 2)
  money = paste0("$", formatC(cost, format = "f", digits = 2, big.mark = ","))
  sat = pick(n, 1:10, c(0.04, 0.03, 0.04, 0.05, 0.08, 0.1, 0.15, 0.2, 0.16, 0.15))
  sat[stats::runif(n) < 1 / 3] = NA
  fmt = function(x) format(x, "%Y-%m-%d %H:%M:%S", tz = "UTC")
  df = data.frame(ticket_id = sprintf("T%06d", seq_len(n)), opened_at = fmt(opened), closed_at = ifelse(is.na(closed), NA, fmt(closed)), priority = priority, team = team,
                  subject = subject, customer_id = cust, cost = money, satisfaction = sat, stringsAsFactors = FALSE)
  readr::write_csv(df, path, na = "")
  path
}

made <- c(make_survey(file.path("tests", "data", "survey.csv")), make_wide(file.path("tests", "data", "indicators_wide.xlsx")), make_tickets(file.path("tests", "data", "tickets.csv")))
purrr::walk(made, function(p) cat(p, format(file.size(p), big.mark = ","), "bytes\n"))
