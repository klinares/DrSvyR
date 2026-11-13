# DrSvyR

<img src="images/drsvyr.jpeg" alt="DrSvyR" width="300">

Shiny apps for analysing complex survey data. Each app is a self-contained
folder that runs on its own and publishes to Posit Connect on its own.

What they share is a standard: every margin of error comes from how the sample
was actually drawn (strata, clusters and weights), not from a simple-random-
sampling default. Respondent data never enters this repository, and nothing an
app computes is presented as a decision the analyst did not make.

## Apps

| App | What it does |
|---|---|
| [`svysegment`](svysegment/) | Finds respondent types in a battery of survey questions with a weighted latent class model, and compares them across groups with design-based intervals. |
| [`QuestionR`](QuestionR/) | Helps a public opinion analyst draft survey items and review a questionnaire. Every model call is steered by text files grounded in survey methodology, and every output is labelled a first draft or an expert-review appraisal, not a pretest. In development (see its `STATUS.md`). |
| [`inteRn`](inteRn/) | Not an app: an AI coding assistant for RStudio, built by a survey methodologist for survey methodologists. It sees the names, types and labels of the objects in your R session, never their values, and asks before it runs code or writes a file. |

## Running an app

From the repository root:

```r
shiny::runApp("svysegment")
```

Each app's README lists the packages it needs.

## Publishing an app to Posit Connect

```r
rsconnect::deployApp("svysegment", appName = "svysegment")
```

Publish the app's folder, not the repository root. Each app folder has its own
`.rscignore` for files that should not be uploaded. The `rsconnect/` folder
that publishing creates inside an app folder is ignored by git.

## Repository layout

```
DrSvyR/
  README.md        this file
  .gitignore       shared by every app
  images/          the repository's own images (this README)
  svysegment/      one app: app.R, R/, www/, data/, README.md
  QuestionR/       one app: app.R, R/, www/ (reflexes/, logo/), tests/ (home only), README.md
  inteRn/          not an app: inteRn.R, install.R, system.md, www/, tests/, README.md
```

## Adding an app

Give it its own top-level folder with an `app.R` (or `ui.R` and `server.R`), its
own README, and its own `.rscignore`. If it ships a demonstration data file,
let that one file back in through `.gitignore` the way `svysegment` does;
every other survey file stays out.
