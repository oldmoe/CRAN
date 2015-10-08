# CRAN

The application is composed of two components:

Indexer, which runs as a rake task, and is scheduled to run every day at 12:00am

Web applications, which is a Sinatra app that displays the packages in the database

The indexer is pretty serial, it can get the package list from a url or a path to a local file. 
The input is dealt with as an IO stream, and is never fully buffered in the system memory.  
This way the application can gracefully handle very large input sizes.
Streaming will also benefit a lot if the app is ever parallelized, as it can help reduce the effects of a slow server/connection

A simple, embedded key/value store was chosen to hold the data (mostly due to time constraints).
LMDB was specifically chosen to allow concurrent access from multiple processes (the rake task and the sinatra app) 
