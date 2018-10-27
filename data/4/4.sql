USE EDUC
GO
--定义计算机系学生基本情况视图V_Computer
CREATE VIEW V_Computer

AS

    SELECT
        sno,
        sname,
        spno,
        classno,
        birthday
    FROM student

    WHERE spno = 'cs'

WITH CHECK OPTION;
GO

--将Student、 Course 和Student_course表中学生的学号，姓名，课程号，课程名，成绩定义为视图V_S_C_G
CREATE VIEW V_S_C_G

AS

    SELECT
        student.sno,
        sname,
        course.cno,
        cname,
        score

    FROM student, course, student_course, teacher_course

    WHERE
      student.sno = student_course.sno AND student_course.tcid = teacher_course.tcid AND course.cno = teacher_course.cno

WITH CHECK OPTION;

GO
--将各系学生人数，平均年龄定义为视图V_NUM_AVG
CREATE VIEW V_NUM_AVG

AS

    SELECT
        student.dno,
        count(dno)                                       AS studnet_num,
        avg(datediff(YEAR, student.birthday, GETDATE())) AS avg_age
    FROM student
    GROUP BY dno

WITH CHECK OPTION;
GO

-- 定义一个反映学生出生年份的视图V_YEAR
CREATE VIEW V_YEAR

AS

    SELECT student.sname, student.birthday
    FROM student

WITH CHECK OPTION;

GO

--将各位学生选修课程的门数及平均成绩定义为视图V_AVG_S_G

CREATE VIEW V_AVG_S_G
AS
    SELECT
        student.sname,
        student.sno,
        count(DISTINCT course.cno) AS num_class,
        avg(student_course.score)  AS avg_score
    FROM student, student_course,
        teacher_course, course
    WHERE
      student.sno = student_course.sno AND student_course.tcid = teacher_course.tcid AND course.cno = teacher_course.cno
    GROUP BY course.cno, student.sname,student.sno
    WITH CHECK OPTION;
GO

--将各门课程的选修人数及平均成绩定义为视图V_AVG_C_G
CREATE VIEW V_AVG_C_G
AS
    SELECT
        course.cname,
        count(student_course.sno) AS num_course,
        avg(student_course.score) AS avg_course
    FROM student_course, student, teacher_course, course
    WHERE
      student_course.sno = student.sno AND student_course.tcid = teacher_course.tcid AND teacher_course.cno = course.cno
    GROUP BY course.cname
    WITH CHECK OPTION;

GO
--查询以上所建的视图结果
SELECT * from V_Computer
SELECT * from V_S_C_G
SELECT * from V_NUM_AVG
SELECT * from V_YEAR
SELECT * from V_AVG_S_G
SELECT * from V_AVG_C_G
GO

-- 查询平均成绩为90分以上的学生学号、姓名和成绩；

SELECT sno,sname, avg_score FROM V_AVG_S_G WHERE V_AVG_S_G.avg_score > 90
GO

--查询各课成绩均大于平均成绩的学生学号、姓名、课程和成绩；

SELECT
    V_S_C_G.sno,
    V_S_C_G.sname,
    V_S_C_G.cname,
    V_S_C_G.score
FROM V_S_C_G, V_AVG_C_G
WHERE V_AVG_C_G.avg_course < V_S_C_G.score
GROUP BY sno,sname,V_S_C_G.cname,score
GO

--按系统计各系平均成绩在80分以上的人数，结果按降序排列

SELECT
    student.dno,
    count(student.dno)
FROM student, V_AVG_S_G
WHERE V_AVG_S_G.sno = student.sno AND V_AVG_S_G.avg_score > 80
GROUP BY student.dno
ORDER BY count(student.dno) DESC
GO

--通过视图V_Computer，分别将学号为“S1”和“S4”的学生姓名更改为“S1_MMM”,”S4_MMM” 并查询结果;
UPDATE V_Computer SET sname='S1_MMM' WHERE V_Computer.sno='S1'
GO


UPDATE V_Computer SET sname='S4_MMM' WHERE V_Computer.sno='S4'
GO

SELECT * FROM V_Computer
GO
--通过视图V_Computer，新增加一个学生记录 ('S12','YAN XI',19,'IS')，并查询结果
INSERT INTO V_Computer
VALUES('S12', 'YAN XI', 'CS', '0001', '1999-10-12 14:40:00')
GO
--通过视图V_Computer，新增加一个学生记录 ('S13', 'YAN XI', 'CS', '0001', '1999-10-12 14:40:00')，并查询结果

INSERT INTO V_Computer
VALUES('S13', 'YAN XI', 'CS', '0001', '1999-10-12 14:40:00')
GO

--通过视图V_Computer，删除学号为“S12”和“S3”的学生信息，并查询结果
DELETE V_Computer WHERE sno='S12' OR sno='S3'
GO  

-- 要通过视图V_S_C_G，将学号为“S12”的姓名改为“S12_MMM”，是否可以实现？并说明原因
-- 要通过视图V_AVG_S_G，将学号为“S1”的平均成绩改为90分，是否可以实现？并说明原因

/*
 不可以 表到sum count avg统计函数时不可修改。
 */

--如何通过视图实现程序的逻辑独立性

/*1.逻辑独立性，主要是通过视图View的机制来保证，好处是修改数据库结构，可在一定程度上不用修改应用程序
  2.物理独立性，主要是指数据库的内部逻辑结构不依赖于数据库物理的存储机制，好处就是可以根据不同类型的物理介质选择不同的存储方式，例如顺序存储方式、B树结构等不同的方式。独立性的好处就是包容变化，隔离依赖*/

-- 在student表的sname列上建立普通降序索引
create index _student_sname_desc on student(sname desc)
GO
-- 在course表的cname列上建立唯一索引
create UNIQUE index _course_cname_dunique on course(cname);
GO

/*在student_course表的sno列上建立聚集索引*/
--不可以，在student_course在建表的时已有聚集索引sno, tcid

/*在student_course表的sno(升序), tid(升序)和score(降序)三列上建立一个普通索引*/
CREATE INDEX _student_course_sno_incre on student_course(sno,tcid,score DESC)
GO
/*将student_course表的sno列上的聚集索引删掉*/
-- 因为索引创建失败，不用删除这个索引