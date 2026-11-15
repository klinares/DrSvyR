---
id: "jpsm/stat_mod_ML_1_SURV615/assignments/HW3"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "assignment"
title: "Homework 3"
original: "stat_mod_ML_1_SURV615/assignments/HW3.qmd"
pages: 
sha256: "bc1cb59ed98fceb2e527870a16e3e4ff20ed162bb23b208b06c591a570fb86c0"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:13"
---


<br> <br>

------------------------------------------------------------------------

```r
if (!require(viridis)) install.packages("viridis", repos = "http://cran.us.r-project.org")
if (!require(ggthemes)) install.packages("ggthemes", repos = "http://cran.us.r-project.org")
if (!require(scales)) install.packages("scales", repos = "http://cran.us.r-project.org")

require(MASS)
library(knitr)
library(tidyverse)

data(Boston)

# set a standard graphic theme for plots from the ggthemes package
theme_set(theme_hc())

options(scipen=999)
```

<br> <br>

**SMML Project 3**

JWHT Chapter 2. Modified Exercise 10.

This exercise involves the Boston housing data set. Assume that we are interested in per capita crime rate, crim.

## A) Examine crim with summary() and in a histogram.

-   Crime rates in Boston appear to be skewed to the right, with values ranging from less than 1 to 89 crimes per 1,000.[^1]

[^1]: Note. Upon some digging, for the Boston data crime rates are calculated as $\frac{reported \space crimes}{suburb \space population} \times 1000$. Therefore, we interpret the crime incidence in these data as per 1000.

```r
Boston |> select(crim) |> summary(crim) |> kable() 

```

```r
Boston |>
  ggplot(aes(x=crim)) +
  geom_histogram(
    color = "#000000", fill = "dodgerblue", alpha=.4) 

```

<br>

## B) Focus on suburbs with the crime rate above 25.

```r
Boston <- Boston |> 
      # keep suburbs above 25, create new column to define new categories
  mutate(crim_high = ifelse(crim > 25, "high", "low"))
```

-   How many suburbs fall into this group?
    -   There are 11 suburbs with crime rates above 25 per 1000.

```r
Boston |> filter(crim_high=="high") |> summarise(suburbs = n()) |> kable()
```

<br>

-   What are the pupil-teacher ratios like in those suburbs?

    -   Among suburbs with crime rates above 25 per 1000, the pupil-to-teacher ratio on average is about 20 students per teacher. However, there is no variation in this ratio among these suburbs as we can see from the summary statistics below for the min and max.

-   How about property tax rates?

    -   Property tax per \$10,000 for these suburbs have a mean of \$666 with no variation.

-   How about median home values?

    -   The median home value for these suburbs ranges between \$5,000 and \$16,300 with an average value of \$9,355.

```r
Boston |> 
  filter(crim_high=="high") |> 
  select(ptratio, tax, medv) |> 
  group_map(~summary(.x)) |> 
  kable(caption = "Suburbs with crime rate above 25")
```

<br>

-   How do the pupil-teacher ratios, property tax rates and median home values compare between these suburbs and the remaining suburbs?

    -   Suburbs with high crime rates have on average a higher peer-to-student ratio of almost two more students per teacher than suburbs with crime rates below 25 per 1000

    -   Suburbs with high crime rates also have on average higher property tax rate of \$666 per \$10,000 versus suburbs with lower crime rates, \$403.

    -   The average median value for homes in suburbs with crime rates above 25 per 1000 was \$9,355 versus \$22,830 for suburbs with lower crime rates.

```r
Boston |> 
  filter(crim_high=="high") |> 
  select(ptratio, tax, medv) |> 
  group_map(~summary(.x)) |> 
  kable(caption = "Suburbs with crime rate at or below 25")
  
```

<br>

-   Below we can see how median home value is likely less for suburbs with crime rates above 25 per 1000, than for suburbs with lower crime rates.

```r
Boston |> 
  dplyr::select(crim_high,  ptratio, tax, medv) |> 
  pivot_longer(-crim_high, names_to = "indicator", values_to="output") |> 
  ggplot(aes(x="", y=output, fill=crim_high)) +
  geom_boxplot() +
  facet_wrap(~indicator, scales = "free_y") +
  theme_bw() +
  theme(text=element_text(size=20))  +
  scale_fill_viridis_d()
```

