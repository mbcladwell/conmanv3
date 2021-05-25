#!/gnu/store/q8brh7j5mwy0hbrly6hjb1m3wwndxqc8-guile-3.0.5/bin/guile \
-e main -s
!#

 (add-to-load-path "/home/mbc/projects")

https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmen&term=96+multi+well+OR+high-throughput+screening+assay+(2021%2F04%2F16[epdat])&retmax=3


https://pubmed.ncbi.nlm.nih.gov/33955247/

https://pubmed.ncbi.nlm.nih.gov/33906944/  ;;Church GM is last author

(pretty-print (get-summaries "1" "30"))

(retrieve-article a)




(get-summaries "1" "30")
(pretty-print ref-records)

(define (get-summaries reldate retmax)
  ;; this is the initializing method
  (let*((db "pubmed")
	(query (string-append "96+multi+well+OR+high-throughput+screening+assay+(" (uri-encode two-weeks-ago) "[epdat])"))
	;;(query (string-append "96+multi+well+OR+high-throughput+screening+assay+(2021%2F04%2F14[epdat])"))
	
	(base "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/")
	;; (define url (string-append base  "esearch.fcgi?db=" db "&term=" query "&usehistory=y"))
	(url (string-append base  "esearch.fcgi?db=" db "&term=" query "&retmax=" retmax))
	(the-body   (receive (response-status response-body)
			(http-request url) response-body))
	(dummy (sleep 1))
        (all-ids-pre   (map match:substring  (list-matches "<Id>[0-9]+</Id>" the-body ) ))
	(e (if (not (null? all-ids-pre))
	       (let* ((all-ids (map (lambda (x) (string-append (xsubstring x 4 12) ",")) all-ids-pre))
		      (all-ids-concat (string-concatenate all-ids))
		      (all-ids-concat (xsubstring all-ids-concat 0 (- (string-length all-ids-concat) 1)))
		      (summary-url (string-append base "esummary.fcgi?db=" db "&id=" all-ids-concat  ))
		      ;; (summary-url (string-append base "esummary.fcgi?db=" db "&id=" all-ids-concat "&version=2.0" ))
		      (all-summaries   (receive (response-status response-body)
					   (http-request summary-url) response-body))
		      (b (find-occurences-in-string "<DocSum>" all-summaries))
		      (c (map (lambda (x) (substring all-summaries (car x) (cdr x))) b))
		      (d (recurse-remove-italicization c '()))
		      ;; this is where I will insert the ref table processing
		      ;; this creates ref-records, an a-list of references
		      (dummy (get-pmid-jrn-title d))
		      ) 
		 	 (map get-id-authors d)
		;; d
		 )		      
               '() ))  )
    (pretty-print e)))
 ;;  e))

  

(define (retrieve-article a-summary)
  ;;this does all the work; summary list repeately processed article by article
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
	 (affils-alist (if (null? author-records) #f (get-affils-alist the-body )))
	 (author-records2 (if (null? affils-alist) #f (recurse-update-contact-records 1 pmid indexed-auth-lst author-records affils-alist '())))
	 (author-records3 (if (null? author-records2) #f (recurse-get-missing-email author-records2 '())))
	 (dummy4 (if (null? author-records3) #f (recurse-send-email author-records3) ))
	 )     
    ;;(pretty-print author-records3)
    #f
    ))

	 (define tb (receive (response-status response-body)
		       (http-request "https://pubmed.ncbi.nlm.nih.gov/33974405/") response-body))


(define (get-authors-records the-body)
  (let*(
	(coord-start (string-match "<div class=\"authors-list\">" the-body ))
	(auth-v (if coord-start
		    (let* (
			   (coord-end (if (string-match "<div class=\"short-article-details\">" the-body )
					  (string-match "<div class=\"short-article-details\">" the-body )
					  (if (string-match "<div class=\"extended-article-details\" id" the-body )
					      (string-match "<div class=\"extended-article-details\" id" the-body )
					      (if (string-match "<span class=\"authors-list-item \"><" the-body )
						  (string-match "<span class=\"authors-list-item \"><" the-body )
						  ))))		       
			   (auth-chunk (xsubstring the-body (match:start coord-start) (match:start coord-end)))
			   (auth-chunk (regexp-substitute/global #f "&#39;"  auth-chunk 'pre "" 'post))  ;; get rid of '; O'Hara
			   (auth-chunk (regexp-substitute/global #f "&amp;"  auth-chunk 'pre "" 'post))  ;; get rid of &
			    (b (find-occurences-in-string "data-ga-label=" auth-chunk))
			    (auth-lst (map (lambda (x) (substring auth-chunk (car x) (cdr x))) b))
			    (first-author (car auth-lst))
			    (proceed-flag (or (string-contains first-author "</a><sup class=\"equal-contrib-container")
			    		     (string-contains first-author "</a><sup class=\"affiliation-links\"><spa")))
			   )
		    ;;  (if proceed-flag (map extract-authors auth-lst) #f))
		    auth-lst)
		    #f )
		)
	)					     			      				 
    			  (pretty-print auth-v))
    ;;auth-v)
  )



(get-authors-records tb)

(pretty-print tb)
(retrieve-article b)

<div class="authors-list">

(string-match "<div class=\"short-article-details\">" tb )

(define d '("-ga-label=\"Manal J Natto\">Manal J Natto</a><sup class=\"affiliation-links\"><span class=\"author-sup-separator\">&nbsp;</span><a class=\"affiliation-link\" title=\"Institute of Infection, Immunity and Inflammation, College of Medical, Veterinary and Life Sciences, University of Glasgow, Glasgow, U.K.\" href=\"#affiliation-1\" ref=\"linksrc=author_aff\">\n                1\n              </a></sup><span class=\"comma\">,&nbsp;</span></span><span class=\"authors-list-item \"><a class=\"full-name\"\n           href=\"/?term=Hulpia+Fcauthor_id=33974405\"\n           ref=\"linksrc=author_name_link\"\n           data-ga-category=\"search\"\n           data-ga-action=\"author_link\"\n          "
 "-ga-label=\"Fabian Hulpia\">Fabian Hulpia</a><sup class=\"affiliation-links\"><span class=\"author-sup-separator\">&nbsp;</span><a class=\"affiliation-link\" title=\"Laboratory for Medicinal Chemistry, Campus Heymans (FFW), Ghent University, Ottergemsesteenweg 460, B-9000 Gent, Belgium.\" href=\"#affiliation-2\" ref=\"linksrc=author_aff\">\n                2\n              </a></sup><span class=\"comma\">,&nbsp;</span></span><span class=\"authors-list-item \"><a class=\"full-name\"\n           href=\"/?term=Kalkman+ERcauthor_id=33974405\"\n           ref=\"linksrc=author_name_link\"\n           data-ga-category=\"search\"\n           data-ga-action=\"author_link\"\n          "
 "-ga-label=\"Eric R Kalkman\">Eric R Kalkman</a><sup class=\"affiliation-links\"><span class=\"author-sup-separator\">&nbsp;</span><a class=\"affiliation-link\" title=\"Institute of Infection, Immunity and Inflammation, College of Medical, Veterinary and Life Sciences, University of Glasgow, Glasgow, U.K.\" href=\"#affiliation-1\" ref=\"linksrc=author_aff\">\n                1\n              </a></sup><span class=\"comma\">,&nbsp;</span></span><span class=\"authors-list-item \"><a class=\"full-name\"\n           href=\"/?term=Baillie+Scauthor_id=33974405\"\n           ref=\"linksrc=author_name_link\"\n           data-ga-category=\"search\"\n           data-ga-action=\"author_link\"\n          "
 "-ga-label=\"Susan Baillie\">Susan Baillie</a><sup class=\"affiliation-links\"><span class=\"author-sup-separator\">&nbsp;</span><a class=\"affiliation-link\" title=\"Institute of Infection, Immunity and Inflammation, College of Medical, Veterinary and Life Sciences, University of Glasgow, Glasgow, U.K.\" href=\"#affiliation-1\" ref=\"linksrc=author_aff\">\n                1\n              </a></sup><span class=\"comma\">,&nbsp;</span></span><span class=\"authors-list-item \"><a class=\"full-name\"\n           href=\"/?term=Alhejeli+Acauthor_id=33974405\"\n           ref=\"linksrc=author_name_link\"\n           data-ga-category=\"search\"\n           data-ga-action=\"author_link\"\n          "
 "-ga-label=\"Amani Alhejeli\">Amani Alhejeli</a><sup class=\"affiliation-links\"><span class=\"author-sup-separator\">&nbsp;</span><a class=\"affiliation-link\" title=\"Institute of Infection, Immunity and Inflammation, College of Medical, Veterinary and Life Sciences, University of Glasgow, Glasgow, U.K.\" href=\"#affiliation-1\" ref=\"linksrc=author_aff\">\n                1\n              </a></sup><span class=\"comma\">,&nbsp;</span></span><span class=\"authors-list-item \"><a class=\"full-name\"\n           href=\"/?term=Miyamoto+Ycauthor_id=33974405\"\n           ref=\"linksrc=author_name_link\"\n           data-ga-category=\"search\"\n           data-ga-action=\"author_link\"\n          "
 "-ga-label=\"Yukiko Miyamoto\">Yukiko Miyamoto</a><span class=\"comma\">,&nbsp;</span></span><span class=\"authors-list-item \"><a class=\"full-name\"\n           href=\"/?term=Eckmann+Lcauthor_id=33974405\"\n           ref=\"linksrc=author_name_link\"\n           data-ga-category=\"search\"\n           data-ga-action=\"author_link\"\n          "
 "-ga-label=\"Lars Eckmann\">Lars Eckmann</a><span class=\"comma\">,&nbsp;</span></span><span class=\"authors-list-item \"><a class=\"full-name\"\n           href=\"/?term=Van+Calenbergh+Scauthor_id=33974405\"\n           ref=\"linksrc=author_name_link\"\n           data-ga-category=\"search\"\n           data-ga-action=\"author_link\"\n          "
 "-ga-label=\"Serge Van Calenbergh\">Serge Van Calenbergh</a><sup class=\"affiliation-links\"><span class=\"author-sup-separator\">&nbsp;</span><a class=\"affiliation-link\" title=\"Laboratory for Medicinal Chemistry, Campus Heymans (FFW), Ghent University, Ottergemsesteenweg 460, B-9000 Gent, Belgium.\" href=\"#affiliation-2\" ref=\"linksrc=author_aff\">\n                2\n              </a></sup><span class=\"comma\">,&nbsp;</span></span><span class=\"authors-list-item \"><a class=\"full-name\"\n           href=\"/?term=de+Koning+HPcauthor_id=33974405\"\n           ref=\"linksrc=author_name_link\"\n           data-ga-category=\"search\"\n           data-ga-action=\"author_link\"\n          "
 "-ga-label=\"Harry P de Koning\">Harry P de Koning</a><sup class=\"affiliation-links\"><span class=\"author-sup-separator\">&nbsp;</span><a class=\"affiliation-link\" title=\"Institute of Infection, Immunity and Inflammation, College of Medical, Veterinary and Life Sciences, University of Glasgow, Glasgow, U.K.\" href=\"#affiliation-1\" ref=\"linksrc=author_aff\">\n                1\n              </a></sup></span>\n  </div>\n\n\n      </div>\n    \n\n    \n\n    \n\n    \n  \n</div>\n\n        \n        \n          "))





(car d)

(define achunk "-ga-label=\"Yukiko Miyamoto\">Yukiko Miyamoto</a><span class=\"comma\">,&nbsp;</span></span><span class=\"authors-list-item \"><a class=\"full-name\"\n           href=\"/?term=Eckmann+Lcauthor_id=33974405\"\n           ref=\"linksrc=author_name_link\"\n           data-ga-category=\"search\"\n           data-ga-action=\"author_link\"\n          ")






(map extract-authors  d)
