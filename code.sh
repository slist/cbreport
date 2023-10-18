#!/bin/bash

LISTING=listing.tex

echo "\\section{Bash scripts}" >${LISTING}


for f in *.sh;
do
	echo -E "\\subsection{$f}" >>${LISTING}
	echo -E "\lstinputlisting[language=Bash]{$f}" >>${LISTING}


done

echo "\\section{Python scripts}" >>${LISTING}

for f in *.py;
do
	echo "\\subsection{$f}" >>${LISTING}
	echo -E "\lstinputlisting[language=Python]{$f}" >>${LISTING}
done
