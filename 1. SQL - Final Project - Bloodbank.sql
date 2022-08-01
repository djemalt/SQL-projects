#Group v
#Participant id 1: 582288
#Participant id 2: 582280


#when you will run the code, the final line will be an error to show the that the trigger is working correctly
#the line directly under we dont not think runs automaticaly, but is a way to show that the trigger is working and allows a date greater than 3 months

create database if not exists Blood;

use blood;


#Creates Blood type table + values

CREATE TABLE IF NOT EXISTS `Blood_type` (
    Blood_type_id INT PRIMARY KEY AUTO_INCREMENT,
    blood_type VARCHAR(255) NOT NULL
);

insert into `Blood_type`
(blood_type)
values
("A+"), ("A-"), ("B+"), ("B-"), ("O+"), ("O-"), ("AB+"), ("AB-");


#Creates donate_to Table and values - FK to blood_type_id for both so only existing bloodtypes can be used

CREATE TABLE IF NOT EXISTS donate_to (
    Blood_id INT NOT NULL,
    donate_to_id INT NOT NULL,
    PRIMARY KEY (Blood_id , donate_to_id),
    CONSTRAINT fk_B_IDdonate_to_Blood_type FOREIGN KEY (Blood_id)
        REFERENCES Blood_type (Blood_type_id),
    CONSTRAINT fk_D_IDdonate_to_Blood_type FOREIGN KEY (donate_to_id)
        REFERENCES Blood_type (Blood_type_id)
);


insert into donate_to
(Blood_id,donate_to_id)
values
(1,1), (1,7),
(2,1), (2,2), (2,7), (2,8),
(3,3), (3,7),
(4,3), (4,4), (4,7), (4,8),
(5,1), (5,3), (5,5), (5,7), 
(6,1), (6,2), (6,3), (6,4), (6,5), (6,6), (6,7), (6,8), 
(7,7),
(8,7), (8,8);



#Creates Recieve_From Table and values  - FK to blood_type_id for both so only existing bloodtypes can be used

CREATE TABLE IF NOT EXISTS Recieve_From (
    Blood_id INT NOT NULL,
    Recieve_From_id INT NOT NULL,
    PRIMARY KEY (Blood_id , Recieve_From_id),
    CONSTRAINT fk_B_IDRecieve_From_Blood_type FOREIGN KEY (Blood_id)
        REFERENCES Blood_type (Blood_type_id),
    CONSTRAINT fk_D_IDRecieve_From_Blood_type FOREIGN KEY (Recieve_From_id)
        REFERENCES Blood_type (Blood_type_id)
);

insert into Recieve_From
(Blood_id,Recieve_From_id)
values
(1,1), (1,2), (1,5), (1,6),
(2,2), (2,6),
(3,3),(3,4),(3,5),(3,6),
(4,4), (4,6),
(5,5),(5,6),
(6,6),
(7,1), (7,2), (7,3), (7,4), (7,5), (7,6), (7,7), (7,8), 
(8,2), (8,4), (8,6), (8,8);

#Creates Countries Table and values 
CREATE TABLE IF NOT EXISTS Countries (
    Country_id INT PRIMARY KEY AUTO_INCREMENT,
    Country_Name VARCHAR(255)
);

insert into Countries
(Country_Name)
values
("USA"),
("Israel"),
("Scottland"),
("UK"),
("Mars"),
("Republic of the Marshall Islands");


#Creates Donation_card Table and values - Part 1 - creates the unique card ID since its needed as a fk for donors table

CREATE TABLE IF NOT EXISTS Donation_card (
    Card_id INT PRIMARY KEY,
    donor_id INT UNIQUE
);


insert into Donation_card
(Card_id)
values
(1001),
(1002),
(1003),
(1004),
(1005),
(1006),
(1007),
(1008),
(1009);

#Creates Donors Table and values 
# FK to blood_type_id for both so only existing bloodtypes can be used
# FK to donor card, so only existing donor cards can be used

CREATE TABLE IF NOT EXISTS donor (
    donor_id INT PRIMARY KEY AUTO_INCREMENT,
    blood_type_id INT,
    first_name VARCHAR(255),
    donor_card_id INT UNIQUE,
    CONSTRAINT fk_Donor_Donation_card FOREIGN KEY (donor_card_id)
        REFERENCES Donation_card (card_id),
    CONSTRAINT fk_Donor_blood_type FOREIGN KEY (blood_type_id)
        REFERENCES `blood_type` (blood_type_id)
);
 

 insert into donor
  (blood_type_id,first_name,donor_card_id)
