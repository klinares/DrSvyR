---
id: "jpsm/Fund_Infe_SURV740/class_examples/Module12_Model_Assisted_Inference_Guide"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "lab"
title: "Module 12: Model-Assisted Inference Study Guide"
original: "Fund_Infe_SURV740/class_examples/Module12_Model_Assisted_Inference_Guide.qmd"
pages: 
sha256: "ebd391da592fda82177d7f1be32da743690b00659b9a352fcd15a4a03701efcc"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:01"
---


# Introduction

This guide demonstrates **model-assisted inference** approaches for survey data analysis, focusing on:

-   **GREG (Generalized Regression) Estimators**: Using design-weighted regression
-   **Doubly Robust (DR) Estimators**: Using unweighted regression with design correction
-   **Design-Based (Horvitz-Thompson) Estimators**: Standard weighted estimation

## Key Concepts

**Model-Assisted Inference** combines:

1.  **Design-based validity**: Estimates remain unbiased even if model is wrong
2.  **Model-based efficiency**: When model is correct, variance is reduced

The GREG estimator can be expressed as:

$$\hat{T}_w = \hat{T}_d + (\mathbf{X} - \hat{\mathbf{X}}_d)^T \hat{\boldsymbol{\beta}}_w$$

Where:

-   $\hat{T}_d$ = Design-based (HT) estimator
-   $\mathbf{X}$ = Known population totals for auxiliary variables
-   $\hat{\mathbf{X}}_d$ = Estimated population totals from sample
-   $\hat{\boldsymbol{\beta}}_w$ = Weighted regression coefficients

# Setup and Data Generation

```r
#| label: setup
#| code-fold: false

# Load required packages
library(MASS)         # For multivariate normal distribution
library(knitr)        # For nice tables
library(kableExtra)   # For enhanced tables
library(tidyverse)    # For data manipulation and visualization


# Set seed for reproducibility
set.seed(740)

# Display options
options(digits = 4, scipen = 999)
```

## Population Generation Function

```r
#| label: population-function
#| code-fold: false

#' Generate a finite population with specified characteristics
#' 
#' @param N Population size
#' @param outcome_type Either "continuous" or "binary"
#' @return A tibble with population data
generate_population <- function(N = 10000, outcome_type = "continuous") {
  
  # Generate covariates
  population <- tibble(
    id = 1:N,
    # x1: Standard normal
    x1 = rnorm(N, mean = 0, sd = 1),
    # x2: Normal with larger variance
    x2 = rnorm(N, mean = 0, sd = 2),
    # x3: Binary indicator (20% probability)
    x3 = rbinom(N, size = 1, prob = 0.2)
  )
  
  # Generate outcome based on type
  if (outcome_type == "continuous") {
    # True model: y = -2 + x1 - x2 + x3 - x1*x2 + error
    population <- population %>%
      mutate(
        mu = -2 + x1 - x2 + x3 - x1 * x2,  # True conditional mean
        y = rnorm(N, mean = mu, sd = 1)     # Add random error
      )
  } else {
    # Binary outcome using logistic model
    population <- population %>%
      mutate(
        logit_p = -2 + x1 - x2 + x3,
        prob = plogis(logit_p),  # Convert to probability
        y = rbinom(N, size = 1, prob = prob)
      )
  }
  
  return(population)
}
```

## Sampling Function with Unequal Probabilities

```r
#| label: sampling-function
#| code-fold: false

#' Draw a probability sample with unequal selection probabilities
#' 
#' @param population Population tibble
#' @param n Sample size
#' @return Sample tibble with selection probabilities and weights
draw_sample <- function(population, n = 500) {
  
  N <- nrow(population)
  
  # Calculate measure of size (MOS) - probability proportional to covariates
  population <- population %>%
    mutate(
      mos = exp(-2 + 0.5 * x1 + 0.5 * x2 + x3),
      # Selection probability proportional to MOS
      pi = n * mos / sum(mos),
      # Design weight (inverse probability)
      d = 1 / pi
    )
  
  # Draw sample using probability proportional to size (PPS)
  sample_ids <- sample(
    x = population$id,
    size = n,
    prob = population$pi,
    replace = FALSE
  )
  
  # Return sample with weights
  sample_data <- population %>%
    filter(id %in% sample_ids)
  
  return(sample_data)
}
```

