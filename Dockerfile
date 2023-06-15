FROM ksyk/texlive:base

# update
RUN apt-get update
RUN apt-get upgrade --yes
RUN tlmgr update --self

# installing dependencies
RUN apt-get install libfontconfig1 --yes

RUN tlmgr install \
# language
	cyrillic cm-unicode polyglossia xltxtra hyphen-russian realscripts \
# math and formatting
	caption enumitem mathtools \
	tufte-latex hardwrap titlesec ragged2e textcase setspace \
	fancyhdr datetime fmtcount \
	pgf imakeidx xindy

ENV PATH=/root/.TinyTeX/bin/x86_64-linux:$PATH

# getting source code
RUN mkdir /root/src
WORKDIR /root/src

COPY book.tex .
COPY Makefile .
COPY index_style.xdy .
COPY chapters ./chapters

CMD ["make", "build", "PROJDIR=/root/src"]