values
(6,"Tal", 1001),
(8,"Eyal",1002),
(2,"Sherlock",1003),
(4,"Shrek",1004),
(6,"Austin",1005),
(6,"Peter", 1006),
(5,"Albert",1007),
(1,"Patrick",1008),
(3,"Elon",1009);


# part 2 of Donor card - Create the FK to donor_id so only existing donors will be available
alter table Donation_card
add 
constraint FK_Donation_card_Donor
foreign key (donor_id) 
references Donor(donor_id);

# to take all donor_id from donor table and match with Card_id, needed to take off safe updates since it was on a PK, we think
#this is used to update added donor_ids to new donation cards,
#order is ; Create Donation card ID -> create donor entry with new card ID-> run the code below and take the donor ID. 
#this will not allow non existing entreis since they are FK of each other


SET SQL_SAFE_UPDATES=0;
UPDATE Donation_card
        INNER JOIN
    donor ON Donor.donor_card_id = Donation_card.card_id 
SET 
    Donation_card.donor_id = donor.donor_id;

SET SQL_SAFE_UPDATES=1;

#Creates Donor additional info table  and values - FK to donor_id and country_id to use only existing ids in our database

CREATE TABLE IF NOT EXISTS donor_info (
    donor_id INT PRIMARY KEY,
    full_name VARCHAR(255),
    contact_number VARCHAR(255),
    D_address VARCHAR(255),
    city VARCHAR(255),
    Country_id INT,
    CONSTRAINT fk_donor_info_Donor FOREIGN KEY (donor_id)
        REFERENCES Donor (donor_id),
    CONSTRAINT fk_Countries_info_Donor FOREIGN KEY (Country_id)
        REFERENCES Countries (Country_id)
);

insert into donor_info
(donor_id,full_name,contact_number,D_address,city,Country_id
)values
(1,"Tal Djemal","050-3955562", "Ha Alumim 1", "Herzliya","2"),
(2,"Eyal Kessler","+41786530550","Hogwarts school of Witchcraft and Wizardry, Room 102",null,"3"),
(3,"Sherlock Holmes",null,"221B Baker Street","London","4"),
(4,"Shrek The Ogre",null,"Swamp","Charleston","1"),
(5,"Austin Powers","+10302301","85 Cathedral Ln","New York","1"),
(6,"Peter Griffin", "+039198312","31 Spooner Street","Quahog","1"),
(7,"Albert Eintstien",null,"112 Mercer Street1","Princeton","1"),
(8,"Patrick Star","+000031","120 Conch Street","Bikini Bottom","6"),
(9,"Elon Musk",null,"Colony 1","Spacex","5");



#Creates donor transacation table and values - FK to donor_id on donors table for only existing donor IDS
#this table is used for our trigger to not allow the same donor to donate twice in 90 days

CREATE TABLE IF NOT EXISTS D_Trans (
    D_Trans INT PRIMARY KEY AUTO_INCREMENT,
    Donor_id INT,
    D_Trans_date DATE NOT NULL,
    CONSTRAINT fk_D_Trans_Donor FOREIGN KEY (Donor_id)
        REFERENCES Donor (Donor_id)
);
 

 insert into d_trans
 (donor_id,D_Trans_date)
 values
 (1,'2022-06-20'),
 (1,'2022-01-20'),
 (1,'2021-06-20'),
 (2,'2022-03-15'),
 (2,'2021-03-15'),
 (2,'2020-03-15'),
 (3,'1888-03-30'),
 (3,'1881-03-30'),
 (3,'1889-07-30'),
 (4,'2006-12-12'),
 (5,'2005-10-16'),
 (6,'2022-06-12'),
 (7,'1930-07-01'),
 (8,'2009-06-13'),
 (9,'2022-09-27');
 
 
 #creates patient table and values - FK to blood_type_id
CREATE TABLE IF NOT EXISTS Patient (
    Patient_ID INT PRIMARY KEY AUTO_INCREMENT,
    Blood_type_id INT NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    Contact_number VARCHAR(255),
    CONSTRAINT fk_Patient_blood_type FOREIGN KEY (blood_type_id)
        REFERENCES `blood_type` (blood_type_id)
);

insert into patient
(Blood_type_id,first_name,last_name,Contact_number)
values
(6,"Teva","Yaari","+9725039481"),
(1,"Sirius", "Black","+13512512"),
(2,"Davy","Jones",null),
(7,"Jhonny","Depp","+10349183"),
(6,"Stewie","Griffin","+3019491"),
(8,"Gregg","Davies","+30130312"),
(8,"Alex","Horn","+31940103");



