/*QUESTION:
  2. Is search worth working on?
  
  ANSWER_Part2:
  Yes, Only 27.3% (which is 1677/6142) of user never use search function.
  Except users who never use search, user uses search 40.94% of time on average in each session. 
  
  DEFINITION of "session":
  All events are ordered by user_id and occurred time, then divided into sessions.  
  A session is a collection of events which includes events from a login event to the next 
  login event of the same user exclude the second the login event*/


SELECT AVG(percent_of_session_with_search) AS avg_percent_of_sessions_with_search
  FROM (  /*TABLE sub6*/
          SELECT *,
                 100*session_with_search_count/total_session AS percent_of_session_with_search
          
            FROM( /*TABLE sub5*/
                  SELECT user_id,
                         COUNT(user_id) AS total_session,
                         SUM(session_with_search) AS session_with_search_count
                         
                    FROM(
                          /*TABLE sub4*/
                          SELECT user_id,
                                 session,
                                 total_event,
                                 search_auto_count,
                                 search_run_count,
                                 CASE WHEN search_auto_count != 0 OR search_run_count != 0 THEN 1 ELSE 0 END AS session_with_search
                            FROM(
                              /*TABLE sub3*/
                              SELECT user_id,
                                     session,
                                     COUNT(session) AS total_event,
                                     SUM(search_auto) AS search_auto_count,
                                     SUM(search_run) AS search_run_count,
                                     SUM(other) AS other
                                     
                                 FROM 
                                    ( /*TABLE sub2*/
                                      SELECT *,
                                             SUM(login_log) OVER (PARTITION BY user_id ORDER BY id) AS session,
                                             CASE WHEN event_name = 'search_autocomplete' THEN 1 ELSE 0 END AS search_auto,
                                             CASE WHEN event_name = 'search_run' THEN 1 ELSE 0 END AS search_run,
                                             CASE WHEN event_name != 'search_autocomplete' AND event_name != 'search_run' THEN 1 ELSE 0 END AS other
                                        FROM (
                                              /*TABLE sub1*/
                                              SELECT user_id,
                                                   occurred_at,
                                                   event_name,
                                                   CASE WHEN event_name = 'login' THEN 1 ELSE 0 END AS login_log,
                                                   ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY occurred_at) AS id
                                              FROM tutorial.yammer_events 
                                              WHERE event_type != 'signup_flow'
                                        ) sub1
                                    )sub2
                                    
                                    GROUP BY user_id, session
                                    ORDER BY user_id, session
                                )sub3
                            )sub4
                    GROUP BY user_id
                    ORDER BY user_id
                  )sub5
          )sub6
  WHERE percent_of_session_with_search != 0