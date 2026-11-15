---
id: "jpsm/stat_mod_ML_1_SURV615/assignments/SSML_project_1"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "assignment"
title: "SMML Project 1"
original: "stat_mod_ML_1_SURV615/assignments/SSML_project_1.Rmd"
pages: 
sha256: "f1298fdf7bd59ba920ea4eb7c75e4c21de0d528e2a074080deffb0a12b39e16f"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:20"
---


```r
knitr::opts_chunk$set(echo = TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3.5)

options(scipen=999)

library(faraway)
library(tidyverse)
```


<br>
<br>

## 1. Use hprice in faraway package
- The data includes 324 observations coming from 36 US metropolitan statistical areas (MSAs) over 9 years from 1986-1994: 36 × 9 = 324
- Assume that the MSAs in the data are a simple random sample of the population of MSAs in the US. See https://www2.census.gov/geo/maps/metroarea/us_wall/Mar2020/CBSA_WallMap_Mar2020.pdf for MSAs.
- Refer to the R manual for faraway for the background information about this dataset as well as variable definitions.
- The housing sale price is the outcome variable of interest. Since the data set has a natural log transformed price variable, narsp, we recode this to create __homeprice__ by transforming __narsp__ back to the dollar unit for an easier interpretation as follows:

```r
data("hprice") # read in data from pacakge

hprice |> summary() # print summary statistics for each variable
?faraway::hprice# view variable information
```

<br>

### 1. What are the mean and the variance of homeprice? What do they mean?
- The average house sale price from 1986-1994 was \$94,411, with a very high variance due to a few houses being sold for a lot more than the average. 

```r
hprice <- hprice |> 
  as_tibble() |> 
  mutate(homeprice = exp(narsp)*1000)



hprice |> 
  summarise(mean_homeprice = mean(homeprice), 
            var_homeprice = var(homeprice))


```

<br>

### 2. Construct a 95% confidence interval of the average homeprice. What does the confidence interval imply?

```r
CI_output <- hprice |> 
  summarise(t_score = qt(p=.05/2, df=n()-1, lower.tail=F),
    se = sd(homeprice) / sqrt(n()), # calculate standard error
    lower = round(mean(homeprice) - t_score*se, 2), 
    upper = round(mean(homeprice) + t_score*se), 2)

CI_output

```
- The confidence interval of house prices (mean \$94,411 [95% CI `r CI_output$lower`, `r CI_output$upper`]) implies that if we were to take repeated samples from the same population with _n_ sample sizes, we would expect the true price to be contained in this interval 95% of the time. 

<br>

### 3. Estimate the average homeprice by whether the MAS was adjacent to a coastline, noted in ajwtr, and the standard errors.
- Houses near the coast line had an average sale price of \$111,243 (se = \$4,656) vs non-coastal houses \$82,389 (se = \$1,229). 
```r
hprice <- hprice |> 
  mutate(ajwtr = ifelse(ajwtr == 1, "Coastal", "Non-Coastal")) # give labels to the numeric values
          

hprice |> 
  group_by(ajwtr) |> 
  reframe(se = sd(homeprice) / sqrt(n()), # reframe ungroups the previous function, returns summary
            sample_mean = mean(homeprice))
```

<br>

### 4. Test the difference in homeprice between coastline MSAs and non-coastline MSAs. Clearly state the formula for the hypothesis, the test method and your rationale for selecting the method. What do you conclude about the hypothesis?
- We will conduct a two sample right-tailed t-test with unknown $\sigma^2$, and we hypothesize that home prices are higher in coastal areas than non-coastal forming the basis of our alternative hypothesis. [Conroy and Molisch 2009](https://link.springer.com/article/10.1007/s11146-009-9195-x) found that coastal houses are twice the cost of comparable homes 9 miles away from the coastal line, suggesting that waterfront houses are more appealing to home buyers  thus more expensive. 
   - Our Null hypothesis is that non-coastal house prices are higher than coastal. 


\begin{align*}
H_0: \mu_{ajwtr=1} - \mu_{ajwtr=0} = \le 0\\
H_A: \mu_{ajwtr=1} - \mu_{ajwtr=0} = > 0
\end{align*}


- First, we examine the assumption of equal variances. 
   - Our f-test's p-value is less than .05, therefore we cannot reject the Null hypothesis, and the variances between coastal and non-coastal metropolitan areas are not equal. We can also use the confidence intervals to test the ratio of the two variances, and we can see that $1$ is not in the \$95% CI; therefore, the variances are not equal and we can account for this in our two sample t-test.  
```r
var.test(homeprice ~ ajwtr, hprice, alternative = "two.sided")

```
- We reject the null hypothesis in favor of the alternative hypothesis that coastal houses probably have higher prices than non-coastal houses. 
   - In our one sided right tailed test, the upper confidence interval bound is a naturally Inf.
   
```r
t.test(homeprice ~ ajwtr, var.equal = FALSE, hprice, alt="greater")
```


<br>

### 5. Estimate the Pearson correlation coefficient between homeprice and per capita income of the MSA of a given year, noted in ypc.
- Our correlation of $r=.74$ indicates a strong association between home prices and per capita income, and is positive meaning that as one increases the other variable increases as well.

```r
cor(hprice$homeprice, hprice$ypc)
```

<br>

### 6. Test whether the correlation coefficient between homeprice and ypc is 0 or not. Clearly state the hypothesis including the formula. What do you conclude?
- We will perform a Pearson's correlation coefficient to test our alternative hypothesis that these two variables are associated. Our Null hypothesis is that the correlation =0.

\begin{align*}
H_0: r=0 \\
H_A: r\ne 0
\end{align*}
  - We reject the null hypothesis in our Pearson's correlation coefficient in favor of our alternative hypothesis suggesting that there is evidence that home prices and per capita income have a positive linear relationship of $.74 (95\%[.69, .79])$. 

```r
cor.test(hprice$homeprice, hprice$ypc)

```

<br>

### 7. Can you say that per capita income has an effect on the home sales price using the results from #6)? Why or why not?
- We cannot conclude that one variable has an effect, nor in the causal sense, on the other at this point until we conduct an OLS regression with home sales regressed on per capita income. 


<br>

### 8. Test the normality of homeprice. Would this test result change your responses to #1) to 7)? Why or why not?
- Home prices appears to be skewed to the right according to our qq plots. Additionally, we used the Shapiro-Wilk normality test and rejected the null hypothesis that the data are normally distributed in favor of the alternative hypothesis that they are probably not normal.
- We can conclude that reporting the mean is not robust to the skewness found in the data and would want to reconsider our t-test to include a Mann Whitney U test used to test sample distributions that are not normally distributed. 
```r
qqnorm(hprice$homeprice)
qqline(hprice$homeprice, col="dodgerblue") # add a blue line


```

```r
shapiro.test(hprice$homeprice)

```

