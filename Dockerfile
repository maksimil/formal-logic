FROM ksyk/texlive:base

# installing dependencies
RUN tlmgr install \
# language
	cyrillic cm-unicode polyglossia xltxtra \
# math and formatting
	caption enumitem \
	tufte-latex hardwrap titlesec ragged2e textcase setspace fancyhdr

RUN apt-get install libfontconfig1 --yes
# RUN tlmgr install fontname microtype cm-super soul

RUN tlmgr install realscripts
RUN tlmgr install hyphen-russian
	
# getting source code
RUN mkdir /root/src
WORKDIR /root/src

COPY fitch.sty .
COPY book.tex .
COPY Makefile .
COPY chapters ./chapters

CMD ["make", "build"]