<br> <br>

## C) Create a scatter plot of the crime rates and the median home values for:

-   1\) all suburbs

-   2\) suburbs bounding Charles River

-   3\) suburbs not bounding Charles River. What do you observe?

    -   We do not observe an obvious linear relationship between crime rates and median home values. However, we do see that higher crime rates might have a non-linear relationship with median home value. Additionally, we do not see a clear linear pattern between median home values and crime rate for suburbs that do not bound the Charles river. However, among suburbs that bound the river, it appears that there might be a negative linear relationship where as median home values rise, crime rates drop, yet fitting an OLS to these data might result in large residuals.

```r

Boston <- Boston |> 
    mutate(charles_river = ifelse(chas==1, " Bounds River", 
                                  "Does not Bound River")) 


Boston |> 
  ggplot(aes(x=medv, y=crim)) +
  geom_point(size=3, alpha=.65, ) + # modifies size & color of dots
  geom_smooth(method='lm', color="dodgerblue", se=FALSE, size=1) +
  theme(text=element_text(size=20))  # changes font size

# we can use a map function to produce scatterplots 
## for different subsets of the data so we do not repeat the code
Boston |> 
  group_by(chas) |> 
  group_map(~ .x |> 
     ggplot(aes(x=medv, y=crim, color=charles_river)) +
  geom_point(size=3, alpha=.65, ) +
  geom_smooth(method='lm', color="dodgerblue", se=FALSE, size=1) +
  theme(text=element_text(size=20), legend.position="top") +
  scale_color_viridis_d(option="D", end=.8) +
  labs(color='Charles River') 
    
  )
```

<br> <br>

## D) Analyze the crime rates as a function of median home values in a simple linear regression with an intercept.

-   Report what the regression coefficients mean in lay terms.

    -   For every one unit increase in a suburb's median home value, crime rates drop .36 , or less than 1 crime, per 1000. For suburbs with a median home value of \$0 the expected average crime rate is 11.8 per 1000.

```r
# a nicer way to pring an LM's model summary 
print_output <- function(output, cex = 0.8) {
  tmp <- capture.output(output)
  plot.new()
  text(0, 1, paste(tmp, collapse='\n'), adj = c(0,1), family = 'mono', cex = cex)
  box()
}
```

```r
mod_1 <- lm(crim ~ medv, Boston) 
print_output(summary(mod_1)) 
```

<br> <br>

## E) Calculate the coefficients reported in D as well as their standard errors by hand.

$$
  \hat{\beta}_1=\dfrac{\sum(x_i-\bar{x})(y_i-\bar{y})}{\sum(x_i-\bar{x})^2}\equiv\dfrac{SS_{XY}(n-1)^{-1}}{SS_{X}(n-1)^{-1}}=\dfrac{s_{XY}}{s_{XX}}
$$

-   where

$$
s_{XY}=\dfrac{\sum(x_i-\bar{x})(y_i-\bar{y})}{n-1}
$$

-   and $$
    s_{XX}=\dfrac{\sum(x_i-\bar{x})^2}{n-1}
    $$

$$
\hat{\beta}_0=\bar{y}-\hat{\beta}_1\bar{x}
$$

-   First, we will add predictions, residuals, and mean differences to our Boston data set as new columns for ease of computation.

```r
Boston <- Boston |> 
  as_tibble() |> 
  mutate(mean_diff_medv = medv - mean(medv),
         mean_diff_crim = crim - mean(crim),
         SS_XY = mean_diff_medv * mean_diff_crim,
         SS_X = mean_diff_medv^2) |> 
  mutate(across(where(is.double), ~ round(.x, 2))) # rounds the new columns
  
Boston |> 
  select(crim, medv, 
         starts_with("mean"), starts_with("SS")) |> 
  slice_sample(n=6) |>  # print N random rows
  kable()

```

<br>

-   We can now calculate our regression coefficients with the equations above.

```r
Boston_betas <- Boston |> 
  summarise(Beta_0 = mean(crim - mean(medv) * sum(SS_XY) / sum(SS_X)),
            Beta_1 = sum(SS_XY) / sum(SS_X))

Boston_betas |> kable()

```

<br>

