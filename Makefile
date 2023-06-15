PROJDIR?=$(PWD)

OUTDIRNAME=out
OBJDIRNAME=obj
OUTDIR=./$(OUTDIRNAME)
OBJDIR=./$(OBJDIRNAME)

DOCKEROUTDIRNAME=docker-out
DOCKEROBJDIRNAME=docker-obj
DOCKEROUTDIR=./$(DOCKEROUTDIRNAME)
DOCKEROBJDIR=./$(DOCKEROBJDIRNAME)

BASENAME=book
RELEASENAME=logic

BASETEX=./$(BASENAME).tex
BASEOBJ=$(OBJDIR)/$(BASENAME).pdf
BASEOUT=$(OUTDIR)/$(RELEASENAME).pdf

LOGSECTION=@echo "\033[32m==== $(1) =====\033[0m"
MAKEDIR=[ ! -d $(1) ] && mkdir -p $(1) || true

SET_XELATEX=$$pdflatex=q[xelatex %O %S]
SET_PATCHES=ensure_path(q[TEXINPUTS], q[./patches])
SET_MAKEIDX=$$makeindex=q[texindy -M $(PROJDIR)/index_style.xdy %S]

LATEX=latexmk -pdf -outdir=$(OBJDIR) -e '$$pdf_previewer=q[zathura %S];$(SET_XELATEX);$(SET_PATCHES);$(SET_MAKEIDX);'
# LATEX=latexmk -pdf -outdir=$(OBJDIR) -e '$$pdf_previewer=q[zathura %S];ensure_path(q[TEXINPUTS], q[./patches]);'

.PHONY: watch build filesys clean build-docker clean-docker

filesys:
	$(call LOGSECTION, Creating filesystem)
	$(call MAKEDIR, $(OUTDIR))
	$(call MAKEDIR, $(OBJDIR))

clean:
	rm -rf $(OUTDIR) $(OBJDIR) $(DOCKEROUTDIR) $(DOCKEROBJDIR)

watch: filesys
	$(call LOGSECTION, Starting watch)
	$(LATEX) -pvc $(BASETEX)

build: filesys
	$(call LOGSECTION, Starting build)
	$(LATEX) $(BASETEX)
	$(call LOGSECTION, Optimizing)
	pdfsizeopt --do-require-image-optimizers=no --quiet $(BASEOBJ) $(BASEOUT)

build-docker:
	$(call LOGSECTION, Preparing directories)
	rm -rf $(DOCKEROUTDIR) $(DOCKEROBJDIR)
	mkdir -p $(DOCKEROUTDIR)
	mkdir -p $(DOCKEROBJDIR)
	echo $$(basename $$(pwd)):$$(date +%Y-%d-%m-%H-%M-%S) >> $(DOCKEROBJDIR)/image
	$(call LOGSECTION, Building the image)
	sudo docker build . -t $$(cat $(DOCKEROBJDIR)/image)
	$(call LOGSECTION, Dockerised build)
	sudo docker run --rm \
	-v $$(pwd)/$(DOCKEROUTDIRNAME):/root/src/$(OUTDIRNAME) \
	-v $$(pwd)/$(DOCKEROBJDIRNAME):/root/src/$(OBJDIRNAME) \
	-i $$(cat $(DOCKEROBJDIR)/image)

clean-docker:
	$(MAKE) clean
	$(call LOGSECTION, Cleaning docker images)
	sudo docker rmi -f $$(sudo docker images -q $$(basename $$(pwd)))
