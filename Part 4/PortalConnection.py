import psycopg2


class PortalConnection:
    def __init__(self):
        self.conn = psycopg2.connect(
            host="localhost",
            user="postgres",
            password="postgres")
        self.conn.autocommit = True

    def getInfo(self,student):
      with self.conn.cursor() as cur:
        # Here's a start of the code for this part
        sql = """
            SELECT jsonb_build_object(
                'student', s.idnr,
                'name', s.name,
                'login', s.login,
                'program', s.program,
                'branch', s.branch,
                'finished', COALESCE(jsonb_agg(DISTINCT jsonb_build_object(
                    'course', f.coursename,
                    'code',  f.course,
                    'credits', f.credits,
                    'grade', f.grade)
                    ) FILTER(WHERE f.coursename IS NOT NULL), '[]'::jsonb),
                'registered',  COALESCE(jsonb_agg(DISTINCT jsonb_build_object(
                    'course', c.name,
                    'code', r.course,
                    'status', r.status,
                    'position', wl.position)
                    ) FILTER (WHERE c.name IS NOT NULL), '[]'::jsonb),
                'seminarCourses', ptg.seminarcourses,
                'mathCredits', ptg.mathcredits,
                'totalCredits', ptg.totalcredits,
                'canGraduate', ptg.qualified
                )::TEXT 
                FROM BasicInformation AS s LEFT JOIN
                FinishedCourses AS f ON s.idnr=f.student
                LEFT JOIN Registrations AS r ON s.idnr=r.student
                LEFT JOIN WaitingList AS wl ON r.student=wl.student AND r.course=wl.course
                LEFT JOIN Courses AS c ON r.course=c.code
                LEFT JOIN PathToGraduation AS ptg ON s.idnr=ptg.student
                WHERE s.idnr=%s
                GROUP BY s.idnr, s.name, s.login, s.program, s.branch,
                ptg.seminarcourses, ptg.mathcredits, ptg.totalcredits, ptg.qualified;
                """
        cur.execute(sql, (student,))
        res = cur.fetchone()
        if res:
            return (str(res[0]))
        else:
            return """{"student":"Not found :("}"""

    def register(self, student, courseCode):
        try:
            with self.conn.cursor() as cur:
                sql = """INSERT INTO Registrations (student, course) VALUES (%s, %s);"""
                cur.execute(sql, (student, courseCode))
            return """{"success":true}"""
        except psycopg2.Error as e:
            message = getError(e)
            return '{"success":false, "error": "'+message+'"}'

    def unregister(self, student, courseCode):
        try:
            with self.conn.cursor() as cur:
                sql="DELETE FROM Registrations WHERE student='"+student +"' AND course='"+courseCode+"';" # sql="""DELETE FROM Registrations WHERE student=%s AND course=%s;"""
                cur.execute(sql) # cur.execute(sql, (student, courseCode))
                if cur.rowcount==0:
                    return """{"success":false, "error": "nothing deleted"}"""
                else:
                    return """{"success": true}"""
        except psycopg2.Error as e:
            message = getError(e)
            return '{"success":false, "error": "'+message+'"}'

def getError(e):
    message = repr(e)
    message = message.replace("\\n"," ")
    message = message.replace("\"","\\\"")
    return message

