-- sql_jobhistory.sql
-- Script for retrieving agent job information in SQL Server
-- ©2019 Thomas Hütter, this script is provided as-is for demo and educational use only,
-- without warranty of any kind for any other purposes, so run at your own risk!

SELECT @@VERSION AS Version;

-- Show job-related tables in msdb
USE msdb;

SELECT * FROM sys.tables
WHERE name LIKE '%sysjob%';

-- For this demo, switch to a copy of msdb
-- and find the releevant data
USE MSDB2;

SELECT * FROM dbo.sysjobs;

SELECT * FROM dbo.sysjobhistory;

SELECT sj.name, sh.run_status, sh.run_date, sh.run_time, sh.run_duration
  FROM sysjobs sj 
  JOIN sysjobhistory sh 
  ON sh.job_id = sj.job_id
  WHERE sh.step_id = 0
  ORDER BY sj.name, sh.run_date, sh.run_time;

SELECT sj.name, sh.run_status, STUFF(STUFF(CAST(sh.run_date AS varchar(8)), 5, 0, '-'), 8, 0, '-') + ' ' +
  STUFF(STUFF(RIGHT('000000' + CAST(sh.run_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':') 'run_datetime',
  STUFF(STUFF(RIGHT('000000' + CAST(sh.run_duration as varchar(6)), 6), 3, 0, ':'), 6, 0, ':') 'run_duration'
  FROM sysjobs sj
  JOIN sysjobhistory sh
  ON sh.job_id = sj.job_id
  where sh.step_id = 0
  order by sj.name, sh.run_date, sh.run_time;

-- Introducing R

-- Bring the R script to SQL
EXEC sp_configure 'external scripts enabled', 1;
RECONFIGURE WITH OVERRIDE;

EXEC sp_execute_external_script   
@language = N'R', 
@script= N' 
OutputDataSet <- InputDataSet', 
@input_data_1 =N'SELECT 1 AS hello' 
WITH RESULT SETS (([hello] int not null)); 

DECLARE @input_query NVARCHAR(MAX) = N'SELECT sj.name, sh.run_status, 
  STUFF(STUFF(CAST(sh.run_date AS varchar(8)), 5, 0, ''-''), 8, 0, ''-'') + '' '' +
  STUFF(STUFF(RIGHT(''000000'' + CAST(sh.run_time as varchar(6)), 6), 3, 0, '':''), 6, 0, '':'') ''run_datetime'',
  STUFF(STUFF(RIGHT(''000000'' + CAST(sh.run_duration as varchar(6)), 6), 3, 0, '':''), 6, 0, '':'') ''run_duration''
  FROM sysjobs sj
  JOIN sysjobhistory sh
  ON sh.job_id = sj.job_id
  where sh.step_id = 0
  order by upper(sj.name), sh.run_date, sh.run_time;'

DECLARE @r_script NVARCHAR(MAX) = N' 
# library(DBI)
library(dplyr)
library(lubridate)
library(ggplot2)
jobhist <- as_tibble(jobhist)
jobhist <- mutate(jobhist, run_datetime = as_datetime(run_datetime), 
  run_seconds = period_to_seconds(hms(run_duration)),
  col = factor(run_status, c(0,1), c(''red'', ''black'')))

png(''/var/opt/extdir/_JobHistory.png'', width = 1280, height = 800)
print(ggplot(jobhist, aes(x = run_datetime, y = run_seconds)) +
  geom_line(colour = jobhist$col,show.legend = FALSE) + 
  geom_smooth(method = ''lm'', se = FALSE, colour = ''blue'') + 
  facet_wrap(~ toupper(name), scales = ''free'') + 
  theme(plot.background = element_rect(fill = ''grey80'')) +
  labs(title = ''SQL Server job durations'', y = ''seconds'', x = NULL))
dev.off()
# print(jobhist[jobhist$run_status == 0, ], n = 10)
out <- data.frame(''_JobHistory.png'')
'
EXEC sp_execute_external_script   
@language = N'R', 
@script = @r_script,
@input_data_1 = @input_query,
@input_data_1_name = N'jobhist',
@output_data_1_name = N'out'
WITH RESULT SETS (([Filename] varchar(50))); 
