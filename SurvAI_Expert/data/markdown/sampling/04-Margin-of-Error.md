---
id: "sampling/04-Margin-of-Error"
source: "sampling"
course: ""
course_title: ""
doc_type: "book"
title: "4  Margin of Error"
original: "04-Margin-of-Error.md"
pages: 
sha256: "53a29474ce3f70102109e7cb14ddc5621a376a7d626c3efa5ec081a3e3a145c1"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:46"
---

<!-- source: https://bookdown.org/dsciencelabs/sampling_and_survey_techniques/04-Margin-of-Error.html -->

# 4  Margin of Error

Margin of error (MoE) is a statistical concept that quantifies the uncertainty in survey results or sample-based estimates. It provides a range within which the true population parameter is likely to fall.

# An error occurred.

Unable to execute JavaScript.

## 4.1 Why is MoE Important?

When conducting surveys or experiments, we rarely measure an entire population. Instead, we take a sample and use it to infer information about the whole group. However, because a sample is only a subset of the population, there is always some level of error. The margin of error helps account for this uncertainty.

## 4.2 Importance of Sample Size

In statistics, **sample size** plays a crucial role in determining the **reliability** and **stability** of an estimate. A **larger sample size** leads to more **precise** and **consistent** estimates of the population parameters. Here’s why:

- **Reduces Variability:** Smaller samples tend to exhibit greater fluctuations in their estimates, whereas larger samples provide more **stable** and **reliable** results.
- **Improves Accuracy:** A small sample may fail to accurately represent the overall population. However, as the sample size increases, the **sample mean converges toward the true population mean** (*Law of Large Numbers*).
- **Minimizes Sampling Error:** Larger samples result in **smaller sampling errors**, making conclusions **more generalizable** to the broader population.
- **Enhances Statistical Power:** A greater sample size **increases the statistical power** of tests, improving the ability to detect **true differences** or **effects**.

To gain a clearer understanding of this concept, let’s visualize how different sample sizes impact the **distribution of sample means**:

### 4.2.1 Python code

    import numpy as np
    import pandas as pd
    import plotly.express as px

    # Set random seed for reproducibility
    np.random.seed(123)

    # Generate a normally distributed population
    population = np.random.normal(loc=50, scale=15, size=10000)  # Mean=50, SD=15

    # Function to take samples and compute mean
    def sample_means(sample_size, n_samples=1000):
        means = [np.mean(np.random.choice(population, 
                sample_size, replace=True)) for _ in range(n_samples)]
        return pd.DataFrame({'SampleSize': f"n = {sample_size}", 'Mean': means})

    # Create sample distributions for different sizes
    samples_20  = sample_means(20)
    samples_50  = sample_means(50)
    samples_100 = sample_means(100)
    samples_500 = sample_means(500)

    # Combine all into one dataset
    sample_data = pd.concat([samples_20, samples_50, samples_100, samples_500])

    # Define high-contrast colors for readability
    custom_colors = {
        "n = 20":  "#D72638",  # Bright Red
        "n = 50":  "#F49D37",  # Deep Orange
        "n = 100": "#3F88C5",  # Strong Blue
        "n = 500": "#2E933C"   # Bold Green
    }

    # Create an interactive violin plot (without jitter)
    fig = px.violin(sample_data, x="SampleSize", y="Mean", color="SampleSize",
                    box=True, hover_data=["SampleSize"], 
                    color_discrete_map=custom_colors)

    # Update layout for readability
    fig.update_layout(
        title="Effect of Sample Size on Stability of Estimates",
        xaxis_title="Sample Size",
        yaxis_title="Sample Mean",
        template="plotly_white",
        font=dict(size=16),
        legend_title_text="Sample Size"
    )

    # Display the plot
    # fig.show()

### 4.2.2 R code

