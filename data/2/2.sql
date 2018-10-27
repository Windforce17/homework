DROP DATABASE IF EXISTS EDUC;
GO

CREATE DATABASE EDUC
ON
  (NAME ='userdb4_data', /*数据文件的逻辑名称,注意不能与日志逻辑同名*/
  FILENAME ='/root/userdb4.mdf', /*物理名称，注意路径必须存在*/
  SIZE =5, /*数据初始长度为M*/
  MAXSIZE =10, /*最大长度为M*/
  FILEGROWTH =1) /*数据文件每次增长M*/
LOG ON
  (NAME =userdb4_log,
  FILENAME ='/root/userdb4.ldf ',
  SIZE =2,
  MAXSIZE =5,
  FILEGROWTH =1)

GO
USE EDUC;
GO


DROP TABLE IF EXISTS [student]
GO
CREATE TABLE [student] (
  [sno]      VARCHAR(20)   NOT NULL PRIMARY KEY,
  [sname]    CHAR(8)       NOT NULL,
  [sex]      CHAR(2)       NULL,
  [native]   CHAR(20)      NULL,
  [birthday] VARCHAR(20)   NULL,
  [dno]      CHAR(6)       NULL,
  [spno]     CHAR(8)       NULL,
  [classno]  CHAR(4)       NULL,
  [entime]   SMALLDATETIME NULL,
  [home]     VARCHAR(40)   NULL,
  [tel]      VARCHAR(40)   NULL
)
GO

DROP TABLE IF EXISTS [course]
GO
CREATE TABLE [course] (
  [cno]        CHAR(10) NOT NULL PRIMARY KEY,
  [spno]       CHAR(8)  NULL,
  [cname]      CHAR(20) NOT NULL,
  [ctno]       TINYINT  NULL,
  [experiment] TINYINT  NULL,
  [lecture]    TINYINT  NULL,
  [semester]   TINYINT  NULL,
  [credit]     TINYINT  NULL
)

GO

DROP TABLE IF EXISTS [student_course]
GO
CREATE TABLE [student_course] (
  [sno]   CHAR(8)  NOT NULL,
  [tcid]  SMALLINT NOT NULL,
  [score] TINYINT  NULL
    PRIMARY KEY ([sno], [tcid])
)


GO

DROP TABLE IF EXISTS [teacher]
GO
CREATE TABLE [teacher] (
  [tno]      CHAR(8)       NOT NULL PRIMARY KEY,
  [tname]    CHAR(8)       NOT NULL,
  [sex]      CHAR(2)       NULL,
  [birthday] SMALLDATETIME NULL,
  [dno]      CHAR(6)       NULL,
  [pno]      TINYINT       NULL,
  [home]     VARCHAR(40)   NULL,
  [zipcode]  CHAR(6)       NULL,
  [tel]      VARCHAR(40)   NULL,
  [email]    VARCHAR(40)   NULL
)


GO

DROP TABLE IF EXISTS [teacher_course]
GO
CREATE TABLE [teacher_course] (
  [tcid]       SMALLINT    NOT NULL PRIMARY KEY,
  [tno]        CHAR(8)     NULL,
  [spno]       CHAR(8)     NULL,
  [classno]    CHAR(4)     NULL,
  [cno]        CHAR(10)    NOT NULL,
  [semester]   CHAR(6)     NULL,
  [schoolyear] CHAR(10)    NULL,
  [classtime]  VARCHAR(40) NULL,
  [classroom]  VARCHAR(40) NULL,
  [weektime]   TINYINT     NULL
)


GO
