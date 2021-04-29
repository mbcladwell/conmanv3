#! /gnu/store/q8brh7j5mwy0hbrly6hjb1m3wwndxqc8-guile-3.0.5/bin/guile \
-e main -s
!#

 (add-to-load-path "/home/mbc/projects")

;; (add-to-load-path "/home/admin/projects")

(use-modules (web client)
	     (srfi srfi-19)   ;; date time
	     (srfi srfi-1)  ;;list searching   
	     (srfi srfi-9)  ;;records
	     (web response)
	     (web request)
	     (web uri)
	     (ice-9 rdelim)
	     (ice-9 i18n)   ;; internationalization
	     (ice-9 popen)
	     (ice-9 regex) ;;list-matches
	     (ice-9 receive)	     
	     (ice-9 string-fun)  ;;string-replace-substring
	     (ice-9 pretty-print)
	     (conmanv3 utilities)
	     (conmanv3 cemail)
	     (conmanv3 logging)   ;; logging is in guile-lib
             (logging logger)
             (logging rotating-log)
             (logging port-log)
	     )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; guix environment --network --expose=/etc/ssl/certs/  --manifest=manifest.scm
;; guile -e main -s ./conman.scm 7 10
;; 7 days (&reldate)
;; max 10 summaries (&retmax)

;;guix environment --pure --network --expose=/etc/ssl/certs/  --manifest=manifest.scm -- ./conman.scm 7 2

;; /gnu/store/0w76khfspfy8qmcpjya41chj3bgfcy0k-guile-3.0.4/bin/guile

;; psql -U ln_admin -h 192.168.1.11 -d conman

;; https://pubmed.ncbi.nlm.nih.gov/"
;; scp ~/projects/conman/conman.scm mbc@192.168.1.11:/home/mbc/projects/conman/conman.scm

;; 14*60*60*24 = 1209600
;; 15*60*60*24 =  1296000



