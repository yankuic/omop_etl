# OMOP Data Guide for Researchers

## Death

The death table contains the death date for each patient that is known to be deceased. Data is collected from both the Epic Electronic Health Record, or EHR, system and Social Security Death Index. If death dates differ across the two sources, the death date as recorded in the Epic EHR is used.

## Measurement

The Measurement table contains records of measurements collected during patient-health care provider interactions in inpatient and outpatient contexts. The Measurement table include records from orders and results for blood pressure, cardiac function indicators, lung function indicators, pain scores, Rothman score, and vital signs.

Note that some diagnoses and procedures are classified as measurements in the OMOP vocabulary, so they will appear in this measurement table.

### Blood pressure (BP)

BP measures include invasive (e.g. arterial line, central venous) and non-invasive methods (e.g. Cuff and automatic). BP values are reported in mmHg.

Manual input and automatic input.

The following BP measures are included:

- Systolic blood pressure
  
  When the method is known, it is mapped to invasive systolic blood pressure (concept id 21490853) or non-invasive systolic arterial pressure (concept id 4354252). If the method is unknown it is mapped as blood pressure (concept id 4326744).

- Diastolic blood pressure

  When the method is known, it is mapped to invasive diastolic blood pressure (concept id 21490851) or non-invasive diastolic arterial pressure (concept id 4068414). If the method is unknown it is mapped as blood pressure (concept id 4326744).

BP - mixed, there are inconsistency in which methods are included here.
BP non-invasive

### Mean Arterial Line measures

- Central Venous Pressure (CVP)

- Mean Arterial Pressure (MAP)

  - Invasive mean blood pressure (Concept ID: 21490852):
    - MAP Arterial line
    - MAP Pulmonary artery
    - MAP CVP

  - Non-invasive mean blood pressure (Concept ID: 21492241)
    - MAP Cuff
    - MAP Non-invasive. Include automatic and manual methods.

Arterial line (invasive)
MAP methods

### Mechanical ventilator measures

Ventilator settings and readings describing the amount of support, provided in the form of ventilation and oxygenation, delivered to the patient.

- Ventilator mode. This setting control how the ventilator assist a patient with inspiration (air/oxygen supply). Possible values include:
  - Assist/Control (A/C)
  - Controlled Mandatory Ventilation (AC/VC+)
  - Synchronized controlled mandatory ventilation ((S)CMV)
  - Synchronous Intermittent Mandatory Ventilation (SIMV)
  - Pressure Support Ventilation (PSV)
  - Presure Controled Ventilation (PCV)
  - Continuous Positive Airway Pressure (CPAP)
  - Volume Support (VS)
  - Volume Control (VC)
  - Volume Control plus (VC+)
  - Control Mode Ventilation (CMV)
  - Airway Pressure Release Ventilation (APRV)
  - Mandatory Minute Ventilation (MMV)
  - Inverse Ratio Ventilation (IRV)
  - High-Frequency Oscillatory Ventilation (HFOV)
  - Bilevel positive airway pressure (BiPAP or DuoPAP or Bi-Level)
  - Proportional assist ventilation (PAV)
  - Adaptive support ventilation (ASV)
  - Automatic tube compensation (ATC)
  - Volume-Assured Pressure Support (VAPS)
  - Synchronized controlled mandatory ventilation with adaptive pressure ventilation (APV-CMV or APVcmv)
  - Adaptive pressure ventilation-synchronised intermittent mandatory ventilation (APV-SIMV or APVsimv)
  - Pressure-controlled synchronised intermittent mandatory ventilation (P-SIMV)
  - Spontaneous ventilation
  - Assisted spontaneous ventilation (invasive and non-invasive)
  - Other

- Tidal Volume. This preset determines how much air is delivered to the lungs by the ventilator on each breath.

- Exhaled Tidal Volume. Reading of the actual volume of air being exhaled by the patient.

- Mechanical respiratory or breathing rate. This setting controls how many breaths are delivered to the patient by the machine. Automatic input. Why sometimes spont and mech resp rate value pairs are incomplete?

- Spontaneous respiratory rate. Reading of the spontanous respiratory rate from patient, as reported by the ventilator.

- Respiratory rate. Spontaneous respiration from patient without mechanical devices involved. Units: breaths per minute.

- Fraction of inspired oxygen (FiO2). Indicates the concentration of oxygen that is being inhaled by the patient.

- Positive end-expiratory pressure (PEEP). Setting that controls the pressure applied by the machine at the end of each breath.

- Peak Inspiratory Pressure (PIP). Reading of the highest level of presure applied to the lungs during breathing. Unit: Centimeters of water presure (cmH2O).

- End Tidal CO2 (ETCO2). Capnometry readings of exhaled CO2. Units: mmHg.

- End Tidal CO2 Oral/Nasal (ETCO2 NO). Readings from oral and nasal capnography. Units: mmHg.

- Glasgow Coma Scale (GCS). GCS score (pediatric and adults) recorded during use of mechanical ventilator.

- Oxygen consumption rate. This preset indicates the volume of oxygen delivered by the ventilator during inspiration. Unit: Lmin, mLmin.

- Pulse Oxymetry (SpO2). Oxygen saturation readings from pulse oxymetry. Units: Percent

If data on spont but not mech rate indicate a potential error.

Respiratory device. Look for mappings for value as concept id.
Respiratory device - map device types to omop concepts.

- Adults. Adult mechs hasnt been used since 2017.
- Pediatric. Since 2017 is being used for both. Now is same flowsheeet.

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
