-- This file will contain all your tables
CREATE TABLE Departments(
    name TEXT PRIMARY KEY NOT NULL,
    abbreviation TEXT UNIQUE NOT NULL
) ;

CREATE TABLE Programs(
    name TEXT PRIMARY KEY NOT NULL,
    abbreviation TEXT UNIQUE NOT NULL
) ;

CREATE TABLE ProgramsIn(
    department TEXT NOT NULL REFERENCES Departments ON DELETE CASCADE,
    program TEXT NOT NULL REFERENCES Programs ON DELETE CASCADE,
    PRIMARY KEY(department, program) 
) ;

CREATE TABLE Students(
    idnr CHAR(10) PRIMARY KEY CHECK(idnr NOT LIKE '%[^0-9]%'),
    name TEXT NOT NULL,
    login TEXT UNIQUE NOT NULL ,
    program TEXT NOT NULL REFERENCES Programs ON DELETE CASCADE,
    UNIQUE(idnr, program)

) ;

CREATE TABLE Branches(
    name TEXT,
    program TEXT REFERENCES Programs ON DELETE CASCADE,
    PRIMARY KEY(name, program)
) ;

CREATE TABLE Courses(
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    credits FLOAT NOT NULL CHECK(credits > 0),
    department TEXT NOT NULL REFERENCES Departments ON DELETE CASCADE
) ;

CREATE TABLE LimitedCourses(
    code CHAR(6) PRIMARY KEY REFERENCES Courses ON DELETE CASCADE,
    capacity INT NOT NULL CHECK(capacity >= 0)
) ;

CREATE TABLE StudentBranches(
    student CHAR(10) PRIMARY KEY REFERENCES Students ON DELETE CASCADE,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY(branch, program) REFERENCES Branches(name, program) ON DELETE CASCADE,
    FOREIGN KEY(student, program) REFERENCES Students(idnr, program) ON DELETE CASCADE
) ;

CREATE TABLE Classifications(
    name TEXT PRIMARY KEY
) ;

CREATE TABLE Classified(
    course CHAR(6) NOT NULL REFERENCES Courses ON DELETE CASCADE,
    classification TEXT NOT NULL REFERENCES Classifications ON DELETE CASCADE,
    PRIMARY KEY(course,classification)
) ;

CREATE TABLE MandatoryProgram(
    course CHAR(6) NOT NULL REFERENCES Courses ON DELETE CASCADE,
    program TEXT NOT NULL,
    PRIMARY KEY(course, program)
) ;

CREATE TABLE MandatoryBranch(
    course CHAR(6) NOT NULL REFERENCES Courses ON DELETE CASCADE,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY(course, branch, program),
    FOREIGN KEY(branch, program) REFERENCES Branches(name, program) ON DELETE CASCADE
) ; 

CREATE TABLE RecommendedBranch(
    course CHAR(6) NOT NULL REFERENCES Courses ON DELETE CASCADE,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY(course, branch, program),
    FOREIGN KEY(branch, program) REFERENCES Branches(name, program) ON DELETE CASCADE
) ; 

CREATE TABLE Registered(
    student CHAR(10) NOT NULL REFERENCES Students ON DELETE CASCADE,
    course CHAR(6) NOT NULL REFERENCES Courses ON DELETE CASCADE,
    PRIMARY KEY(student, course)
) ;

CREATE TABLE Taken(
    student CHAR(10) NOT NULL REFERENCES Students ON DELETE CASCADE,
    course CHAR(6) NOT NULL REFERENCES Courses ON DELETE CASCADE,
    grade CHAR(1) NOT NULL CHECK(grade IN ('U','3','4','5')),
    PRIMARY KEY(student, course)
) ; 

CREATE TABLE WaitingList(
    student CHAR(10) NOT NULL REFERENCES Students ON DELETE CASCADE,
    course CHAR(6) NOT NULL REFERENCES LimitedCourses ON DELETE CASCADE,
    position INT NOT NULL CHECK(position > 0),
    PRIMARY KEY(student, course),
    UNIQUE(course, position)
) ; 

CREATE TABLE Prerequisites(
    course CHAR(6) NOT NULL REFERENCES Courses ON DELETE CASCADE,
    prerequisitedCourse CHAR(6) NOT NULL REFERENCES Courses ON DELETE CASCADE,
    PRIMARY KEY(course, prerequisitedCourse)
)