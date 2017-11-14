/*QUESTION:
  1. Are user's search experience generally good or bad?
  
  ANSWER:
  User tend to use search_autocompletion more often than search_run
  
  DEFINITION of "session":
  All events are ordered by user_id and occurred time, then divided into sessions.  
  A session is a collection of events which includes events from a login event to the next 
  login event of the same user exclude the second the login event*/

SELECT week,
       SUM(search_auto) AS num_of_auto,
       SUM(search_run) AS num_of_run
FROM(
       SELECT user_id,
             occurred_at,
             event_name,
             week,
             CASE WHEN sub.event_name='search_autocomplete' THEN 1 ELSE 0 END AS search_auto,
             CASE WHEN sub.event_name='search_run' THEN 1 ELSE 0 END AS search_run
      FROM(
            SELECT *,
                   DATE_TRUNC('week', occurred_at) AS week
              FROM tutorial.yammer_events 
          ) sub  
) sub2

GROUP BY week
ORDER BY week