---
id: "sampling/03-Sampling-Methods"
source: "sampling"
course: ""
course_title: ""
doc_type: "book"
title: "3  Sampling Methods"
original: "03-Sampling-Methods.md"
pages: 
sha256: "dfe19aa38626e70ee5a0a28a689c742af61a0de6f25af068caf38d2d6865a44c"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:46"
---

<!-- source: https://bookdown.org/dsciencelabs/sampling_and_survey_techniques/03-Sampling-Methods.html -->

# 3  Sampling Methods

Sampling is the process of selecting a subset of individuals from a larger population to make statistical inferences. It can be broadly categorized into Probability Sampling and Non-Probability Sampling.

# An error occurred.

Unable to execute JavaScript.

## 3.1 Probability Sampling

Probability sampling ensures that every individual in the population has a known, nonzero chance of being selected. This allows for generalizable and unbiased results.

### 3.1.1 Simple Random Sampling

Simple Random Sampling is a method where each individual in the population has an **equal chance** of being chosen. This technique ensures that the sample is **random and unbiased** by using random selection methods.

**Characteristics:**

- **Equal Probability** → Every individual has the same chance of being selected.  
- **No Specific Pattern** → The selection process is entirely **random**.  
- **Objective Representation** → The method avoids bias and ensures a fair representation of the population.

There are two primary ways to perform random sampling:

#### Using a Random Number Generator

Suppose we have 1000 students in a university, and we need a random sample of 100 students. The steps are:

- Assign numbers from 1 to 1000 to each student.  
- Use a **random number generator** to select 100 unique numbers.  
- The students corresponding to those numbers will be included in the sample.

**Python Code:**

    import pandas as pd

    # Create a dataset (example: student data)
    students = pd.DataFrame({'ID': range(1, 1001), 
                             'Name': ['Student ' + str(i) for i in range(1, 1001)]})

    # Set seed for reproducibility
    random_state = 123

    # Randomly select 100 students from the dataset
    sample_students = students.sample(n=100, random_state=random_state)

    # Print the selected sample
    print(sample_students)

          ID         Name
    131  132  Student 132
    203  204  Student 204
    50    51   Student 51
    585  586  Student 586
    138  139  Student 139
    ..   ...          ...
    938  939  Student 939
    814  815  Student 815
    994  995  Student 995
    805  806  Student 806
    558  559  Student 559

    [100 rows x 2 columns]

**R Code:**

```r
# Load dataset (contoh: data mahasiswa)
students <- data.frame(ID = 1:1000, 
                       Name = paste("Student", 1:1000))

# Set seed for reproducibility
set.seed(123)

# Randomly select 100 students from the dataset
sample_students <- students[sample(nrow(students), 100, replace = FALSE), ]

# Print the selected sample
print(head(sample_students))
```

         ID        Name
    415 415 Student 415
    463 463 Student 463
    179 179 Student 179
    526 526 Student 526
    195 195 Student 195
    938 938 Student 938

#### Lottery Method

The Lottery Method is one of the Simple Random Sampling techniques where each individual in the population has an equal chance of being selected. This method is called “Lottery” because it resembles a lottery system, such as a raffle or prize draw, where names or **numbers are placed in a container**, **shuffled**, and **randomly drawn**.

**Python Code Lottery Method:**

    import random

    # List of students (example names)
    students = ["Syifa","Nabila", "Alya", "Isnaini", "Bagas",
                  "Alfayed","Shalfa","Olivia","Nabila", "Fika",
                  "Luthfi","Nabil", "Joans", "Riyadh", "Rachelia",
                  "Nova", "Zain", "Ragil", "Dadan", "Dwi", "Chello", "Siti"]

    # Number of samples to draw
    num_samples = 5 

    # Shuffle the list (simulating shuffling the papers)
    random.shuffle(students)

    # Randomly draw the required number of samples
    selected_students = random.sample(students, num_samples)

    # Print the selected names
    print("Selected students:", selected_students)

    Selected students: ['Siti', 'Dadan', 'Nova', 'Ragil', 'Luthfi']

**R Code Lottery Method:**

