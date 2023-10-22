-- Create tbl_DimDemo with DemoID as an identity column
CREATE TABLE tbl_DimDemo
(
    DemoID INT IDENTITY(1,1) PRIMARY KEY,
    DemoName VARCHAR(255) NOT NULL,
);