#!/gnu/store/q8brh7j5mwy0hbrly6hjb1m3wwndxqc8-guile-3.0.5/bin/guile \
-e main -s
!#

 (add-to-load-path "/home/mbc/projects")

https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmen&term=96+multi+well+OR+high-throughput+screening+assay+(2021%2F04%2F16[epdat])&retmax=3


https://pubmed.ncbi.nlm.nih.gov/32781280/

https://pubmed.ncbi.nlm.nih.gov/33906944/  ;;Church GM is last author

 586:17  7 (map1 ((("33892103") ("Ivanenkov YA" "Yu Filyae…" …)) …))
In /home/mbc/projects/conmanv3/./conman.scm:
   465:57  6 (retrieve-article _)
   607:35  5 (recurse-get-missing-email _ _)
   594:63  4 (get-missing-email #<<contact> pmid: "33892103" index:…> …)
   211:19  3 (find-email "Vakhitova JV")
   171:14  2 (find-fl-aoi "Vakhitova JV")
In srfi/srfi-1.scm:
   603:19  1 (map2 ("Vakhitova JV" "Vakhitova JV" "Vakhitova JV" . #) …)
In /home/mbc/projects/conmanv3/./conman.scm:
   154:20  0 (first-or-last-auth? "Vakhitova JV" _)

/home/mbc/projects/conmanv3/./conman.scm:154:20: In procedure first-or-last-auth?:
In procedure car: Wrong type argument in position 1 (expecting pair): ()


(define a (get-summaries "1" "30"))
(define b (map retrieve-article a))
(pretty-print a)

(define g  (find-email "Vakhitova JV"))
(define h (get-articles-for-auth "Vakhitova JV"))
(define i (map first-or-last-auth? (circular-list "Vakhitova JV") h))
(define j (find-fl-aoi "Vakhitova JV"))


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


