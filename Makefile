first:
#	Get author from Linux user
	./cbgetauthor.sh
#	Get creds from default section in ~/.carbonblack/credentials.cbc
	./cbcreds.sh default >config.sh
	./cbdevices.sh
#	cbcontainer.sh will add K8s info in devices.tex, so it must be after devices.sh
	./cbcontainer.sh
	./cbc-alerts-reason.py |sort |uniq >alerts_reason.txt
	./cbc-alerts-remoteip.py >alerts_remoteip.txt
# 	Create AUX file for glossary and TOC
	-xelatex -interaction=nonstopmode cbreport.tex
	makeglossaries cbreport
#	Create PDF with glossary included
	-xelatex -synctex=1 -interaction=nonstopmode cbreport.tex
	xpdf cbreport.pdf &

example:
#	Copy txt and tex files from example directory
	cp example/* .
	-xelatex -interaction=nonstopmode cbreport.tex
	makeglossaries cbreport
	-xelatex -synctex=1 -interaction=nonstopmode cbreport.tex
	cp cbreport.pdf cbreport_example.pdf
	xpdf cbreport_example.pdf &

code:
	./code.sh
	-xelatex -shell-escape -interaction=nonstopmode code.tex
	xpdf code.pdf &

clean:
	$(RM) *.log *.pdf *.out *.aux *.toc *.json *.txt *.synctex.gz \
	 *.g* *.ist *.lot critical.tex device* author.tex cbreport.lof \
	 config.sh listing.tex hardeningpolicies.tex