```r
# List of students (example names)
students <- c("Syifa","Nabila", "Alya", "Isnaini", "Bagas",
              "Alfayed","Shalfa","Olivia","Nabila", "Fika",
              "Luthfi","Nabil", "Joans", "Riyadh", "Rachelia",
              "Nova", "Zain", "Ragil", "Dadan", "Dwi", "Chello", "Siti")

# Number of samples to draw
num_samples <- 5  

# Shuffle the list (simulating shuffling the papers)
students <- sample(students)  

# Randomly draw the required number of samples
selected_students <- sample(students, num_samples)

# Print the selected names
print(selected_students)
```

    [1] "Nabila"  "Luthfi"  "Syifa"   "Alya"    "Alfayed"

Here is the advantages and disadvantages in **Simple Random Sampling**:

| **Advantages** | **Disadvantages** |
|----|----|
| **Minimizes Bias** → Every individual has an equal chance, making the process **fair**. | **Requires a Complete Population List** → A full database of individuals is needed. |
| **Simple to Implement** → Especially with software tools. | **Inefficient for Large Populations** → If done manually, it can be time-consuming. |
| **Applicable to Large Populations** → Works well with technology-assisted selection. | **Might Not Ensure Proportional Representation** → Some subgroups may be underrepresented by pure randomness. |

Simple Random Sampling is a **fair, easy, and objective** method for selecting representative samples in research, surveys, and experiments. It is highly effective when a **complete list of the population** is available.

### 3.1.2 Systematic Sampling

Systematic Sampling is a probabilistic sampling technique where elements are selected from a population at fixed intervals $(k)$ after choosing a random starting point. Instead of selecting samples purely at random, this method follows a structured approach, making it more efficient and easier to implement than Simple Random Sampling.

#### Python Code: Systematic Sampling

    import numpy as np
    import pandas as pd

    # Create a sample population dataset
    data = pd.DataFrame({'Student_ID': np.arange(1, 101), 
                         'Name': ['Student_' + str(i) for i in range(1, 101)]})

    # Define sample size and interval
    N = len(data)  # Population size
    n = 10         # Desired sample size
    k = N // n     # Sampling interval

    # Randomly choose a starting point
    np.random.seed(42)
    start = np.random.randint(0, k)

    # Select every k-th element
    systematic_sample = data.iloc[start::k]

    # Display results
    print("Selected Sample:")

    Selected Sample:

    print(systematic_sample)

        Student_ID        Name
    6            7   Student_7
    16          17  Student_17
    26          27  Student_27
    36          37  Student_37
    46          47  Student_47
    56          57  Student_57
    66          67  Student_67
    76          77  Student_77
    86          87  Student_87
    96          97  Student_97

#### R Code: Systematic Sampling

```r
set.seed(42)

# Create a sample population dataset
data <- data.frame(
  Student_ID = 1:100,
  Name = paste("Student", 1:100, sep = "_")
)

# Define sample size and interval
N <- nrow(data)  # Population size
n <- 10          # Desired sample size
k <- N %/% n     # Sampling interval

# Randomly choose a starting point
start <- sample(1:k, 1)

# Select every k-th element
systematic_sample <- data[seq(start, N, by = k), ]

# Display results
print(systematic_sample)
```

       Student_ID       Name
    1           1  Student_1
    11         11 Student_11
    21         21 Student_21
    31         31 Student_31
    41         41 Student_41
    51         51 Student_51
    61         61 Student_61
    71         71 Student_71
    81         81 Student_81
    91         91 Student_91

**Key Concern:** The Risk of Hidden Patterns

If the population follows a specific pattern or cycle, Systematic Sampling may introduce bias. For example, if an employee work schedule is arranged in a repeating morning-afternoon-night shift pattern and we select every 3rd employee, we might only sample morning-shift workers, leading to biased results. To mitigate this risk, researchers should check for patterns in the population before applying Systematic Sampling.

### 3.1.3 Stratified Sampling

Stratified Sampling is a **probability sampling technique** in which the population is divided into **subgroups (strata)** based on shared characteristics. A sample is then drawn **proportionally** from each stratum to ensure that all groups are adequately represented.

This method is particularly useful when the population is **heterogeneous** and contains **distinct categories**, such as gender, age groups, income levels, or education levels.

**Example Scenario:**