# Estimation Functions

## 1. Horvitz-Thompson (Design-Based) Estimator

```r
#| label: ht-estimator
#| code-fold: false

#' Horvitz-Thompson (HT) estimator for population mean
#' 
#' This is the standard design-based estimator using only weights
#' 
#' @param sample Sample data with 'y' and 'd' (weights)
#' @param N Population size
#' @return Estimated population mean
estimate_ht <- function(sample, N) {
  
  estimate <- sample %>%
    summarise(
      # Weighted sum / N
      mean_ht = sum(d * y) / N
    ) %>%
    pull(mean_ht)
  
  return(estimate)
}
```

**How it works:**

-   Uses only design weights ($d_i = 1/\pi_i$)
-   No model assumptions
-   Always design-unbiased (under probability sampling)
-   Can be inefficient if outcome relates to selection probabilities

## 2. GREG Estimator (Design-Weighted Regression)

```r
#| label: greg-estimator
#| code-fold: false

#' GREG estimator using design-weighted regression
#' 
#' Steps:
#' 1. Fit weighted regression: y ~ X using design weights
#' 2. Predict for all population units
#' 3. Add weighted residuals
#' 
#' @param sample Sample data
#' @param population Population data
#' @param N Population size
#' @param predictors Character vector of predictor names
#' @return Estimated population mean
estimate_greg <- function(sample, population, N, 
                          predictors = c("x1", "x2", "x3")) {
  
  # Create formula
  formula_str <- paste("y ~", paste(predictors, collapse = " + "))
  model_formula <- as.formula(formula_str)
  
  # Fit WEIGHTED regression using design weights
  model <- lm(
    formula = model_formula,
    data = sample,
    weights = d  # Design weights
  )
  
  # Predict for entire population
  population <- population %>%
    mutate(
      y_pred = predict(model, newdata = population)
    )
  
  # Predict for sample (to get residuals)
  sample <- sample %>%
    mutate(
      y_pred = predict(model, newdata = sample),
      residual = y - y_pred
    )
  
  # GREG formula: Mean of predictions + weighted mean of residuals
  mean_predictions <- mean(population$y_pred)
  weighted_mean_residuals <- sum(sample$d * sample$residual) / N
  
  estimate <- mean_predictions + weighted_mean_residuals
  
  return(estimate)
}
```

**Why GREG works:**

1.  **If model is correct**: Residuals are small → highly efficient
2.  **If model is wrong**: Weighted residuals correct the bias → still design-unbiased
3.  **Best of both worlds**: Model efficiency + design validity

## 3. Doubly Robust (DR) Estimator

```r
#| label: dr-estimator
#| code-fold: false

#' Doubly Robust estimator using unweighted regression
#' 
#' Uses unweighted regression but corrects with design weights
#' 
#' @param sample Sample data
#' @param population Population data
#' @param N Population size
#' @param predictors Character vector of predictor names
#' @return Estimated population mean
estimate_dr <- function(sample, population, N,
                        predictors = c("x1", "x2", "x3")) {
  
  # Create formula
  formula_str <- paste("y ~", paste(predictors, collapse = " + "))
  model_formula <- as.formula(formula_str)
  
  # Fit UNWEIGHTED regression (more stable if model is good)
  model <- lm(
    formula = model_formula,
    data = sample
  )
  
  # Predict for entire population
  population <- population %>%
    mutate(
      y_pred = predict(model, newdata = population)
    )
  
  # Predict for sample
  sample <- sample %>%
    mutate(
      y_pred = predict(model, newdata = sample),
      residual = y - y_pred
    )
  
  # DR formula: Mean of all predictions + design-weighted residuals
  mean_predictions <- mean(population$y_pred)
  weighted_mean_residuals <- sum(sample$d * sample$residual) / N
  
  estimate <- mean_predictions + weighted_mean_residuals
  
  return(estimate)
}
```

