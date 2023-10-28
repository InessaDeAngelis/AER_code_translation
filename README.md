# American Economic Review Code Translation

## Overview & Objectives
This repo contains the publicly available replication materials from the August 2023, September 2023, and October 2023 Issues of the American Economic Review (omitted articles are noted below). 

The goal of this project is to figure out if there are errors in the STATA code by translating the replication code provided into Python and then comparing the human translated code to the same code translated by LLMs. We want to find out if we need to translate code, like we translate languages and how LLMs can help us with this translation process. Furthermore, in some languages there is a specific word that encompasses a whole set of feelings/actions which cannot be directly translated into English - there are a number of Japanese words like this and the word “hygge” from Danish is another example. Is this same inability to directly translate words the case with code and LLMs?

## Repo Structure
The repo is organized by journal issue, with all the August 2023 materials located in the `2023-08_Issue` folder, September 2023 materials located in the `2023-09_Issue` folder, and the October 2023 materials located in the `2023-10_Issue` folder.

`2023-08_Issue` contains the following articles and materials located in their own sub-folder: 

  - [Does Identity Affect Labor Supply?](https://www.aeaweb.org/articles?id=10.1257/aer.20211826)
  
  - [The Micro Anatomy of Macro Consumption Adjustments](https://www.aeaweb.org/articles?id=10.1257/aer.20201931)
  
  - [The Missing Intercept: A Demand Equivalence Approach](https://www.aeaweb.org/articles?id=10.1257/aer.20211751)
  
  - ~~[The Reversal Interest Rate](https://www.aeaweb.org/articles?id=10.1257/aer.20190150)~~ (Hold for now - uses solely MatLab)
  
   - ~~[Individuals and Organizations as Sources of State Effectiveness](https://www.aeaweb.org/articles?id=10.1257/aer.20191598)~~ (Hold for now - uses solely R)
  
  - ~~[The Political Economy of International Regulatory Cooperation](https://www.aeaweb.org/articles?id=10.1257/aer.20200780)~~ (no replication package)
  
  - ~~[Who Benefits from State Corporate Tax Cuts? A Local Labor Markets Approach with Heterogeneous Firms: Comment](https://www.aeaweb.org/articles?id=10.1257/aer.20201753)~~ (replication of a 2014 paper)

`2023-09_Issue` contains the following articles and materials located in their own sub-folder: 

  - [Worth Your Weight: Experimental Evidence on the Benefits of Obesity in Low-Income Countries](https://www.aeaweb.org/articles?id=10.1257/aer.20211879) (request data from DHS)

  - [Imperfect Financial Markets and Investment Inefficiencies](https://www.aeaweb.org/articles?id=10.1257/aer.20170725)
  
  - [A Road to Efficiency through Communication and Commitment](https://www.aeaweb.org/articles?id=10.1257/aer.20171014)
  
  - [Second-Best Fairness: The Trade-off between False Positives and False Negatives](https://www.aeaweb.org/articles?id=10.1257/aer.20211015)
  
  - ~~[Market Structure, Oligopsony Power, and Productivity](https://www.aeaweb.org/articles?id=10.1257/aer.20210383)~~ (data access issues)
  
  - ~~[The Macroeconomics of the Greek Depression](https://www.aeaweb.org/articles?id=10.1257/aer.20210864)~~ (republication package unavailable)

`2023-10_Issue` contains the following articles and materials located in their own sub-folder: 

  - [The Economic Origins of Government](https://www.aeaweb.org/articles?id=10.1257/aer.20201919) (request data from authors)
  
  - [Intrinsic Information Preferences and Skewness](https://www.aeaweb.org/articles?id=10.1257/aer.20171474)
  
  - [A Signal to End Child Marriage: Theory and Experimental Evidence from Bangladesh](https://www.aeaweb.org/articles?id=10.1257/aer.20220720) (request data from DHS)
  
  - ~~[Matching Mechanisms for Refugee Resettlement](https://www.aeaweb.org/articles?id=10.1257/aer.20210096)~~ (republication package unavailable)
  
  - ~~[Profits, Scale Economies, and the Gains from Trade and Industrial Policy](https://www.aeaweb.org/articles?id=10.1257/aer.20210419)~~ (data access issues)
  
  - ~~[The Behavioral Foundations of Default Effects: Theory and Evidence from Medicare Part D](https://www.aeaweb.org/articles?id=10.1257/aer.20210013)~~ (data access issues)

## Instructions
Please translate the STATA code into Python using the LLMs as much as possible. Then, clearly label the translated code documents with your name and add the file into the `Translated code` folder within each article folder. Throughout the process, take notes about which aspects of the translation the LLMs did well and poorly and identify issues you discovered and fixed during the translation process. 

### Detailed Instructions & Prompts
First, ask ChatGPT3.5, the following prompt: *"the following code is Stata, can you identify errors"*. If there is too much code, break it into chunks and ask the LLM about one chunk at a time. 

Second, copy the code and comments outputted by the LLM and paste them into a labelled text (.txt) file. Please note in the text file the recommendations and errors identified. Name this file using the following structure: "original_code_notes_yourinitials" (example: original_code_notes_IDA.txt). Upload this file into the `Translated_code` folder within each article folder.

Third, ask ChatGPT, the following prompt: *"can you translate this code into Python"*. Copy the outputted code and create a script (.py file). Name this file using the following structure: "translated_code_yourinitials" (example: translated_code_IDA.py). Then, upload the script into the `Translated_code` folder within each article folder. 

Fourth, create a second script (.py file) and using the Python code outputted by ChatGPT, go through and manually run the code, edit, and fix it. Take detailed notes (as a .txt file) on your process, errors you identity, and anything else of note (such as dropped variables, inconsistencies, etc). 

Name the code file using the following structure: "fixed_code_yourinitials" (example: fixed_code_IDA.py) and the text file: "fixed_code_notes_yourinitials" (example: fixed_code_IDA.txt). When completed, upload this script and your notes file into the `Translated_code` folder within each article folder. 

It is very important to save all notes as .txt files (no Word documents) and code as .py files. And please follow the naming structure outlined for each file. 
