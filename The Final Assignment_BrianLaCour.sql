--**********************************************************************************************--
-- Title: ITFnd130Final
-- Author: BrianLaCour
-- Desc: This file demonstrates how to design and create; 
--       tables, views, and stored procedures
-- Change Log: When,Who,What
-- 2017-01-01,BrianLaCour,Created File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'ITFnd130FinalDB_BrianLaCour')
	 Begin 
	  Alter Database [ITFnd130FinalDB_BrianLaCour] set Single_user With Rollback Immediate;
	  Drop Database ITFnd130FinalDB_BrianLaCour;
	 End
	Create Database ITFnd130FinalDB_BrianLaCour;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use ITFnd130FinalDB_BrianLaCour;

-- Create Tables (Review Module 01)-- 
Create Table Courses
 ([CourseID] [int] IDENTITY(1,1) NOT NULL 
 ,[CourseName] [nvarchar](100) NOT NULL
 ,[CourseStartDate] [Date] NULL
 ,[CourseEndDate] [Date] NULL
 ,[CourseStartTime] [Time](2) NULL
 ,[CourseEndTime] [Time](2) NULL
 ,[CourseDaysOfWeek] [nVarchar](100) NULL
 ,[CourseCurrentPrice] [Money] NULL
 );
go

Create Table Students
 ([StudentID] [int] IDENTITY(1,1) NOT NULL
 ,[StudentFirstName] [nvarchar](100) NULL
 ,[StudentLastName] [nvarchar](100) NULL
 ,[StudentEmail] [nvarchar](100) NULL
 ,[StudentNumber] [nvarchar](100) NULL
 ,[StudentPhoneNumber] [nchar](100) NULL
 ,[StudentStreetAddress] [nvarchar](100) NULL
 ,[StudentCity] [nvarchar](100) NULL
 ,[StudentStateCode] [nchar](2) NULL
 ,[StudentZipCode] [nchar](5) NULL
 );
go

Create Table Enrollments
 ([EnrollmentID] int IDENTITY(1,1) NOT NULL
 ,[CourseID] [int] NOT NULL 
 ,[StudentID] [int] NOT NULL
 ,[EnrollmentDate] [date] NULL
 ,[CourseAmountPaid] [Money] NULL
 );
go


-- Add Constraints (Review Module 02) -- 
Begin  -- Courses
 Alter Table Courses
  Add Constraint pkCourses 
   Primary Key CLUSTERED (CourseID);

 Alter Table Courses 
  Add Constraint ukCourses 
   Unique (CourseName);

 Alter Table Courses
  Add Constraint dfCourseStartDate
   Default GetDate() For CourseStartDate;

 Alter Table Courses
  Add Constraint dfCourseEndDate
   Default GetDate() For CourseEndDate;
		
 Alter Table Courses
  Add Constraint dfCourseStartTime
   Default GetDate() For CourseStartTime;

 Alter Table Courses
  Add Constraint dfCourseEndTime
   Default GetDate() For CourseEndTime;

 Alter Table Courses
  Add Constraint ckCourseCurrentPriceZeroOrHigher
   Check ([CourseCurrentPrice] >= 0);

Alter Table Courses
 Add Constraint ckCourseStartDateBeforeEndDate
  Check ([CourseStartDate] < [CourseEndDate]);

Alter Table Courses
 Add Constraint ckCourseEndDateAfterStartDate
  Check ([CourseEndDate] > [CourseStartDate]);
End
go

