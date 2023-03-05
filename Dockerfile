FROM ksyk/texlive:base

# installing dependencies
RUN apt-get install libfontconfig1 --yes

RUN tlmgr install \
# language
	cyrillic cm-unicode polyglossia xltxtra hyphen-russian realscripts \
# math and formatting
	caption enumitem \
	tufte-latex hardwrap titlesec ragged2e textcase setspace fancyhdr datetime fmtcount


# getting source code
RUN mkdir /root/src
WORKDIR /root/src

COPY fitch.sty .
COPY book.tex .
COPY Makefile .
COPY chapters ./chapters

CMD ["make", "build"]