**Doubly Robust property:**

-   Unweighted regression can be more stable (lower variance)
-   Design weights still correct for selection bias via residuals
-   Valid if either model OR weights are correct

# Simulation Study: Continuous Outcome

## Simulation Function

```r
#| label: simulation-continuous
#| code-fold: false

#' Run simulation comparing estimators for continuous outcome
#' 
#' @param n_sims Number of simulation replications
#' @param N Population size
#' @param n Sample size
#' @return Tibble with simulation results
run_simulation_continuous <- function(n_sims = 1000, N = 10000, n = 500) {
  
  # Generate population once
  population <- generate_population(N = N, outcome_type = "continuous")
  true_mean <- mean(population$y)
  
  cat("True population mean:", round(true_mean, 4), "\n")
  cat("Running", n_sims, "simulations...\n\n")
  
  # Store results
  results <- tibble(
    sim = 1:n_sims,
    ht = numeric(n_sims),
    greg_x3 = numeric(n_sims),
    greg_x1_x3 = numeric(n_sims),
    greg_x1_x2_x3 = numeric(n_sims),
    greg_full = numeric(n_sims),
    dr_x3 = numeric(n_sims),
    dr_x1_x3 = numeric(n_sims),
    dr_x1_x2_x3 = numeric(n_sims),
    dr_full = numeric(n_sims)
  )
  
  # Run simulations
  for (i in 1:n_sims) {
    # Draw sample
    sample_data <- draw_sample(population, n = n)
    
    # HT estimator
    results$ht[i] <- estimate_ht(sample_data, N)
    
    # GREG with different predictor sets
    results$greg_x3[i] <- estimate_greg(
      sample_data, population, N, 
      predictors = "x3"
    )
    results$greg_x1_x3[i] <- estimate_greg(
      sample_data, population, N,
      predictors = c("x1", "x3")
    )
    results$greg_x1_x2_x3[i] <- estimate_greg(
      sample_data, population, N,
      predictors = c("x1", "x2", "x3")
    )
    results$greg_full[i] <- estimate_greg(
      sample_data, population, N,
      predictors = c("x1", "x2", "x3", "I(x1*x2)")
    )
    
    # DR with different predictor sets
    results$dr_x3[i] <- estimate_dr(
      sample_data, population, N,
      predictors = "x3"
    )
    results$dr_x1_x3[i] <- estimate_dr(
      sample_data, population, N,
      predictors = c("x1", "x3")
    )
    results$dr_x1_x2_x3[i] <- estimate_dr(
      sample_data, population, N,
      predictors = c("x1", "x2", "x3")
    )
    results$dr_full[i] <- estimate_dr(
      sample_data, population, N,
      predictors = c("x1", "x2", "x3", "I(x1*x2)")
    )
    
    # Progress update
    if (i %% 100 == 0) cat("Completed", i, "simulations\n")
  }
  
  # Calculate performance metrics
  performance <- results %>%
    select(-sim) %>%
    pivot_longer(
      cols = everything(),
      names_to = "estimator",
      values_to = "estimate"
    ) %>%
    group_by(estimator) %>%
    summarise(
      bias = mean(estimate - true_mean),
      variance = var(estimate),
      mse = mean((estimate - true_mean)^2),
      rmse = sqrt(mse),
      .groups = "drop"
    ) %>%
    mutate(
      se = sqrt(variance),
      method = case_when(
        str_detect(estimator, "ht") ~ "H-T",
        str_detect(estimator, "greg") ~ "GREG",
        str_detect(estimator, "dr") ~ "DR"
      ),
      predictors = case_when(
        str_detect(estimator, "x3$") ~ "x3",
        str_detect(estimator, "x1_x3") ~ "(x1, x3)",
        str_detect(estimator, "x1_x2_x3") ~ "(x1, x2, x3)",
        str_detect(estimator, "full") ~ "(x1, x2, x3, x1*x2)",
        TRUE ~ "None"
      )
    ) %>%
    arrange(method, predictors)
  
  return(list(
    results = results,
    performance = performance,
    true_mean = true_mean
  ))
}
```

