#!/gnu/store/q8brh7j5mwy0hbrly6hjb1m3wwndxqc8-guile-3.0.5/bin/guile \
-e main -s
!#

 (add-to-load-path "/home/mbc/projects")

https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmen&term=96+multi+well+OR+high-throughput+screening+assay+(2021%2F04%2F16[epdat])&retmax=3


https://pubmed.ncbi.nlm.nih.gov/33955247/

https://pubmed.ncbi.nlm.nih.gov/33906944/  ;;Church GM is last author

(pretty-print (get-summaries "1" "30"))

(retrieve-article a)

(define a '(("33955247")
  ("Gerbeth-Kreul C"
   "Pommereau A"
   "Ruf S"
   "Kane JL Jr"
   "Kuntzweiler T"
   "Hessler G"
   "Engel CK"
   "Shum P"
   "Wei L"
   "Czech J"
   "Licher T")))





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
		  ;;    (d (recurse-remove-italicization c '()))
		      ;; this is where I will insert the ref table processing
		      ;; this creates ref-records, an a-list of references
		;;      (dummy (get-pmid-jrn-title d))
		      ) 
		 ;;	 (map get-id-authors d)
		 c
		 )		      
               '() ))  )
    (pretty-print e)))
 ;;  e))

  
  (pretty-print (recurse-remove-italicization b '()))
&lt;sup&gt;0&lt;/sup&gt;

(define b '("Sum>\n\t<Id>33955247</Id>\n\t<Item Name=\"PubDate\" Type=\"Date\">2021 May 6</Item>\n\t<Item Name=\"EPubDate\" Type=\"Date\">2021 May 6</Item>\n\t<Item Name=\"Source\" Type=\"String\">SLAS Discov</Item>\n\t<Item Name=\"AuthorList\" Type=\"List\">\n\t\t<Item Name=\"Author\" Type=\"String\">Gerbeth-Kreul C</Item>\n\t\t<Item Name=\"Author\" Type=\"String\">Pommereau A</Item>\n\t\t<Item Name=\"Author\" Type=\"String\">Ruf S</Item>\n\t\t<Item Name=\"Author\" Type=\"String\">Kane JL Jr</Item>\n\t\t<Item Name=\"Author\" Type=\"String\">Kuntzweiler T</Item>\n\t\t<Item Name=\"Author\" Type=\"String\">Hessler G</Item>\n\t\t<Item Name=\"Author\" Type=\"String\">Engel CK</Item>\n\t\t<Item Name=\"Author\" Type=\"String\">Shum P</Item>\n\t\t<Item Name=\"Author\" Type=\"String\">Wei L</Item>\n\t\t<Item Name=\"Author\" Type=\"String\">Czech J</Item>\n\t\t<Item Name=\"Author\" Type=\"String\">Licher T</Item>\n\t</Item>\n\t<Item Name=\"LastAuthor\" Type=\"String\">Licher T</Item>\n\t<Item Name=\"Title\" Type=\"String\">A Solid Supported Membrane-Based Technology for Electrophysical Screening of B&lt;sup&gt;0&lt;/sup&gt;AT1-Modulating Compounds.</Item>\n\t<Item Name=\"Volume\" Type=\"String\"></Item>\n\t<Item Name=\"Issue\" Type=\"String\"></Item>\n\t<Item Name=\"Pages\" Type=\"String\">24725552211011180</Item>\n\t<Item Name=\"LangList\" Type=\"List\">\n\t\t<Item Name=\"Lang\" Type=\"String\">English</Item>\n\t</Item>\n\t<Item Name=\"NlmUniqueID\" Type=\"String\">101697563</Item>\n\t<Item Name=\"ISSN\" Type=\"String\">2472-5552</Item>\n\t<Item Name=\"ESSN\" Type=\"String\">2472-5560</Item>\n\t<Item Name=\"PubTypeList\" Type=\"List\">\n\t\t<Item Name=\"PubType\" Type=\"String\">Journal Article</Item>\n\t</Item>\n\t<Item Name=\"RecordStatus\" Type=\"String\">PubMed - as supplied by publisher</Item>\n\t<Item Name=\"PubStatus\" Type=\"String\">aheadofprint</Item>\n\t<Item Name=\"ArticleIds\" Type=\"List\">\n\t\t<Item Name=\"pubmed\" Type=\"String\">33955247</Item>\n\t\t<Item Name=\"doi\" Type=\"String\">10.1177/24725552211011180</Item>\n\t\t<Item Name=\"rid\" Type=\"String\">33955247</Item>\n\t\t<Item Name=\"eid\" Type=\"String\">33955247</Item>\n\t</Item>\n\t<Item Name=\"DOI\" Type=\"String\">10.1177/24725552211011180</Item>\n\t<Item Name=\"History\" Type=\"List\">\n\t\t<Item Name=\"entrez\" Type=\"Date\">2021/05/06 08:44</Item>\n\t\t<Item Name=\"pubmed\" Type=\"Date\">2021/05/07 06:00</Item>\n\t\t<Item Name=\"medline\" Type=\"Date\">2021/05/07 06:00</Item>\n\t</Item>\n\t<Item Name=\"References\" Type=\"List\"></Item>\n\t<Item Name=\"HasAbstract\" Type=\"Integer\">1</Item>\n\t<Item Name=\"PmcRefCount\" Type=\"Integer\">0</Item>\n\t<Item Name=\"FullJournalName\" Type=\"String\">SLAS discovery : advancing life sciences R &amp; D</Item>\n\t<Item Name=\"ELocationID\" Type=\"String\">doi: 10.1177/24725552211011180</Item>\n\t<Item Name=\"SO\" Type=\"String\">2021 May 6;:24725552211011180</Item>\n</DocSum>\n\n</eSummaryResult>\n"))
