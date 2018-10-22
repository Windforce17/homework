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