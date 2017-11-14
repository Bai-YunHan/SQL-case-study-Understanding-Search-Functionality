/*QUESTION:
  1. Are user's search experience generally good or bad?
  
  ANSWER:
  User uses search_autocomplete two time's more than search_run in a session when search is needed,
  
  DEFINITION of "session":
  All events are ordered by user_id and occurred time, then divided into sessions.  
  A session is a collection of events which includes events from a login event to the next 
  login event of the same user exclude the second the login event*/

SELECT ---COUNT(user_id) AS session_with_search,
       AVG(search_auto_percent) AS percent_search_auto,
       AVG(search_run_percent) AS percent_search_run
  FROM (/*TABLE sub4: */
        SELECT user_id,
               session,
               100*search_auto_count/total_event AS search_auto_percent,
               100*search_run_count/total_event AS search_run_percent
          FROM(
            /* TABLE sub3: Columns: {total_event:count the total number of event in each seassion,
                                     search_auto_count: count the number of search_auto in each session,
                                     search_run_count: count the number of search_run in each session}*/
            SELECT sub2.user_id,
                   sub2.session,
                   COUNT(session) AS total_event,
                   SUM(search_auto) AS search_auto_count,
                   SUM(search_run) AS search_run_count,
                   SUM(other) AS other
                   
               FROM 
                  ( /* TABLE sub2: Columns: {search_auto: filter out search_autocomplete,
                                             search_run: filter out search_run,
                                             other: filter out other event}
                                   Divide all events into sessions. */
                    SELECT *,
                           SUM(login_log) OVER (PARTITION BY user_id ORDER BY id) AS session,
                           CASE WHEN event_name = 'search_autocomplete' THEN 1 ELSE 0 END AS search_auto,
                           CASE WHEN event_name = 'search_run' THEN 1 ELSE 0 END AS search_run,
                           CASE WHEN event_name != 'search_autocomplete' AND event_name != 'search_run' THEN 1 ELSE 0 END AS other
                      FROM (
                            /* TABLE sub1: Order the table by the yammer_event table by user_id and occurred_at
                                           Remove the rows where event_type = signup_flow
                                           Add new column: login_log, filter out the rows where event_name = login */
                            SELECT user_id,
                                 occurred_at,
                                 event_name,
                                 CASE WHEN event_name = 'login' THEN 1 ELSE 0 END AS login_log,
                                 ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY occurred_at) AS id
                            FROM tutorial.yammer_events 
                            WHERE event_type != 'signup_flow'
                      )sub1
                  )sub2
                  GROUP BY user_id, session
                  ORDER BY user_id, session
              )sub3
            )sub4
          WHERE search_auto_percent != 0 OR search_run_percent != 0 --- We'll only look at sessions where there's a need for searching.
                                                                    --- If a search_has auto_percent = 0 and search_run_percent = 0 
                                                                    --- then it means there's no need for search in this session at all. 