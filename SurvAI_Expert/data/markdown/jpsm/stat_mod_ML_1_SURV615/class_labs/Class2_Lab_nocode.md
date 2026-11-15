---
id: "jpsm/stat_mod_ML_1_SURV615/class_labs/Class2_Lab_nocode"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lab"
title: "SMML Class 2 Lab"
original: "stat_mod_ML_1_SURV615/class_labs/Class2_Lab_nocode.Rmd"
pages: 
sha256: "6520763996a73e10c34f42d063f6edafcfb38b444461af22f2b832fa7bc1c7cd"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:20"
---



```r
knitr::opts_chunk$set(echo = TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3.5)

options(scipen=999)
```



##  We will use \texttt{Wage} data in R package \texttt{ISLR} <br>
```r
library(ISLR2) 
library(tidyverse)
```

```r
data("Wage") 
dim(Wage)
summary(Wage) 
```
 
### 1. Focus on the variable, \texttt{wage}
A. Mean and variance of \texttt{wage}
```r
mean(Wage$wage)
var(Wage$wage)

```
Does the var() function give you the population or sample variance (hint: ?var)?
- Sample variance, because it comes from the sample. 

B. Manually calculate the population and sample variance for wage. The code for calculating the population variance is provided. You will have to tweak it to calculate the sample variance.
```r
library(dplyr)

n <- dim(Wage)[[1]]


# calculate population variance
# Wage %>%
#   mutate(dif2 = (wage - mean(wage))^2
#          ) %>%
#   summarise(pop_var = (sum(dif2)/3000))

Wage |> 
  summarise(sam_var = sum((wage - mean(wage))^2) / (n() - 1),
            pop_var <- sum((wage - mean(wage))^2) / (n() ))
  
# calculate sample variance


```
Which matches what you got using var()? Which is larger and why do you think that is?
- The Var matches the sample variance. 


B. Using the sample variance of the estimated mean you've already calculated, estimate the 95% confidence interval of the true mean? 
```r

# calculate sample size of Wage and save sample variance of Wage$wage as object called "sampvar"
n <- dim(Wage)[[1]]
sampvar <- var(Wage$wage)

# calculate the appropriate t statistic to calculate a 95% CI for mean of wage
t.score<-qt(p=.05/2, df=n-1, lower.tail=F)
t.score

# calculate 95% CI for estimated mean of wage
lowCI <- mean(Wage$wage)-t.score*sqrt(sampvar)/sqrt(n)
upCI <- mean(Wage$wage)+t.score*sqrt(sampvar)/sqrt(n)
print(c(lowCI,upCI))

# Conduct single sample t-test of Wage$wage with 95% CI.
t.test(Wage$wage, conf.level = 0.95)
```
* How would you interpret the 95% confidence interval of the mean?
- If we repeat this study sampling from the mean with N sample size, we would expect this interval to contain the true mean 95% of the time. 
* What are the null and alternative hypotheses associated with the t-test you ran above?
- Null hypothesis is associated with no difference in the means, while the alternative hypothesis is associated with a two-sided test meaning that the difference in the sample means are probably different. Nully hypothesis is equal to 0.
* How does the 95% CI from t.test() compare to the interval you calculated by hand?
- The confidence intervals calculated in both seem to account for a two sided test.

C. Does \texttt{wage} follow a normal distribution? 
```r
library(ggplot2)
``` 

```r
ggplot(Wage, aes(x=wage)) + geom_histogram(binwidth=5)

qqnorm(Wage$wage, main="Wage", ylab="y_{i:n}", xlab="m_{i:n}") + 
  qqline(Wage$wage, col="red",lwd=2)


```
* Based on the figures would you say wage is normally distributed?
- It appears that Wages is positive skewed. 


```r
shapiro.test(Wage$wage)
```
* How would you interpret the results of the Shapiro-Wilk Normality test? \
- Based on the Shapiro-Wilk test the Wage follows a normal distribution. Although, this could be due to the large sample size. 


D. What are the steps to take to compare \texttt{wage} of those without vs. with college or higher education? (Hints: What do you need to assess before using a two sample t-test?)

$$
H_0: \mu_{\ge CollEduc}=\mu_{<CollEduc} vs. H_A: \mu_{\ge CollEduc} \neq \mu_{<CollEduc}
$$ 


  * Step 1) Recode \texttt{education}
  * Step 2) Check means and variances by recoded education
  * Step 3) ?
  * Step 4) Conduct proper testing
 
Step 1) Recode \texttt{education}
```r
# library(tidyverse) -- this will load dplyr and a number of other packages 
table(Wage$education)
Wage <- Wage%>%
  mutate(CollEduc=ifelse(education=="4. College Grad"|
                         education=="5. Advanced Degree",1,0))
```
* Look at the help page for the ifelse() function. What is the code above doing?
- ifelse function is is recoding the education variable if 4 or 5 as = 1, all else as 0.

Step 2) Check means and variances by recoded education
```r
Wage %>%
  group_by(CollEduc)%>%
  summarize(m=mean(wage),
            var=var(wage))
```

