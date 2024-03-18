-- PS 1
SELECT
  p.pharmacyName,
  SUM(c.quantity) AS total_hospital_meds
FROM Pharmacy p
JOIN Prescription pr ON p.pharmacyID = pr.pharmacyID
JOIN Contain c ON pr.prescriptionID = c.prescriptionID
JOIN Medicine m ON c.medicineID = m.medicineID
JOIN Treatment t ON pr.treatmentID = t.treatmentID
WHERE
  t.date BETWEEN '2021-01-01' AND '2022-12-31'
  AND m.hospitalExclusive = 'Y' 
GROUP BY
  p.pharmacyName
ORDER BY
  total_hospital_meds DESC;



-- PS 2
SELECT
  ip.planName AS plan_name,
  ic.companyName AS company_name,
  COUNT(*) AS num_treatments
FROM InsurancePlan ip
JOIN InsuranceCompany ic ON ip.companyID = ic.companyID
JOIN Claim c ON ip.UIN = c.uin
GROUP BY
  ip.planName,
  ic.companyName
ORDER BY
  plan_name,
  company_name;
  
  
-- PS 3
SELECT
  ic.companyName,
  MAX(claim_count) AS most_claimed_plan,
  MIN(claim_count) AS least_claimed_plan
FROM InsuranceCompany ic
LEFT JOIN (
  SELECT
    ic.companyName,
    ip.planName,
    COUNT(*) AS claim_count
  FROM InsurancePlan ip
  JOIN InsuranceCompany ic ON ip.companyID = ic.companyID
  JOIN Claim c ON ip.UIN = c.uin
  GROUP BY
    ic.companyName,
    ip.planName
) AS plan_claims ON ic.companyName = plan_claims.companyName
GROUP BY
  ic.companyName
ORDER BY
  ic.companyName;
  
  
-- PS 4
SELECT
  a.state,
  COUNT(p.personID) AS total_people,
  COUNT(pat.patientID) AS total_patients,
  COUNT(p.personID) / COUNT(pat.patientID) AS people_to_patient_ratio
FROM Address a
LEFT JOIN Person p ON p.addressID = a.addressID
LEFT JOIN Patient pat ON p.personID = pat.patientID
GROUP BY
  a.state
ORDER BY
  people_to_patient_ratio;
  
  
-- PS 5
SELECT
  p.pharmacyName,
  SUM(c.quantity) AS total_tax_i_medicine
FROM Pharmacy p
JOIN Prescription pr ON p.pharmacyID = pr.pharmacyID
JOIN Contain c ON pr.prescriptionID = c.prescriptionID
JOIN Medicine m ON c.medicineID = m.medicineID
JOIN Treatment t ON pr.treatmentID = t.treatmentID
JOIN Address a ON p.addressID = a.addressID
WHERE
  t.date BETWEEN '2021-01-01' AND '2021-12-31'
  AND a.state = 'AZ'  -- Assuming Jhonny is from Arizona
  AND m.taxCriteria = 'I'
GROUP BY
  p.pharmacyName
ORDER BY
  total_tax_i_medicine DESC;
