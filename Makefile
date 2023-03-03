OUTDIR=./out
OBJDIR=./obj

BASENAME=book

BASETEX=./$(BASENAME).tex
BASEOBJ=$(OBJDIR)/$(BASENAME).pdf
BASEOUT=$(OUTDIR)/$(BASENAME).pdf

LOGSECTION=@echo "\033[32m==== $(1) =====\033[0m"

LATEX=latexmk -pdf -outdir=$(OBJDIR) -e '$$pdf_previewer=q[zathura %S];ensure_path(q[TEXINPUTS], q[./patches]);'

.PHONY: watch build filesys clean build-docker clean-docker

filesys:
	$(call LOGSECTION, Creating filesystem)
	[ ! -d $(OUTDIR) ] && mkdir -p $(OUTDIR) || true
	[ ! -d $(OBJDIR) ] && mkdir -p $(OBJDIR) || true

clean:
	rm -rf $(OUTDIR) $(OBJDIR)

watch: filesys
	$(call LOGSECTION, Starting watch)
	$(LATEX) -pvc $(BASETEX)

build: filesys
	$(call LOGSECTION, Starting build)
	$(LATEX) $(BASETEX)
	$(call LOGSECTION, Optimizing)
	pdfsizeopt --do-require-image-optimizers=no --quiet $(BASEOBJ) $(BASEOUT)

# build-docker:
#   $(call LOGSECTION, Preparing directories)
#   $(MAKE) clean
#   mkdir -p $(OUTDIR)
#   echo $$(basename $$(pwd)):$$(date +%Y-%d-%m-%H-%M-%S) >> $(OUTDIR)/image
#   $(call LOGSECTION, Building the image)
#   sudo docker build . -t $$(cat $(OUTDIR)/image)
#   $(call LOGSECTION, Dockerised build)
#   sudo docker run --rm -v $$(pwd)/out:/root/src/out -it $$(cat $(OUTDIR)/image)
# 
# clean-docker:
#   $(MAKE) clean
#   $(call LOGSECTION, Cleaning docker images)
#   sudo docker rmi -f $$(sudo docker images -q $$(basename $$(pwd)))
