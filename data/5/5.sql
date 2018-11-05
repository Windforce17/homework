/*利用触发器完成记录EDUC中student_course表的修改日志，包括修改人，学生姓名，学生学号，课程名，修改前成绩，修改后成绩，修改时间，修改日志记录在表student_course_log中*/

-- 参考资料
/*
	http://www.w3school.com.cn/sql/sql_top.asp
	http://dataidol.com/tonyrogerson/2014/06/16/how-hekaton-xtp-achieves-durability-for-memory-optimised-tables/
	https://blog.csdn.net/jackmacro/article/details/6405877
	*/
CREATE TABLE student_course_log
(

  sname        char(8)       NOT NULL, --学生姓名
  sno          char(8)       NOT NULL, --学号
  cname        char(20)      NOT NULL, --课程名称
  score_before int           NULL, --修改前学生成绩
  score_after  int           NULL, --修改后学生成绩
  update_name  varchar(100)  NOT NULL, --修改者
  changetime   smalldatetime NOT NULL, --修改时间
  lsn          varchar(100)  NULL--修改日志序列号
    PRIMARY KEY (changetime, update_name)
);
go

create trigger record_update_trigger
  on student_course
  after update
AS
  BEGIN
    DECLARE @name VARCHAR(50);
    DECLARE @lsn varchar(100);
    DECLARE @updatetime smalldatetime;
    SELECT @name = SUSER_NAME();
    SELECT top 1 @updatetime = [Checkpoint Begin] FROM ::fn_dblog(null, null) ORDER BY [Checkpoint Begin] desc;

    SELECT top 1 @lsn = [Current LSN] FROM ::fn_dblog(null, null) ORDER BY [Checkpoint Begin] desc;

    INSERT INTO student_course_log (update_name, changetime, lsn) VALUES (@name, @changetime, @lsn);
    INSERT INTO student_course_log (sname, sno, cname, score_before, score_after)
    SELECT student.sname, A.sno, course.cname, a.score, b.score
    from INSERTED a,
         DELETED b,
         student,
         course,
         teacher_course,
         student_course
    WHERE student.sno = a.sno
      and teacher_course.tcid = a.tcid
      and teacher_course.cno = course.cno;

  end
go

/*编写作业，完成每周自动备份数据库*/
-- 试了试Transact-SQL 成功创建了job
-- https://docs.microsoft.com/zh-cn/sql/relational-databases/system-stored-procedures/sp-add-job-transact-sql?view=sql-server-2017
USE msdb ;
GO
EXEC dbo.sp_add_job
    @job_name = N'Weekly  Data Backup' ;
GO
EXEC sp_add_jobstep
    @job_name = N'Weekly  Data Backup',
    @step_name = N'Set database to read only',
    @subsystem = N'TSQL',
    @command = N'ALTER DATABASE EDUC SET READ_ONLY',
    @retry_attempts = 5,
    @retry_interval = 5 ;
GO
EXEC dbo.sp_add_schedule
    @schedule_name = N'RunOnce',
    @freq_type = 1,
    @active_start_time = 233000
;
USE msdb ;
GO
EXEC sp_attach_schedule
   @job_name = N'Weekly  Data Backup',
   @schedule_name = N'RunOnce';
GO
EXEC dbo.sp_add_jobserver
    @job_name = N'Weekly  Data Backup';
GO

