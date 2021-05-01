#!/gnu/store/q8brh7j5mwy0hbrly6hjb1m3wwndxqc8-guile-3.0.5/bin/guile \
-e main -s
!#

 (add-to-load-path "/home/mbc/projects")

https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmen&term=96+multi+well+OR+high-throughput+screening+assay+(2021%2F04%2F16[epdat])&retmax=3


https://pubmed.ncbi.nlm.nih.gov/32781280/

https://pubmed.ncbi.nlm.nih.gov/33865888/


(define a (get-summaries "1" "3"))
(define b (map retrieve-article a))
(pretty-print b)


(define d (get-missing-email b '()))


(define (get-missing-email contacts  contacts-out)
  ;;input: contact records with all info but maybe email is missing
  ;;if email is missing find it
  ;;I will also count contacts in this method
  (if (null? (cdr contacts))
      (let* ((the-contact (car contacts))
	     (email (contact-email the-contact))
	     (email-null?   (string=? "null" email))
	     (deplorables '( "Pfizer" "China"))
	     (affil (contact-affil the-contact))
	     (ok-affiliation? (not (any-not-false? (map string-contains-ci (circular-list affil) deplorables))))
	     (auth-name (contact-qname the-contact))
	     (new-email (if (and email-null?  ok-affiliation?) (find-email auth-name) email))
	     (dummy (set! author-count (+ author-count 1)))
	     (dummy (set-contact-email! the-contact new-email))
	     (dummy (set! contacts-out (cons the-contact contacts-out)))
	     )
	contacts-out)
      (let* ((the-contact (car contacts))
	     (email (contact-email the-contact))
	     (email-null?   (string=? "null" email))
	     (deplorables '( "Pfizer" "China"))
	     (affil (contact-affil the-contact))
	     (ok-affiliation? (not (any-not-false? (map string-contains-ci (circular-list affil) deplorables))))
	     (auth-name (contact-qname the-contact))
	     (new-email (if (and email-null?  ok-affiliation?) (find-email auth-name) email))
	     (dummy (set! author-count (+ author-count 1)))
	     (dummy (set-contact-email! the-contact new-email))
	     (dummy (set! contacts-out (cons the-contact contacts-out)))
	     )
	(get-missing-email (cdr contacts)  contacts-out))))



(define a-contact (make-contact  "33912478" 1 "Church G" "Zhaoyang Sun"  "Zhaoyang" "Sun"  "Department of Laboratory Medicine, Huadong Hospital, Affiliated With Fudan University, Shanghai, China." "null" ))


(get-missing-email (list a-contact) '())
(find-email "Church GM")
(find-fl-aoi "Church GM")
(first-or-last-auth? "Church GM" "32753383")
(pretty-print (get-articles-for-auth "Church G"))

(define arts '("33906944"
 "33828272"
 "33755419"
 "32753383"
 "33293535"))


(get-articles-for-auth "Church GM")

;; CHANGE # article gotten back to 20!!!!

(contact-email a-contact)

(contact-qname a-contact)
(find-email "Sun Z")
(find-fl-aoi "sun Z")
