# DrSvyR

Survey data usually gets read one question at a time. This tool asks a
different question: taken together, what does a battery of related answers say
about the people who gave them? It looks for a small number of distinct types
of respondent — people who answer the set in recognisably different ways — and
places every respondent it can reach in the type their answers fit best. Then
it compares those placements across the groups you care about.

Every margin of error it reports comes from how the sample was actually drawn.
That is the point of the tool. Software that assumes people were sampled
independently reports margins roughly half as wide, and a difference that looks
decisive under those defaults often does not survive once the clustering and
the weights are accounted for.

## Before you start

You need a SPSS or Stata file, and you need to know which variables in it carry
the respondent identifier, the stratum, the sampling unit and the weight. You
also need a folder for the tool to write into — everything it produces goes
there, and nothing is ever written back into the file you started with. That
folder has to sit outside the tool's own repository, and the tool will say so
if you point it at one inside: your scored data and your decision log should
never end up somewhere a `git add .` can reach them. Your survey file itself
can stay wherever it already is, including inside the repository; it is only
ever read.

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

**Search is the slow screen.** It fits every candidate number of groups from
two hundred different starting points, which is what makes the answer
reproducible rather than a property of where the algorithm happened to begin.
Two hundred short runs are taken far enough to tell the promising starts from
the poor ones, and only the best twenty are run to convergence. Give it a few
minutes and leave it alone.

Model is quick, because it does not fit anything. The size you chose was
already fitted during the search and that is the fit you are shown; the time
there goes on the replicate intervals.

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
matters, so the first place to look is the screen you are on.

If a step fails, the message on screen names the function it failed in, and the
full stack is appended to **`errors.log`** at the top of your work folder. That
file is what to send when you ask for help: the message alone rarely says where
a number went wrong, and the log does.

Beyond that, the report the tool writes has an appendix called *What was
tested*, which lists what was verified, what rests on published method, what
was a judgement call, and what has not been tested at all. That last column is
the one to read first.

The rest of the work folder holds `decisions/`, a log of what was chosen and
when; `output/`, with the report, every table as CSV, your data back with
segment membership added, and `cfg.R`, a copy of the analysis specification you
can re-run without this app; and `cache/`, which you can delete at any time.

---

When you are ready, open **1. Project** in the list on the left. It will ask
for the folder to work in and the survey file to read, and everything else
follows from there.