* $\hat\mu_{<CollEduc}=\hat{\bar{y}}_{<CollEduc}=98.2$ and $\hat{\sigma}^2_{<CollEduc}=s^2_{<CollEduc}=910$
* $\hat\mu_{\ge CollEduc}=\hat{\bar{y}}_{\ge CollEduc}=135$ and $\hat{\sigma}^2_{\ge CollEduc}=s^2_{\ge CollEduc}=2324$ \

Step 3) Test equal variance
* Corresponding hypothesis: $H_0:\sigma^2_{<CollEduc}=\sigma^2_{\ge CollEduc}$ vs. $H_A:\sigma^2_{< CollEduc}\neq\sigma^2_{\ge CollEduc}$

```r
var.test(wage ~ CollEduc, Wage, alternative = "two.sided")
```
* What are the null and alternative hypotheses associated with the var.test() above?
- The F-test is testing the Null of whether the variances are not equal, and here the alternative hypothesis is that the variances are equal in our two samples. 
* How do you interpret the results? \
- Since, our p-value is less than .05, we cannot reject the Null, and we conclude that the variances are not equal. 

Step 4) Conduct proper testing based on what you found in the previous step.
* Corresponding hypothesis: $H_0: \mu_{<CollEduc}=\mu_{\ge CollEduc}$ vs. $H_A: \mu_{<CollEduc} \neq \mu_{\ge CollEduc}$
```r

higher_ed <- Wage |> filter(CollEduc == 1) |> select(wage)
lower_ed <- Wage |> filter(CollEduc == 0) |> select(wage)

t_test <- t.test(higher_ed, lower_ed, var.equal = FALSE)
t_test

```
* What are the null/alternative hypotheses associated with this t-test?
- The Null in this Welch 2 sample t-test is that the means are the same, while the alternative hypothesis is that these means are not the same. 
* How do you interpret the results?
- The mean wage for college education respondents are statistically higher than those without a higher education level.  
* How would you conduct this test if you came to the opposite conclusion (regarding the two sample variances) in the previous step?\
- By using the argument var.equal = FALSE.



E. What is the correlation coefficient between \texttt{wage} and \texttt{age}? 
```r
cor(Wage$wage, Wage$age)
cor.test(Wage$wage, Wage$age)

```
\hfill

What are the conclusions from F? 
Can we use conclusions from above?
- Wage and age has a small relationship based on our Pearson's correlation analysis.


F. If we're concerned that the wage distribution in the groups we want to compare (here it is those with/without college education) we should consider using a non-parametric test for comparing means like the Wilcoxon test.
```r
# stratify by college education status and look at each distribution as before (i.e., histogram, qqplot, normality test)
coll_edu <- filter(Wage, CollEduc==1) ## Subset Wage data to only include those with college edu or greater
nocoll_edu <- filter(Wage, CollEduc!=1) ## Subset Wage data to only include those with less than college edu 
```


How could we  compare the two wage distributions since? Conduct a Wilcoxon rank sum (AKA Mann-Whitney U test) test comparing the mean wage of those without vs. with college or higher education.
```r
# conduct non-parametric test
wilcox.test(wage ~ CollEduc, data = Wage,
                    exact = FALSE, conf.int=0.95)
```
* How do the results compare to the t-test you conducted earlier? \
- The results tell us the same story, yet the 95% CI are different.

\newpage

### 2. Focus on the variable, \texttt{logwage}

A. What is the estimated mean and variance of the sample?
```r
Wage |> 
  summarise(mean(logwage), var(logwage))
```
\

B. What is the sample standard error for logwage? Use it to calculate 95% confidence interval of the true mean.
```r
Wage |> 
  summarise(se = sd(logwage) / sqrt(n()), 
            # calculate 95% CI
            mean(logwage), 
            low = mean(logwage) - 1.96*se,
            upper = mean(logwage) + 1.96*se)

```
* The sample standard error is $.0064$.
* The 95% confidence interval of $\mu_{logwage}$ is $[4.64, 4.67]$\

C. Does \texttt{logwage} follow a normal distribution? Evaluate its distribution both graphically and statistically.
- There is some negative skewness in the log of wages data. 
```r
qqnorm(Wage$logwage)
qqline(Wage$logwage, col="red")

hist(Wage$logwage)
```

- Based on the Shapiro-Wilk test the log of Wage follows a normal distribution. Although, this could be due to the large sample size. 
```r
shapiro.test(Wage$logwage)

```
* While, compared to \texttt{wage}, \texttt{logwage} appears more normally distributed, it still fails to meet the normal distribution requirements.\

D. Assess the relationship between \texttt{wage} and \texttt{logwage}.
```r
ggplot(Wage, aes(x=wage,y=logwage)) + geom_point()
```

* How would you describe the relationship between Wage and logwage?\
- The relationship between wage and logwage follows a curvlinear relationship. 

```r
# There are often multiple ways in R to achieve the same result.
mean(log(Wage$wage))
mean(Wage$logwage)
```

 


