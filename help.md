# DrSvyR

Survey data usually gets read one question at a time. This tool asks a
different question: taken together, what does a battery of related answers say
about the people who gave them? It finds either a small number of distinct
types of respondent, or a single underlying scale people have more or less of.
It places every respondent it can reach, and it compares those placements
across the groups you care about.

Every margin of error it reports comes from how the sample was actually drawn.
That is the point of the tool. Software that assumes people were sampled
independently reports margins roughly half as wide, and a difference that looks
decisive under those defaults often does not survive once the clustering and
the weights are accounted for.

## Before you start

You need a SPSS or Stata file, and you need to know which variables in it carry
the respondent identifier, the stratum, the sampling unit and the weight. You
also need a folder for the tool to write into — everything it produces goes
there, and nothing is ever written back into the file you started with.

Your respondents never leave your machine. The language model in this tool sees
only figures the tool has already computed: how many people answered a
question, how far apart two groups are, how large a segment is. It never sees a
respondent record, and it never sees your data file.

## How it goes

![The eleven stages](figures/fig_stages.png)

Eleven screens in order. Each waits on the one before it, so a screen that looks
empty usually means something upstream has not been settled yet rather than
that something has gone wrong. The single loop runs from Model back to Items:
if the fitted model tells you the battery was wrong, you can go back and change
it once.

Give yourself a few minutes at Search and at Model. Those two fit the model
two hundred times over from different starting points, which is what makes the
answer reproducible, and it is the slow part.

## What the tool decides, and what you decide

![Protocol, reflexes, and the analyst](figures/fig_protocol.png)

The tool computes. It does not choose. How many groups there are, which
questions belong in the battery, which category the comparisons are read
against, whether a limitation matters enough to change the conclusion — those
are yours. Each one is recorded along with the evidence that was in front of you
when you made it, so the report can say not just what was found but how it came
to be looked for.

There is a methodologist on its own tab, and it remembers the whole session. It
reads the numbers this tool computed and will argue with you about them. It can
propose an action; it cannot take one. You accept or you reject, and when you
reject it you say why — that sentence goes into the record beside the decision
it explains.

## When something does not look right

Every screen carries a short explanation of what it is showing and why it
matters, so the first place to look is the screen you are on. Beyond that, the
report the tool writes has an appendix called *What was tested*, which lists
what was verified, what rests on published method, what was a judgement call,
and what has not been tested at all. That last column is the one to read first.

The work folder holds the rest: a decision log of what was chosen and when, the
tables behind every figure as CSV, and a copy of the analysis specification you
can re-run without this app.

---

When you are ready, open **1. Project** in the list on the left. It will ask
for the folder to work in and the survey file to read, and everything else
follows from there.
