This is the Open Source version of 1H Guardian monitoring daemon

guardian folder includes the monitoring daemon and its perl modules

lifesigns folder includes the daemon responsible for delivering the 
  data from the server.
  We took the decision to have a separate daemon instead of API in 
  Apache/Nginx because, Apache/Nginx can be down and we will want
  to know that they are down.

archon folder contains the workers that gather the data from each
  server and populate it into the DB

scipts folder contains other test tools that were developed, during
  the development of Guardian


All software in this repository is under the GPLv2 license.
