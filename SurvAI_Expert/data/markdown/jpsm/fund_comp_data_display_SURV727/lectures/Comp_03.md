---
id: "jpsm/fund_comp_data_display_SURV727/lectures/Comp_03"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lecture"
title: "R Markdown"
original: "fund_comp_data_display_SURV727/lectures/Comp_03.pdf"
pages: 26
sha256: "ef9833f7f2a94bf8cdf4fc8c4881e775da8a363f1c073e49e4395aa88508ed8b"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:56"
---

<!-- page 1 -->

# R Markdown
## Fundamentals of Computing and Data Display

Christoph Kern    Ruben Bach

(c.kern, r.bach)@uni-mannheim.de

<!-- page 2 -->

# Outline

1. Introduction
2. Markdown
    - R Markdown
    - Pandoc
3. $\LaTeX$
4. Resources
5. References

Fundamentals of Computing and Data Display | R Markdown | 2 / 26

<!-- page 3 -->

# Introduction

A non-reproducible workflow$^1$

1. Conduct analysis in statistical package
2. Copy-and-paste results to a word processor
3. Update data or change pre-processing code
4. Start all over again

$\rightarrow$ Separation of analysis and presentation of results

* Prone to errors
* Selective presentation of findings
* Results are **not readily reproducible**

---
$^1$`https://www.youtube.com/watch?time_continue=2&v=s3JldKoA0zw`

<!-- page 4 -->

# Introduction

*“By reproducible research, we mean research papers with accompanying software tools that allow the reader to directly reproduce the results and employ the methods that are presented in the research paper”* (Gentleman and Lang 2007)

Workflow Components$^2$

* Transparency (e.g., by using dynamic documents)
* Reproducibility (e.g., by using dynamic documents)
* Efficiency (a good workflow saves you time, by automating as much of the process as possible)
* Maintainability (standardized script names, good commenting practices, README files)
* Modularity (discrete tasks into separate components (e.g. scripts))
* Portability (e.g., by using relative (not absolute) pathnames)

---
$^2$`http://blog.revolutionanalytics.com/2010/10/a-workflow-for-r.html`

Fundamentals of Computing and Data Display  
R Markdown

<!-- page 5 -->

Introduction

# Introduction

$\rightarrow$ Knitting source code together with presentation of results into **dynamic reproducible documents**

Some (additional) benefits...

- Avoids effort duplication
- Enables to easily update code
- Results are clearly linked to source
- Streamlines collaboration in teams
- Automates recurring tasks
- ...

Fundamentals of Computing and Data Display R Markdown 5 / 26

<!-- page 6 -->

Markdown

# Markdown

1. Introduction
2. Markdown
    - R Markdown
    - Pandoc
3. $\text{\LaTeX}$
4. Resources
5. References

Fundamentals of Computing and Data Display | R Markdown | 6 / 26

<!-- page 7 -->

# Markdown

A lightweight markup language

* Plain text format for writing structured documents
* Easy-to-write and easy-to-read
* Originally supported only .html as output
  * Syntax description and a Perl script for converting Markdown to HTML
* Many implementations and extensions available

`https://spec.commonmark.org/`

<!-- page 8 -->

Markdown | R Markdown

# R Markdown

**Markdown + R code**

* An authoring framework for data science
* (Pre-)installed and loaded by RStudio if needed
  * Heavily integrated into the RStudio IDE
* Implements an extension of the original markdown syntax
* Bundles other packages for extensive functionality
  * knitr, e.g. .Rmd $\rightarrow$ .md
  * pandoc, e.g. .md $\rightarrow$ .html

rmarkdown

`https://rmarkdown.rstudio.com/`

Fundamentals of Computing and Data Display | R Markdown | 8 / 26

<!-- page 9 -->

Markdown R Markdown

# R Markdown

Figure: `rmarkdown::render("example.Rmd")`$^3$

Rmd $\rightarrow$ knitr $\rightarrow$ md $\rightarrow$ pandoc $\rightarrow$

---
$^3$Wickham and Grolemund (2017)

Fundamentals of Computing and Data Display R Markdown 9 / 26

*[Figure: The page displays a horizontal workflow diagram with no axes, titled `rmarkdown::render("example.Rmd")`, illustrating the sequential document rendering process. Using rightward arrows, it shows a linear pattern where an "Rmd" file is processed by "knitr" into an "md" file, which is then converted by "pandoc" into a group of final output documents.]*

<!-- page 10 -->

Markdown | R Markdown

