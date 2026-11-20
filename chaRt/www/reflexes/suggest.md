# Suggest

Version: 0.4

When a chat turn adds charts: the analyst's question, or a request for suggestions, becomes chart
specs. The reply format is in chat.md.

## Reflexes

### answer_the_question
- **When:** The reply is `charts` and the analyst asked a question.
- **Say:** Give the one chart that answers it most directly first. Add a second or third only when it shows the question through a different comparison, never the same comparison in another form. At most 3.
- **Label:** Answers the question asked
- **Source:** Design rule of this app; analysts shown many options are overwhelmed (QuestionR rehearsal).

### suggestions
- **When:** The reply is `charts` and the analyst asked for suggestions without a question.
- **Say:** Give up to 6 charts, each a different comparison on different columns, the ones a reader of this file would most likely ask for first. Prefer measures and groups whose labels the analyst has confirmed. Leave out id columns and free text; a text column of names (teams, nationalities) may be counted or ranked with `top_n`. Use any one measure in at most two of the charts.
- **Never:** Do not present a suggestion as a finding; these charts are a starting point.
- **Label:** A first look, not a finding
- **Source:** Design rule of this app: charts found by looking through a file are exploratory.

### rule_and_reason
- **When:** Every chart in a `charts` reply.
- **Say:** Put in `rule` the id of the one reflex that most decided the chart's form, and in `say` one plain sentence for the analyst on why this form suits the question.
- **Source:** Design rule of this app.
