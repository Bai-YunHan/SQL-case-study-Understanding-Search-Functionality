/*QUESTION:
  3. What specificly should be improved?
  
  ANSWER:
  When users do click on search results, 
  Ideally, user should have a much higher chance to get their wanted content by clicking 
  the first few search result. 
  However, the distribution of clicks is even which simply tells that the quality of 
  search_run results doesn't meet the requirement.
*/

SELECT TRIM('search_click_result_' FROM event_name)::INT AS search_result_list,
       COUNT(event_name)
  FROM tutorial.yammer_events 
  WHERE event_type != 'signup_flow' 
    AND event_name != 'search_autocomplete' AND event_name != 'search_run'
    AND event_name != 'login' AND event_name != 'home_page' 
    AND event_name != 'like_message' AND event_name != 'send_message'
    AND event_name != 'view_inbox'
  GROUP BY search_result_list
  ORDER BY search_result_list