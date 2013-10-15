VER=19
REFGEN3_GFF3_URL=ftp://ftp.ensemblgenomes.org/pub/release-$(VER)/plants/gff3/zea_mays/Zea_mays.AGPv3.$(VER).gff3.gz
REFGEN3_GFF3_FILE=Zea_mays.AGPv3.$(VER).gff3
REFGEN3_SQLITE_DB=Zea_mays.AGPv3.$(VER).sqlite
CHROMS=1 2 3 4 5 6 7 8 9 10 Mt Pt
REFGEN3_SEQS=$(foreach chrom, $(CHROMS), Zea_mays.AGPv3.$(VER).dna.chromosome.$(chrom).fa.gz)
REFGEN3_SEQS_URLS=$(addprefix ftp://ftp.ensemblgenomes.org/pub/release-$(VER)/plants/fasta/zea_mays/dna/, $(REFGEN3_SEQS))
REFGEN3_CHROM_INFO=Zea_mays.AGPv3.$(VER).chrom_info.txt

# set up directory structure
RESOURCES=resources
$(RESOURCES):
        mkdir -p $@

SEQS=$(RESOURCES)/chrs
$(SEQS):
        mkdir -p $@

# primary targets
txdb: $(RESOURCES)/$(REFGEN3_SQLITE_DB)
chrs: $(SEQS)/$(REFGEN3_SEQS):

$(RESOURCES)/$(REFGEN3_GFF3_FILE):
        @echo "Downloading RefGen3 GFF3"
        curl $(REFGEN3_GFF3_URL) | gzcat > $@

$(SEQS)/$(REFGEN3_SEQS):
        @echo "Downloading full RefGen3 sequences for chromosomes 1-10, Mt, Pt"
        (cd $(SEQS) && curl -O $(REFGEN3_SEQS_URLS))

$(RESOURCES)/$(REFGEN3_CHROM_INFO):
        @echo "Creating chromosome length table for RefGen3"
        curl $(REFGEN3_SEQS_URLS) | gzcat - | bioawk -c fastx '{print $$name"\t"length($$seq)"\tNA"}' > $@

$(RESOURCES)/$(REFGEN3_SQLITE_DB): $(RESOURCES)/$(REFGEN3_GFF3_FILE) $(RESOURCES)/$(REFGEN3_CHROM_INFO)
        @echo "Creating SQLite Database of RefGen3 tracks"
        Rscript R/txdb.R $(RESOURCES)/$(REFGEN3_GFF3_FILE) $(RESOURCES)/$(REFGEN3_CHROM_INFO) $(REFGEN3_GFF3_URL) "Zea mays" $(RESOURCE\
S)/$(REFGEN3_SQLITE_DB)