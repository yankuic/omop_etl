# OMOP Data Guide for Researchers

## Death

The death table contains the death date for each patient that is known to be deceased. Data is collected from both the Epic Electronic Health Record, or EHR, system and Social Security Death Index. If death dates differ across the two sources, the death date as recorded in the Epic EHR is used.

## Measurement

The Measurement table contains records of measurements collected during patient-health care provider interactions in inpatient and outpatient contexts. The Measurement table include records from orders and results for blood pressure, cardiac function indicators, lung function indicators, pain scores, Rothman score, and vital signs.

Note that some diagnoses and procedures are classified as measurements in the OMOP vocabulary, so they will appear in this measurement table.

### Blood pressure (BP)

BP measures include invasive (e.g. arterial line, central venous) and non-invasive methods (e.g. Cuff and automatic). BP values are reported in mmHg.

The following BP measures are included:

- Systolic blood pressure
  
  When the method is known, it is mapped to invasive systolic blood pressure (concept id 21490853) or non-invasive systolic arterial pressure (concept id 4354252). If the method is unknown it is mapped as blood pressure (concept id 4326744).

- Diastolic blood pressure

  When the method is known, it is mapped to invasive diastolic blood pressure (concept id 21490851) or non-invasive diastolic arterial pressure (concept id 4068414). If the method is unknown it is mapped as blood pressure (concept id 4326744).

- Central Venous Pressure (CVP)

- Mean Arterial Pressure (MAP)

  - Invasive mean blood pressure (Concept ID: 21490852):
    - MAP Arterial line
    - MAP Pulmonary artery
    - MAP CVP

  - Non-invasive mean blood pressure (Concept ID: 21492241)
    - MAP Cuff
    - MAP Non-invasive. Include automatic and manual methods.

### Heart rate

Heart rate is reported in Beats per minute.

### Height

## Data Validation

- What is data quality?

- Data Quality Check?

  - Statistic
  - Decision threshold - pass/fail rule.

- Representation of the true state of a patient.
- Is UFH data well represented in OMOP?

Data quality dimensions

- Completeness
- Plausibility
- Conformance

Biang et al.

Completeness. How are we ensuring to include and describing the data elements that are in our extracts? (e.g., data guide)

Correctness/accuracy. How are we assessing truth? This can be more philosophical with multiple right answers, but important that we are consistent in our approach. In IDR, we tend to say that the data are correct if researchers get the same values as went into the EHR (regardless of whether they represent a patient’s actual state or experience).

Plausibility. This is one that we talk about a lot, especially when clinical folks, like Gigi, Ben, look at data. Plausibility focuses on actual values as a representation of a real-world object or conceptual construct by examining the distribution and density of values or by comparing multiple values that have an expected relationship to each other. Kahn et al (2016)
