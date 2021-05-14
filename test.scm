#!/gnu/store/q8brh7j5mwy0hbrly6hjb1m3wwndxqc8-guile-3.0.5/bin/guile \
-e main -s
!#

 (add-to-load-path "/home/mbc/projects")

https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmen&term=96+multi+well+OR+high-throughput+screening+assay+(2021%2F04%2F16[epdat])&retmax=3


https://pubmed.ncbi.nlm.nih.gov/33929276/

https://pubmed.ncbi.nlm.nih.gov/33906944/  ;;Church GM is last author

(pretty-print (get-summaries "1" "30"))

(define a '((("33929276")
  ("Shing B" "Balen M" "McKerrow JH" "Debnath A"))))




<Item Name="Title" Type="String">






(get-summaries "1" "30")
(pretty-print ref-records)


  
  (pretty-print (recurse-remove-italicization a '()))


(define a '("Sum>\n\t<Id>33929276</Id>\n\t<Item Name=\"PubDate\" Type=\"Date\">2021 Apr 30</Item>\n\t<Item Name=\"EPubDate\" Type=\"Date\">2021 Apr 30</Item>\n\t<Item Name=\"Source\" Type=\"String\">Expert Rev Anti Infect Ther</Item>\n\t<Item Name=\"AuthorList\" Type=\"List\">\n\t\t<Item Name=\"Author\" Type=\"String\">Shing B</Item>\n\t\t<Item Name=\"Author\" Type=\"String\">Balen M</Item>\n\t\t<Item Name=\"Author\" Type=\"String\">McKerrow JH</Item>\n\t\t<Item Name=\"Author\" Type=\"String\">Debnath A</Item>\n\t</Item>\n\t<Item Name=\"LastAuthor\" Type=\"String\">Debnath A</Item>\n\t<Item Name=\"Title\" Type=\"String\">&lt;i&gt;Acanthamoeba&lt;/i&gt; Keratitis: an update on amebicidal and cysticidal drug screening methodologies and potential treatment with azole drugs.</Item>\n\t<Item Name=\"Volume\" Type=\"String\"></Item>\n\t<Item Name=\"Issue\" Type=\"String\"></Item>\n\t<Item Name=\"Pages\" Type=\"String\"></Item>\n\t<Item Name=\"LangList\" Type=\"List\">\n\t\t<Item Name=\"Lang\" Type=\"String\">English</Item>\n\t</Item>\n\t<Item Name=\"NlmUniqueID\" Type=\"String\">101181284</Item>\n\t<Item Name=\"ISSN\" Type=\"String\">1478-7210</Item>\n\t<Item Name=\"ESSN\" Type=\"String\">1744-8336</Item>\n\t<Item Name=\"PubTypeList\" Type=\"List\">\n\t\t<Item Name=\"PubType\" Type=\"String\">Journal Article</Item>\n\t</Item>\n\t<Item Name=\"RecordStatus\" Type=\"String\">PubMed - as supplied by publisher</Item>\n\t<Item Name=\"PubStatus\" Type=\"String\">aheadofprint</Item>\n\t<Item Name=\"ArticleIds\" Type=\"List\">\n\t\t<Item Name=\"pubmed\" Type=\"String\">33929276</Item>\n\t\t<Item Name=\"doi\" Type=\"String\">10.1080/14787210.2021.1924673</Item>\n\t\t<Item Name=\"rid\" Type=\"String\">33929276</Item>\n\t\t<Item Name=\"eid\" Type=\"String\">33929276</Item>\n\t</Item>\n\t<Item Name=\"DOI\" Type=\"String\">10.1080/14787210.2021.1924673</Item>\n\t<Item Name=\"History\" Type=\"List\">\n\t\t<Item Name=\"entrez\" Type=\"Date\">2021/04/30 12:13</Item>\n\t\t<Item Name=\"pubmed\" Type=\"Date\">2021/05/01 06:00</Item>\n\t\t<Item Name=\"medline\" Type=\"Date\">2021/05/01 06:00</Item>\n\t</Item>\n\t<Item Name=\"References\" Type=\"List\"></Item>\n\t<Item Name=\"HasAbstract\" Type=\"Integer\">1</Item>\n\t<Item Name=\"PmcRefCount\" Type=\"Integer\">0</Item>\n\t<Item Name=\"FullJournalName\" Type=\"String\">Expert review of anti-infective therapy</Item>\n\t<Item Name=\"ELocationID\" Type=\"String\">doi: 10.1080/14787210.2021.1924673</Item>\n\t<Item Name=\"SO\" Type=\"String\">2021 Apr 30;</Item>\n</DocSum>\n"
 "Sum>\n\t<Id>33929058</Id>\n\t<Item Name=\"PubDate\" Type=\"Date\">2021 Apr 30</Item>\n\t<Item Name=\"EPubDate\" Type=\"Date\">2021 Apr 30</Item>\n\t<Item Name=\"Source\" Type=\"String\">Transfusion</Item>\n\t<Item Name=\"AuthorList\" Type=\"List\">\n\t\t<Item Name=\"Author\" Type=\"String\">Gowda L</Item>\n\t\t<Item Name=\"Author\" Type=\"String\">Vege S</Item>\n\t\t<Item Name=\"Author\" Type=\"String\">Kessler D</Item>\n\t\t<Item Name=\"Author\" Type=\"String\">Shaz B</Item>\n\t\t<Item Name=\"Author\" Type=\"String\">Westhoff CM</Item>\n\t</Item>\n\t<Item Name=\"LastAuthor\" Type=\"String\">Westhoff CM</Item>\n\t<Item Name=\"Title\" Type=\"String\">Screening of blood donors for sickle cell trait using a DNA-based approach: Frequency in a multiethnic donor population.</Item>\n\t<Item Name=\"Volume\" Type=\"String\"></Item>\n\t<Item Name=\"Issue\" Type=\"String\"></Item>\n\t<Item Name=\"Pages\" Type=\"String\"></Item>\n\t<Item Name=\"LangList\" Type=\"List\">\n\t\t<Item Name=\"Lang\" Type=\"String\">English</Item>\n\t</Item>\n\t<Item Name=\"NlmUniqueID\" Type=\"String\">0417360</Item>\n\t<Item Name=\"ISSN\" Type=\"String\">0041-1132</Item>\n\t<Item Name=\"ESSN\" Type=\"String\">1537-2995</Item>\n\t<Item Name=\"PubTypeList\" Type=\"List\">\n\t\t<Item Name=\"PubType\" Type=\"String\">Journal Article</Item>\n\t</Item>\n\t<Item Name=\"RecordStatus\" Type=\"String\">PubMed - as supplied by publisher</Item>\n\t<Item Name=\"PubStatus\" Type=\"String\">aheadofprint</Item>\n\t<Item Name=\"ArticleIds\" Type=\"List\">\n\t\t<Item Name=\"pubmed\" Type=\"String\">33929058</Item>\n\t\t<Item Name=\"doi\" Type=\"String\">10.1111/trf.16403</Item>\n\t\t<Item Name=\"rid\" Type=\"String\">33929058</Item>\n\t\t<Item Name=\"eid\" Type=\"String\">33929058</Item>\n\t</Item>\n\t<Item Name=\"DOI\" Type=\"String\">10.1111/trf.16403</Item>\n\t<Item Name=\"History\" Type=\"List\">\n\t\t<Item Name=\"revised\" Type=\"Date\">2021/02/16 00:00</Item>\n\t\t<Item Name=\"received\" Type=\"Date\">2020/07/16 00:00</Item>\n\t\t<Item Name=\"accepted\" Type=\"Date\">2021/02/17 00:00</Item>\n\t\t<Item Name=\"entrez\" Type=\"Date\">2021/04/30 08:53</Item>\n\t\t<Item Name=\"pubmed\" Type=\"Date\">2021/05/01 06:00</Item>\n\t\t<Item Name=\"medline\" Type=\"Date\">2021/05/01 06:00</Item>\n\t</Item>\n\t<Item Name=\"References\" Type=\"List\"></Item>\n\t<Item Name=\"HasAbstract\" Type=\"Integer\">1</Item>\n\t<Item Name=\"PmcRefCount\" Type=\"Integer\">0</Item>\n\t<Item Name=\"FullJournalName\" Type=\"String\">Transfusion</Item>\n\t<Item Name=\"ELocationID\" Type=\"String\">doi: 10.1111/trf.16403</Item>\n\t<Item Name=\"SO\" Type=\"String\">2021 Apr 30;</Item>\n</DocSum>\n\n</eSummaryResult>\n"))