```r
# Load required libraries
library(ggplot2)
library(dplyr)
library(plotly)

set.seed(123)  # For reproducibility

# Generate a normally distributed population
population <- rnorm(10000, mean = 50, sd = 15)

# Function to take samples and compute mean
sample_means <- function(sample_size, n_samples = 1000) {
  means <- replicate(n_samples, mean(sample(population, 
                                            sample_size, replace = TRUE)))
  return(data.frame(SampleSize = paste0("n = ", sample_size), Mean = means))
}

# Create sample distributions for different sizes
samples_20  <- sample_means(20)
samples_50  <- sample_means(50)
samples_100 <- sample_means(100)
samples_500 <- sample_means(500)

# Combine all into one dataset
sample_data <- bind_rows(samples_20, samples_50, samples_100, samples_500)

# Convert SampleSize to a factor for better visualization
sample_data$SampleSize <- factor(sample_data$SampleSize, 
                                 levels = c("n = 20", 
                                            "n = 50", 
                                            "n = 100", 
                                            "n = 500"))

# Define high-contrast colors for readability
custom_colors <- c("n = 20"  = "#D72638",  # Bright Red
                   "n = 50"  = "#F49D37",  # Deep Orange
                   "n = 100" = "#3F88C5",  # Strong Blue
                   "n = 500" = "#2E933C")  # Bold Green

# Create violin plot with matching outline, avoiding duplicate legends
p <- ggplot(sample_data, aes(x = SampleSize, 
                             y = Mean, 
                             fill = SampleSize)) +
  geom_violin(alpha = 0.6, color = NA) +  # Remove outline from legend
  geom_boxplot(width = 0.1, fill = "white", 
               outlier.shape = NA, aes(color = SampleSize), size = 0.6) +  
  scale_fill_manual(values = custom_colors) +  # Custom fill colors 
  scale_color_manual(values = custom_colors, guide = "none") + 
  labs(
    title = "Effect of Sample Size on Stability of Estimates",
    x = "Sample Size", y = "Sample Mean",
    fill = "Sample Size"
  ) +
  theme_minimal(base_size = 14) +  
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    legend.position = "top"
  )

# Convert ggplot to interactive Plotly plot
ggplotly(p)
```

## 4.3 Factors Affecting Sample Size

Determining the appropriate sample size is crucial for obtaining accurate and meaningful results in statistical analysis. Several key factors influence the required sample size:

- Population Variability (Standard Deviation, SD)

The more diverse a population, the larger the sample needed to capture its full characteristics. If a population has high variability, a small sample may not be representative, leading to unreliable estimates.

- Confidence Level

The confidence level (e.g., 90%, 95%, or 99%) indicates how certain we want to be that the sample accurately represents the population. A higher confidence level requires a larger sample size to reduce uncertainty.

3.  Margin of Error (MoE)

The margin of error measures how much the sample estimate is expected to vary from the true population value. A smaller margin of error (e.g., ±1% instead of ±5%) requires a larger sample to ensure higher precision.

4.  Population Size

For small populations, a higher percentage needs to be sampled to achieve reliable results. However, beyond a certain point, increasing sample size provides diminishing returns in accuracy.

5.  Study Complexity and Statistical Power

More complex studies (e.g., subgroup analysis, machine learning models) require larger sample sizes to ensure meaningful results. In hypothesis testing, a larger sample size increases statistical power, making it easier to detect true effects.

While a larger sample size improves accuracy, it also requires more time, cost, and resources. The goal is to find the optimal balance that ensures reliable results without unnecessary effort.

