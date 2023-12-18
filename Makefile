#Select org from ~/.carbonblack/credentials.cbc
org=default

first:
#	Get author from Linux user
	./cbgetauthor.sh
#	Get creds from default section in ~/.carbonblack/credentials.cbc
	./cbcreds.sh ${org} >config.sh
	./cbdevices.sh
#	cbcontainer.sh will add K8s info in devices.tex, so it must be after devices.sh
	./cbcontainer.sh
# 	Create AUX file for glossary and TOC
	-xelatex -interaction=nonstopmode cbreport.tex
	makeglossaries cbreport
#	Create PDF with glossary included
	-xelatex -synctex=1 -interaction=nonstopmode cbreport.tex
	xpdf cbreport.pdf &

.PHONY: example
example:
#	Copy txt and tex files from example directory
	cp example/* .
#	Use '-' before xelatex to ignore errors
	-xelatex -interaction=nonstopmode cbreport.tex
	makeglossaries cbreport
	-xelatex -synctex=1 -interaction=nonstopmode cbreport.tex
	cp cbreport.pdf cbreport_example.pdf
	xpdf cbreport_example.pdf &

.PHONY: code
code:
	./code.sh
	-xelatex -shell-escape -interaction=nonstopmode code.tex
	xpdf code.pdf &

.PHONY: cbctl
cbctl:
	./cbcreds.sh default >config.sh
	./cbgetcbctl.sh

clean:
	$(RM) *.log *.pdf *.out *.aux *.toc *.json *.txt *.synctex.gz \
	 *.g* *.ist *.lot critical.tex device* author.tex cbreport.lof \
	 config.sh listing.tex hardeningpolicies.tex download_links.json \
	 alerts_reason.txt reasons.txt cbctl alertreason.tex high.tex \
	 vulnoverview.tex registrylistdiff.tex *.old namespacelistdiff.tex \
	 clusterlistdiff.tex malware.tex runtimealert.tex alertsnamespace.tex \
	 alertsremoteip.tex



