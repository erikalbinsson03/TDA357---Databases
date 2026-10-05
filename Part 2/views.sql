CREATE VIEW BasicInformation AS 
    SELECT Stud.idnr, Stud.name, Stud.login, Stud.program, Bra.branch
        FROM Students AS Stud LEFT JOIN
        StudentBranches AS Bra ON Stud.idnr=Bra.student
    ORDER BY idnr ASC ;

CREATE VIEW FinishedCourses AS
    SELECT Tak.student, Tak.course, Cou.name AS coursename, Tak.grade, Cou.credits
        FROM Taken AS Tak INNER JOIN
        Courses AS Cou ON Tak.course=Cou.code
    ORDER BY student ASC ;

CREATE VIEW Registrations AS
    SELECT Reg.student, Reg.course, 'registered' AS status
        FROM Registered AS Reg
        UNION
        SELECT Wait.student, Wait.course, 'waiting' AS status
        FROM WaitingList AS Wait 
    ORDER BY status, course, student ASC ;

CREATE VIEW PassedCourses AS
    SELECT Fin.student, Fin.course, Fin.credits
        FROM FinishedCourses AS Fin
        WHERE Fin.grade IN ('3','4','5') 
    ORDER BY student, course ASC ;

CREATE VIEW UnreadMandatory AS
    SELECT Stu.idnr AS student, MandPro.course
        FROM Students AS Stu INNER JOIN 
        MandatoryProgram AS MandPro ON Stu.program=MandPro.program 
    UNION 
    SELECT StuBra.student AS student, MandBra.course
        FROM StudentBranches AS StuBra INNER JOIN
        MandatoryBranch AS MandBra ON StuBra.branch=MandBra.branch AND StuBra.program=MandBra.program
    EXCEPT
    SELECT Pass.student, Pass.course
        FROM PassedCourses AS Pass 
    ORDER BY student, course ASC ; 

CREATE VIEW PathToGraduation AS
    SELECT student, totalCredits, mandatoryLeft, mathCredits, seminarCourses, 
    CASE 
        WHEN mandatoryLeft=0
        AND recommendedCredits>=10
        AND mathCredits>=20
        AND seminarCourses>=1
        THEN TRUE 
        ELSE FALSE 
    END AS qualified
    FROM(
         WITH 
        totalCreditsQuery AS
            (SELECT student, SUM(credits) AS totalCredits
            FROM PassedCourses
            GROUP BY student),
        
        mandatoryLeftQuery AS
            (SELECT student, COUNT(course) AS mandatoryLeft
            FROM UnreadMandatory
            GROUP BY student),

        mathCreditsQuery AS
            (SELECT Pass.student, SUM(Pass.credits) AS mathCredits
            FROM PassedCourses AS Pass
            LEFT JOIN Classified AS Class ON Pass.course=Class.course
            WHERE Class.classification='math'
            GROUP BY Pass.student),

        seminarCoursesQuery AS
            (SELECT Pass.student, COUNT(Pass.course) AS seminarCourses
            FROM PassedCourses AS Pass
            LEFT JOIN Classified AS Class ON Pass.course=Class.course
            WHERE Class.classification='seminar'
            GROUP BY Pass.student),

        RecommendedCourses AS
            (SELECT Pass.student, SUM(Pass.credits) AS recommendedCredits
            FROM PassedCourses AS Pass 
            INNER JOIN StudentBranches AS StuBra ON Pass.student=StuBra.student
            INNER JOIN RecommendedBranch AS RecBra 
                ON StuBra.branch=RecBra.branch
                AND StuBra.program=RecBra.program 
                AND Pass.course=RecBra.course
            GROUP BY Pass.student),

        allColumns AS
            (SELECT Stu.idnr AS student, 
            COALESCE(tot.totalCredits, 0) AS totalCredits, 
            COALESCE(man.mandatoryLeft, 0) AS mandatoryLeft, 
            COALESCE(math.mathCredits, 0) AS mathCredits, 
            COALESCE(semi.seminarCourses, 0) AS seminarCourses,
            COALESCE(rec.recommendedCredits, 0) AS recommendedCredits
            FROM Students AS Stu
            LEFT JOIN totalCreditsQuery AS tot ON Stu.idnr=tot.student
            LEFT JOIN mandatoryLeftQuery AS man ON Stu.idnr=man.student
            LEFT JOIN mathCreditsQuery AS math ON Stu.idnr=math.student
            LEFT JOIN seminarCoursesQuery AS semi ON Stu.idnr=semi.student
            LEFT JOIN RecommendedCourses AS rec ON Stu.idnr=rec.student)
    
    SELECT * FROM allColumns
    ) ;