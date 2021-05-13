#!/gnu/store/q8brh7j5mwy0hbrly6hjb1m3wwndxqc8-guile-3.0.5/bin/guile \
-e main -s
!#

 (add-to-load-path "/home/mbc/projects")

https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmen&term=96+multi+well+OR+high-throughput+screening+assay+(2021%2F04%2F16[epdat])&retmax=3


https://pubmed.ncbi.nlm.nih.gov/32781280/

https://pubmed.ncbi.nlm.nih.gov/33906944/  ;;Church GM is last author

(pretty-print (get-summaries "1" "30"))

(define a '((("33970005") ("Mutabazi UP" "Brysiewicz P"))))



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
	 ;;(author-records (if the-body (get-authors-records the-body) #f))
	 ;; (affils-alist '())
	 ;; (affils-alist (if (null? author-records) #f (get-affils-alist the-body )))
	 ;; (author-records2 (if (null? affils-alist) #f (recurse-update-contact-records 1 pmid indexed-auth-lst author-records affils-alist '())))
	 ;; (author-records3 (if (null? author-records2) #f (recurse-get-missing-email author-records2 '())))
;;	 (dummy4 (if (null? author-records3) #f (recurse-send-email author-records3) ))
	 )     
    (pretty-print the-body)
  ;;  #f
    ))

(retrieve-article (car a))

(map retrieve-article a)


(define the-body (receive (response-status response-body)
	 	     (http-request "https://pubmed.ncbi.nlm.nih.gov/33970005/") response-body))


(null? #f)

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
					     (string-contains first-author "</a><sup class=\"affiliation-links\"><spa")))

			   )
		     ;; (if proceed-flag (map extract-authors auth-lst) #f)
		      auth-lst
		      ) ;;end of let
		    #f
		    ) ;;end of if
		)
	)					     			      				 
    auth-v)
  )


(define b '(("-ga-label=\"Uwonkunda P Mutabazi\">Uwonkunda P Mutabazi</a><sup class=\"affiliation-links\"><span class=\"author-sup-separator\">&nbsp;</span><a class=\"affiliation-link\" title=\"School of Nursing and Public Health, University of KwaZulu-Natal, Durban. uwonkundap@yahoo.fr.\" href=\"#affiliation-1\" ref=\"linksrc=author_aff\">\n                1\n              </a></sup><span class=\"comma\">,&nbsp;</span></span><span class=\"authors-list-item \"><a class=\"full-name\"\n           href=\"/?term=Brysiewicz+Pcauthor_id=33970005\"\n           ref=\"linksrc=author_name_link\"\n           data-ga-category=\"search\"\n           data-ga-action=\"author_link\"\n          "
 "-ga-label=\"Petra Brysiewicz\">Petra Brysiewicz</a></span>\n  </div>\n\n\n      </div>\n    \n\n    \n\n    \n\n    \n  \n</div>\n\n        \n        \n          ")))

(pretty-print (get-authors-records the-body))

(define achunk "-ga-label=\"Petra Brysiewicz\">Petra Brysiewicz</a></span>\n  </div>\n\n\n      </div>\n    \n\n    \n\n    \n\n    \n  \n</div>\n\n        \n        \n          ")

(define achunk "-ga-label=\"Uwonkunda P Mutabazi\">Uwonkunda P Mutabazi</a><sup class=\"affiliation-links\"><span class=\"author-sup-separator\">&nbsp;</span><a class=\"affiliation-link\" title=\"School of Nursing and Public Health, University of KwaZulu-Natal, Durban. uwonkundap@yahoo.fr.\" href=\"#affiliation-1\" ref=\"linksrc=author_aff\">\n                1\n              </a></sup><span class=\"comma\">,&nbsp;</span></span><span class=\"authors-list-item \"><a class=\"full-name\"\n           href=\"/?term=Brysiewicz+Pcauthor_id=33970005\"\n           ref=\"linksrc=author_name_link\"\n           data-ga-category=\"search\"\n           data-ga-action=\"author_link\"\n          ")




(define the-list  (list (string-match (string-append ">[" all-chars "]+</a><sup class=\"equal-contrib-container")  achunk)			  
		      (string-match (string-append ">[" all-chars "]+</a><sup class=\"affiliation-links\"><spa")  achunk)
		      (string-match (string-append ">[" all-chars "]+</a></span>")  achunk)))

(define c (get-coords the-list))


(extract-authors (cadar b))

"-ga-label=\"Uwonkunda P Mutabazi\">Uwonkunda P Mutabazi</a><sup class=\"affiliation-links\"><span class=\"author-sup-separator\">&nbsp;</span><a class=\"affiliation-link\" title=\"School of Nursing and Public Health, University of KwaZulu-Natal, Durban. uwonkundap@yahoo.fr.\" href=\"#affiliation-1\" ref=\"linksrc=author_aff\">\n                1\n              </a></sup><span class=\"comma\">,&nbsp;</span></span><span class=\"authors-list-item \"><a class=\"full-name\"\n           href=\"/?term=Brysiewicz+Pcauthor_id=33970005\"\n           ref=\"linksrc=author_name_link\"\n           data-ga-category=\"search\"\n           data-ga-action=\"author_link\"\n          "



 "-ga-label=\"Petra Brysiewicz\">Petra Brysiewicz</a></span>\n  </div>\n\n\n      </div>\n    \n\n    \n\n    \n\n    \n  \n</div>\n\n        \n        \n          "

(any-not-false? '(#f #t #t))
(any )
