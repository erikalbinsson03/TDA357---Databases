CREATE FUNCTION course_register() RETURNS trigger AS $course_register$
    BEGIN 
        IF -- check if student already registered/waiting
            (NEW.student, NEW.course) IN 
                (SELECT student, course FROM Registrations) 
            THEN
                RAISE EXCEPTION 'Failure: Already registered or in waiting list'; 
        END IF;

        If EXISTS -- check if passed prereq
            (SELECT 1 
            FROM Prerequisites p
            WHERE p.course=NEW.course AND p.prerequisitedCourse NOT IN
                (SELECT pc.course FROM PassedCourses pc WHERE pc.student=NEW.student)) 
            THEN
                RAISE EXCEPTION 'Failure: Student has not passed all the prerequisite courses';
        END IF;

        IF -- check if passed already
            NEW.course IN
                (SELECT course FROM PassedCourses WHERE student=NEW.student) 
            THEN 
                RAISE EXCEPTION 'Failure: Student has passed course';
        END IF;



        IF EXISTS -- put on waitinglist if full
            (SELECT 1 
            FROM Registrations r JOIN
                LimitedCourses l ON r.course=l.code
            WHERE r.course=NEW.course AND r.status='registered'
            GROUP BY r.course, l.capacity
            HAVING COUNT(*)>=l.capacity)
            THEN
                INSERT INTO WaitingList 
                VALUES(NEW.student, NEW.course, COALESCE((SELECT MAX(position) FROM WaitingList WHERE course = NEW.course), 0) + 1);
            RETURN NULL;
        END IF;

        INSERT INTO Registered
        VALUES (NEW.student, NEW.course);

        RETURN NULL;
    END;
$course_register$ LANGUAGE plpgsql;

CREATE TRIGGER course_register INSTEAD OF INSERT OR UPDATE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION course_register();


CREATE FUNCTION course_unregister() RETURNS trigger AS $course_unregister$
    BEGIN
        IF -- check if removed student in waitlist  
            (OLD.student, OLD.course) IN (SELECT student, course FROM WaitingList)
            THEN
                UPDATE WaitingList SET position=position-1
                WHERE course=OLD.course AND position>(SELECT position FROM WaitingList WHERE student=OLD.student AND course=OLD.course);
            
            DELETE FROM WaitingList WHERE student=OLD.student AND course=OLD.course;
            RETURN OLD;
        END IF;

        IF -- check if removed student in course
            (OLD.student, OLD.course) IN (SELECT student, course FROM Registered)
            THEN
                DELETE FROM Registered WHERE student=OLD.student AND course=OLD.course;
                
                IF EXISTS -- check if course is full even after removal
                    (SELECT 1 
                    FROM Registrations r JOIN
                        LimitedCourses l ON r.course=l.code
                    WHERE r.course=OLD.course AND r.status='registered'
                    GROUP BY r.course, l.capacity
                    HAVING COUNT(*)>=l.capacity)
                    THEN
                        RETURN OLD;
                END IF;


                DECLARE 
                    acceptedStudent RECORD;
                BEGIN
                    SELECT student, position INTO acceptedStudent FROM WaitingList
                    WHERE course=OLD.course 
                    ORDER BY position ASC LIMIT 1;
                 
                    IF EXISTS -- if waitinglist for the course is not empty, take the first one into registered and update waitinglist
                        (SELECT 1 FROM WaitingList WHERE course=OLD.course)
                        THEN 
                            INSERT INTO Registered SELECT acceptedStudent.student, OLD.course; -- insert accepted student into registered
                    
                        
                            DELETE FROM WaitingList -- remove accepted student from waitlist
                            WHERE course=OLD.course AND student=acceptedStudent.student;

                            UPDATE WaitingList SET position=position-1
                            WHERE course=OLD.course AND position>acceptedStudent.position;
                    END IF;
                END;
                RETURN OLD;
        END IF;

        RETURN OLD;
    END;
$course_unregister$ LANGUAGE plpgsql;

CREATE TRIGGER course_unregister INSTEAD OF DELETE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION course_unregister();
