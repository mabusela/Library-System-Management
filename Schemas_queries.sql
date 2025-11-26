-- Create the dataBase
Create DATABASE library_db;
-- Create the tables
 use library_db;
 DROP TABLE IF EXISTS branch;
 create table branch (
		branch_id varchar(10) PRIMARY KEY,	
        manager_id varchar(10),	
        branch_address varchar(55),
        contact_no varchar(20)
 );
 
 DROP TABLE IF EXISTS employee;
 Create Table employee (
 emp_id varchar(10) PRIMARY KEY,
 emp_name  varchar(55),
 position  varchar(55),
 salary INT,	
 branch_id  varchar(25) -- FK
 );
 
 DROP TABLE IF EXISTS books;
 create table books (
 isbn varchar(25) PRIMARY KEY,
 book_title	varchar(100),
 category varchar(25),	
 rental_price float,
 status varchar(5),
 author	varchar(35),
 publisher varchar(55)
 );
 
 DROP TABLE IF EXISTS members;
 CREATE TABLE members (
 member_id varchar(10) PRIMARY KEY,
 member_name varchar(25),
 member_address varchar(25), 
 reg_date date
 );
 
 DROP TABLE IF EXISTS issued_status;
 Create Table issued_status(
 issued_id VARCHAR(10) PRIMARY KEY,
 issued_member_id VARCHAR(10), -- FK
 issued_book_name VARCHAR(100),
 issued_date DATE,
 issued_book_isbn VARCHAR(25), -- FK
 issued_emp_id VARCHAR(10)  -- FK
 );
 
 drop table if exists return_status;
 create table return_status(
 return_id	VARCHAR(10) PRIMARY KEY,
 issued_id	VARCHAR(10), -- FK
 return_book_name  VARCHAR(100),
 return_date date,
 return_book_isbn VARCHAR(25)
 );
 
 -- FOREING KEYS
 ALTER TABLE issued_status
 add constraint fk_members
 foreign key(issued_member_id)
 references members(member_id);
 
  ALTER TABLE issued_status
 add constraint fk_books
 foreign key(issued_book_isbn)
 references books(isbn);
 
 ALTER TABLE issued_status
 add constraint fk_employees
 foreign key(issued_emp_id)
 references employee(emp_id);
 
  ALTER TABLE employee
 add constraint fk_branch
 foreign key(branch_id)
 references branch(branch_id);
 
   ALTER TABLE  return_status
 add constraint fk_issue
 foreign key(issued_id)
 references issued_status(issued_id);