### 4.3.1 Python Code

    import numpy as np
    import pandas as pd
    import plotly.express as px

    # Sample Size Calculation Function
    def calculate_sample_size(std_dev, confidence_z, margin_of_error):
        return ((confidence_z * std_dev) / margin_of_error) ** 2

    # Define Parameters
    sd_values = np.arange(5, 35, 5)  # Population standard deviations
    confidence_levels = [1.645, 1.96, 2.576]  # 90%, 95%, 99% Z-scores
    margin_errors = np.arange(1, 11, 1)  # Different margin of errors

    # Generate Data for Population Variability Impact
    var_data = pd.DataFrame([(sd, moe, calculate_sample_size(sd, 1.96, moe)) 
                             for sd in sd_values for moe in margin_errors], 
                            columns=["SD", "MarginError", "SampleSize"])
    var_data["MarginError"] = var_data["MarginError"].astype(str)  

    # Generate Data for Confidence Level Impact
    conf_data = pd.DataFrame([(z, moe, calculate_sample_size(15, z, moe)) 
                              for z in confidence_levels for moe in margin_errors], 
                             columns=["ConfidenceZ", "MarginError", "SampleSize"])
    conf_data["ConfidenceZ"] = conf_data["ConfidenceZ"].map({1.645: "90%", 
                               1.96: "95%", 2.576: "99%"})
    conf_data["MarginError"] = conf_data["MarginError"].astype(str)

    # Generate Data for Margin of Error Impact
    me_data = pd.DataFrame({"MarginError": margin_errors, 
                            "SampleSize": [calculate_sample_size(15, 1.96, 
                            moe) for moe in margin_errors]})

    # Plot 1: Effect of Population Variability
    fig1 = px.line(var_data, x="SD", y="SampleSize", color="MarginError",
                   title="Effect of Population Variability on Sample Size",
                   labels={"SD": "Population Standard Deviation (SD)", 
                   "SampleSize": "Required Sample Size"},
                   color_discrete_sequence=px.colors.qualitative.Set1) 

    # Plot 2: Effect of Confidence Level
    fig2 = px.line(conf_data, x="ConfidenceZ", y="SampleSize", color="MarginError",
                   title="Effect of Confidence Level on Sample Size",
                   labels={"ConfidenceZ": "Confidence Level", 
                   "SampleSize": "Required Sample Size"},
                   color_discrete_sequence=px.colors.qualitative.Set2, 
                   markers=True)

    # Plot 3: Effect of Margin of Error
    fig3 = px.line(me_data, x="MarginError", y="SampleSize",
                   title="Effect of Margin of Error on Sample Size",
                   labels={"MarginError": "Margin of Error", 
                   "SampleSize": "Required Sample Size"},
                   markers=True, line_shape="spline",
                   color_discrete_sequence=["blue"])  # Single color for clarity

    # Show Plots
    fig1.show()

    fig2.show()

    fig3.show()

### 4.3.2 R Code

```r
# Load required libraries
library(plotly)
library(dplyr)

# Sample Size Calculation Function
calculate_sample_size <- function(sd, confidence_z, margin_error) {
  return(((confidence_z * sd) / margin_error)^2)
}

# Define Parameters
sd_values <- seq(5, 30, by = 5)  # Population standard deviations
confidence_levels <- c(1.645, 1.96, 2.576)  # 90%, 95%, 99% Z-scores
margin_errors <- seq(1, 10, by = 1)  # Different margin of errors

# Generate Data for Variability Impact
var_data <- expand.grid(SD = sd_values, MarginError = margin_errors)
var_data$SampleSize <- mapply(calculate_sample_size, var_data$SD, 1.96, var_data$MarginError)

# Generate Data for Confidence Level Impact
conf_data <- expand.grid(ConfidenceZ = confidence_levels, MarginError = margin_errors)
conf_data$SampleSize <- mapply(calculate_sample_size, 15, conf_data$ConfidenceZ, conf_data$MarginError)
conf_data$ConfidenceZ <- factor(conf_data$ConfidenceZ, levels = confidence_levels, labels = c("90%", "95%", "99%"))

# Generate Data for Margin of Error Impact
me_data <- data.frame(
  MarginError = margin_errors,
  SampleSize = calculate_sample_size(15, 1.96, margin_errors)
)

# Create Plotly Plots

# Plot 1: Effect of Population Variability
p1 <- plot_ly(var_data, x = ~SD, y = ~SampleSize, color = ~as.factor(MarginError),
              type = 'scatter', mode = 'lines', line = list(width = 2)) %>%
  layout(title = "Effect of Population Variability on Sample Size",
         xaxis = list(title = "Population Standard Deviation (SD)"),
         yaxis = list(title = "Required Sample Size"),
         legend = list(title = list(text = "Margin of Error")))

# Plot 2: Effect of Confidence Level
p2 <- plot_ly(conf_data, x = ~ConfidenceZ, y = ~SampleSize, color = ~as.factor(MarginError),
              type = 'scatter', mode = 'lines+markers', line = list(width = 2)) %>%
  layout(title = "Effect of Confidence Level on Sample Size",
         xaxis = list(title = "Confidence Level"),
         yaxis = list(title = "Required Sample Size"),
         legend = list(title = list(text = "Margin of Error")))

# Plot 3: Effect of Margin of Error
p3 <- plot_ly(me_data, x = ~MarginError, y = ~SampleSize,
              type = 'scatter', mode = 'lines+markers', line = list(color = 'blue', width = 2)) %>%
  layout(title = "Effect of Margin of Error on Sample Size",
         xaxis = list(title = "Margin of Error"),
         yaxis = list(title = "Required Sample Size"))

# Display Interactive Plots
p1
```

