-- ============================================================
-- Smart Clinic Database System
-- Target platform: MySQL 8.0.16+ / MySQL 8.4
-- Academic project dataset for the Kingdom of Saudi Arabia.
-- All personal data are fictional and used only for database testing.
-- ============================================================

DROP DATABASE IF EXISTS smart_clinic_db;
CREATE DATABASE smart_clinic_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE smart_clinic_db;

-- ============================================================
-- 1. TABLE CREATION
-- EER hierarchy:
-- Person -> Patient, Employee
-- Employee -> Doctor, Receptionist
-- ============================================================

CREATE TABLE person (
    person_id       INT PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    gender          ENUM('Female', 'Male', 'Other') NOT NULL,
    date_of_birth   DATE NOT NULL,
    phone           VARCHAR(20) NOT NULL UNIQUE,
    email           VARCHAR(120) UNIQUE,
    address_line    VARCHAR(255),
    person_type     ENUM('Patient', 'Employee') NOT NULL
) ENGINE = InnoDB;

CREATE TABLE patient (
    person_id                 INT PRIMARY KEY,
    patient_no                VARCHAR(15) NOT NULL UNIQUE,
    blood_type                ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    allergies                 VARCHAR(255),
    emergency_contact_name    VARCHAR(100) NOT NULL,
    emergency_contact_phone   VARCHAR(20) NOT NULL,
    registered_on             DATE NOT NULL,
    CONSTRAINT fk_patient_person
        FOREIGN KEY (person_id) REFERENCES person(person_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE employee (
    person_id       INT PRIMARY KEY,
    employee_no     VARCHAR(15) NOT NULL UNIQUE,
    hire_date       DATE NOT NULL,
    salary          DECIMAL(10,2) NOT NULL CHECK (salary >= 0),
    employee_role   ENUM('Doctor', 'Receptionist') NOT NULL,
    CONSTRAINT fk_employee_person
        FOREIGN KEY (person_id) REFERENCES person(person_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE doctor (
    person_id          INT PRIMARY KEY,
    license_no         VARCHAR(30) NOT NULL UNIQUE,
    specialty          VARCHAR(80) NOT NULL,
    room_no            VARCHAR(10) NOT NULL UNIQUE,
    consultation_fee   DECIMAL(10,2) NOT NULL CHECK (consultation_fee >= 0),
    CONSTRAINT fk_doctor_employee
        FOREIGN KEY (person_id) REFERENCES employee(person_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE receptionist (
    person_id       INT PRIMARY KEY,
    work_shift      ENUM('Morning', 'Evening', 'Night') NOT NULL,
    extension_no    VARCHAR(10) NOT NULL UNIQUE,
    CONSTRAINT fk_receptionist_employee
        FOREIGN KEY (person_id) REFERENCES employee(person_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE appointment (
    appointment_id      INT AUTO_INCREMENT PRIMARY KEY,
    patient_id          INT NOT NULL,
    doctor_id           INT NOT NULL,
    scheduled_at        DATETIME NOT NULL,
    reason               VARCHAR(255) NOT NULL,
    status               ENUM('Scheduled', 'Completed', 'Cancelled', 'No-Show')
                         NOT NULL DEFAULT 'Scheduled',
    consultation_fee     DECIMAL(10,2) NOT NULL CHECK (consultation_fee >= 0),
    payment_status       ENUM('Unpaid', 'Partially Paid', 'Paid')
                         NOT NULL DEFAULT 'Unpaid',
    created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_doctor_schedule UNIQUE (doctor_id, scheduled_at),
    CONSTRAINT fk_appointment_patient
        FOREIGN KEY (patient_id) REFERENCES patient(person_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_appointment_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor(person_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE treatment (
    treatment_id       INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id     INT NOT NULL,
    treatment_date     DATE NOT NULL,
    diagnosis          VARCHAR(150) NOT NULL,
    treatment_notes    TEXT NOT NULL,
    follow_up_date     DATE,
    CONSTRAINT fk_treatment_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE medicine (
    medicine_id        INT AUTO_INCREMENT PRIMARY KEY,
    medicine_name      VARCHAR(120) NOT NULL,
    strength           VARCHAR(50) NOT NULL,
    dosage_form        VARCHAR(50) NOT NULL,
    stock_quantity     INT NOT NULL CHECK (stock_quantity >= 0),
    reorder_level      INT NOT NULL CHECK (reorder_level >= 0),
    unit_price         DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    CONSTRAINT uq_medicine UNIQUE (medicine_name, strength, dosage_form)
) ENGINE = InnoDB;

CREATE TABLE prescription (
    prescription_id    INT AUTO_INCREMENT PRIMARY KEY,
    treatment_id       INT NOT NULL UNIQUE,
    issued_at           DATETIME NOT NULL,
    instructions       VARCHAR(255),
    CONSTRAINT fk_prescription_treatment
        FOREIGN KEY (treatment_id) REFERENCES treatment(treatment_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE prescription_item (
    prescription_id    INT NOT NULL,
    medicine_id        INT NOT NULL,
    dosage             VARCHAR(80) NOT NULL,
    frequency          VARCHAR(80) NOT NULL,
    duration_days      INT NOT NULL CHECK (duration_days > 0),
    quantity           INT NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (prescription_id, medicine_id),
    CONSTRAINT fk_prescription_item_prescription
        FOREIGN KEY (prescription_id) REFERENCES prescription(prescription_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_prescription_item_medicine
        FOREIGN KEY (medicine_id) REFERENCES medicine(medicine_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE payment (
    payment_id         INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id     INT NOT NULL,
    amount             DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_date       DATETIME NOT NULL,
    payment_method     ENUM('Cash', 'Card', 'Insurance', 'Bank Transfer') NOT NULL,
    reference_no       VARCHAR(40) NOT NULL UNIQUE,
    notes              VARCHAR(255),
    CONSTRAINT fk_payment_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- ============================================================
-- 2. TRIGGER
-- Automatically deduct medicine stock whenever a prescription
-- item is added. The trigger blocks insufficient-stock requests.
-- ============================================================

DELIMITER //

CREATE TRIGGER trg_prescription_item_before_insert
BEFORE INSERT ON prescription_item
FOR EACH ROW
BEGIN
    DECLARE v_current_stock INT;

    SELECT stock_quantity
      INTO v_current_stock
      FROM medicine
     WHERE medicine_id = NEW.medicine_id;

    IF v_current_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient medicine stock for this prescription';
    ELSE
        UPDATE medicine
           SET stock_quantity = stock_quantity - NEW.quantity
         WHERE medicine_id = NEW.medicine_id;
    END IF;
END//

DELIMITER ;

-- ============================================================
-- 3. SAMPLE DATA
-- At least five records are inserted into every table.
-- ============================================================

INSERT INTO person
(person_id, first_name, last_name, gender, date_of_birth, phone, email, address_line, person_type)
VALUES
(1,   'Noura',    'Al-Qahtani',   'Female', '1998-04-12', '+966-53-000-0001', 'noura.alqahtani0001@gmail.com',    'Al Malaz, Riyadh',              'Patient'),
(2,   'Fahad',    'Al-Otaibi',    'Male',   '1985-11-30', '+966-56-000-0002', 'fahad.alotaibi0002@gmail.com',     'Al Olaya, Riyadh',              'Patient'),
(3,   'Reem',     'Al-Harbi',     'Female', '2001-02-19', '+966-53-000-0003', 'reem.alharbi0003@gmail.com',       'Al Rawdah, Jeddah',             'Patient'),
(4,   'Saud',     'Al-Dosari',    'Male',   '1975-07-08', '+966-56-000-0004', 'saud.aldosari0004@gmail.com',      'Al Faisaliyah, Dammam',         'Patient'),
(5,   'Maha',     'Al-Ghamdi',    'Female', '1990-09-25', '+966-53-000-0005', 'maha.alghamdi0005@gmail.com',      'Al Khobar Al Shamalia, Khobar', 'Patient'),
(101, 'Khalid',   'Al-Shammari',  'Male',   '1978-01-15', '+966-53-000-0101', 'khalid.alshammari0101@gmail.com',  'Al Yasmin, Riyadh',             'Employee'),
(102, 'Hessa',    'Al-Zahrani',   'Female', '1982-03-21', '+966-56-000-0102', 'hessa.alzahrani0102@gmail.com',    'Al Nakheel, Riyadh',            'Employee'),
(103, 'Abdullah', 'Al-Mutairi',   'Male',   '1980-06-17', '+966-53-000-0103', 'abdullah.almutairi0103@gmail.com', 'Al Hamra, Jeddah',              'Employee'),
(104, 'Sara',     'Al-Anazi',     'Female', '1987-12-04', '+966-56-000-0104', 'sara.alanazi0104@gmail.com',       'Al Rakah, Khobar',              'Employee'),
(105, 'Turki',    'Al-Rashid',    'Male',   '1976-09-09', '+966-53-000-0105', 'turki.alrashid0105@gmail.com',     'Al Shati, Dammam',              'Employee'),
(106, 'Layan',    'Al-Shehri',    'Female', '1995-05-10', '+966-56-000-0106', 'layan.alshehri0106@gmail.com',     'Al Quds, Riyadh',               'Employee'),
(107, 'Majed',    'Al-Harbi',     'Male',   '1993-08-14', '+966-53-000-0107', 'majed.alharbi0107@gmail.com',      'Al Safa, Jeddah',               'Employee'),
(108, 'Rana',     'Al-Qahtani',   'Female', '1996-11-02', '+966-56-000-0108', 'rana.alqahtani0108@gmail.com',     'Al Aqrabiyah, Khobar',          'Employee'),
(109, 'Nawaf',    'Al-Dosari',    'Male',   '1992-04-26', '+966-53-000-0109', 'nawaf.aldosari0109@gmail.com',     'Al Manar, Dammam',              'Employee'),
(110, 'Abeer',    'Al-Ghamdi',    'Female', '1997-07-19', '+966-56-000-0110', 'abeer.alghamdi0110@gmail.com',     'Al Narjis, Riyadh',             'Employee');

INSERT INTO patient
(person_id, patient_no, blood_type, allergies, emergency_contact_name, emergency_contact_phone, registered_on)
VALUES
(1, 'P0001', 'A+',  'Penicillin', 'Abdullah Al-Qahtani', '+966-53-100-0001', '2026-06-01'),
(2, 'P0002', 'O+',  NULL,         'Noura Al-Otaibi',     '+966-56-100-0002', '2026-06-02'),
(3, 'P0003', 'B+',  'Peanuts',    'Mohammed Al-Harbi',   '+966-53-100-0003', '2026-06-03'),
(4, 'P0004', 'AB-', 'Aspirin',    'Hessa Al-Dosari',     '+966-56-100-0004', '2026-06-04'),
(5, 'P0005', 'O-',  NULL,         'Ahmed Al-Ghamdi',     '+966-53-100-0005', '2026-06-05');


INSERT INTO employee
(person_id, employee_no, hire_date, salary, employee_role)
VALUES
(101, 'E0101', '2021-01-10', 3200.00, 'Doctor'),
(102, 'E0102', '2020-03-15', 3400.00, 'Doctor'),
(103, 'E0103', '2022-06-01', 3100.00, 'Doctor'),
(104, 'E0104', '2019-09-20', 3600.00, 'Doctor'),
(105, 'E0105', '2018-11-05', 3800.00, 'Doctor'),
(106, 'E0106', '2023-02-12', 1200.00, 'Receptionist'),
(107, 'E0107', '2022-10-18', 1250.00, 'Receptionist'),
(108, 'E0108', '2024-01-08', 1180.00, 'Receptionist'),
(109, 'E0109', '2021-07-25', 1300.00, 'Receptionist'),
(110, 'E0110', '2025-03-03', 1150.00, 'Receptionist');

INSERT INTO doctor
(person_id, license_no, specialty, room_no, consultation_fee)
VALUES
(101, 'LIC-GP-1001',   'General Medicine', 'D101', 150.00),
(102, 'LIC-CAR-1002',  'Cardiology',        'D102', 180.00),
(103, 'LIC-DER-1003',  'Dermatology',       'D103', 200.00),
(104, 'LIC-ORT-1004',  'Orthopedics',       'D104', 160.00),
(105, 'LIC-END-1005',  'Endocrinology',     'D105', 170.00);

INSERT INTO receptionist
(person_id, work_shift, extension_no)
VALUES
(106, 'Morning', '201'),
(107, 'Evening', '202'),
(108, 'Morning', '203'),
(109, 'Evening', '204'),
(110, 'Night',   '205');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, scheduled_at, reason, status, consultation_fee, payment_status)
VALUES
(1, 1, 101, '2026-07-10 09:00:00', 'Persistent headache',          'Completed', 150.00, 'Paid'),
(2, 2, 102, '2026-07-11 10:00:00', 'High blood pressure',          'Completed', 180.00, 'Paid'),
(3, 3, 103, '2026-07-12 11:00:00', 'Skin rash',                    'Completed', 200.00, 'Paid'),
(4, 4, 104, '2026-07-13 12:00:00', 'Knee pain',                    'Completed', 160.00, 'Partially Paid'),
(5, 5, 105, '2026-07-14 14:00:00', 'Diabetes review',              'Completed', 170.00, 'Paid'),
(6, 1, 102, '2026-08-01 10:00:00', 'Cardiology follow-up',         'Scheduled', 180.00, 'Unpaid'),
(7, 2, 101, '2026-08-02 09:00:00', 'General health check',         'Scheduled', 150.00, 'Unpaid'),
(8, 3, 105, '2026-08-03 15:00:00', 'Hormonal imbalance review',    'Scheduled', 170.00, 'Unpaid');

INSERT INTO treatment
(treatment_id, appointment_id, treatment_date, diagnosis, treatment_notes, follow_up_date)
VALUES
(1, 1, '2026-07-10', 'Migraine',              'Rest, hydration, and analgesic treatment.',              '2026-07-24'),
(2, 2, '2026-07-11', 'Hypertension',          'Begin blood-pressure medication and reduce salt intake.','2026-08-01'),
(3, 3, '2026-07-12', 'Contact dermatitis',    'Use topical cream and avoid suspected irritants.',       '2026-07-26'),
(4, 4, '2026-07-13', 'Knee osteoarthritis',   'Anti-inflammatory medicine and physiotherapy advice.',   '2026-08-10'),
(5, 5, '2026-07-14', 'Type 2 diabetes',       'Continue glucose monitoring and start metformin.',       '2026-08-14'),
(6, 2, '2026-07-11', 'Elevated cholesterol',  'Dietary advice and repeat lipid test in three months.',   '2026-10-11');

INSERT INTO medicine
(medicine_id, medicine_name, strength, dosage_form, stock_quantity, reorder_level, unit_price)
VALUES
(1, 'Paracetamol',   '500 mg', 'Tablet', 100, 20, 0.20),
(2, 'Amlodipine',    '5 mg',   'Tablet',  80, 15, 0.45),
(3, 'Hydrocortisone','1%',     'Cream',   60, 10, 2.50),
(4, 'Ibuprofen',     '400 mg', 'Tablet',  90, 20, 0.35),
(5, 'Metformin',     '500 mg', 'Tablet', 120, 25, 0.30);

INSERT INTO prescription
(prescription_id, treatment_id, issued_at, instructions)
VALUES
(1, 1, '2026-07-10 09:30:00', 'Take after food and avoid exceeding the stated dose.'),
(2, 2, '2026-07-11 10:30:00', 'Check blood pressure daily.'),
(3, 3, '2026-07-12 11:30:00', 'Apply only to affected areas.'),
(4, 4, '2026-07-13 12:30:00', 'Stop use if stomach irritation occurs.'),
(5, 5, '2026-07-14 14:30:00', 'Take with meals and monitor glucose.');

-- The trigger deducts stock during these inserts.
INSERT INTO prescription_item
(prescription_id, medicine_id, dosage, frequency, duration_days, quantity)
VALUES
(1, 1, '500 mg', 'Twice daily',       10, 20),
(2, 2, '5 mg',   'Once daily',        30, 30),
(3, 3, 'Thin layer', 'Twice daily',   10, 10),
(4, 4, '400 mg', 'Twice daily',        7, 15),
(5, 5, '500 mg', 'Twice daily',       20, 40),
(5, 1, '500 mg', 'When required',      5, 10);

INSERT INTO payment
(payment_id, appointment_id, amount, payment_date, payment_method, reference_no, notes)
VALUES
(1, 1, 150.00, '2026-07-10 09:45:00', 'Card',          'PAY-2026-0001', 'Paid in full'),
(2, 2, 100.00, '2026-07-11 10:40:00', 'Insurance',     'PAY-2026-0002', 'Insurance portion'),
(3, 2,  80.00, '2026-07-11 10:42:00', 'Cash',          'PAY-2026-0003', 'Patient balance'),
(4, 3, 200.00, '2026-07-12 11:40:00', 'Card',          'PAY-2026-0004', 'Paid in full'),
(5, 4,  60.00, '2026-07-13 12:40:00', 'Cash',          'PAY-2026-0005', 'Partial payment'),
(6, 5, 170.00, '2026-07-14 14:40:00', 'Bank Transfer', 'PAY-2026-0006', 'Paid in full');

-- Reset AUTO_INCREMENT values after explicit identifiers.
ALTER TABLE appointment AUTO_INCREMENT = 9;
ALTER TABLE treatment AUTO_INCREMENT = 7;
ALTER TABLE medicine AUTO_INCREMENT = 6;
ALTER TABLE prescription AUTO_INCREMENT = 6;
ALTER TABLE payment AUTO_INCREMENT = 7;

-- ============================================================
-- 4. VIEW
-- Provides one reporting row per appointment with patient,
-- doctor, payment, and appointment status information.
-- ============================================================

CREATE OR REPLACE VIEW vw_appointment_summary AS
SELECT
    a.appointment_id,
    a.scheduled_at,
    CONCAT(pp.first_name, ' ', pp.last_name) AS patient_name,
    CONCAT(pd.first_name, ' ', pd.last_name) AS doctor_name,
    d.specialty,
    a.reason,
    a.status,
    a.consultation_fee,
    COALESCE(SUM(pay.amount), 0.00) AS amount_paid,
    CASE
        WHEN COALESCE(SUM(pay.amount), 0.00) >= a.consultation_fee THEN 'Paid'
        WHEN COALESCE(SUM(pay.amount), 0.00) > 0 THEN 'Partially Paid'
        ELSE 'Unpaid'
    END AS calculated_payment_status
FROM appointment a
JOIN patient pat
  ON pat.person_id = a.patient_id
JOIN person pp
  ON pp.person_id = pat.person_id
JOIN doctor d
  ON d.person_id = a.doctor_id
JOIN person pd
  ON pd.person_id = d.person_id
LEFT JOIN payment pay
  ON pay.appointment_id = a.appointment_id
GROUP BY
    a.appointment_id,
    a.scheduled_at,
    pp.first_name,
    pp.last_name,
    pd.first_name,
    pd.last_name,
    d.specialty,
    a.reason,
    a.status,
    a.consultation_fee;

-- ============================================================
-- 5. REQUIRED SQL OPERATIONS
-- ============================================================

-- Q1: Basic SELECT - medicines with remaining stock of 50 or less.
SELECT medicine_id, medicine_name, strength, stock_quantity, reorder_level
FROM medicine
WHERE stock_quantity <= 50
ORDER BY stock_quantity, medicine_name;

-- Q2: JOIN - appointment schedule with patient and doctor details.
SELECT
    a.appointment_id,
    a.scheduled_at,
    CONCAT(pp.first_name, ' ', pp.last_name) AS patient_name,
    CONCAT(pd.first_name, ' ', pd.last_name) AS doctor_name,
    d.specialty,
    a.status
FROM appointment a
JOIN patient pat ON pat.person_id = a.patient_id
JOIN person pp ON pp.person_id = pat.person_id
JOIN doctor d ON d.person_id = a.doctor_id
JOIN person pd ON pd.person_id = d.person_id
ORDER BY a.scheduled_at;

-- Q3: Nested query - patients whose total payments exceed
-- the average total paid per paying patient.
SELECT
    pr.person_id AS patient_id,
    CONCAT(pr.first_name, ' ', pr.last_name) AS patient_name,
    SUM(pay.amount) AS total_paid
FROM patient pat
JOIN person pr ON pr.person_id = pat.person_id
JOIN appointment a ON a.patient_id = pat.person_id
JOIN payment pay ON pay.appointment_id = a.appointment_id
GROUP BY pr.person_id, pr.first_name, pr.last_name
HAVING SUM(pay.amount) >
(
    SELECT AVG(patient_total)
    FROM
    (
        SELECT a2.patient_id, SUM(pay2.amount) AS patient_total
        FROM appointment a2
        JOIN payment pay2 ON pay2.appointment_id = a2.appointment_id
        GROUP BY a2.patient_id
    ) AS patient_totals
)
ORDER BY total_paid DESC;

-- Q4: Aggregate functions with GROUP BY - workload and collections.
SELECT
    d.person_id AS doctor_id,
    CONCAT(p.first_name, ' ', p.last_name) AS doctor_name,
    d.specialty,
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    COUNT(DISTINCT CASE
        WHEN a.status = 'Completed' THEN a.appointment_id
    END) AS completed_appointments,
    COALESCE(SUM(pay.amount), 0.00) AS total_collected
FROM doctor d
JOIN person p ON p.person_id = d.person_id
LEFT JOIN appointment a ON a.doctor_id = d.person_id
LEFT JOIN payment pay ON pay.appointment_id = a.appointment_id
GROUP BY d.person_id, p.first_name, p.last_name, d.specialty
ORDER BY total_appointments DESC, doctor_name;

-- Q5: Query the view.
SELECT *
FROM vw_appointment_summary
ORDER BY scheduled_at;

-- Q6 and Q7: UPDATE and DELETE.
-- A transaction is used so the demonstration does not permanently
-- remove the sample appointment.
START TRANSACTION;

UPDATE appointment
SET status = 'Cancelled',
    reason = CONCAT(reason, ' - patient requested cancellation')
WHERE appointment_id = 8;

SELECT appointment_id, reason, status
FROM appointment
WHERE appointment_id = 8;

DELETE FROM appointment
WHERE appointment_id = 8
  AND status = 'Cancelled';

SELECT COUNT(*) AS remaining_appointments
FROM appointment;

ROLLBACK;

-- Confirm that the rollback restored appointment 8.
SELECT appointment_id, reason, status
FROM appointment
WHERE appointment_id = 8;

-- Q8: Trigger demonstration.
-- The insert invokes trg_prescription_item_before_insert and deducts
-- five units of Ibuprofen. ROLLBACK restores both tables afterward.
START TRANSACTION;

SELECT medicine_id, medicine_name, stock_quantity
FROM medicine
WHERE medicine_id = 4;

INSERT INTO prescription_item
(prescription_id, medicine_id, dosage, frequency, duration_days, quantity)
VALUES
(5, 4, '400 mg', 'Once daily', 5, 5);

SELECT medicine_id, medicine_name, stock_quantity
FROM medicine
WHERE medicine_id = 4;

ROLLBACK;

SHOW TRIGGERS FROM smart_clinic_db;

-- ============================================================
-- 6. TABLE POPULATION VERIFICATION
-- Run these statements and capture screenshots in MySQL Workbench.
-- ============================================================

SELECT * FROM person ORDER BY person_id;
SELECT * FROM patient ORDER BY person_id;
SELECT * FROM employee ORDER BY person_id;
SELECT * FROM doctor ORDER BY person_id;
SELECT * FROM receptionist ORDER BY person_id;
SELECT * FROM appointment ORDER BY appointment_id;
SELECT * FROM treatment ORDER BY treatment_id;
SELECT * FROM medicine ORDER BY medicine_id;
SELECT * FROM prescription ORDER BY prescription_id;
SELECT * FROM prescription_item ORDER BY prescription_id, medicine_id;
SELECT * FROM payment ORDER BY payment_id;