Imagine a university with **10,000 students** divided into **three faculties**:

| Faculty  | Population | Proportion (%) | Sample Size (out of 500) |
|----------|------------|----------------|--------------------------|
| Science  | 5,000      | 50%            | 250                      |
| Arts     | 3,000      | 30%            | 150                      |
| Business | 2,000      | 20%            | 100                      |

The **total sample size is 500 students**, and the number of students from each faculty is selected **proportionally** to its representation in the population.

#### Python Code: Stratified Sampling

    import pandas as pd
    from sklearn.model_selection import train_test_split

    # Dataset with the given names
    data = {'Name': ['Syifa', 'Nabila', 'Alya', 'Isnaini', 'Rizky', 'Alfayed', 
                     'Whirdyana', 'Olivia', 'Nabila A', 'Fika',
                     'Luthfi', 'Nabil', 'Joans', 'Riyadh', 'Rachelia', 'Nova', 
                     'Zain', 'Ragil', 'Dadan', 'Dwi', 'Chello', 'Siti'],
                     'Faculty': ['Science', 'Arts', 'Science', 'Business', 
                     'Science', 'Arts', 'Business', 'Arts', 'Science', 'Business',
                     'Science', 'Arts', 'Business', 'Arts', 'Science', 'Business', 
                     'Science', 'Arts', 'Business', 'Arts', 'Science', 'Business']}

    df = pd.DataFrame(data)

    # Display initial group sizes
    print("Original data distribution:")

    Original data distribution:

    print(df['Faculty'].value_counts())

    Faculty
    Science     8
    Arts        7
    Business    7
    Name: count, dtype: int64

    # Stratified Sampling (30% from each group)
    stratified_sample, _ = train_test_split(df, test_size=0.7, 
                                           stratify=df['Faculty'], random_state=42)

    # Display sample group sizes
    print("\nSampled data distribution (should be ~30% of each group):")

    Sampled data distribution (should be ~30% of each group):

    print(stratified_sample['Faculty'].value_counts())

    Faculty
    Science     2
    Business    2
    Arts        2
    Name: count, dtype: int64

    # Show sampled data
    print("\nStratified Sample:")

    Stratified Sample:

    print(stratified_sample)

            Name   Faculty
    16      Zain   Science
    18     Dadan  Business
    5    Alfayed      Arts
    14  Rachelia   Science
    17     Ragil      Arts
    3    Isnaini  Business

#### R Code: Stratified Sampling

```r
library(dplyr)
library(purrr)

# Dataset with given names
data <- data.frame(
  Name = c("Syifa", "Nabila", "Alya", "Isnaini", "Rizky", "Alfayed", 
           "Whirdyana", "Olivia", "Nabila A", "Fika",
           "Luthfi", "Nabil", "Joans", "Riyadh", "Rachelia",
           "Nova", "Zain", "Ragil", "Dadan", "Dwi", "Chello", "Siti"),
  Faculty = c("Science", "Arts", "Science", "Business", 
              "Science", "Arts", "Business", "Arts", "Science", "Business",
              "Science", "Arts", "Business", "Arts", "Science", 
              "Business", "Science", "Arts", "Business", "Arts",
              "Science", "Business")
)

# Show original data distribution
cat("Original data distribution:\n")
```

    Original data distribution:

```r
print(table(data$Faculty))
```

        Arts Business  Science 
           7        7        8 

```r
# Determine sample size per strata (30% per group, rounded down)
sample_sizes <- data %>%
  count(Faculty) %>%
  mutate(sample_size = floor(n * 0.3))

# Perform stratified sampling with exact count per group
set.seed(42)

stratified_sample <- sample_sizes %>%
  split(.$Faculty) %>%
  map2(.x = ., .y = sample_sizes$sample_size, ~ data %>%
         filter(Faculty == .x$Faculty) %>%
         slice_sample(n = .y)) %>%
  bind_rows() %>%
  select(Name, Faculty)

# Show sampled data distribution
cat("\nSampled data distribution (should be exactly 30% of each group):\n")
```

    Sampled data distribution (should be exactly 30% of each group):

```r
print(table(stratified_sample$Faculty))
```

        Arts Business  Science 
           2        2        2 

