UPDATE `users` SET `pass`='$S$DlKfHKC6iOAoj3QnqVR0y7oOLFDfiz213nPQdeCNWqB8XuSrJPFk', `status`=1 WHERE `uid`=1;
update apachesolr_environment set url='http://solr:8983/solr/scratchpads2' where env_id='solr';
