# REAL TIME PROGRAMMING
### Laboratory work 2
### Student Dodi Cristian-Dumitru
#### Group: FAF-181

<br>
<hr>

## Tasks:
- You will be required to copy the Dynamic Supervisor + Workers that compute the sentiment score and adapt this copy of the system to compute the Engagement Ratio per Tweet. Notice that some tweets are actually retweets and contain a special field retweet_status​ . You will have to extract it and treat it as a separate tweet. The Engagement Ratio will be computed as: (#favorites + #retweets) / #followers​ .
- Your workers now print sentiment scores, but for this lab, they will have to send it to a dedicated aggregator actor where the sentiment score, the engagement ratio, and the original tweet will be merged together. Hint: you will need special ids to recombine everything properly because synchronous communication is forbidden.
- Finally, you will have to load everything into a database, for example Mongo, and given that writing messages one by one is not efficient, you will have to implement a backpressure mechanism called adaptive batching​​. Adaptive batching means that you write/send data in batches if the maximum batch size is reached, for example 128 elements, or the time is up, for example a window of 200ms is provided, whichever occurs first. This will be the responsibility of the sink actor(s).
- To make things interesting, you will have to split the tweet JSON into users and tweets and keep them in separate collections/tables in the DB.
- Of course, don't forget about using actors and supervisors for your system to keep it running.

### Some optional tasks:
- Reactive pull backpressure mechanism between the aggregator actor and the sink.
- Create an actor that would compute the Engagement Ratio per User.
- Resumable/pausable transmission between the aggregator and the sink, that is, if sink or DB is unavailable, the aggregator will buffer the messages until they can be sent again.
- Have a metrics endpoint to monitor the stats of the sink/DB controller service on ingested messages, average execution time, 75th, 90th, 95th percentile execution time, number of crashes per given time window, etc.