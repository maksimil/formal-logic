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

LATEX=latexmk -pdf -outdir=$(OBJDIR) -e '$$pdflatex = q[xelatex %O %S];$$pdf_previewer=q[zathura %S];ensure_path(q[TEXINPUTS], q[./patches]);'
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
	$(call MAKEDIR, $(DOCKEROUTDIR))
	$(call MAKEDIR, $(DOCKEROBJDIR))
	echo $$(basename $$(pwd)):$$(date +%Y-%d-%m-%H-%M-%S) >> $(DOCKEROUTDIR)/image
	$(call LOGSECTION, Building the image)
	sudo docker build . -t $$(cat $(DOCKEROUTDIR)/image)
	$(call LOGSECTION, Dockerised build)
	sudo docker run --rm \
	-v $$(pwd)/$(DOCKEROUTDIRNAME):/root/src/$(OUTDIRNAME) \
	-v $$(pwd)/$(DOCKEROBJDIRNAME):/root/src/$(OBJDIRNAME) \
	-it $$(cat $(DOCKEROUTDIR)/image)

clean-docker:
	$(MAKE) clean
	$(call LOGSECTION, Cleaning docker images)
	sudo docker rmi -f $$(sudo docker images -q $$(basename $$(pwd)))