```r
# Display the sampled data
print(stratified_sample)
```

          Name  Faculty
    1   Nabila     Arts
    2   Riyadh     Arts
    3  Isnaini Business
    4     Siti Business
    5     Alya  Science
    6 Nabila A  Science

### 3.1.4 Cluster Sampling

Cluster Sampling is a probabilistic sampling technique where instead of selecting individuals randomly, we select entire groups (clusters). Once a cluster is selected, all individuals within that cluster are included in the sample.

This method is widely used for large populations where individual random selection is costly or impractical. It is especially useful in geographically spread-out populations or organizational structures like schools, hospitals, or companies.

#### Python Code: Cluster Sampling

    import pandas as pd
    import numpy as np

    # Sample dataset with 3 clusters (3 Schools)
    data = pd.DataFrame({
        'Name': ['Syifa', 'Nabila', 'Alya', 'Isnaini', 'Rizky', 
                'Alfayed', 'Whirdyana', 'Olivia', 'Nabila A', 'Fika',
                 'Luthfi', 'Nabil', 'Joans', 'Riyadh', 'Rachelia', 
                 'Nova', 'Zain', 'Ragil', 'Dadan', 'Dwi', 'Chello', 'Siti'],
        'School': ['School A', 'School A', 'School A', 'School A', 
                   'School A', 'School B', 'School B', 'School B', 
                   'School B', 'School B','School B', 'School C', 
                   'School C', 'School C', 'School C', 'School C', 
                   'School C', 'School C', 'School C', 'School C', 
                   'School C', 'School C']
    })

    # Show original data distribution
    print("Original Data Distribution:")

    Original Data Distribution:

    print(data['School'].value_counts())

    School
    School C    11
    School B     6
    School A     5
    Name: count, dtype: int64

    # Randomly select clusters (e.g., choose 1 out of 3 schools)
    np.random.seed(42)
    selected_clusters = np.random.choice(data['School'].unique(), 
                                         size=1, replace=False)

    # Select all individuals from the chosen clusters
    cluster_sample = data[data['School'].isin(selected_clusters)]

    # Display results
    print("\nSelected Cluster(s):", selected_clusters)

    Selected Cluster(s): ['School A']

    print("\nCluster Sample:")

    Cluster Sample:

    print(cluster_sample)

          Name    School
    0    Syifa  School A
    1   Nabila  School A
    2     Alya  School A
    3  Isnaini  School A
    4    Rizky  School A

#### R Code: Cluster Sampling

```r
library(dplyr)

# Sample dataset with 3 clusters (3 Schools)
data <- data.frame(
  Name = c("Syifa", "Nabila", "Alya", "Isnaini", "Rizky", "Alfayed", 
           "Whirdyana", "Olivia", "Nabila A", "Fika",
           "Luthfi", "Nabil", "Joans", "Riyadh", "Rachelia", 
           "Nova", "Zain", "Ragil", "Dadan", "Dwi", "Chello", "Siti"),
  School = c("School A", "School A", "School A", "School A", "School A", 
             "School B", "School B", "School B", "School B", "School B",
             "School B", "School C", "School C", "School C", "School C", 
             "School C", "School C", "School C", "School C", "School C", 
              "School C", "School C")
)

# Show original data distribution
cat("Original Data Distribution:\n")
```

    Original Data Distribution:

```r
print(table(data$School))
```

    School A School B School C 
           5        6       11 

```r
# Randomly select clusters (e.g., choose 1 out of 3 schools)
set.seed(42)
selected_clusters <- sample(unique(data$School), size = 1)

# Select all individuals from the chosen clusters
cluster_sample <- data %>% filter(School %in% selected_clusters)

# Display results
cat("\nSelected Cluster(s):", selected_clusters, "\n")
```

    Selected Cluster(s): School A 

```r
cat("\nCluster Sample:\n")
```

    Cluster Sample:

```r
print(cluster_sample)
```

         Name   School
    1   Syifa School A
    2  Nabila School A
    3    Alya School A
    4 Isnaini School A
    5   Rizky School A

## 3.2 Non-Probability Sampling

Non-probability sampling does not provide every individual with a known chance of selection, making it prone to bias but useful in exploratory research.

