Oracle OS Watcher Black Box

   Modified: 2/10/2012

Overview

   Oracle OS Watcher Black Box is a great utility which can be downloaded 
   from the Oracle support web site if you have an account. This program 
   collects OS performance data at regular intervals and stores them in a
   series of files. It also comes with a program to convert the data 
   into charts.

Install

   Download OS Watcher Black Box from Oracle support. It should be a .tar 
   file (oswbb4.0.tar for example). Put the file in 
   ${WAHOO}/plugin/oracle-oswbb.

   Set the OSWBB* parameters in the .wahoo configuration file. Wahoo will
   install and start the program within 5 minutes if the Wahoo cron job is
    running.
   
      # Number of hours to store files for.
      OSWBB_ARCHIVE_HOURS=24
      # Number of seconds to wait between snapshots.
      OSWBB_SNAPSHOT_SECONDS=60
