# Design skills

A design skill is a short markdown file that tells the model how a chart should look when it
writes the drawing code. The analyst picks one skill for a dashboard. The model follows the
skill for composition, colour, labels and motion; `www/reflexes/design.md` holds the rules no
skill can relax (the numbers, the integrity of the chart, the toolkit).

Format: a title, `Version:`, then the sections Intent, Composition, Colour, Labels and
annotation, Motion, Checklist for the review, Never. Keep a skill under 60 lines: it is sent
with every design call.

An office's own skills go in the folder named by `APP_SKILLS_DIR` in `app.R`. They are read at
start-up and never leave the machine. A skill written for another language (Python, matplotlib)
is used for its design intent only; the model writes R with the toolkit.