```r
p2
```

```r
p3
```

## 4.4 Probability Sample Size

Probability sampling ensures that every member of the population has a known, non-zero chance of being selected. Here are examples of different **probability sampling methods** and how to calculate the required sample size.

### 4.4.1 Simple Random Sampling (SRS)

Every individual in the population has an **equal** chance of being selected.

**Example: Estimating Average Test Scores** A school wants to estimate the **average math test score** of students.

- Population size (**N**) = 2,000 students  
- Standard deviation (**σ**) = 15  
- Desired confidence level = **95%** (**Z = 1.96**)  
- Margin of error (**E**) = 2 points

$$n = \left( \frac{Z \cdot \sigma}{E} \right)^2$$

 

$$n = \left( \frac{1.96 \times 15}{2} \right)^2$$

$$n = (14.7)^2 = 216.1$$

 

$$n \approx 217$$

**Conclusion:** The school should randomly select **217 students** for an accurate estimate.

### 4.4.2 Stratified Random Sampling

The population is divided into **subgroups (strata)** based on characteristics (e.g., gender, grade level), and a random sample is taken from each.

**Example: Employee Satisfaction Survey** A company wants to assess employee satisfaction across three departments.

- **Departments:** HR (100 employees), IT (200 employees), Sales (300 employees)  
- **Total Population (N) = 600**  
- Required Sample Size (**n**) = 200

To ensure proportional representation:

$$n_{HR} = \frac{100}{600} \times 200 = 33$$

 

$$n_{IT} = \frac{200}{600} \times 200 = 67$$

 

$$n_{Sales} = \frac{300}{600} \times 200 = 100$$

**Conclusion:** The company should survey **33 HR, 67 IT, and 100 Sales employees**.

### 4.4.3 Systematic Sampling

Every **k-th** individual is selected from an ordered list.

**Example: Checking Product Quality**

A factory produces **10,000** smartphones daily. The quality team inspects **500** of them.

To select samples systematically: 

$$k = \frac{10,000}{500} = 20$$

A random starting point is chosen (e.g., **7**), then every **20th** phone is selected:  
**7, 27, 47, 67, 87…**

**Conclusion:** A total of **500 phones** will be inspected systematically.

### 4.4.4 Cluster Sampling

The population is divided into **clusters**, and **entire clusters** are randomly selected.

**Example: Measuring Household Electricity Consumption**

A city has **10 districts**, each with **5,000 households**. Instead of surveying individuals across all districts, researchers randomly select **3 districts** and survey **all households within them**.

**Conclusion:** If each district has **5,000 households**, then **3 districts × 5,000 = 15,000 households** will be surveyed.

## 4.5 Non-Probability Sample Size

Non-probability sampling is used when random selection is not feasible, often due to time, cost, or accessibility constraints. In these methods, **sample size determination is more subjective**, as it depends on practical considerations rather than statistical formulas. Below are common **non-probability sampling methods** and how sample sizes are determined.

### 4.5.1 Convenience Sampling

Selection is based on **availability and willingness** of participants.

**Example: Coffee Shop Customer Survey**

A coffee shop wants to understand customer preferences. The manager surveys **the first 100 customers** who visit in the morning.

**Sample Size Consideration:**

- No fixed formula, depends on **time constraints** and **available respondents**.  
- The manager stops at **100 responses**, assuming this is sufficient for insights.

### 4.5.2 Purposive (Judgmental) Sampling

Participants are **handpicked** based on specific **criteria**.

**Example: Expert Opinion on Climate Change**

A researcher wants insights from **climate scientists**. They select **50 experts** based on qualifications and experience.

**Sample Size Consideration:**

- Depends on the **research objective**.  
- Common practice: **10-50 experts** for specialized studies.

### 4.5.3 Quota Sampling

The researcher **sets quotas** for different subgroups.

**Example: Market Research for a New Product**

A company surveys **500 people**, ensuring:

- **250 males, 250 females**  
- **100 young adults (18-25), 200 middle-aged (26-45), 200 older adults (46+)**

**Sample Size Consideration:**

- Based on **market representation** and **business needs**.  
- Typically uses **proportional allocation**.

### 4.5.4 Snowball Sampling

