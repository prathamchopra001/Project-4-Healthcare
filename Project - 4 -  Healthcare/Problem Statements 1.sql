USE healthcaredb_p4;

-- Problem statement-1
SELECT 
    CASE
        WHEN TIMESTAMPDIFF(YEAR, p.dob, CURDATE()) BETWEEN 0 AND 14 THEN 'Children'
        WHEN TIMESTAMPDIFF(YEAR, p.dob, CURDATE()) BETWEEN 15 AND 24 THEN 'Youth' 
        WHEN TIMESTAMPDIFF(YEAR, p.dob, CURDATE()) BETWEEN 25 AND 64 THEN 'Adults'
        ELSE 'Seniors'
    END AS age_category,
    COUNT(*) AS no_of_treatments
FROM treatment t
JOIN patient p ON t.patientID = p.patientID
WHERE EXTRACT(YEAR FROM t.date) = 2022
GROUP BY age_category;
    
    
-- Problem statement-2
SELECT
    d.diseaseName AS Disease,
    SUM(CASE WHEN pe.gender = 'Male' THEN 1 ELSE 0 END) AS MaleCount,
    SUM(CASE WHEN pe.gender = 'Female' THEN 1 ELSE 0 END) AS FemaleCount,
    CASE
        WHEN SUM(CASE WHEN pe.gender = 'Female' THEN 1 ELSE 0 END) = 0 THEN 'Male Only'
        WHEN SUM(CASE WHEN pe.gender = 'Male' THEN 1 ELSE 0 END) = 0 THEN 'Female Only'
        ELSE ROUND(CAST(SUM(CASE WHEN pe.gender = 'Male' THEN 1 ELSE 0 END) AS FLOAT) / 
             CAST(SUM(CASE WHEN pe.gender = 'Female' THEN 1 ELSE 0 END) AS FLOAT),2)
    END AS Male_to_Female_Ratio
FROM
    Disease d
JOIN
    Treatment t ON d.ï»¿diseaseID = t.diseaseID
JOIN
    Patient pa ON t.patientID = pa.patientID
JOIN
    Person pe ON pa.patientID = pe.personID
GROUP BY
    d.diseaseName
ORDER BY
    Male_to_Female_Ratio DESC;

    
-- Problem statement-3
WITH No_of_treatment_claims AS (
    SELECT
        pe.gender AS Gender,
        COUNT(DISTINCT t.treatmentID) AS No_of_Treatments,
        COUNT(DISTINCT c.claimID) AS No_of_Claims
    FROM
        Treatment t
    JOIN
        Patient pa ON t.patientID = pa.patientID
    JOIN
        Person pe ON pa.patientID = pe.personID
    LEFT JOIN
        Claim c ON t.claimID = c.claimID
    GROUP BY
        pe.gender
)
SELECT
    Gender,
    No_of_Treatments,
    No_of_Claims,
    ROUND(CASE
    WHEN No_of_Claims = 0 THEN NULL
    ELSE CAST(No_of_Treatments AS FLOAT) / No_of_Claims
	END, 2) AS Treatment_to_Claim_Ratio
	FROM No_of_treatment_claims
ORDER BY
    Gender;

-- Probelm statement-4
   SELECT
    ph.pharmacyName AS Pharmacy_Name,
    SUM(k.quantity) AS Total_Quantity,
    ROUND(SUM(m.maxPrice * k.quantity),2) AS Total_Max_Retail_Price,
    ROUND(SUM(m.maxPrice * (1 - k.discount / 100) * k.quantity),2)AS Total_Price_After_Discount
FROM
    Pharmacy ph
JOIN
    Keep k ON ph.pharmacyID = k.pharmacyID
JOIN
    Medicine m ON k.medicineID = m.medicineID
GROUP BY
    ph.pharmacyName;


-- Problem statement-5
    SELECT
    ph.pharmacyName AS PharmacyName,
    MAX(prescription_medicines.num_medicines) AS MaxMedicines,
    MIN(prescription_medicines.num_medicines) AS MinMedicines,
    Round(AVG(prescription_medicines.num_medicines),2) AS AvgMedicines
FROM
    Pharmacy ph
LEFT JOIN (
    SELECT
        pr.pharmacyID,
        pr.prescriptionID,
        COUNT(*) AS num_medicines
    FROM
        Prescription pr
    JOIN
        Contain c ON pr.prescriptionID = c.prescriptionID
    GROUP BY
        pr.pharmacyID, pr.prescriptionID
) AS prescription_medicines ON ph.pharmacyID = prescription_medicines.pharmacyID
GROUP BY
    ph.pharmacyName;

