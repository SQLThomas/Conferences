# sql_jobhistory.R
# Demo script: monitoring your SQL Server agent jobs
# ©2019 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

# Load packages -----------------------------------------------------------
library(DBI)
library(dplyr)
library(lubridate)
library(ggplot2)


# Set database name -------------------------------------------------------
db_name <- 'MSDB2'


# Open DB connection ------------------------------------------------------
conn <- dbConnect(odbc::odbc(), dsn = 'dockersql', uid = 'Gast', pwd = 'Gast2000!')


# Prepare query statement -------------------------------------------------
sqlStmt <- paste0("SELECT sj.name, sh.run_status, CAST(sh.run_date AS varchar(8)) + ' ' +
  STUFF(STUFF(RIGHT('000000' + CAST(sh.run_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':') 'run_datetime',
  STUFF(STUFF(RIGHT('000000' + CAST(sh.run_duration as varchar(6)), 6), 3, 0, ':'), 6, 0, ':') 'run_duration'
  FROM ", db_name, ".dbo.sysjobs sj
  JOIN ", db_name, ".dbo.sysjobhistory sh
  ON sh.job_id = sj.job_id
  where sh.step_id = 0
  order by upper(sj.name), sh.run_date, sh.run_time;")


# Run query, transform result to a tibble ---------------------------------
jobhist <- dbGetQuery(conn, sqlStmt)
jobhist <- as_tibble(jobhist)
jobhist


# Transform run date, time, duration --------------------------------------
jobhist <- mutate(jobhist, run_datetime = as_datetime(run_datetime, tz = 'UTC', format = NULL), 
                  run_seconds = period_to_seconds(hms(run_duration)))
jobhist


# Show first visualizations -----------------------------------------------
ggplot(jobhist, aes(x = run_datetime, y = run_seconds, group = name, col = name)) + 
  geom_line()

ggplot(jobhist, aes(x = run_datetime, y = run_seconds)) +
  geom_line() + 
  facet_wrap(~ name, scales = 'free') + 
  theme(plot.background = element_rect(fill = 'grey80')) +
  labs(title = 'SQL Server job durations', y = 'seconds', x = NULL)


# Add colurs for run states -----------------------------------------------
jobhist <- mutate(jobhist, col = factor(run_status, c(0,1), c('red', 'darkgreen')))
jobhist
ggplot(jobhist, aes(x = run_datetime, y = run_seconds)) +
  geom_line(colour = jobhist$col, show.legend = FALSE) + 
  facet_wrap(~ name, scales = 'free') + 
  theme(plot.background = element_rect(fill = 'grey80')) +
  labs(title = 'SQL Server job durations', y = 'seconds', x = NULL)


# Add trend lines based on linear model -----------------------------------
ggplot(jobhist, aes(x = run_datetime, y = run_seconds)) +
  geom_line(colour = jobhist$col,show.legend = FALSE) + 
  geom_smooth(method = "lm", se = FALSE, colour = 'blue') + 
  facet_wrap(~ name, scales = 'free') + 
  theme(plot.background = element_rect(fill = 'grey80')) +
  labs(title = 'SQL Server job durations', y = 'seconds', x = NULL)


# Disconnect DB connection ------------------------------------------------
dbDisconnect(conn)
