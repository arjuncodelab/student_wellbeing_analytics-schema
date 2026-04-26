## Student Wellbeing & Digital Behavior Analysis
### Project Goal:
In an era of increasing digital consumption, how does "Doom-Scrolling" affect the academic success of students globally?
I designed a relational database to audit 50,000+ student records, identifying the tipping poiny ehrtr digial addiction leads to acdemic failure.

### The Architecture:
##### - Normalization: 01_schema_design.sql
Transformed a flat 'Mixed' dataset into a relational schema (Students, Countries, Academics, Mental Health, Financial Behaviour).
##### - Data Integrity: 02_data_etl.sql
Implemented strict CHECK constraints and Foreign key relationships to ensure zero data leakage.
##### - The Insights: 03_queries_used_for_analytical_insights
-- Q1 Wellbeing Tipping point
Goal: Identify if there is a 'cliff' where internet usage destroys wellbeing.
Insight: 7 hours a day is the cliff where internet_usage actually destroying wellbeing while 3 hours a day internet usage show highest quality of wellbeing.
-- Q2 Brain Rot Productive Tax
Goal: Do students with above average 'Brain Rot' scores actually perform worse?
Insight: Yes, above average 'Brain Rot' (26.14) have average productivity of 8.2 while students who have Brain Rot below average (11.75) have average porductivity of 9.43.
