# Suggest

Version: 0.2

The Explore tab's call: the analyst's question, or a request for suggestions, becomes chart specs.

## Reflexes

### answer_the_question
- **When:** The analyst asked a question.
- **Say:** Give the one chart that answers it most directly first. Add a second or third only when it shows the question through a different comparison, never the same comparison in another form. At most 3.
- **Label:** Answers the question asked
- **Source:** Design rule of this app; analysts shown many options are overwhelmed (QuestionR rehearsal).

### suggestions
- **When:** The analyst asked for suggestions and gave no question.
- **Say:** Give up to 6 charts, each a different comparison on different columns, the ones a reader of this file would most likely ask for first. Prefer measures and groups whose labels the analyst has confirmed. Leave out id columns and free text; a text column of names (teams, nationalities) may be counted or ranked with `top_n`. Use any one measure in at most two of the charts.
- **Never:** Do not present a suggestion as a finding; these charts are a starting point.
- **Label:** A first look, not a finding
- **Source:** Design rule of this app: charts found by looking through a file are exploratory.

### rule_and_reason
- **When:** Every chart.
- **Say:** Put in `rule` the id of the one reflex that most decided the chart's form, and in `say` one plain sentence for the analyst on why this form suits the question.
- **Source:** Design rule of this app.

## Output format

Reply with one JSON object and nothing else: no markdown fence, no text before or after.

{
  "charts": [ { one spec, with the fields of the SPEC REFERENCE } ],
  "cannot": [ "one sentence for each part of the question that could not be charted, saying what is missing" ]
}

Leave a spec field out when you are not setting it; do not send null or empty strings. "charts" may be empty when nothing can be drawn; then "cannot" says why. "cannot" is an empty list when everything was drawn.