### 3.2.1 Convenience Sampling

Convenience Sampling is a non-probability sampling method where subjects are selected based on ease of access, availability, and proximity rather than randomness. It is commonly used in exploratory research, pilot studies, or situations where time and resources are limited.

Instead of carefully choosing a representative sample, researchers select participants who are easiest to reach—such as nearby students, colleagues, or online survey respondents.

#### Python Code: Convenience Sampling

    import pandas as pd

    # Example dataset of students 
    data = pd.DataFrame({
        'Student_ID': range(1, 21),
        'Name': ['Student_' + str(i) for i in range(1, 21)],
        'Location': ['Campus'] * 10 + ['Online'] * 10}) # 10 from campus, 10 online

    # Selecting the first 5 students available (e.g., from campus)
    convenience_sample = data.head(5)

    # Display selected sample
    print(convenience_sample)

       Student_ID       Name Location
    0           1  Student_1   Campus
    1           2  Student_2   Campus
    2           3  Student_3   Campus
    3           4  Student_4   Campus
    4           5  Student_5   Campus

#### R Code: Convenience Sampling

```r
# Create a sample dataset
data <- data.frame(
  Student_ID = 1:20,
  Name = paste("Student", 1:20, sep = "_"),
  Location = c(rep("Campus", 10), rep("Online", 10)) # 10 from campus, 10 online
)

# Selecting the first 5 students available (e.g., from campus)
convenience_sample <- data[1:5, ]

# Display selected sample
print(convenience_sample)
```

      Student_ID      Name Location
    1          1 Student_1   Campus
    2          2 Student_2   Campus
    3          3 Student_3   Campus
    4          4 Student_4   Campus
    5          5 Student_5   Campus

### 3.2.2 Quota Sampling

Quota Sampling is a non-probability sampling method where researchers divide the population into subgroups (quotas) based on specific characteristics (e.g., age, gender, occupation) and select participants non-randomly to meet a predefined quota for each subgroup.

Unlike stratified random sampling, where individuals are randomly selected within each subgroup, quota sampling allows researchers to handpick individuals within quotas based on convenience or judgment, which introduces potential bias.

#### Python Code: Quota Sampling

    import pandas as pd

    # Creating a dataset with 100 individuals (50 males, 50 females)
    data = pd.DataFrame({
        'ID': range(1, 101),
        'Name': ['Person_' + str(i) for i in range(1, 101)],
        'Gender': ['Male'] * 50 + ['Female'] * 50,
    })

    # Defining quotas: 5 males and 5 females
    quota_male = data[data['Gender'] == 'Male'].head(5)
    quota_female = data[data['Gender'] == 'Female'].head(5)

    # Combining quota-based sample
    quota_sample = pd.concat([quota_male, quota_female])

    # Displaying the selected sample
    print(quota_sample)

        ID       Name  Gender
    0    1   Person_1    Male
    1    2   Person_2    Male
    2    3   Person_3    Male
    3    4   Person_4    Male
    4    5   Person_5    Male
    50  51  Person_51  Female
    51  52  Person_52  Female
    52  53  Person_53  Female
    53  54  Person_54  Female
    54  55  Person_55  Female

#### R Code: Quota Sampling

```r
# Creating a dataset
data <- data.frame(
  ID = 1:100,
  Name = paste("Person", 1:100, sep = "_"),
  Gender = c(rep("Male", 50), rep("Female", 50))
)

# Defining quotas: 5 males and 5 females
quota_male <- head(subset(data, Gender == "Male"), 5)
quota_female <- head(subset(data, Gender == "Female"), 5)

# Combining quota-based sample
quota_sample <- rbind(quota_male, quota_female)

# Displaying the selected sample
print(quota_sample)
```

       ID      Name Gender
    1   1  Person_1   Male
    2   2  Person_2   Male
    3   3  Person_3   Male
    4   4  Person_4   Male
    5   5  Person_5   Male
    51 51 Person_51 Female
    52 52 Person_52 Female
    53 53 Person_53 Female
    54 54 Person_54 Female
    55 55 Person_55 Female

### 3.2.3 Judgmental Sampling

Researchers use their expertise to select the most relevant subjects. While it ensures focus, it introduces potential researcher bias.

