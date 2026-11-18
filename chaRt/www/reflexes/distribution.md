# Distribution

Version: 0.1

How one measure is spread: histogram, box.

<!--
The four SURV752 modules read so far use histograms and box plots (as margins of a scatter, and
box plots of slices) but do not teach rules for choosing between them. The rules below are marked
as general practice where that is what they are.
-->

## Reflexes

### histogram_one_measure
- **When:** The question asks how one measure is spread: where most values lie, how wide the range is, whether there is more than one peak.
- **Say:** Use a histogram of that measure. Leave `bins` out; R chooses them.
- **Label:** One measure's spread as a histogram
- **Source:** General practice; histograms appear as scatterplot margins in SURV752, Correlation (module 4).

### box_across_groups
- **When:** The question compares the spread of a measure across groups.
- **Say:** With 4 to 12 groups use a box. With 2 or 3 groups prefer a histogram with `facet` on the group, which shows the shape a box hides.
- **Never:** Do not use a box for a measure with only a few distinct values.
- **Label:** Spread across groups as boxes
- **Source:** General practice; box plots of slices and as scatterplot margins appear in SURV752, Correlation (Slicing; Enhancing Scatterplots: Boxplots), where the class notes a box encodes less of the data than a rug.