# Text formatting

Pandoc's Markdown$^4$

```markdown
<!-- Text formatting -->
*italic* or _italic_
**bold** __bold__
`code`
superscript^2^ and subscript~2~
~~strikethrough~~
LaTeX equations inside $ $ or $$ $$

<!-- Headings -->
# 1st Level Header
## 2nd Level Header
### 3rd Level Header
```

---
$^4$`http://pandoc.org/MANUAL.html#pandocs-markdown`

Fundamentals of Computing and Data Display | R Markdown | 10 / 26

<!-- page 11 -->

Markdown R Markdown

# Text formatting

```markdown
<!-- Lists -->
1. the first item
2. the second item
    - one unordered item

<!-- Links and images -->
<http://example.com>
[linked phrase](http://example.com)
![optional caption text](path/to/img.png)

<!-- Tables -->
First Header | Second Header
------------ | -------------
Content Cell | Content Cell
Content Cell | Content Cell
```

Fundamentals of Computing and Data Display R Markdown 11 / 26

<!-- page 12 -->

# Code chunks

````
```{r, options}
code
```
````

- Include R code via (self-contained) chunks
  - Embed code in text with `` `r ` ``
  - Other language engines
    - `names(knitr::knit_engines$get())`
- Chunks can be named with ```` ```{r name} ````
- Control chunk output with options
  - Set locally in chunk header
  - Set globally with `knitr::opts_chunk$set()`
  - `https://yihui.name/knitr/options/`
- Enable caching with `cache = TRUE`

<!-- page 13 -->

# Code chunks

Table: Controlling output with chunk options$^5$

| Option | Run code | Show code | Output | Plots | Messages | Warnings |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| `eval = FALSE` | – | | – | – | – | – |
| `include = FALSE` | | – | – | – | – | – |
| `echo = FALSE` | | – | | | | |
| `results = "hide"` | | | – | | | |
| `fig.show = "hide"` | | | | – | | |
| `message = FALSE` | | | | | – | |
| `warning = FALSE` | | | | | | – |

---
$^5$Wickham and Grolemund (2017)

<!-- page 14 -->

Markdown | R Markdown

# YAML header

```yaml
---
title: "Yet Another Markup Language"
output: html_document
---
```

* Specify metadata with `YAML syntax`
  * A set of tag-value pairs
  * Structured with indentation
* Set basic **document information** (title, author, date, ...)
  * `http://pandoc.org/MANUAL.html#variables-set-by-pandoc`
* Declare **parameters** with `params` field
  * Accessible with `params$name` in code chunks
* Set the default **output format**

Fundamentals of Computing and Data Display | R Markdown | 14 / 26

<!-- page 15 -->

# YAML header

Table: Output formats$^6$

| Output value | creates |
| :--- | :--- |
| `html_notebook` | R Notebook |
| `html_document` | HTML |
| `pdf_document` | PDF |
| `word_document` | Microsoft Word |
| `odt_document` | OpenDocument Text |
| `rtf_document` | Rich Text Format |
| `md_document` | Markdown |
| `ioslides_presentation` | ioslides HTML slides |
| `slidy_presentation` | slidy HTML slides |
| `beamer_presentation` | Beamer pdf slides |
| ... | ... |

---
$^6$`https://rmarkdown.rstudio.com/formats.html`

<!-- page 16 -->

# YAML header

Output options

* Each output format is associated with a set of options
* For `html_document`, see `?rmarkdown::html_document`
  * `toc`
  * `highlight`
  * `df_print`
  * `theme`
  * ...
* `pdf_document`
  * `toc`
  * `keep_tex`
  * ...

<!-- page 17 -->

Markdown R Markdown

# Citations

1. Set bibliography file in YAML header
   - Various formats supported, e.g. BibTeX, endnote, ...
   - Control style with a CSL file (optional)
   - Alternative: Use inline references with YAML's `references` field

```yaml
---
bibliography: refs.bib
csl: style.csl
---
```

2. Use citation keys in text

```markdown
Smith cited [@smith04].
Smith cited without author [-@smith04].
@smith04 cited in line.
```

3. Render

Fundamentals of Computing and Data Display R Markdown 17 / 26

<!-- page 18 -->

# More formats, templates, themes

* bookdown
  * `http://www.bookdown.org`
* prettydoc
  * `https://github.com/yixuan/prettydoc/`
* rticles
  * `https://github.com/rstudio/rticles`
* rmdformats
  * `https://github.com/juba/rmdformats`

