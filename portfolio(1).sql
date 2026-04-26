-- Q1 Wellbeing Tipping point
-- Goal: Identify if there is a 'cliff' where internet usage destroys wellbeing.
WITH q AS (
    SELECT
    student_id,
    internet_access_hours,
    wellbeing_index,
    PERCENT_RANK() OVER(ORDER BY internet_access_hours) AS 'percentile_rank'
    FROM students
)
SELECT
 CASE
  WHEN percentile_rank <= 0.25 THEN 'Low'
  WHEN percentile_rank <= 0.50 THEN 'Mid'
  WHEN percentile_rank <= 0.75 THEN 'High'
  WHEN percentile_rank <= 1.0 THEN 'Max'
  END as 'Quartile',
  ROUND(AVG(wellbeing_index),2) AS avg_wellbeing,
  ROUND(AVG(internet_access_hours),2) as avg_internet_access_hour
  FROM q
  GROUP BY Quartile
  ORDER BY avg_internet_access_hour DESC, avg_wellbeing DESC
;
-- Q2 Brain Rot Productive Tax
-- Goal: Do students with above average 'Brain Rot' scores actually perform worse?
WITH students_filtered AS (
  SELECT student_id, brain_rot_index, productivity_score, class_attendance_rate
  FROM students
  WHERE brain_rot_index IS NOT NULL
    AND class_attendance_rate > 80
),
avg_brain AS (
  SELECT AVG(brain_rot_index) AS avg_brain_rot
  FROM students_filtered
)
SELECT
  CASE WHEN s.brain_rot_index > a.avg_brain_rot THEN 'above_avg_brain_rot'
  ELSE "below_or_equal_avg_brain_rot"
  END AS brain_rot_group,
  ROUND(AVG(s.productivity_score),2) AS avg_productivity,
  ROUND(AVG(s.brain_rot_index), 2) as avg_brain_rot,
  MAX(s.brain_rot_index) as max_brain_rot,
  MIN(s.brain_rot_index) as min_brain_rot
FROM students_filtered s
CROSS JOIN avg_brain a
GROUP BY brain_rot_group;

-- Q3 Behavioral Spending
-- Goal: Is ads_clickeding a stronger driver of spending than family income?
SELECT
 family_income_level,
 CASE
  WHEN ads_clicked_per_week > 10 THEN 'High'
  WHEN ads_clicked_per_week > 3 THEN 'Moderate'
 ELSE 'Low'
 END AS ad_engagement,
 ROUND(AVG(ads_clicked_per_week),2) AS avg_ads_click_per_week,
 ROUND(AVG(digital_spending_per_month),2) AS avg_digital_spending_per_month,
 ROUND(AVG(impulse_purchase_score), 2) AS avg_impulse_score
from students group by family_income_level, ad_engagement
ORDER BY avg_ads_click_per_week DESC, avg_digital_spending_per_month DESC;

---- Q4 Infrastructure ROI
-- Goal: Does better internet speed actually result in higher academic motivation?
WITH stats AS (
    SELECT
    CASE
       WHEN AVG(s.academic_motivation) < s.academic_motivation THEN 'High_performing_students'
       WHEN AVG(s.academic_motivation) > s.academic_motivation THEN 'Low_performing_students'
    ELSE 'moderate_performing_students'
    END as 'performance',
    c.internet_infrastructure_index,
    ROUND(AVG(s.academic_motivation),2) AS counrty_avg_academic_motivation,
    COUNT(*) AS sample_size
    FROM students s
    JOIN countries c ON s.country_id = c.country_id
    GROUP BY c.country_id
)
SELECT
 internet_infrastructure_index,
 performance,
 counrty_avg_academic_motivation,
 sample_size
FROM stats
WHERE internet_infrastructure_index > 40
ORDER BY internet_infrastructure_index DESC, performance;

-- Q5 Doom Scrolling By Major
-- Goal: Which fields of study are most "addicted" to short-form content?
SELECT
 field_of_study,
 ROUND(AVG(short_video_hours) / NULLIF(AVG(internet_access_hours),0), 2) as 'doom_scorll'
 FROM students
 WHERE field_of_study != 'None' AND field_of_study IS NOT NULL
 GROUP BY field_of_study
 ORDER BY doom_scorll DESC;
-- although sum have different values, by slight margin, avg and doom_scroll have excat value(0.29) across all field, is there an issue in query?

-- Q6 Multi_factor Academic_risk.
-- Goal: Identify the volume of studnets meeting the 'Triple Threat"
-- Criteria: High Late Night usage, Low attendance and High Anxiety.
SELECT
    CASE
        WHEN late_night_score >= 3 AND class_attendance_rate < 70 AND anxiety_score > 7 THEN 'High_Risk'
        ELSE 'Standard_Risk'
        END as 'Risk_assesment',
        ROUND(AVG(anxiety_score),2) AS avg_anxiety,
        Count(*) AS student_count
        FROM students
        WHERE anxiety_score IS NOT NULL OR
         class_attendance_rate IS NOT NULL OR
         late_night_score IS NOT NULL
        GROUP BY Risk_assesment;

-- Q7 Economic_resilience
-- Goal: Compare how family income affects wellbeing across different country development levels.
WITH wellbeing_status AS(
    SELECT
     s.wellbeing_index,
     c.development_level,
     s.family_income_level
    FROM students s
    JOIN countries c ON s.country_id = c.country_id
    WHERE
    s.family_income_level IS NOT NULL
)
SELECT
 development_level, family_income_level,
 CASE
  WHEN family_income_level = 'High' THEN wellbeing_index
  WHEN family_income_level = 'Low' THEN wellbeing_index
  WHEN family_income_level = 'Middle' THEN wellbeing_index
  END AS  'Economic_resilience',
  ROUND(AVG(wellbeing_index),2) AS 'avg_wellbeing',
  COUNT(*) AS 'sample_size'
FROM wellbeing_status
GROUP BY development_level,family_income_level
ORDER BY development_level;

-- Q8 Device Access Parity
-- Goal: Measure the Academic Risk differene between students
SELECT device_access,
 ROUND(AVG(academic_risk_score),2) as 'Risk_assessment',
 ROUND(AVG(productivity_score), 2) as 'avg_productiviy'
  FROM students
  GROUP BY device_access;
-- Q9 Digital Addiction Recovery, The Gold Standard Student
-- Goal: What percentage of students successfully balance high study and low social media?
SELECT 
 COUNT(CASE WHEN s.social_media_hours < 2 AND s.study_hours_per_week > 10 THEN 1 END) * 100/
 COUNT(*)
 AS 'Gold_Standard_Attention_PCT',
 ROUND(AVG(s.attention_span_minutes),2) AS 'global_avg_attention_span',
 ROUND(AVG(CASE WHEN s.social_media_hours < 2 AND s.study_hours_per_week > 10 THEN s.attention_span_minutes END),2)
 AS "golden_standard_avg_attention_span"
FROM students s
;