## Run Continuous Outcome Simulation

```r
#| label: run-continuous
#| cache: true

# Run simulation
sim_continuous <- run_simulation_continuous(n_sims = 1000, N = 10000, n = 500)

# Display performance metrics
sim_continuous$performance %>%
  select(method, predictors, bias, se, rmse) %>%
  kable(
    digits = 2,
    caption = "Simulation Results: Continuous Outcome",
    col.names = c("Method", "Predictors", "Bias", "SE", "RMSE")
  ) %>%
  kable_styling(latex_options = c("striped", "hold_position"))
```

## Visualize Results: Continuous Outcome

```r
#| label: plot-continuous-bias
#| fig-cap: "Bias comparison across estimators (continuous outcome)"

sim_continuous$performance %>%
  ggplot(aes(x = predictors, y = bias, fill = method)) +
  geom_col(position = "dodge") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(
    title = "Bias Comparison: Model-Assisted Estimators",
    subtitle = "True model: y = -2 + x1 - x2 + x3 - x1*x2 + ε",
    x = "Calibration Variables",
    y = "Bias",
    fill = "Estimator"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

```r
#| label: plot-continuous-rmse
#| fig-cap: "RMSE comparison across estimators (continuous outcome)"

sim_continuous$performance %>%
  ggplot(aes(x = predictors, y = rmse, fill = method)) +
  geom_col(position = "dodge") +
  labs(
    title = "RMSE Comparison: Model-Assisted Estimators",
    subtitle = "Lower is better",
    x = "Calibration Variables",
    y = "Root Mean Squared Error (RMSE)",
    fill = "Estimator"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

# Simulation Study: Binary Outcome

## Binary Outcome Functions

```r
#| label: binary-estimators
#| code-fold: false

#' GREG estimator for binary outcome using logistic regression
estimate_greg_binary <- function(sample, population, N,
                                 predictors = c("x1", "x2", "x3")) {
  
  # Create formula
  formula_str <- paste("y ~", paste(predictors, collapse = " + "))
  model_formula <- as.formula(formula_str)
  
  # Fit weighted logistic regression
  model <- glm(
    formula = model_formula,
    data = sample,
    family = binomial(link = "logit"),
    weights = d  # Design weights
  )
  
  # Predict probabilities for population
  population <- population %>%
    mutate(
      y_pred = predict(model, newdata = population, type = "response")
    )
  
  # Predict for sample (for residuals)
  sample <- sample %>%
    mutate(
      y_pred = predict(model, newdata = sample, type = "response"),
      residual = y - y_pred
    )
  
  # GREG formula
  mean_predictions <- mean(population$y_pred)
  weighted_mean_residuals <- sum(sample$d * sample$residual) / N
  
  estimate <- mean_predictions + weighted_mean_residuals
  
  return(estimate)
}

#' DR estimator for binary outcome
estimate_dr_binary <- function(sample, population, N,
                               predictors = c("x1", "x2", "x3")) {
  
  # Create formula
  formula_str <- paste("y ~", paste(predictors, collapse = " + "))
  model_formula <- as.formula(formula_str)
  
  # Fit unweighted logistic regression
  model <- glm(
    formula = model_formula,
    data = sample,
    family = binomial(link = "logit")
  )
  
  # Predict for population
  population <- population %>%
    mutate(
      y_pred = predict(model, newdata = population, type = "response")
    )
  
  # Predict for sample
  sample <- sample %>%
    mutate(
      y_pred = predict(model, newdata = sample, type = "response"),
      residual = y - y_pred
    )
  
  # DR formula
  mean_predictions <- mean(population$y_pred)
  weighted_mean_residuals <- sum(sample$d * sample$residual) / N
  
  estimate <- mean_predictions + weighted_mean_residuals
  
  return(estimate)
}
```

## Binary Simulation Function

```r
#| label: simulation-binary
#| code-fold: true

#' Run simulation for binary outcome
run_simulation_binary <- function(n_sims = 1000, N = 10000, n = 500) {
  
  # Generate population
  population <- generate_population(N = N, outcome_type = "binary")
  true_mean <- mean(population$y)
  
  cat("True population proportion:", round(true_mean, 4), "\n")
  cat("Running", n_sims, "simulations...\n\n")
  
  # Store results
  results <- tibble(
    sim = 1:n_sims,
    ht = numeric(n_sims),
    greg_x3 = numeric(n_sims),
    greg_x1_x3 = numeric(n_sims),
    greg_x1_x2_x3 = numeric(n_sims),
    dr_x3 = numeric(n_sims),
    dr_x1_x3 = numeric(n_sims),
    dr_x1_x2_x3 = numeric(n_sims)
  )
  
  # Run simulations
  for (i in 1:n_sims) {
    sample_data <- draw_sample(population, n = n)
    
    # HT
    results$ht[i] <- estimate_ht(sample_data, N)
    
    # GREG with different predictors
    results$greg_x3[i] <- estimate_greg_binary(
      sample_data, population, N, "x3"
    )
    results$greg_x1_x3[i] <- estimate_greg_binary(
      sample_data, population, N, c("x1", "x3")
    )
    results$greg_x1_x2_x3[i] <- estimate_greg_binary(
      sample_data, population, N, c("x1", "x2", "x3")
    )
    
    # DR with different predictors
    results$dr_x3[i] <- estimate_dr_binary(
      sample_data, population, N, "x3"
    )
    results$dr_x1_x3[i] <- estimate_dr_binary(
      sample_data, population, N, c("x1", "x3")
    )
    results$dr_x1_x2_x3[i] <- estimate_dr_binary(
      sample_data, population, N, c("x1", "x2", "x3")
    )
    
    if (i %% 100 == 0) cat("Completed", i, "simulations\n")
  }
  
  # Calculate performance
  performance <- results %>%
    select(-sim) %>%
    pivot_longer(
      cols = everything(),
      names_to = "estimator",
      values_to = "estimate"
    ) %>%
    group_by(estimator) %>%
    summarise(
      bias = mean(estimate - true_mean),
      variance = var(estimate),
      mse = mean((estimate - true_mean)^2),
      rmse = sqrt(mse),
      .groups = "drop"
    ) %>%
    mutate(
      se = sqrt(variance),
      method = case_when(
        str_detect(estimator, "ht") ~ "H-T",
        str_detect(estimator, "greg") ~ "GREG",
        str_detect(estimator, "dr") ~ "DR"
      ),
      predictors = case_when(
        str_detect(estimator, "x3$") ~ "x3",
        str_detect(estimator, "x1_x3") ~ "(x1, x3)",
        str_detect(estimator, "x1_x2_x3") ~ "(x1, x2, x3)",
        TRUE ~ "None"
      )
    ) %>%
    arrange(method, predictors)
  
  return(list(
    results = results,
    performance = performance,
    true_mean = true_mean
  ))
}
```

## Run Binary Outcome Simulation

```r
#| label: run-binary
#| cache: true

# Run simulation
sim_binary <- run_simulation_binary(n_sims = 1000, N = 10000, n = 500)

# Display results
sim_binary$performance %>%
  select(method, predictors, bias, se, rmse) %>%
  kable(
    digits = 4,
    caption = "Simulation Results: Binary Outcome",
    col.names = c("Method", "Predictors", "Bias", "SE", "RMSE")
  ) %>%
  kable_styling(latex_options = c("striped", "hold_position"))
```

## Visualize Results: Binary Outcome

```r
#| label: plot-binary
#| fig-cap: "Performance comparison for binary outcome"

sim_binary$performance %>%
  pivot_longer(
    cols = c(bias, se, rmse),
    names_to = "metric",
    values_to = "value"
  ) %>%
  ggplot(aes(x = predictors, y = value, fill = method)) +
  geom_col(position = "dodge") +
  facet_wrap(~ metric, scales = "free_y", ncol = 1) +
  labs(
    title = "Performance Metrics: Binary Outcome",
    x = "Calibration Variables",
    y = "Value",
    fill = "Estimator"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

# Key Takeaways

## When to Use Each Estimator

1.  **Horvitz-Thompson (H-T)**
    -   Always design-unbiased
    -   Use when you don't trust any models
    -   Higher variance when outcome related to selection
2.  **GREG (Design-Weighted Regression)**
    -   **Best choice** when you have good auxiliary variables
    -   Reduces variance if model is approximately correct
    -   Still valid if model is wrong (design-unbiased)
    -   Weighted regression handles heteroscedasticity
3.  **Doubly Robust (Unweighted Regression)**
    -   More stable estimates when model is good
    -   Valid if either model OR weights are correct
    -   Can have higher bias if both are wrong

## Model Specification Matters

From the simulations, we see:

-   **Correct model specification** → GREG has lowest RMSE
-   **Missing interactions** (x1\*x2) → Increased bias and RMSE
-   **Minimal predictors** (x3 only) → Performance closer to H-T

**Key insight**: Model-assisted methods are most valuable when:

1.  Auxiliary variables are strongly related to outcome
2.  Selection probabilities depend on these variables
3.  Model includes important interactions

## Practical Recommendations

1.  **Start with GREG** using well-chosen auxiliary variables
2.  **Include variables** related to:
    -   The outcome of interest
    -   The sampling design
3.  **Check model diagnostics** (residual plots, etc.)
4.  **Compare results** across different predictor sets
5.  **Be cautious** with complex models (overfitting risk)

# Appendix: Function Reference

## Quick Reference Table

| Function | Purpose | Key Arguments |
|---------------------|-------------------|-------------------------------|
| `generate_population()` | Create finite population | N, outcome_type |
| `draw_sample()` | PPS sampling | population, n |
| `estimate_ht()` | H-T estimator | sample, N |
| `estimate_greg()` | GREG (weighted reg) | sample, population, N, predictors |
| `estimate_dr()` | DR (unweighted reg) | sample, population, N, predictors |
| `estimate_greg_binary()` | GREG for binary | sample, population, N, predictors |
| `estimate_dr_binary()` | DR for binary | sample, population, N, predictors |

## Mathematical Formulas

### GREG Estimator

$$\bar{Y}_w = N^{-1}\left(\sum_{i=1}^N \hat{y}_i^W + \sum_{i=1}^n d_i(y_i - \hat{y}_i^W)\right)$$

Where:

-   $\hat{y}_i^W = \mathbf{x}_i^T \hat{\boldsymbol{\beta}}_w$ (weighted regression prediction)
-   $\hat{\boldsymbol{\beta}}_w = \left(\sum_{i=1}^n d_i \mathbf{x}_i \mathbf{x}_i^T\right)^{-1} \left(\sum_{i=1}^n d_i \mathbf{x}_i^T y_i\right)$

### Doubly Robust Estimator

$$\bar{Y}_R = N^{-1}\left(\sum_{i=1}^N \hat{y}_i + \sum_{i=1}^n d_i(y_i - \hat{y}_i)\right)$$

Where:

-   $\hat{y}_i = \mathbf{x}_i^T \hat{\boldsymbol{\beta}}_0$ (unweighted regression prediction)
-   $\hat{\boldsymbol{\beta}}_0 = \left(\sum_{i=1}^n \mathbf{x}_i \mathbf{x}_i^T\right)^{-1} \left(\sum_{i=1}^n y_i \mathbf{x}_i^T\right)$

# 