#### Python Code: Judgmental Sampling

    import pandas as pd

    # Creating a dataset
    data = pd.DataFrame({
        'Name': ['Syifa', 'Nabila', 'Alya', 'Isnaini', 'Rizky', 
                 'Alfayed', 'Whirdyana', 'Olivia'],
        'Faculty': ['Science', 'Arts', 'Science', 'Business', 
                    'Science', 'Arts', 'Business', 'Arts'],
        'Experience (Years)': [5, 3, 10, 2, 7, 4, 8, 6]  # Experience in years
    })

    # Researcher selects only experienced Science faculty members (Judgement Sampling)
    selected_sample = data[(data['Faculty'] == 'Science') & 
                           (data['Experience (Years)'] > 5)]

    # Displaying selected individuals
    print(selected_sample)

        Name  Faculty  Experience (Years)
    2   Alya  Science                  10
    4  Rizky  Science                   7

#### R Code: Judgmental Sampling

```r
# Load necessary library
library(dplyr)

# Creating a dataset
data <- data.frame(
  Name = c("Syifa", "Nabila", "Alya", "Isnaini", "Rizky",
           "Alfayed", "Whirdyana", "Olivia"),
  Faculty = c("Science", "Arts", "Science", 
              "Business", "Science", "Arts", "Business", "Arts"),
  Experience_Years = c(5, 3, 10, 2, 7, 4, 8, 6)  # Experience in years
)

# Researcher selects only experienced Science faculty members
selected_sample <- data %>%
  filter(Faculty == "Science", Experience_Years > 5)

# Displaying selected individuals
print(selected_sample)
```

       Name Faculty Experience_Years
    1  Alya Science               10
    2 Rizky Science                7

### 3.2.4 Snowball Sampling

Snowball Sampling is a non-probability sampling method used to study hard-to-reach or hidden populations (e.g., drug users, undocumented immigrants, people with rare diseases).

Instead of selecting participants randomly, researchers start with a small group of known individuals (seeds), who then recruit others from their social networks, creating a “snowball” effect.

#### Python Code: Snowball Sampling

    import pandas as pd
    import random

    # Creating a dataset of 100 individuals
    data = pd.DataFrame({
        'ID': range(1, 101),
        'Name': ['Person_' + str(i) for i in range(1, 101)],
        'Group': ['Hidden Population'] * 100
    })

    # Start with 2 "seed" participants, 42 is just a common convention.
    initial_sample = data.sample(n=2, random_state=42) # Any number can be used 

    # Snowball effect: Each seed recruits 2 more participants
    snowball_sample = initial_sample.copy()
    for _ in range(3):  # Repeat recruitment process
        new_recruits = data.sample(n=len(snowball_sample) * 2, 
        random_state=random.randint(1, 100))
        snowball_sample = pd.concat([snowball_sample, 
        new_recruits]).drop_duplicates()

    # Displaying the selected sample
    print(snowball_sample.head())

        ID       Name              Group
    83  84  Person_84  Hidden Population
    53  54  Person_54  Hidden Population
    5    6   Person_6  Hidden Population
    93  94  Person_94  Hidden Population
    41  42  Person_42  Hidden Population

#### R Code: Snowball Sampling

```r
# Load necessary library
library(dplyr)

# Creating a dataset
data <- data.frame(
  ID = 1:100,
  Name = paste("Person", 1:100, sep = "_"),
  Group = rep("Hidden Population", 100)
)

# Start with 2 "seed" participants
set.seed(42)
initial_sample <- sample_n(data, 2)

# Snowball effect: Each seed recruits 2 more participants
snowball_sample <- initial_sample
for (i in 1:3) {  # Repeat recruitment process
  new_recruits <- sample_n(data, nrow(snowball_sample) * 2)
  snowball_sample <- distinct(bind_rows(snowball_sample, new_recruits))
}

# Displaying the selected sample
print(head(snowball_sample))
```

      ID      Name             Group
    1 49 Person_49 Hidden Population
    2 65 Person_65 Hidden Population
    3 25 Person_25 Hidden Population
    4 74 Person_74 Hidden Population
    5 18 Person_18 Hidden Population
    6 47 Person_47 Hidden Population