Begin -- Students
 Alter Table Students
  Add Constraint pkStudents
   Primary Key CLUSTERED (StudentID);

 Alter Table Students 
  Add Constraint ukStudentNumber 
   Unique (StudentNumber);
		  
 Alter Table Students
  Add Constraint ukStudentEmail
   Unique (StudentEmail);--Set unique so multiple accounts can't be made with the same email

 Alter Table Students
  Add Constraint ckStudentEmail
   Check (StudentEmail like '%_@_%._%');

 Alter Table Students
  Add Constraint ckStudentStateCode
   Check (StudentStateCode like '[a-z][a-z]');

 Alter Table Students
  Add Constraint ckZipCode
   Check (StudentZipCode BETWEEN 00601 AND 99929);-- Actual range of Zip Codes posted by USPS
 
 Alter Table Students
  Add Constraint ckZipCodeFormat
   Check (StudentZipCode like '[0-9][0-9][0-9][0-9][0-9]'
    or StudentZipCode like '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
End
go

Begin -- Enrollments
 Alter Table Enrollments 
  Add Constraint pkEnrollments 
   Primary Key Clustered (EnrollmentID);

 Alter Table Enrollments
  Add Constraint dfEnrollmentDate
   Default GetDate() For EnrollmentDate;

 Alter Table Enrollments
  Add Constraint fkEnrollmentsToCourses
   Foreign Key (CourseID) References Courses(CourseID);

 Alter Table Enrollments
  Add Constraint fkEnrollmentsToStudents
   Foreign Key (StudentID) References Students(StudentID);

 Alter Table Enrollments 
  Add Constraint ckCourseAmountPaidZeroOrHigher 
   Check ([CourseAmountPaid] >= 0);

End 
go

-- Add Views (Review Module 03 and 06) -- 
Create or Alter View vCourses With Schemabinding
 As 
  Select Top 1000000000
   Courses.CourseID, 
   Courses.CourseName, 
   Courses.CourseStartDate, 
   Courses.CourseEndDate, 
   Courses.CourseStartTime, 
   Courses.CourseEndTime, 
   Courses.CourseDaysOfWeek, 
   Courses.CourseCurrentPrice
  From dbo.Courses
   Order by Courses.CourseID ASC;
Go
  
Create or Alter View vStudents With Schemabinding
 As 
  Select Top 1000000000
   Students.StudentID,
   Students.StudentFirstName, 
   Students.StudentLastName, 
   Students.StudentEmail, 
   Students.StudentNumber, 
   Students.StudentPhoneNumber, 
   Students.StudentStreetAddress, 
   Students.StudentCity, 
   Students.StudentStateCode, 
   Students.StudentZipCode
  From dbo.Students
   Order by Students.StudentID;
Go

Create or Alter View vEnrollments With Schemabinding
 As 
  Select Top 1000000000
   Enrollments.EnrollmentID,
   Enrollments.CourseID, 
   Enrollments.StudentID, 
   Enrollments.EnrollmentDate, 
   Enrollments.CourseAmountPaid
  From dbo.Enrollments
   Order By Enrollments.EnrollmentID;
Go

Create or Alter View vEnrollmentsWithCostsAndPaid With Schemabinding
 As
  Select Top 1000000000
   vEnrollments.EnrollmentID,
   vEnrollments.StudentID,		  
   CONCAT(vStudents.StudentLastName, ', ', vStudents.StudentFirstName) AS StudentFullName,		  
   vEnrollments.CourseID,
   vCourses.CourseName,
   vCourses.CourseCurrentPrice,
   vEnrollments.CourseAmountPaid,
   SUM(vCourses.CourseCurrentPrice - vEnrollments.CourseAmountPaid) AS StudentRemainingBalance
  From dbo.vEnrollments
   Inner Join dbo.vCourses on vEnrollments.CourseID = vCourses.CourseID
   Inner Join dbo.vStudents on vEnrollments.StudentID = vStudents.StudentID
  Group By vEnrollments.EnrollmentID, vEnrollments.StudentID, vStudents.StudentLastName, vStudents.StudentFirstName, vEnrollments.CourseID, vCourses.CourseName, vCourses.CourseCurrentPrice, vEnrollments.CourseAmountPaid
  Order By vEnrollments.EnrollmentID
Go
	 
Create or Alter View vOpenBalances With Schemabinding
 As
  Select Top 1000000000
   vEnrollments.EnrollmentID,
   vEnrollments.StudentID,		  
   CONCAT(vStudents.StudentLastName, ', ', vStudents.StudentFirstName) AS StudentFullName,		  
   vEnrollments.CourseID,
   vCourses.CourseName,
   vCourses.CourseCurrentPrice,
   vEnrollments.CourseAmountPaid,
   SUM(vCourses.CourseCurrentPrice - vEnrollments.CourseAmountPaid) AS StudentRemainingBalance
  From dbo.vEnrollments
   Inner Join dbo.vCourses on vEnrollments.CourseID = vCourses.CourseID
   Inner Join dbo.vStudents on vEnrollments.StudentID = vStudents.StudentID
   Inner Join dbo.vEnrollmentsWithCostsAndPaid on vEnrollments.EnrollmentID = vEnrollmentsWithCostsAndPaid.EnrollmentID
   Where vEnrollmentsWithCostsAndPaid.StudentRemainingBalance > 0
  Group By vEnrollments.EnrollmentID, vEnrollments.StudentID, vStudents.StudentLastName, vStudents.StudentFirstName, vEnrollments.CourseID, vCourses.CourseName, vCourses.CourseCurrentPrice, vEnrollments.CourseAmountPaid
  Order By vEnrollments.EnrollmentID
Go

--< Test Tables by adding Sample Data >--  
Insert Into dbo.Courses
 (CourseName, CourseStartDate, CourseEndDate, CourseStartTime, CourseEndTime, CourseDaysOfWeek, CourseCurrentPrice)
 Values
  ('SQL1 - Winter 2017', '2017-01-10', '2017-01-24', '6:00','8:50', 'T', 399),
  ('SQL2 - Winter 2017', '2017-01-31', '2017-02-14', '6:00','8:50', 'T', 399);
GO

Insert Into dbo.Students
 (StudentFirstName, StudentLastName, StudentEmail, StudentNumber, StudentPhoneNumber, StudentStreetAddress, StudentCity, StudentStateCode, StudentZipCode)
 Values
  ('Bob', 'Smith', 'Bsmith@HipMail.com', 'B-Smith-071', '(206) 111-2222', '123 Main St.', 'Seattle', 'WA', 98001),
  ('Sue', 'Jones', 'SueJones@YaYou.com', 'S-Jones-003', '(206) 231-4321', '333 1st Ave.', 'Seattle', 'WA', 98001);
Go

Insert Into dbo.Enrollments
 (CourseID, StudentID, EnrollmentDate, CourseAmountPaid)
 Values
  (1, 1, '20170103', 399),
  (1, 2, '20170112', 349),
  (2, 1, '20161214', 399),
  (2, 2, '20161214', 349);
Go

-- Add Stored Procedures (Review Module 04 and 08) --
Create or Alter
Procedure pViewCourses
As
 Begin
  Select
   vCourses.CourseID,
   vCourses.CourseName,
   vCourses.CourseStartDate,
   vCourses.CourseEndDate,
   vCourses.CourseStartTime,
   vCourses.CourseEndTime,
   vCourses.CourseDaysOfWeek,
   vCourses.CourseCurrentPrice
   From vCourses;
 End
Go

Create or Alter
Procedure pViewStudents
As
 Begin
  Select 
   vStudents.StudentID,
   vStudents.StudentFirstName,
   vStudents.StudentLastName,
   vStudents.StudentEmail,
   vStudents.StudentNumber,
   vStudents.StudentPhoneNumber,
   vStudents.StudentStreetAddress,
   vStudents.StudentCity,
   vStudents.StudentStateCode,
   vStudents.StudentZipCode
  From vStudents;
 End
Go

Create or Alter
Procedure pViewEnrollments
As
 Begin
  Select
   vEnrollments.EnrollmentID,
   vEnrollments.CourseID,
   vEnrollments.StudentID,
   vEnrollments.EnrollmentDate,
   vEnrollments.CourseAmountPaid  
  From vEnrollments;
 End
Go

Create or Alter
Procedure pViewEnrollmentsWithCostsAndPaid
As
 Begin
  Select * From vEnrollmentsWithCostsAndPaid
 End
Go

Create or Alter
Function dbo.fBalanceRemainingOnCourses(@StudentIDBalanceFind int)
Returns Table
As
 Return
  Select
   vEnrollmentsWithCostsAndPaid.EnrollmentID,
   vEnrollmentsWithCostsAndPaid.StudentID,
   vEnrollmentsWithCostsAndPaid.StudentFullName,
   vEnrollmentsWithCostsAndPaid.CourseID,
   vEnrollmentsWithCostsAndPaid.CourseName,
   vEnrollmentsWithCostsAndPaid.CourseCurrentPrice,
   vEnrollmentsWithCostsAndPaid.CourseAmountPaid,
   vEnrollmentsWithCostsAndPaid.StudentRemainingBalance
  From
   vEnrollmentsWithCostsAndPaid
  Where
   vEnrollmentsWithCostsAndPaid.StudentID = @StudentIDBalanceFind
Go

Create or Alter 
Procedure pOpenBalances
AS
 Begin
  Select * From vOpenBalances
 End
Go

Create or Alter Proc pInsStudents
 (@StudentFirstName nvarchar(100),
  @StudentLastName nvarchar(100),
  @StudentEmail nvarchar(100))
As
 Begin
  Begin Try
   Begin Tran;
    Insert Into Students (StudentFirstName, StudentLastName, StudentEmail)
     Values (@StudentFirstName, @StudentLastName, @StudentEmail);
   Commit Tran;
  End Try
  Begin Catch
   Print 'There was a error. Common issues include: Duplicate Email Addresses!' 
   Print Error_Number();  
   Print Error_Message();
   Rollback Tran;
  End Catch
 End
go

Alter Proc pInsStudents
 (@StudentFirstName nvarchar(100)
 ,@StudentLastName nvarchar(100)
 ,@StudentEmail nvarchar(100)
 )
As
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Tran;
    Insert Into Students (StudentFirstName, StudentLastName, StudentEmail)
     Values (@StudentFirstName, @StudentLastName, @StudentEmail);
   Commit Tran;
   Set @RC = +1;
  End Try
  Begin Catch
   Print Error_Number();  
   Print Error_Message();
   Set @RC = -1;
   Rollback Tran;
  End Catch
  Return @RC;
 End
go

Create Proc pUpdStudents
 (@StudentID int
 ,@StudentFirstName nvarchar(100)
 ,@StudentLastName nvarchar(100)
 ,@StudentEmail nvarchar(100)
 )
As
 Begin
  Begin Tran
   Update Students 
    Set StudentFirstName = @StudentFirstName
	   ,StudentLastName = @StudentLastName
	   ,StudentEmail = @StudentEmail
     Where StudentID = @StudentID;
  Commit Tran
 End
go

Create or Alter Proc pDelStudents
 (@StudentID int)
As
 Begin
  Begin Tran
   Delete 
    From Students 
     Where StudentID = @StudentID;
  Commit Tran
 End
go

Create or Alter Proc pSelStudents
(@StudentID int = 0)
As
 Begin
  Select 
    StudentID
   ,StudentFirstName
   ,StudentLastName
   ,StudentEmail 
   From Students
    Where StudentID = @StudentID 
	OR @StudentID = 0;
 End
go



-- Set Permissions --
Deny Select, Insert, Update, Delete On dbo.Courses to Public;
Go
Deny Select, Insert, Update, Delete On dbo.Students to Public;
Go
Deny Select, Insert, Update, Delete On dbo.Enrollments to Public;
Go
Grant Select On dbo.vCourses to Public;
Go
Grant Select On dbo.vStudents to Public;
Go
Grant Select On dbo.vEnrollments to Public;
Go
Grant Select On dbo.vEnrollmentsWithCostsAndPaid to Public;
Go
Grant Select On dbo.vOpenBalances to Public;
Go
--< Test Sprocs >-- 
Exec pViewCourses
Exec pViewStudents
Exec pViewEnrollments
Exec pViewEnrollmentsWithCostsAndPaid
Select * From fBalanceRemainingOnCourses(1)
Select * From fBalanceRemainingOnCourses(2)
Exec pOpenBalances
Declare @Status int;
Exec @Status = pInsStudents 
 @StudentFirstName = 'Brian',
 @StudentLastName = 'LaCour',
 @StudentEmail = 'BALaCour@WU.edu';
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Common Issues: Duplicate Data'
  End as [Status]
Select * From vStudents Where StudentID = @@IDENTITY
Exec pViewStudents
Exec pViewStudents
Exec pUpdStudents 
 @StudentID = 3,
 @StudentFirstName = 'Brian',
 @StudentLastName = 'LaCour',
 @StudentEmail = 'BALaCour@UW.edu';
Exec pViewStudents
Exec pDelStudents
 @StudentID = 3;
Select Case @Status
  When +1 Then 'Delete was successful!'
  When -1 Then 'Delete failed! Common Issues: Foriegn Key Violation'
  End as [Status];
Select * From vStudents Where StudentID = @@IDENTITY;
Exec pViewStudents
Exec pSelStudents;
Exec pSelStudents @StudentID = 1;
Exec pSelStudents @StudentID = 2;
--{ IMPORTANT!!! }--
-- To get full credit, your script must run without having to highlight individual statements!!!  
/**************************************************************************************************/