(define article-count 0)
(define author-count 0)
(define author-find-email-count 0)
(define batch-id (date->string  (current-date) "~Y~m~d~I~M"))
(define generic-email-regexp (make-regexp "[A-Za-z0-9.-]*@[-A-Za-z0-9.]+(\\.com|\\.edu|\\.org|\\.net|\\.uk|\\.fr|\\.de|\\.it|\\.ru|\\.in|\\.au|\\.ca|\\.io|\\.py|\\.se|\\.dk|\\.sg|\\.be)" regexp/extended))
(define duration (time-difference (make-time time-utc  0 1209600) (make-time time-utc  0 0))) ;;14 days ago
;;(define duration (time-difference (make-time time-utc  0 1296000) (make-time time-utc  0 0))) ;;15 days ago
(define two-weeks-ago (date->string  (time-utc->date (subtract-duration (current-time) duration)) "~Y/~m/~d"))
(define all-chars "-a-zA-Z0-9ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜƏƒƠơƯƯǺǻǼǽǾǿńŻć<>~_+=,.:;()&#@®\" ")
(define ref-records '())  ;;this will hold pmid, title, journal as records; key is pmid

;; '((("fname" . "joey")("email" . "joey@acme.com") ))
(define emails-sent '())  ;;if an email is sent, cons it to this list


(setup-logging)

(define-record-type <reference>
  (make-reference pmid journal title)
  reference?
  (pmid    reference-pmid)
  (journal reference-journal)
  (title   reference-title ))

;;(set! results )(cons "923478234" (make-reference "948593485" "JMB" "A Title"))

(define-record-type <contact>
  (make-contact pmid index qname wholen firstn lastn affil email)
  contact?
  (pmid    contact-pmid set-contact-pmid!)
  (index contact-index set-contact-index!)
  (qname contact-qname set-contact-qname!)
  (wholen contact-wholen)
  (firstn contact-firstn)
  (lastn contact-lastn)
  (affil contact-affil set-contact-affil!)
  (email contact-email set-contact-email!))


(define (recurse-lst-add-index counter inlst outlist)
  ;;take an input list and turn it into an a-list where the index
  ;;is a number starting at counter and incremented by one
  (if (null? (cdr inlst))
      (begin
	(set! outlist (acons counter (car inlst) outlist))
	outlist)
      (begin
	(set! outlist (acons counter (car inlst)  outlist))
	(set! counter (+ counter 1))
	(recurse-lst-add-index counter (cdr inlst) outlist))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Find missing email methods
;; 
;; (find-email aoi)
;;     |
;;     |--> (find-fl-aoi aoi)                                                OK
;;     |         | find articles where author of interest
;;     |         | is the first or last author
;;     |         |
;;     |         |--> (get-articles-for-auth aoi)                            OK
;;     |         |        get N article for an author
;;     |         |
;;     |         |--> (map first-or-last-auth? aoi pmid)                     OK
;;     |                  determine whether the author is the
;;     |                  first or last author of article
;;     |
;;     |--> (map search-fl-for-auth aoi pmid)
;;               Pull down a single article where aoi
;;               is the first or last author and search
;;               html for email address



(define (get-articles-for-auth auth)
  (let* ( (authmod (string-replace-substring auth " " "+"))
	 (url (string-append "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=" (uri-encode authmod) "[auth]&retmax=20"))
	 (summary-url  (uri-encode url )) 
	 (the-body   (receive (response-status response-body)
	 		 (http-request url) response-body))
	 (dummy (set! author-find-email-count (+ author-find-email-count 1)))
	 (dummy2 (sleep 1))
	 (a (map match:substring  (list-matches "<Id>[0-9]{8}</Id>" the-body )))
	 (b (map (lambda (x) (substring x 4 (- (string-length x) 5))) a))
	)
    b))

;; (get-articles-for-auth "Marjanović Ž")


(define (first-or-last-auth? auth pmid)
  ;;is the supplied author first or last in the pmid
 (let* ((summary-url (string-append "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id="  pmid))
	(the-body   (receive (response-status response-body)
			(http-request summary-url) response-body))
	(dummy (sleep 2))
	(b (map match:substring  (list-matches "<Item Name=\"Author\" Type=\"String\">[-A-Za-zÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜƏƒƠơƯƯǺǻǼǽǾǿńŻć ]+</Item>" the-body )))
	(c (map (lambda (x) (substring x 34 (- (string-length x) 7))) b))
	(first-auth (car c))
	(last-auth (list-cdr-ref c (- (length c) 1)))
	(both-auths (cons first-auth last-auth))
	(contains (lset-intersection string=? (list auth) both-auths) ))
   (if (> (length contains) 0) #t #f)))

;; (first-or-last-auth? "Church GM" "32753383")
;; (first-or-last-auth? "Bhak Y" "32753383")
;; (first-or-last-auth? "Weber JA" "32753383")
;; (first-or-last-auth? "Bhak Y" "32381713")
  

(define (find-fl-aoi auth)
  ;; find first last author of interest (aoi)
  ;; return a list of pmids where the auth is the first or last author
  (let* ((a (get-articles-for-auth auth))
	 (b   (map first-or-last-auth? (circular-list auth) a))
	 (holder '())
	 (dummy (if b (map (lambda (x y) (if x (set! holder (append! holder (list y))) #f)) b a) #f))
	 )
 ;;   (pretty-print holder)))
     holder))

 ;; (pretty-print (find-fl-aoi "Church G"))
 ;; (pretty-print  (get-articles-for-auth "Marjanović Ž"))

(define (search-fl-for-auth auth pmid-list)
  ;; search article where author of interest in either first or last
  ;; search for email id
  ;; articles is a list of pmids that have already been determined by find-fl-auth
  ;; to have the author of interest as first or last author
  ;; returns email or #f
  ;; process the list until you find an email
 (if (null? pmid-list) #f
      (let* ((url (string-append "https://pubmed.ncbi.nlm.nih.gov/" (car pmid-list) "/"))
	     (the-body (receive (response-status response-body)
			   (http-request url) response-body))
	     (dummy (sleep 1))
	     (coord-start (string-match "<div class=\"affiliations\">" the-body ))
	     (coord-end (string-match " <ul class=\"identifiers\" id=\"full-view-identifiers\">" the-body ))
	     (affil-chunk (if coord-start (xsubstring the-body (match:start coord-start) (match:start coord-end)) #f))
	     (first-space  (string-contains auth " "))
	     (lname (string-downcase (xsubstring auth 0  first-space )))	  
	     (a (if affil-chunk (regexp-exec generic-email-regexp affil-chunk) #f))
	     (email  (if a (xsubstring (match:string a) (match:start a) (match:end a)) #f)))
	(if email email (search-fl-for-auth auth (cdr pmid-list))))))


  
;; (search-fl-for-auth "Church G" "32753383")   this one has the email address
;; (search-fl-for-auth "Church G" "32381713")

(define (find-email auth)
  ;; fl-pmids are the pmids that have the author of interest as first or last author
  ;; note that more than 20 pmids may be triggering server to abort
  (let* (
	 (fl-pmids (find-fl-aoi auth))
	 (dummy (sleep 1))
	 (email (if fl-pmids (search-fl-for-auth  auth fl-pmids) #f))
	 )
      (if email email "null")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Summaries
;; note that &retmax=10 can limit what is returned
;; äöüÄÖÜßńñéáíúóçèŻ
;; ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜƏƒƠơƯƯǺǻǼǽǾǿ

(define (get-id-authors x)
  (let* ((a (map match:substring  (list-matches "<Item Name=\"Author\" Type=\"String\">[-a-zA-Z0-9ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜƏƒƠơƯƯǺǻǼǽǾǿńŻć<>~_+=,.:;()&#@\" ]+</Item>" x )))
	 (b (map (lambda (x) (substring x 34 (- (string-length x) 7)) ) a))
	 (c (string-match "<Id>[0-9]{8}</Id>" x))
	 (d (xsubstring x (+ (match:start c) 4) (- (match:end c) 5))))
    (cons (list d) (list b))))

(define (get-title x)
  (let* ((a (map match:substring  (list-matches "<Item Name=\"Author\" Type=\"String\">[-a-zA-Z0-9ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜƏƒƠơƯƯǺǻǼǽǾǿńŻć<>~_+=,.:;()&#@\" ]+</Item>" x )))
	 (b (map (lambda (x) (substring x 34 (- (string-length x) 7)) ) a))
	 (c (string-match "<Id>[0-9]{8}</Id>" x))
	 (d (xsubstring x (+ (match:start c) 4) (- (match:end c) 5))))
    (cons (list d) (list b))))

(define (get-summaries reldate retmax)
  ;; this is the initializing method
  (let*((db "pubmed")
	(query (string-append "96+multi+well+OR+high-throughput+screening+assay+(" (uri-encode two-weeks-ago) "[epdat])"))
	(base "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/")
	;; (define url (string-append base  "esearch.fcgi?db=" db "&term=" query "&usehistory=y"))
	(url (string-append base  "esearch.fcgi?db=" db "&term=" query "&retmax=" retmax))
	(the-body   (receive (response-status response-body)
			(http-request url) response-body))
	(dummy (sleep 1))
        (all-ids-pre   (map match:substring  (list-matches "<Id>[0-9]+</Id>" the-body ) ))
	(d (if (not (null? all-ids-pre))
	       (let* ((all-ids (map (lambda (x) (string-append (xsubstring x 4 12) ",")) all-ids-pre))
		      (all-ids-concat (string-concatenate all-ids))
		      (all-ids-concat (xsubstring all-ids-concat 0 (- (string-length all-ids-concat) 1)))
		      (summary-url (string-append base "esummary.fcgi?db=" db "&id=" all-ids-concat  ))
		      ;; (summary-url (string-append base "esummary.fcgi?db=" db "&id=" all-ids-concat "&version=2.0" ))
		      (all-summaries   (receive (response-status response-body)
					   (http-request summary-url) response-body))
		      (b (find-occurences-in-string "<DocSum>" all-summaries))
		      (c (map (lambda (x) (substring all-summaries (car x) (cdr x))) b))
		      ;; this is where I will insert the ref table processing
		      ;; this creates ref-records, an a-list of references
		      (dummy (get-pmid-jrn-title c))
		      )
		 (map get-id-authors c)
		 )		      
               '() ))  )
  ;;  (pretty-print d)))
   d))

;; (pretty-print (get-summaries "40" "3"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Authors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (update-contact-records counter pmid auth-list authors affils auth-out)
  ;;fill missing fields pmid, index, qname using the passed in, indexed auth-list
  (if (null? (cdr authors))
      (let* ((the-contact (car authors))
	     (affil-id (contact-affil the-contact)) ;;what I need
	     (affil-list (assoc affil-id affils))
	     (affil (cadr affil-list))
	     (email (caddr affil-list))
	     (dummy (set-contact-affil! the-contact affil))
	     (dummy (set-contact-email! the-contact email))
	     (dummy (set-contact-pmid! the-contact pmid))
	     (dummy (set-contact-index! the-contact counter))
	     (dummy (set-contact-qname! the-contact (cdr (assoc counter auth-list))))
	     (dummy (set! auth-out (cons the-contact auth-out)))
	     )
	auth-out)
      (let* ((the-contact (car authors))
	     (affil-id (contact-affil the-contact)) ;;what I need
	     (affil-list (assoc affil-id affils))
	     (affil (cadr affil-list))
	     (email (caddr affil-list))
	     (dummy (set-contact-affil! the-contact affil))
	     (dummy (set-contact-email! the-contact email))
	     (dummy (set-contact-pmid! the-contact pmid))
	     (dummy (set-contact-index! the-contact counter))
	     (dummy (set-contact-qname! the-contact (cdr (assoc counter auth-list))))
	     (dummy (set! auth-out (cons the-contact auth-out)))
	     (counter (+ counter 1))
	     )
	(update-contact-records counter  pmid auth-list (cdr authors) affils auth-out))))



(define authors-regexp
  ;; pulls out a single author
  (make-regexp "data-ga-label=[a-zA-Z0-9~_+=,.:;'()//&#@<>/\" -]+</a></sup><span" regexp/extended))

(define (extract-authors achunk)
  ;; If there are equal contributors, a different string search strategy is needed
  ;; the string extraction is such that either method extracts the same coordinates
  (let* (   
	 (name-vec  (if (string-match "equal-contrib-container" achunk )
			(string-match ">[-a-zA-ZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜƏƒƠơƯƯǺǻǼǽǾǿńŻć0-9<>~_+=,.:;()&#@\" ]+</a><sup class=\"equal-contrib-container"  achunk)
			(string-match ">[-a-zA-ZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜƏƒƠơƯƯǺǻǼǽǾǿńŻć0-9<>~_+=,.:;()&#@\" ]+</a><sup class=\"affiliation-links\"><spa"  achunk)
			))		    
	 (full-name (xsubstring achunk (+ (match:start name-vec) 1)(- (match:end name-vec) 39))) ;;;39
	(name-num-sp (string-count full-name #\sp))
	 (first-sp (string-contains full-name " "))
	 (second-sp (if (> name-num-sp 1) (string-contains full-name " " (+ first-sp 1)) #f))
	 (third-sp (if (> name-num-sp 2) (string-contains full-name " " (+ second-sp 1)) #f))
	 (first (if (or (= name-num-sp  1) (= name-num-sp  2)) (xsubstring full-name 0  first-sp )  "null"  ))	 
	 (last (cond ((= name-num-sp 3) (xsubstring full-name (+ third-sp 1) (string-length full-name)))
		     ((= name-num-sp 2) (xsubstring full-name (+ second-sp 1) (string-length full-name)))
	  	     ((= name-num-sp 1) (xsubstring full-name (+ first-sp 1) (string-length full-name)))
	 	     ((= name-num-sp 0) full-name)))
	 (affiliation-pre (string-match ">\n *[0-9]+\n *<" achunk) )
	 (affiliation (string-trim-both (xsubstring (match:string affiliation-pre) (+ (match:start affiliation-pre) 1)(- (match:end affiliation-pre) 1))))
	 ;;(a-contact (make-contact "" "" "" full-name  first last affiliation ""))
	 )
   ;; (pretty-print affiliation)
   (make-contact "" "" "" full-name  first last affiliation "")
    ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Affiliations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(define affiliations-regexp
  ;; pulls out a single author
  (make-regexp ">[0-9]+</sup>[-a-zA-Z0-9ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜƏƒƠơƯƯǺǻǼǽǾǿńŻć<>~_+=,.:;()&#@\"\\/ ]+</li>" regexp/extended))

(define (recurse-affil-lst inlst outlist)
  (if (null? (cdr inlst))
      (begin
	(set! outlist (acons (caar inlst) (cdar inlst) outlist))
	outlist)
      (begin
	(set! outlist (acons (caar inlst) (cdar inlst) outlist))
	(recurse-affil-lst (cdr inlst) outlist))))

;;(set! address-list (acons name address address-list))

(define (get-affils-alist the-body)
  (let*(
	(coord2-start (string-match "<div class=\"affiliations\">" the-body ))
	(the-alist (if coord2-start
	 	       (let* (
	 		    (coord2-end (string-match " <ul class=\"identifiers\" id=\"full-view-identifiers\">" the-body ))
	 		    (affil-chunk (xsubstring the-body (match:start coord2-start) (match:start coord2-end)))
	 		    (affil-v (map match:substring (list-matches affiliations-regexp affil-chunk)))
			    (lst-affils (map extract-affiliations affil-v ))
			    ;;here we must recurse and build alist
			    (affils-alist (recurse-affil-lst lst-affils '()))
	 		    ;;(lst-affils (map extract-affiliations affil-v ))
			    )
		       ;;lst-affils)
	 	        affils-alist)
	 	     #f )))
    the-alist)
  )


(define (extract-affiliations achunk )
    ;; affiliation2 is the affiliation without the email address
  (let* (
	 (affil-num-pre  (string-match ">[0-9]+</sup>"  achunk))		 
	 (affil-num (xsubstring (match:string affil-num-pre) (+ (match:start affil-num-pre) 1)(- (match:end affil-num-pre) 6)))
	 (affiliation-pre (string-match "</sup>[-a-zA-Z0-9ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜƏƒƠơƯƯǺǻǼǽǾǿńŻć<>~_+=,.:;()&#@\"\\/ ]+</li>" achunk))
	 (affiliation (string-trim-both (xsubstring (match:string affiliation-pre) (+ (match:start affiliation-pre) 6) (-(match:end affiliation-pre) 5 ) )))
	 (email-pre (regexp-exec generic-email-regexp affiliation))
	 (email-coords? (if email-pre (vector-ref email-pre 1) #f))
	 (email (if email-coords? (xsubstring affiliation (car email-coords?) (cdr email-coords?)) "null" ))
	 (email-add? (string-match "Electronic address:" affiliation))
	 (affiliation2 (if email-add? (xsubstring affiliation 0 (car (vector-ref email-add? 1))) affiliation))
	 )
  (list affil-num  affiliation2 email )))


(define (get-authors-records the-body)
  (let*(
	(coord-start (string-match "<div class=\"authors-list\">" the-body ))
	(auth-v (if coord-start
		    (let* (
			   (coord-end (if (string-match "<div class=\"short-article-details\">" the-body )
					  (string-match "<div class=\"short-article-details\">" the-body )
					  (string-match "<div class=\"extended-article-details\" id" the-body )))		       
			   (auth-chunk (xsubstring the-body (match:start coord-start) (match:start coord-end)))
			   (auth-chunk (regexp-substitute/global #f "&#39;"  auth-chunk 'pre "" 'post))  ;; get rid of '; O'Hara
			   (auth-chunk (regexp-substitute/global #f "&amp;"  auth-chunk 'pre "" 'post))  ;; get rid of &
			   (b (find-occurences-in-string "data-ga-label=" auth-chunk))
			   (auth-lst (map (lambda (x) (substring auth-chunk (car x) (cdr x))) b))
			   (first-author (car auth-lst))
			   (proceed-flag (or (string-contains first-author "</a><sup class=\"equal-contrib-container")
					     (string-contains first-author "</a><sup class=\"affiliation-links\"><spa"))))
		      (if proceed-flag (map extract-authors auth-lst) #f))
		    #f )
		)
	)					     			      				 
    ;;			  (pretty-print proceed-flag)))
    auth-v)
  )


(define (retrieve-article a-summary)
  ;;output here is the list of contacts that then must be processed for missing emails
  (let* ((pmid (caar a-summary))
	 (auth-list (cadr a-summary))
	 (indexed-auth-lst (recurse-lst-add-index 1 auth-list '()))
	 (url (string-append "https://pubmed.ncbi.nlm.nih.gov/" pmid "/"))
	 (the-body (receive (response-status response-body)
		       (http-request url) response-body))
	 (dummy (set! article-count (+ article-count 1)))
	 (dummy2 (sleep 1))
	 ;; must test here for the text </a><sup class=\"equal-contrib-container OR </a><sup class=\"affiliation-links\"><spa
	 ;; if not present, no affiliations, move on
	 (author-records (if the-body (get-authors-records the-body) #f))
	 (affils-alist '())
	 (affils-alist (if author-records (get-affils-alist the-body )))
	 (dummy (update-contact-records 1 pmid indexed-auth-lst author-records affils-alist '()))
	 (dummy (get-missing-email author-records '() ))
	 )     
    author-records
    ))


;;(pretty-print (retrieve-article "32781280"))


;; provides a list of articles.  One article looks like:
;; (full_name first_name last_name id id affiliation [email])  e.g.:
;;
  ;; (("Peng Song"
 ;;  "Peng"
 ;;  "Song"
 ;;  "1"
 ;;  "1"
 ;;  "College of Water Resources and Civil Engineering, China Agricultural University, Beijing 100083, China."
 ;;  "null")
 ;; ("Yang Xiao"
 ;;  "Yang"
 ;;  "Xiao"
 ;;  "1"
 ;;  "1"
 ;;  "College of Water Resources and Civil Engineering, China Agricultural University, Beijing 100083, China."
 ;;  "null")
 ;; ("Zhiyong Jason Ren"
 ;;  "Zhiyong"
 ;;  "Ren" etc.....
;;
;; Must merge the names with the affiliations
;; Not all affiliations will contain an email address
;; provide url with &metadataPrefix=pmc_fm&tool=cntmgr&email=info@labsolns.com so I may be contacted prior to banning

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load the ref table for custom emails



(define (process-vec-pmid lst results)
  ;;results passed in is '()
  (if (null? (cdr lst))
      (begin
	(if (null? (car lst))
	    (set! results (append  results '("null")))
	    (set! results (append  results (list (xsubstring (match:string (caar lst) )  (+ (match:start (caar lst)) 4) (- (match:end (caar lst)) 5) )))))
	results)
      (begin
	(if (null? (car lst))
	    (set! results (append  results '("null")))
            (set! results (append  results (list (xsubstring (match:string (caar lst) )  (+ (match:start (caar lst)) 4) (- (match:end (caar lst)) 5) )))))
	(process-vec-pmid (cdr lst) results))))

(define (process-vec-journal lst results)
  ;;results passed in is '()
  (if (null? (cdr lst))
      (begin
	(if (null? (car lst))
	    (set! results (append  results '("null")))
	    (set! results (append  results (list (xsubstring (match:string (caar lst) )  (+ (match:start (caar lst)) 43) (- (match:end (caar lst)) 7) )))))
	results)
      (begin
	(if (null? (car lst))
	    (set! results (append  results '("null")))
            (set! results (append  results (list (xsubstring (match:string (caar lst) )  (+ (match:start (caar lst)) 43) (- (match:end (caar lst)) 7) )))))
	(process-vec-journal (cdr lst) results))))

(define (process-vec-title lst results)
  ;;results passed in is '()
  (if (null? (cdr lst))
      (begin
	(if (null? (car lst))
	    (set! results (append  results '("null")))
	    (set! results (append  results (list (xsubstring (match:string (caar lst) )  (+ (match:start (caar lst)) 33) (- (match:end (caar lst)) 7) )))))
	results)
      (begin
	(if (null? (car lst))
	    (set! results (append  results '("null")))
            (set! results (append  results (list (xsubstring (match:string (caar lst) )  (+ (match:start (caar lst)) 33) (- (match:end (caar lst)) 7) )))))
	(process-vec-title (cdr lst) results))))




(define (make-ref-records pmid journal title results)
;; results is the empty list to hold records
  (if (null? (cdr pmid))
      (begin
	(set! results (acons  (car pmid) (make-reference (car pmid) (car journal) (car title)) results))
	results)
      (begin
	(set! results (acons (car pmid) (make-reference (car pmid) (car journal) (car title)) results))
	(make-ref-records (cdr pmid) (cdr journal) (cdr title) results))))


(define (get-pmid-jrn-title x)
  ;; this should come right after:
  ;; b (find-occurences-in-string "<DocSum>" all-summaries))
  ;; c (map (lambda (x) (substring all-summaries (car x) (cdr x))) b))
  ;; i.e. the summaries list is the input - pass in c
  ;; note that failed title or journal searches will insert "null"; failure is probably a missing character in the search term e.g. ®
  (let* ((search-term (string-append "<Id>[0-9]+</Id>"))
	 (a  (map list-matches  (circular-list search-term) x ))
	 (b (process-vec-pmid a '()))  ;;all PMIDs
	 (search-term (string-append "<Item Name=\"Title\" Type=\"String\">[" all-chars  "]+</Item>"))
	 (c  (map list-matches  (circular-list search-term) x ))
	 (d (process-vec-title c '()))  ;;Title
	 (search-term (string-append "<Item Name=\"FullJournalName\" Type=\"String\">[" all-chars  "]+</Item>"))
	 (e  (map list-matches  (circular-list search-term) x ))
	 (f (process-vec-journal e '()))  ;;Journals
	 )
    (make-ref-records b f d ref-records)))




;; (define (join-summary-article  a-summary an-article )
;;   ;; an-article might be false if there were no affiliations
;;   ;; join to a null list
;;   (let* ((a (if an-article
;; 		(map cons (cadr a-summary) an-article)
;; 		(map cons (cadr a-summary) (circular-list '("null" "null" "null")))))	 
;; 	 (b (map cons (circular-list (caar a-summary)) a)))
;;     b))





(define (get-missing-email contacts  contacts-out)
  ;;input: contact record with all info but maybe email is missing
  ;;if email is missing find it
  ;;I will also count contacts in this method
  (if (null? (cdr contacts))
      (let* ((the-contact (car contacts))
	     (email (contact-email the-contact))
	     (email-null?   (string=? "null" email))
	     (deplorables '("China" "Pfizer"))
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
	     (deplorables '("China" "Pfizer"))
	     (affil (contact-affil the-contact))
	     (ok-affiliation? (not (any-not-false? (map string-contains-ci (circular-list affil) deplorables))))
	     (auth-name (contact-qname the-contact))
	     (new-email (if (and email-null?  ok-affiliation?) (find-email auth-name) email))
	     (dummy (set! author-count (+ author-count 1)))
	     (dummy (set-contact-email! the-contact new-email))
	     (dummy (set! contacts-out (cons the-contact contacts-out)))
	     )
	(get-missing-email (cdr contacts)  contacts-out))))


(define (send-email lst)
  ;;lst is the list of contact records
  ;;recurse over the contacts list and send an email if email is not null
  ;;the ref records have journal and title info, search with pmid
  ;;input to cemail is an alist:
  ;; (("email" . "Leen.Delang@kuleuven.be")
  ;;  ("journal" . "Microorganisms")
  ;;  ("title" . "Repurposing Drugs for Mayaro Virus: Identification.... Inhibitors.")
  ;;  ("firstn" . "Rana"))

  (if (null? (cdr lst))
      (let* ((contact (car lst))
	     (email (contact-email contact))
	     (firstn (contact-email contact) )
	     (pmid (contact-pmid contact))
	     (ref (assoc pmid ref-records))
	     (title (reference-title ref))
	     (journal (reference-journal ref))
	     (the-list (list (cons "email" email)(cons "journal" journal)(cons "title" title)(cons "firstn" firstn)))
	     (for-report (list (cons "firstn" firstn)(cons "email" email))))
	(if (equal? email "null") #f
	    (begin
	      (send-custom-email the-list)
	      (set! emails-sent (cons for-report emails-sent)))))
      (let* ((contact (car lst))
	    (email (contact-email contact))
	    (firstn (contact-email contact) )
	    (pmid (contact-pmid contact))
	    (ref (assoc pmid ref-records))
	    (title (reference-title ref))
	    (journal (reference-journal ref))
	    (the-list (list (cons "email" email) (cons "journal" journal)(cons "title" title)(cons "firstn" firstn)))
	    (for-report (list (cons "firstn" firstn)(cons "email" email)))
	    (dummy (if (equal? email "null") #f
		       (begin
			 (send-custom-email the-list)
			 (set! emails-sent (cons for-report emails-sent))))))
	(send-email (cdr lst)))))




;; (pretty-print (map-over-summaries one-summary))


(define (main args)
  ;; args: '( "script name" "past days to query" "Number of articles to pull")
  (let* ((start-time (current-time time-monotonic))
	 (dummy2 (log-msg 'CRITICAL (string-append "Starting up at: "  (number->string (time-second start-time)))))
	 (a (get-summaries (cadr args) (caddr args)))
	 (b (map retrieve-article a))
	 (dummy (if (null? b) #f (send-email b) ))
	 (dummy (if (null? emails-sent) #f (send-report emails-sent) ))
	 (stop-time (current-time time-monotonic))
	 (elapsed-time (ceiling (/ (time-second (time-difference stop-time start-time)) 60)))
	 (dummy3 (log-msg 'INFO (string-append "Elapsed time: " (number->string   elapsed-time) " minutes.")))
	 (dummy4 (log-msg 'INFO (string-append "Article-count: " (number->string  article-count) )))
	 (dummy5 (log-msg 'INFO (string-append "Author-count: " (number->string  author-count) )))
	 (dummy6 (log-msg 'INFO (string-append "Author-find-email-count: " (number->string  author-find-email-count) )))
	 (dummy7 (shutdown-logging))
	 ;;(stmnt (string-append "INSERT INTO conmanstats (batchid, article, author, author_search, elapsed ) VALUES ("  batch-id ", " (number->string article-count) ", " (number->string author-count) ", " (number->string author-find-email-count) ", " (number->string elapsed-time) ")"))
	 (dummy8 (send-report (list (cons "batchid" batch-id) (cons "article" (number->string article-count)) (cons "author" (number->string author-count)) (cons "author-find" (number->string author-find-email-count)) (cons "elapsed-time" (number->string elapsed-time))) emails-sent)) 
	 )
  ;; (pretty-print b)))    
   (pretty-print (string-append "Elapsed time: " (number->string  elapsed-time) " minutes." ))))
   
;; (main '( "" "1" "3"))

