
create database SQL_project_trips;
use sql_project_trips;
-- 1. Customers
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    RegistrationDate DATE
);

-- 2. Drivers
CREATE TABLE Drivers (
    DriverID INT PRIMARY KEY,
    Name VARCHAR(100),
    Rating DECIMAL(2,1),
    VehicleID INT
);

-- 3. Cabs
CREATE TABLE Cabs (
    CabID INT PRIMARY KEY,
    CabType VARCHAR(20),
    RegistrationNumber VARCHAR(20),
    Capacity INT
);

-- 4. Bookings
CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY,
    CustomerID INT,
    DriverID INT,
    CabID INT,
    BookingDate DATETIME,
    PickupLocation VARCHAR(100),
    DropoffLocation VARCHAR(100),
    TripStart DATETIME,
    TripEnd DATETIME,
    DistanceKM DECIMAL(5,2),
    Fare DECIMAL(10,2),
    Status VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID),
    FOREIGN KEY (CabID) REFERENCES Cabs(CabID)
);

-- 5. Feedback
CREATE TABLE Feedback (
    FeedbackID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT,
    CustomerRating INT,
    DriverRating INT,
    Comments TEXT,
    CancellationReason VARCHAR(100),
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

-- 6. TripDetails
CREATE TABLE TripDetails (
    TripID INT PRIMARY KEY,
    BookingID INT,
    StartTime DATETIME,
    EndTime DATETIME,
    DistanceKM DECIMAL(5,2),
    Fare DECIMAL(10,2),
    PaymentMethod VARCHAR(20),
    SurgeMultiplier DECIMAL(3,2),
    Stops INT,
    GPSRoute TEXT,
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
    );
    
    
LOAD DATA INFILE 'D:\\SQL\\Customers.csv'
INTO TABLE Customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(CustomerID, Name, Email, Phone, RegistrationDate);

LOAD DATA INFILE 'D:/SQL/Drivers.csv'
INTO TABLE Drivers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(DriverID, Name, Rating, VehicleID);

LOAD DATA INFILE 'D:/SQL/Cabs.csv'
INTO TABLE Cabs
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(CabID, CabType, RegistrationNumber, Capacity);

LOAD DATA INFILE 'D:/SQL/Bookings.csv'
INTO TABLE Bookings
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(BookingID, CustomerID, DriverID, CabID, BookingDate, PickupLocation, DropoffLocation, TripStart, TripEnd, DistanceKM, Fare, Status);

LOAD DATA INFILE 'D:/SQL/Feedback.csv'
INTO TABLE Feedback
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(BookingID, CustomerRating, DriverRating, Comments, CancellationReason);

LOAD DATA INFILE 'D:/SQL/TripDetails.csv'
INTO TABLE TripDetails
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(TripID, BookingID, StartTime, EndTime, DistanceKM, Fare, PaymentMethod, SurgeMultiplier, Stops, GPSRoute);