## 3.3 Hybrid Sampling

In some research scenarios, Probability Sampling (random selection) and Non-Probability Sampling (subjective selection) can be combined to balance representation and practicality, it is called as a **Hybrid Sampling**.

### 3.3.1 Python Code: Hybrid Sampling

Here, we randomly select faculties (Probability Sampling), then select experienced members within each faculty (Judgement Sampling).

    import pandas as pd
    import random

    # Creating a dataset
    data = pd.DataFrame({
        'Name': ['Syifa', 'Nabila', 'Alya', 'Isnaini', 'Rizky', 
                 'Alfayed', 'Whirdyana', 'Olivia', 'Nabil', 'Joans'],
        'Faculty': ['Science', 'Arts', 'Science', 'Business', 'Science',
                    'Arts', 'Business', 'Arts', 'Science', 'Business'],
        'Experience (Years)': [5, 3, 10, 2, 7, 4, 8, 6, 12, 9]
    })

    # 1️⃣ Probability Sampling: Randomly select 2 faculties
    random_faculties = random.sample(list(data['Faculty'].unique()), 2)

    # 2️⃣ Non-Probability Sampling: Select experienced individuals from chosen faculties
    hybrid_sample = data[(data['Faculty'].isin(random_faculties)) & 
                         (data['Experience (Years)'] > 5)]

    # Display results
    print(hybrid_sample)

            Name   Faculty  Experience (Years)
    6  Whirdyana  Business                   8
    7     Olivia      Arts                   6
    9      Joans  Business                   9

### 3.3.2 R Code: Hybrid Sampling

We randomly select faculties (Probability Sampling) and then apply Judgment Sampling for experienced individuals.

```r
# Load necessary library
library(dplyr)

# Creating a dataset
data <- data.frame(
  Name = c("Syifa", "Nabila", "Alya", "Isnaini", "Rizky", "Alfayed",
           "Whirdyana", "Olivia", "Nabil", "Joans"),
  Faculty = c("Science", "Arts", "Science", "Business", 
              "Science", "Arts", "Business", "Arts", "Science", "Business"),
  Experience_Years = c(5, 3, 10, 2, 7, 4, 8, 6, 12, 9)
)

# 1️⃣ Probability Sampling: Randomly select 2 faculties
set.seed(42)
random_faculties <- sample(unique(data$Faculty), 2)

# 2️⃣ Non-Probability Sampling: Select experienced individuals from chosen faculties
hybrid_sample <- data %>%
  filter(Faculty %in% random_faculties, Experience_Years > 5)

# Display results
print(hybrid_sample)
```

           Name  Faculty Experience_Years
    1      Alya  Science               10
    2     Rizky  Science                7
    3 Whirdyana Business                8
    4     Nabil  Science               12
    5     Joans Business                9

## 3.4 Strengths & Limitations

The following table compares different sampling methods based on their strengths and limitations:

| Sampling Method | Category | Strengths | Limitations |
|----|----|----|----|
| Simple Random Sampling | Probability | Unbiased, easy to implement | Requires full population list |
| Stratified Sampling | Probability | Ensures subgroup representation | Complex and time-consuming |
| Cluster Sampling | Probability | Cost-effective for large populations | Risk of sampling error |
| Systematic Sampling | Probability | More efficient than SRS | Can introduce bias if patterns exist |
| Convenience Sampling | Non-Probability | Quick and inexpensive | High risk of bias |
| Quota Sampling | Non-Probability | Ensures subgroup representation | Non-random selection introduces bias |
| Snowball Sampling | Non-Probability | Useful for niche populations | Limited generalizability |
| Judgmental Sampling | Non-Probability | Focused and expert-driven | Subject to researcher bias |

## 3.5 Real-World Applications

- **Market Research:** Stratified sampling ensures different demographics are represented in surveys.
- **Medical Studies:** Random sampling helps in clinical trials to obtain unbiased results.
- **Social Sciences:** Snowball sampling is used for studying hidden populations like drug users or marginalized groups.
- **Business Analytics:** Convenience sampling is commonly used in quick customer feedback surveys.

Understanding and choosing the appropriate sampling method is crucial for obtaining valid and reliable research outcomes.
