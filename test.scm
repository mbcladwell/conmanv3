#!/gnu/store/q8brh7j5mwy0hbrly6hjb1m3wwndxqc8-guile-3.0.5/bin/guile \
-e main -s
!#

 (add-to-load-path "/home/mbc/projects")

https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmen&term=96+multi+well+OR+high-throughput+screening+assay+(2021%2F04%2F16[epdat])&retmax=3


https://pubmed.ncbi.nlm.nih.gov/32781280/

https://pubmed.ncbi.nlm.nih.gov/33906944/  ;;Church GM is last author


(define a (get-summaries "1" "3"))
(define b (map retrieve-article a))
(pretty-print b)


(get-missing-email (list a-contact) '())
(find-email "Church GM")
(find-fl-aoi "Church GM")
(first-or-last-auth? "Church GM" "33906944")
(pretty-print (get-articles-for-auth "Church G"))

(define arts '("33906944"
 "33828272"
 "33755419"
 "32753383"
 "33293535"))


(define a (get-articles-for-auth "Church GM"))
(map first-or-last-auth? (circular-list "Church GM") a)


(define (retrieve-article a-summary)
  ;;this does all the work; author list repeately processed article by article
  ;;including send email
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
	 (affils-alist (if author-records (get-affils-alist the-body ) #f))
	 (author-records2 (if affils-alist (update-contact-records 1 pmid indexed-auth-lst author-records affils-alist '()) #f))
	;; (author-records3 (if author-records2 (get-missing-email author-records2 '() ) #f))
	;; (dummy3 (if (null? author-records3) #f (send-email author-records3) ))
	 )     
    (pretty-print author-records2)
    ))

(define a (get-summaries "1" "3"))
 (retrieve-article (car a))

(define b (list (make-contact "33919699" 5 "Wang J" "Jingxin Wang" "Jingxin" "Wang" "Department of Medicinal Chemistry, University of Kansas, Lawrence, KS 66047, USA." "null")
 (make-contact "33919699" 4 "Boskovic ZV" "Zarko V Boskovic" "Zarko" "Boskovic" "Department of Medicinal Chemistry, University of Kansas, Lawrence, KS 66047, USA." "null")
 (make-contact "33919699" 3 "Pearson ZJ" "Zach J Pearson" "Zach" "Pearson" "Department of Medicinal Chemistry, University of Kansas, Lawrence, KS 66047, USA." "null")
 (make-contact "33919699" 2 "Zhao J" "Junxing Zhao" "Junxing" "Zhao" "Department of Medicinal Chemistry, University of Kansas, Lawrence, KS 66047, USA." "null")
 (make-contact "33919699" 1 "Tang Z" "Zhichao Tang" "Zhichao" "Tang" "Department of Medicinal Chemistry, University of Kansas, Lawrence, KS 66047, USA." "null")))

(get-missing-email (list (cadr b)) '())
