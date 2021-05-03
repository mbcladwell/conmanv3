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



(define a (get-summaries "1" "3"))
(retrieve-article (car a))

 (make-contact "33919699" 4 "Boskovic ZV" "Zarko V Boskovic" "Zarko" "Boskovic" "Department of Medicinal Chemistry, University of Kansas, Lawrence, KS 66047, USA." "null")
 (make-contact "33919699" 3 "Pearson ZJ" "Zach J Pearson" "Zach" "Pearson" "Department of Medicinal Chemistry, University of Kansas, Lawrence, KS 66047, USA." "null")
(make-contact "33919699" 2 "Zhao J" "Junxing Zhao" "Junxing" "Zhao" "Department of Medicinal Chemistry, University of Kansas, Lawrence, KS 66047, USA." "null")

(define b (list
	    (make-contact "33919699" 1 "Tang Z" "Zhichao Tang" "Zhichao" "Tang" "Department of Medicinal Chemistry, University of Kansas, Lawrence, KS 66047, USA." "null")
	   (make-contact "33919699" 5 "Wang J" "Jingxin Wang" "Jingxin" "Wang" "Department of Medicinal Chemistry, University of Kansas, Lawrence, KS 66047, USA." "null")
))


(pretty-print (get-missing-email   (car b) '()))
(pretty-print (recurse-get-missing-email b '()))

(pretty-print b)
(recurse-send-email b)

(pretty-print ref-records)
(cdr (assoc "33919699" ref-records))