<!-- page 19 -->

Markdown Pandoc

# Pandoc

`https://pandoc.org/`

- Converter used by `rmarkdown` to create output file
- Can be run on its own from your OS's terminal
- Numerous markup and document formats supported

```
# Pandoc examples
pandoc -s -o output.html input.txt
pandoc -f markdown -t latex file.txt
pandoc -f html -t markdown hello.html
```

Fundamentals of Computing and Data Display R Markdown 19 / 26

<!-- page 20 -->

# $\text{\LaTeX}$

1. Introduction
2. Markdown
   - R Markdown
   - Pandoc
3. **$\text{\LaTeX}$**
4. Resources
5. References

---
Fundamentals of Computing and Data Display | R Markdown | 20 / 26

<!-- page 21 -->

$\LaTeX$

# $\LaTeX$

- $\LaTeX$ is a markup language (like Markdown, HTML, ...)
- Allows to create high-quality documents
- Takes some time to learn
- The typical workflow
  1. Create $\LaTeX$ source code file (`.tex`)
  2. Compile it via $\LaTeX$ or pdf$\LaTeX$
  3. Use a viewer (PDF, DVI) to view the compiled file
- Needs a installed $\LaTeX$-distribution (e.g. Mik$\TeX$, $\TeX$ Live, TinyTeX)
  - Also needed to generate **PDF output from a .Rmd file**

Fundamentals of Computing and Data Display | R Markdown | 21 / 26

<!-- page 22 -->

# $\text{\LaTeX}$ example

```latex
% Preamble
\documentclass[11pt, a4paper]{scrartcl}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[english]{babel}

\title{Title}
\author{Author}

% Body
\begin{document}

\maketitle

\section{Heading}

A \LaTeX{} example document.

\begin{equation}
\mathcal{T}(x; \Theta) = \sum_{m=1}^{M} \gamma_m I{(x \in \tau_m)}.
\end{equation}

\end{document}
```

Fundamentals of Computing and Data Display | R Markdown | 22 / 26

<!-- page 23 -->

$\text{\LaTeX}$

# $\text{\LaTeX}$ example

## Assignment 1

**TST-101 – Test course**

**The name**

**July 22, 2018**

---
Fundamentals of Computing and Data Display | R Markdown | 23 / 26

<!-- page 24 -->

LaTeX

# Sweave

*"Sweave is a tool that allows to embed the R code for complete data analyses in latex documents. The purpose is to create dynamic reports, which can be updated automatically if data or analysis change."*$^7$

**R + LaTeX**

1. Create a file.Rnw
2. Use LaTeX as in .tex files
3. Include R code chunks
```r
<>=
R-code
@
```
4. Create .tex and PDF with `Sweave(‘file.Rnw’)`
    * `help("Sweave", package = "utils")`

---
$^7$`https://leisch.userweb.mwn.de/Sweave/`

Fundamentals of Computing and Data Display | R Markdown | 24 / 26

<!-- page 25 -->

# Resources

* R Markdown template paper
  * Bauer, P. C. (2018). Writing a Reproducible Paper in R Markdown. `http://dx.doi.org/10.2139/ssrn.3175518`
* R Task View
  * `https://cran.r-project.org/web/views/ReproducibleResearch.html`
* GitHub Pages
  * `https://pages.github.com/`
* Cheatsheets
  * `https://github.com/rstudio/cheatsheets/raw/master/rmarkdown-2.0.pdf`
  * `https://www.rstudio.com/wp-content/uploads/2015/03/rmarkdown-reference.pdf`

<!-- page 26 -->

# References

Gandrud, C. (2015). *Reproducible Research With R and R Studio*. Boca Raton, FL: Chapman & Hall/CRC Press.

Gentleman, R. and Lang, D. (2007). Statistical Analyses and Reproducible Research. *Journal of Computational and Graphical Statistics* 16(1), 1–23.

Wickham, H. and Grolemund, G. (2017). *R for Data Science*. Sebastopol, CA: O’Reilly.

Xie, Y., Allaire, J.J., Grolemund, G. (2018). *R Markdown: The Definitive Guide*. Boca Raton, FL: Chapman & Hall/CRC.

Xie, Y. (2016). *bookdown: Authoring Books and Technical Documents with R Markdown*. Boca Raton, FL: Chapman & Hall/CRC.

Xie, Y. (2015). *Dynamic Documents with R and knitr*. Boca Raton, FL: Chapman & Hall/CRC.
