/*QUESTION:
  1. Are user's search experience generally good or bad?
  
  ANSWER:
  When search is needed, user spent quite a lot of time on search.
  This shows that the search feature is not efficient enough.
  
  DEFINITION of "session":
  All events are ordered by user_id and occurred time, then divided into sessions.  
  A session is a collection of events which includes events from a login event to the next 
  login event of the same user exclude the second the login event*/

SELECT CASE WHEN avg_search_time >= 80 THEN '80%-100%'
            WHEN avg_search_time < 80 AND avg_search_time >= 60 THEN '60%-80%'
            WHEN avg_search_time < 60 AND avg_search_time >= 40 THEN '40%-60%'
            WHEN avg_search_time < 40 AND avg_search_time >= 20 THEN '20%-40%'
            WHEN avg_search_time < 20 AND avg_search_time > 0 THEN '1%-20%' 
            WHEN avg_search_time = 0 THEN 'never_use_search'
            END AS percent_search_time_per_session,
            COUNT(1) AS number_of_user
  FROM( 
        /*TABLE sub5*/
        SELECT user_id,
               AVG(search_time) AS avg_search_time
          FROM(
                /*TABLE sub4*/
                SELECT *,
                       100*(total_event-other)/total_event AS search_time
                  FROM (
                          /*TABLE sub3*/
                          SELECT user_id,
                                 session,
                                 COUNT(session) AS total_event,
                                 SUM(search_auto) AS search_auto_count,
                                 SUM(search_run) AS search_run_count,
                                 SUM(search_click) AS search_click_count,
                                 SUM(other) AS other
                                 
                             FROM 
                                ( /*TABLE sub2*/
                                  SELECT *,
                                         SUM(login_log) OVER (PARTITION BY user_id ORDER BY id) AS session,
                                         CASE WHEN event_name = 'search_autocomplete' THEN 1 ELSE 0 END AS search_auto,
                                         CASE WHEN event_name = 'search_run' THEN 1 ELSE 0 END AS search_run,
                                         CASE WHEN event_name != 'search_autocomplete' AND event_name != 'search_run'
                                         AND event_name != 'login' AND event_name != 'home_page' 
                                         AND event_name != 'like_message' AND event_name != 'send_message'
                                         AND event_name != 'view_inbox' THEN 1 ELSE 0 END AS search_click,
                                         CASE WHEN event_name = 'login' OR event_name = 'home_page'
                                         OR event_name = 'like_message' OR event_name = 'send_message' 
                                         OR event_name = 'view_inbox' THEN 1 ELSE 0 END AS other
                                         
                                    FROM (/*TABLE sub1*/
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
                    WHERE search_auto_count != 0 OR search_run_count != 0 OR search_click_count !=0
            )sub4
            GROUP BY user_id
    )sub5
    GROUP BY 1
    ORDER BY 1