#creates Patient transaction table and values -FL to patient_id and blood_type id
CREATE TABLE IF NOT EXISTS P_trans (
    P_trans_id INT PRIMARY KEY AUTO_INCREMENT,
    Patient_id INT NOT NULL,
    blood_type_id INT NOT NULL,
    donor_card_id INT,
    P_Trans_date DATE NOT NULL,
    CONSTRAINT fk_P_trans_blood_type FOREIGN KEY (blood_type_id)
        REFERENCES `blood_type` (blood_type_id),
    CONSTRAINT fk_P_trans_Patient FOREIGN KEY (Patient_id)
        REFERENCES `Patient` (Patient_ID)
);
 
 insert into P_trans
 (Patient_id,blood_type_id,donor_card_id,P_Trans_date)
 values
 (1,6,1001,'2022-01-01'),
 (2,1,1001,'2020-04-12'),
 (3,2,1004,'2008-03-08'),
 (4,7,1009,'2022-03-04'),
 (5,6,1006,'2021-12-01'),
 (6,8,1002,'2020-10-01'),
 (7,8,1001,'2019-03-16');




# end of table creating and values
# ----------------------------------------------------------------------------------------------------------

#start of Reports
#ORDER -> Trigger -> Index -> Report Query -> Create View -> View view

 #TRIGGER
 
 #this trigger will not allow the same donor to donate twice in the span of 3 months(90 days)
 #checks the differences in dates for each donor relative to the most recent donation date (max date)
DELIMITER //
CREATE TRIGGER Donor_trans_90_day_check
BEFORE INSERT ON D_trans
FOR EACH ROW
BEGIN

 IF (
	SELECT datediff(new.D_Trans_date, D_Trans_date) FROM 
	(
		select d.donor_id, max(d.d_trans_date) d_trans_date from d_trans as d
		group by d.donor_id
	) as t
	where donor_id=new.donor_id) <=90
 then
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = "You can only donate blood once every 3 months";
END IF;
END//
DELIMITER ;


# ----------------------------------------------------------------------
#INDEX

#index to help speed up country names for our report. in a much larger scale there could be hundreds of country names, and we can change the where clause to whatever country we are 
#looking to include or exlude, which can help speed up the processs

create index Report_querie_country_name_idx
on countries (country_name);

#REPORT QUEREY

#this report returns the number of donors we have in each country and total.
# it returns how many of Each blood type per country, in total per blood type and in total of all donors
#use if grouping to change the name of the last row, it would incorrectly show AB- because of the joins
SELECT 
    IF(GROUPING(bt.blood_type),
        'Total Donors',
        bt.blood_type) as `Blood_type`,
    c.Country_Name,
    COUNT(*) AS '# of donors with this type'
FROM
    donor_info AS di
        INNER JOIN
    countries AS c USING (Country_id)
        INNER JOIN
    donor AS d USING (donor_id)
        INNER JOIN
    blood_type AS bt USING (blood_type_id)
WHERE
    country_name NOT LIKE '%Republic%'
        AND country_name NOT LIKE 'Mars'
GROUP BY bt.blood_type , country_name WITH ROLLUP;


# VIEW

#creates the view that will return a table that shows all unqiue blood type ids and names, in addition
#to who they can donate to and recieve from, showing names of blood types instead of ID numbers.

CREATE VIEW Blood_Donation_Information AS
    SELECT 
        bt.*,
        GROUP_CONCAT(DISTINCT (b3.blood_type)) AS don_to,
        GROUP_CONCAT(DISTINCT (b2.blood_type)) AS rec_from
    FROM
        blood_type AS BT
            INNER JOIN
        Recieve_From AS r ON bt.blood_type_id = r.blood_id
            INNER JOIN
        donate_to AS d ON bt.blood_type_id = d.blood_id
            LEFT JOIN
        blood_type AS b2 ON b2.blood_type_id = r.Recieve_From_id
            LEFT JOIN
        blood_type AS b3 ON b3.blood_type_id = d.donate_to_id
    GROUP BY blood_type_id;


#to see the View table
SELECT 
    *
FROM
    Blood_Donation_Information;


# TEST for trigger- this is only 1 month ahead - wont allow

 insert into d_trans
 (donor_id,D_Trans_date)
 values
 (1,'2022-07-20');
 
 # TEST for trigger- this is 4 months ahead - should allow

 insert into d_trans
 (donor_id,D_Trans_date)
 values
 (1,'2022-10-20');

