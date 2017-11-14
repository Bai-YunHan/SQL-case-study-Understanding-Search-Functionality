/*QUESTION:
  2. Is search worth working on?
  
  ANSWER Part_1:
  Yes, Only 27.3% (which is 1677/6142) of user never use search function.  
  Except users who never use search, user uses search 40.94% of time on average in each session.
  
  DEFINITION of "session":
  All events are ordered by user_id and occurred time, then divided into sessions.  
  A session is a collection of events which includes events from a login event to the next 
  login event of the same user exclude the second the login event*/

SELECT CASE WHEN percent_of_session_with_search >= 80 THEN '80%-100%'
            WHEN percent_of_session_with_search < 80 AND percent_of_session_with_search >= 60 THEN '60%-80%'
            WHEN percent_of_session_with_search < 60 AND percent_of_session_with_search >= 40 THEN '40%-60%'
            WHEN percent_of_session_with_search < 40 AND percent_of_session_with_search >= 20 THEN '20%-40%'
            WHEN percent_of_session_with_search < 20 AND percent_of_session_with_search > 0 THEN '1%-20%' ---the minimum percent is 5%
            WHEN percent_of_session_with_search = 0 THEN '0%'
            END AS percent_of_session_with_search,
            COUNT(1) AS number_of_user
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
                                              /*END OF TABLE sub1*/
                                        ) sub1
                                        /*END OF TABLE sub2*/
                                    )sub2
                                    GROUP BY user_id, session
                                    ORDER BY user_id, session
                                    /*END OF TABLE sub3*/
                                )sub3
                                /*END OF TABLE sub4*/
                            )sub4
                    GROUP BY user_id
                    ORDER BY user_id
                    /*END OF TABLE sub5*/
                  )sub5
                  /*END OF TABLE sub6*/
              )sub6
        GROUP BY 1
        ORDER BY 1