Used for **hard-to-reach populations**, where participants **refer others**.

**Example: Studying Homeless Individuals**

A researcher interviews **10 homeless individuals**, who refer others, growing the sample to **100 participants**.

**Sample Size Consideration:**

- Sample grows **organically** until data **saturation** (new responses add little value).  
- Often **50-200 participants**.

## 4.6 Real-World Examples

In this study, you will compare **Probability Sampling** and **Non-Probability Sampling** in handling **Margin of Error (MoE)** when estimating **university students’ monthly food expenses**. Please, apply **all methods** from both **Probability Sampling** and **Non-Probability Sampling** to gain a comprehensive understanding of their differences and effectiveness.

### 4.6.1 Selecting Sampling Methods

#### A. Probability Sampling

1.  **Simple Random Sampling (SRS)**
    - Randomly select students from the entire population using a random number generator or a random number table.
2.  **Stratified Sampling**
    - Divide the population into groups (strata), such as **faculty or academic year**.  
    - Randomly select students from each stratum **proportionally**.
3.  **Systematic Sampling**
    - Select every **k-th student** from a sorted list of students.  
    - Example: If there are **10,000 students** and a sample of **200** is needed, select every **50th student** (10,000/200 = 50).
4.  **Cluster Sampling**
    - Randomly select **some classes or student groups** and survey all students in those groups.  
    - Example: Choose **5 random classes** and interview all students in those classes.
5.  **Multi-Stage Sampling**
    - Combine multiple techniques, such as:
      - **Stage 1:** Randomly select **faculties**  
      - **Stage 2:** Randomly select **classes within faculties**  
      - **Stage 3:** Randomly select **students within those classes**

#### B. Non-Probability Sampling

1.  **Convenience Sampling**
    - Interview students who are **easily accessible**, such as in the cafeteria or library.
2.  **Quota Sampling**
    - Ensure a fixed number of students are surveyed in each category (e.g., **50 students per faculty**) without random selection.
3.  **Judgmental (Purposive) Sampling**
    - Select students who are **believed to be representative**, such as dormitory residents who may have more consistent food expenses.
4.  **Snowball Sampling**
    - Start with a few students and ask them to recommend other students for the survey.

### 4.6.2 Data Collection

1.  **Apply each sampling method to select student samples.**  
2.  **Record their monthly food expenses.**  
3.  **Store data in a spreadsheet or statistical software for analysis.**

### 4.6.3 Calculate Margin of Error

For **Probability Sampling**, calculate the **Margin of Error (MoE)** using the formula:

$$MoE = Z \times \frac{\sigma}{\sqrt{n}}$$

Where:

- $Z$ = **1.96** (for 95% confidence level)  
- $\sigma$ = **Sample standard deviation (calculated from data)**  
- $n$ = **Sample size**

Perform **MoE calculations** for each Probability Sampling method and compare the results.

### 4.6.4 Bias Analysis

- Explain the **sources of bias** in each **Non-Probability Sampling** method.  
- Discuss **how this bias affects survey results** and **the difference compared to Probability Sampling**.

### 4.6.5 Determine Sample Size

Use the following formula to determine required Sample Size for MoE = $5$:

$$n = \left( \frac{Z \times \sigma}{MoE} \right)^2$$

Where:  
- $Z$ = **1.96**  
- $\sigma$ = **Sample standard deviation**  
- $MoE$ = **$5$**

Calculate the **minimum required sample size** and interpret the results.

### 4.6.6 Create a Study Report

The final report should include:

1.  **Introduction** – Purpose of the study and importance of MoE in sampling  
2.  **Sampling Methods Used** – Explanation of all methods applied  
3.  **MoE Calculations for Probability Sampling**  
4.  **Bias Analysis in Non-Probability Sampling**  
5.  **Comparison of All Methods**  
6.  **Required Sample Size for MoE = $5$**  
7.  **Conclusion and Recommendations**

### 4.6.7 Additional Instructions

- Use **Excel, R, or Python** to calculate MoE and generate comparison charts.  
- If using Python, use **numpy, pandas, and scipy.stats** for analysis.  
- If using R, use **qnorm()**, **sqrt()**, and **mean()** functions.  
- Ensure all calculations and results are clearly interpreted.  
- Submit your answer on RPubs or Google Colab.
