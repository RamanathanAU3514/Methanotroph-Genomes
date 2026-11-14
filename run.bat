@echo off
if exist methanotroph_genomes.tsv del methanotroph_genomes.tsv
for /f %%g in (genera.txt) do (
  datasets summary genome taxon %%g --assembly-level complete --as-json-lines | dataformat tsv genome --fields organism-name,organism-tax-id,accession,assminfo-level >> methanotroph_genomes.tsv
)
echo Done