USE soft;
GO

DROP FUNCTION IF EXISTS jobsMinRange;
GO


CREATE FUNCTION jobsMinRange(@min_level int, @max_level int)
  RETURNS TABLE
AS
  RETURN (select job_desc
      from jobs
      where min_lvl between @min_level and @max_level)
GO

DROP PROCEDURE IF EXISTS jobs_MinRange;
GO

CREATE PROCEDURE jobs_MinRange
    @min_level INT, @max_level INT
AS
  SELECT *
  FROM jobsMinRange(@min_level, @max_level)
