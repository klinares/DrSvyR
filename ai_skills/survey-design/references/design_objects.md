# Design objects: templates and pitfalls

All examples run on `survey::api` (California schools), public data.

```r
library(survey)
library(srvyr)
library(dplyr)
data(api, package = "survey")
```

## Common designs

**Stratified, with finite population correction**

```r
des_strat <- svydesign(ids = ~1, strata = ~stype, weights = ~pw, fpc = ~fpc,
                       data = apistrat)
# srvyr
des_strat_tbl <- apistrat |> as_survey_design(strata = stype, weights = pw, fpc = fpc)
```

**One-stage cluster sample**

```r
des_clus1 <- svydesign(ids = ~dnum, weights = ~pw, fpc = ~fpc, data = apiclus1)
```

**Two-stage cluster sample** (districts, then schools)

```r
des_clus2 <- svydesign(ids = ~dnum + snum, fpc = ~fpc1 + fpc2, data = apiclus2)
```

**Stratified multistage with PSU codes reused across strata**

```r
# nest = TRUE tells survey that PSU 1 in stratum A is not PSU 1 in stratum B.
svydesign(ids = ~psu, strata = ~stratum, weights = ~wt, nest = TRUE, data = d)
```

**Replicate weights from the data producer**

```r
svrepdesign(weights = ~wt, repweights = "^repwt[0-9]+$", type = "JKn",
            scale = 1, rscales = 1, mse = TRUE, data = d)
```

`type`, `scale` and `rscales` come from the survey's documentation (e.g.
Fay's BRR with rho = 0.5 is `type = "Fay", rho = 0.5`; successive difference
replication is `type = "successive-difference"`). A wrong scale silently
scales every variance.

**Making replicate weights from a linearisation design**

```r
des_jk <- as.svrepdesign(des_clus1, type = "JK1")
des_boot <- as.svrepdesign(des_clus1, type = "bootstrap", replicates = 500)
```

## Estimates

```r
svymean(~api00, des_strat)
svymean(~api00, des_strat, deff = TRUE) |> deff()
confint(svymean(~api00, des_clus1), df = degf(des_clus1))
svyby(~api00, ~stype, des_strat, svymean, vartype = c("se", "ci"))
svyciprop(~I(sch.wide == "Yes"), des_strat, method = "logit")
svyquantile(~api00, des_strat, quantiles = c(0.25, 0.5, 0.75))

des_strat_tbl |>
  group_by(stype) |>
  summarise(api00 = survey_mean(api00, vartype = "ci"),
            n = unweighted(n()))
```

## Domains

```r
# Right: subset the design
svymean(~api00, subset(des_strat, awards == "Yes"))
des_strat_tbl |> filter(awards == "Yes") |> summarise(m = survey_mean(api00))

# Wrong: subset the data, then build a design -- drops strata/PSUs from the
# variance calculation
# svydesign(ids = ~1, strata = ~stype, weights = ~pw, data = filter(apistrat, awards == "Yes"))
```

## Models and tests

```r
fit <- svyglm(api00 ~ ell + meals + stype, design = des_strat)
broom::tidy(fit, conf.int = TRUE)
regTermTest(fit, ~stype)
svychisq(~sch.wide + stype, des_strat)          # Rao-Scott adjusted
svyttest(api00 ~ awards, des_strat)
```

## Pitfalls

| Symptom | Cause | Fix |
|---|---|---|
| Standard errors much smaller than expected | clusters ignored (`ids = ~1` on a cluster sample) | give the PSU in `ids` |
| "Stratum has only one PSU" error | singleton stratum | `options(survey.lonely.psu = "adjust")` and say so, or collapse strata as a documented decision |
| Domain SEs differ from published ones | data filtered before building the design | subset the design |
| Variances off by a constant factor | wrong `scale`/`rscales` for replicate weights | take them from the documentation |
| `lm(y ~ x, weights = wt)` | weights treated as precision weights | `svyglm()` |
| Estimates of "missing" categories wrong | `na.rm` dropped cases silently | count missing first; decide on purpose |