-   Since we computed the beta coefficients, we can compute predictions by hand and add them to the data frame. We will distinguish the new columns we compute by hand with "**\_2**" to compare with those we extracted from the linear model.

    -   Note. Our calculations by hand for the model predictions and residuals are identical to what we extracted from the model.

```r
Boston <- Boston |> 
  mutate(# add predictions from the model
         mod_predictions = predict(mod_1),
         # predict by hand
         mod_predictions_2 = Boston_betas$Beta_0 + Boston_betas$Beta_1*medv,
        
         # also add residuals from the model
         mod_residuals = resid(mod_1),
         # which is the same if we subtract observed from predicted
         mod_residuals_2 = crim - mod_predictions,
         across(where(is.double), ~ round(.x, 2)))

Boston |> 
  select(crim, starts_with("mod")) |> 
  slice_sample(n=6) |> # select a random draw of suburbs to print
  kable()

```

<br>

-   We can continue our hand calculations for beta coefficient standard errors since we calculated by hand model predictions and residuals, and verified them with model estimates above.

```r
Boston <- Boston |> 
  # we need to take squared deviations of the residuals
  mutate(sq_medv_resid = mod_residuals_2^2) 

# we can also save out the number of parameters from the model for computation
num_param <- length(mod_1$coefficients)


Boston_betas <- Boston |> 
  summarise(Beta_0 = mean(crim - mean(medv) * sum(SS_XY) / sum(SS_X)),
            Beta_1 = sum(SS_XY) / sum(SS_X),
            h_sigma_sq_medv = sum(sq_medv_resid) / (n() - num_param),
            
            # calculate SE for intercept
            Beta_0_se = sqrt(h_sigma_sq_medv *
               (1/n() + mean(medv)^2/sum(SS_X))),
            
            # calculate SE for slope
            Beta_1_se = sqrt(h_sigma_sq_medv / sum(SS_X))
  ) |> 
  select(Beta_0, Beta_1, Beta_0_se, Beta_1_se) |> 
  pivot_longer(everything()) |> 
  rename(coeff=name) |> 
  mutate(coeff_type = 
           ifelse(str_detect(coeff, "se"), "Std. Error", "Estimate"),
         coeff = str_remove(coeff, "_se"),
         coeff = case_when(
           coeff == "Beta_0" ~ "Intercept",
           coeff == "Beta_1" ~ "medv"
         )) |> 
  pivot_wider(names_from = coeff_type, values_from = value)

Boston_betas |> kable()


```

<br> <br>

## F) Create a scatter plot of the crime rates and the median home values with a regression line.

-   Is the regression line a good summary of the crime rates? Examine residuals to assess this.

    -   The regression line does not seem to fit the data well, suggesting that the line of best fit does not minimize residuals, particularly for suburbs with lower median home values and high crime rates. Moreover, the regression line predicts negative crime rates for suburbs with higher median home values.

    -   Summary statistics on model residuals shows that errors have a zero error mean. However, our histogram and density plot shows that our residuals are not normally distributed (right-skewed); thus, violating the assumption of normality of errors which we also examined with a qqplot which supports this observation.

```r
Boston |> 
  ggplot(aes(y=crim, x=medv)) +
  geom_point(size=2)+
  geom_smooth(method='lm', color="dodgerblue", se=TRUE, size=1)
```

```r
Boston |> 
  select(mod_residuals) |> 
  summary() |> 
  kable()

```

```r

Boston |> 
  ggplot(aes(x=mod_residuals_2)) +
  geom_histogram(aes(y=..density..)) +
  geom_density(fill="dodgerblue", alpha=.2)

qqnorm(Boston$mod_residuals_2)
qqline(Boston$mod_residuals_2, col="dodgerblue")

```

<br> <br>

## G) Create a scatter plot of predicted crim (x-axis) and residuals (y-axis).

-   What do you observe?

    -   Data points are not scattered or centered around zero. There is a pattern i.e. not spread randomly around zero for predicted values.

        We observe a pattern in residuals suggesting that we do not satisfy the assumption of equal variance of errors or homoscedasticity. We observe unequal error variance called heteroscedasticity which can be an issue for predicting valeus.

```r

Boston |> 
  ggplot(aes(x=mod_predictions_2, y=mod_residuals_2)) +
  geom_point(size=3)
```
