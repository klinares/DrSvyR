# Reflexes

Lessons learned while doing survey and data-science work with AI assistants:
things that went wrong once and should not again, and conventions the team
settled on. inteRn puts the most recent entries in its instructions; other
agents read this file directly.

<!--
One lesson per line: "- YYYY-MM-DD: text". Append at the end; do not edit or
reorder old lines (correct one by adding a newer line). Write each as a rule
someone else can follow, without names, paths, keys or data values.
Add from inteRn with: /reflex add <text>
-->

## Entries

- 2026-11-06: In dplyr 1.2 and later, case_match() is deprecated; recode survey codes with recode_values(..., unmatched = "error") so an undocumented code stops the script instead of becoming NA.
- 2026-11-06: When a small count is suppressed and a second cell is hidden to protect it, label the second cell "suppressed", never "<10": it may be large, and readers (and models) take "<10" literally.
- 2026-11-06: With the row count known, an exact valid count next to a suppressed missing count reveals it; show the valid count as a bound too.
- 2026-11-06: Never state counts or values about a dataset from memory, even a well-known public one; profile it with the tools and report only what they return.
