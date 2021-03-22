DRAFT:=voucher-delegation
VERSION:=$(shell ./getver ${DRAFT}.mkd )
YANGDATE=2020-01-06
YANGFILE=yang/ietf-delegated-voucher@${YANGDATE}.yang
PYANG=pyang
EXAMPLES=ietf-delegated-voucher-tree.txt
EXAMPLES+=${YANGFILE}

${DRAFT}-${VERSION}.txt: ${DRAFT}.txt
	cp ${DRAFT}.txt ${DRAFT}-${VERSION}.txt
	: git add ${DRAFT}-${VERSION}.txt ${DRAFT}.txt

%.xml: %.mkd ${EXAMPLES}
	kramdown-rfc2629 ${DRAFT}.mkd | ./insert-figures >${DRAFT}.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc --v2v3 ${DRAFT}.xml
	mv ${DRAFT}.v2v3.xml ${DRAFT}.xml

%.txt: %.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc --text -o $@ $?

%.html: %.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc --html -o $@ $?

ietf-delegated-voucher-tree.txt: ${YANGFILE}
	${PYANG} --path=../../anima/bootstrap/yang --path=../../anima/voucher -f tree --tree-print-groupings --tree-line-length=70 ${YANGFILE} > ietf-delegated-voucher-tree.txt

${YANGFILE}: ietf-delegated-voucher.yang
	mkdir -p yang
	sed -e"s/YYYY-MM-DD/${YANGDATE}/" ietf-delegated-voucher.yang > ${YANGFILE}


submit: ${DRAFT}.xml
	curl -S -F "user=mcr+ietf@sandelman.ca" -F "xml=@${DRAFT}.xml;type=application/xml" https://datatracker.ietf.org/api/submit

version:
	echo Version: ${VERSION}

clean:
	-rm -f ${DRAFT}.xml

.PRECIOUS: ${DRAFT}.xml
