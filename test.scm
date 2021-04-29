#!/gnu/store/q8brh7j5mwy0hbrly6hjb1m3wwndxqc8-guile-3.0.5/bin/guile \
-e main -s
!#

 (add-to-load-path "/home/mbc/projects")




https://pubmed.ncbi.nlm.nih.gov/32781280/

https://pubmed.ncbi.nlm.nih.gov/33865888/


(define a (get-summaries "1" "3"))
(define b (map retrieve-article a))

ref-records
(retrieve-article (car a))
