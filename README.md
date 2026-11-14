# Methanotroph Genome Data Collection

Methods, code and troubleshooting notes for building a table of methanotroph genomes.

Data collected on 14 November 2026 from the NCBI database. NCBI data changes over time, so repeating the work later may give different numbers.

## Aim

Build one table of methanotrophs (bacteria that use methane as food), giving each organism's name, its classification, whether it has the enzyme methane monooxygenase (MMO), and the ID of its whole genome.

The result is an Excel file, `methanotroph_genomes_final.xlsx`, with 124 complete genomes from 18 genera. Another 8 genera have no complete genome in NCBI and are listed as such.

No programming knowledge is needed to repeat this work. Every command below can be copied and pasted into the Windows command window.

## Files in this repository

| File | What it is |
| --- | --- |
| `genera.txt` | The 26 genus names, one per line (input). |
| `run.bat` | Script that searches NCBI for complete genomes of every genus in `genera.txt`. |
| `methanotroph_genomes.tsv` | Raw genome list from NCBI (260 lines before cleaning). |
| `accessions.txt` | The 124 genome IDs that were checked for MMO (input). |
| `check_mmo.bat` | Script that downloads each genome's protein list and counts MMO gene names. |
| `mmo_results.csv` | One line per genome with the number of pMMO and sMMO gene hits. |
| `hits.zip` | One text file per genome listing the monooxygenase genes found (the evidence). |
| `methanotroph_genomes_final.xlsx` | The finished table, with Summary and Method sheets. |
| `methods_document.docx` | The same methods as a Word document. |

## Overview: the work in six steps

1. **Make the list of genera.** A text file, `genera.txt`, holds the 26 methanotroph genus names.
2. **Download the genome list from NCBI.** The NCBI program `datasets.exe` looked up every complete genome for each genus and saved the result as `methanotroph_genomes.tsv`.
3. **Clean the list.** Repeated header rows were removed, and each genome that appeared twice (as a RefSeq `GCF_` ID and a GenBank `GCA_` ID) was kept once. The list went from 260 lines to 124 genomes.
4. **Add the classification.** Phylum, class, order, family and genus were added for every organism.
5. **Check for MMO.** `check_mmo.bat` downloaded the protein list of each genome and searched it for pMMO and sMMO gene names, saving the counts in `mmo_results.csv`.
6. **Build the final Excel file.** The classification, genome IDs and MMO results were combined into `methanotroph_genomes_final.xlsx`.

## Tools used

Everything ran in one folder, for example `C:\Users\raman\Downloads\New folder`.

| Name | Type | What it does |
| --- | --- | --- |
| Windows Command Prompt (cmd) | Program (built into Windows) | The black window where commands are typed. |
| `datasets.exe` | Program (from NCBI) | Looks up genomes in the NCBI database and downloads them. |
| `dataformat.exe` | Program (from NCBI) | Turns the NCBI answer into a plain table (tab-separated text). |
| `tar` | Program (built into Windows) | Opens the downloaded `.zip` packages. |

`datasets.exe` and `dataformat.exe` are not included in this repository. Download them from the NCBI Datasets command-line page and put them in the same folder as the scripts.

A script is a text file of commands. A `.bat` file is a script that Windows runs line by line when its name is typed.

## Step-by-step procedure

### Step 1. Prepare the folder and open the command window

Create one folder and put `datasets.exe` and `dataformat.exe` in it. Open the folder, click the address bar at the top, type `cmd` and press Enter. A black window opens that is already inside the folder. Check the program works with:

```
datasets --version
```

It printed `datasets version: 18.41.1`, so no installation was needed.

### Step 2. Create `genera.txt`

Type `notepad genera.txt`, click Yes to create the file, paste the 26 genus names below and press Ctrl+S.

```
Methylococcus
Methylomonas
Methylobacter
Methylomicrobium
Methylosarcina
Methylosoma
Methylocaldum
Methylogaea
Methyloparacoccus
Methylovulum
Methylomagnum
Methylotuvimicrobium
Methylothermus
Methylohalobius
Methylomarinovum
Crenothrix
Clonothrix
Methylocystis
Methylosinus
Methylocella
Methylocapsa
Methyloferula
Methylorosula
Methylacidiphilum
Methylacidimicrobium
Methylomirabilis
```

### Step 3. Test on one genus

```
datasets summary genome taxon "Methylococcus" --assembly-level complete --as-json-lines | dataformat tsv genome --fields organism-name,organism-tax-id,accession,assminfo-level
```

This printed a table of 25 lines, each with an organism name, taxonomic ID and genome ID (`GCF_` or `GCA_`). `--assembly-level complete` means only fully assembled genomes are listed.

### Step 4. Run all genera with `run.bat`

Type `notepad run.bat`, click Yes, paste the text below and save with Ctrl+S.

```
@echo off
if exist methanotroph_genomes.tsv del methanotroph_genomes.tsv
for /f %%g in (genera.txt) do (
  datasets summary genome taxon %%g --assembly-level complete --as-json-lines | dataformat tsv genome --fields organism-name,organism-tax-id,accession,assminfo-level >> methanotroph_genomes.tsv
)
echo Done
```

Then type `run.bat` and wait for `Done`. The loop runs the Step 3 command once per genus and adds every answer to `methanotroph_genomes.tsv`.

### Step 5. Add the two genera that failed by name

*Methylacidiphilum* and *Methylomirabilis* were searched by their NCBI taxonomy number instead (see the errors section):

```
datasets summary genome taxon 511745 --assembly-level complete --as-json-lines | dataformat tsv genome --fields organism-name,organism-tax-id,accession,assminfo-level >> methanotroph_genomes.tsv
datasets summary genome taxon 1170227 --assembly-level complete --as-json-lines | dataformat tsv genome --fields organism-name,organism-tax-id,accession,assminfo-level >> methanotroph_genomes.tsv
```

### Step 6. Clean the list and add the classification

The `.tsv` file was cleaned and the classification columns were added with a short Python program. This step does not need to be repeated by hand: the same result can be reached by opening the `.tsv` in Excel, deleting the repeated header rows, deleting `GCA_` lines whose `GCF_` twin is present, and typing the classification columns from NCBI Taxonomy.

### Step 7. Test the MMO search on one genome

The test genome was *Methylococcus capsulatus* Bath (`GCF_000008325.1`):

```
datasets download genome accession GCF_000008325.1 --include protein --filename g.zip
tar -xf g.zip
findstr /i "monooxygenase" ncbi_dataset\data\GCF_000008325.1\protein.faa
```

The first line downloads the genome's protein list, the second unzips it and the third prints every protein whose name contains "monooxygenase". The result showed both pMMO and sMMO genes, as expected from the literature. The test also showed that pMMO is named "ammonia monooxygenase subunit AmoA/B/C" in NCBI, so the search words were adjusted.

### Step 8. Run `check_mmo.bat` for all 124 genomes

With `accessions.txt` and `check_mmo.bat` in the folder, type:

```
check_mmo.bat
```

For each genome ID in `accessions.txt`, the script downloads the protein list, saves the monooxygenase lines in a `hits` folder, counts pMMO and sMMO gene names and writes one line to `mmo_results.csv`. It then deletes the download so the disk does not fill up. The run finished within about 15 minutes.

### Step 9. Build the final Excel file

`mmo_results.csv` was merged with the genome table, then colour-coded pMMO and sMMO columns, a Summary sheet and a Method sheet were added.

### How to save files correctly on Windows

Notepad often adds `.txt` to the end of a name, giving `genera.txt.txt` or `run.bat.txt`. Two ways to avoid this:

- Create the file from cmd with `notepad filename` (for example `notepad run.bat`), which keeps the exact name.
- In File Explorer, choose View > Show > File name extensions, so the real ending is visible, then rename if needed with `ren genera.txt.txt genera.txt`.

## Errors faced and how each was fixed

Seven problems came up. None of them affected the final data.

| # | What appeared on screen | Cause | Fix |
| --- | --- | --- | --- |
| 1 | `'conda' is not recognized as an internal or external command` | Conda (a software manager) is not installed on this computer. | Ignored. It was not needed, because `datasets.exe` was downloaded directly. |
| 2 | `'run.bat' is not recognized as an internal or external command` | The script file was saved as `run.bat.txt` (or in another folder), so Windows could not find `run.bat`. | Created the file again with `notepad run.bat` from inside the folder. |
| 3 | `The system cannot find the file genera.txt` | The list was saved as `genera.txt.txt`. | Renamed it with `ren genera.txt.txt genera.txt`. |
| 4 | `The taxonomy name 'Clonothrix' ... is valid, but no genome data is currently available` | NCBI has no genome for this genus. The same message appeared for *Methylorosula*. | Not an error in the work. Both genera are listed in the table as having no genome. |
| 5 | `The taxonomy name 'Methylacidiphilum' is not exact` | NCBI has several entries with this name and wants a number to choose one. | Searched by taxonomy ID 511745 instead of the name. |
| 6 | `The taxonomy name 'Methylomirabilis' is not exact` | Same reason as above. | Searched by taxonomy ID 1170227 instead of the name. |
| 7 | `NO_PROTEIN_FILE` for three genomes in `mmo_results.csv` | Three GenBank-only genomes (`GCA_988217825.1`, `GCA_988217405.1`, `GCA_988142285.1`) have no protein annotation to search. | Marked "Not checked" in the Excel file. They need a separate BLAST check. |

One more point was found during testing rather than as an error: the first search words for MMO would have missed pMMO, because NCBI names its genes "ammonia monooxygenase subunit AmoA/B/C". The search words in `check_mmo.bat` were changed to include these names before the full run.

## Results

Of the 124 complete genomes, 67 have pMMO only, 51 have both pMMO and sMMO, 3 have sMMO only, and 3 could not be checked. No checked genome lacked both enzymes.

| Genus | Genomes | pMMO only | pMMO and sMMO | sMMO only | Not checked |
| --- | --- | --- | --- | --- | --- |
| *Methylococcus* | 13 | 1 | 12 | 0 | 0 |
| *Methylomonas* | 29 | 13 | 16 | 0 | 0 |
| *Methylobacter* | 5 | 3 | 1 | 0 | 1 |
| *Methylomicrobium* | 2 | 2 | 0 | 0 | 0 |
| *Methylocaldum* | 7 | 6 | 1 | 0 | 0 |
| *Methylogaea* | 1 | 1 | 0 | 0 | 0 |
| *Methyloparacoccus* | 1 | 1 | 0 | 0 | 0 |
| *Methylovulum* | 1 | 1 | 0 | 0 | 0 |
| *Methylomagnum* | 1 | 0 | 1 | 0 | 0 |
| *Methylotuvimicrobium* | 8 | 7 | 1 | 0 | 0 |
| *Methylomarinovum* | 2 | 2 | 0 | 0 | 0 |
| *Methylocystis* | 23 | 16 | 6 | 0 | 1 |
| *Methylosinus* | 15 | 2 | 13 | 0 | 0 |
| *Methylocella* | 4 | 0 | 0 | 3 | 1 |
| *Methylocapsa* | 2 | 2 | 0 | 0 | 0 |
| *Methylacidiphilum* | 6 | 6 | 0 | 0 | 0 |
| *Methylacidimicrobium* | 2 | 2 | 0 | 0 | 0 |
| *Methylomirabilis* | 2 | 2 | 0 | 0 | 0 |
| **Total** | **124** | **67** | **51** | **3** | **3** |

Two results match what is known in the literature: *Methylocella* has sMMO only, and the acid-loving *Methylacidiphilum* and *Methylacidimicrobium* and the nitrite-using *Methylomirabilis* have pMMO only.

The eight genera with no complete genome in NCBI are *Methylosarcina*, *Methylosoma*, *Methylothermus*, *Methylohalobius*, *Crenothrix*, *Clonothrix*, *Methyloferula* and *Methylorosula*. They are listed in the Excel file with no genome ID.

## Limitations

The MMO result is only as good as the gene names in the NCBI annotation, so a few points need a decision or a follow-up check.

- **Annotation names.** An MMO gene that NCBI left unnamed or named differently would be missed. A BLAST search of known PmoA and MmoX sequences against the genomes would confirm any surprising result.
- **sMMO calls.** "Yes" for sMMO means 2 or more matching gene names, and "Partial" means 1. The hit counts are in the notes column of the Excel file. A full sMMO set has six genes (*mmoX, Y, B, Z, D, C*), so some "Yes" results may be incomplete clusters.
- **Three genomes not checked.** They are GenBank-only assemblies without protein annotation.
- **Eight genera without a complete genome.** If draft genomes are also wanted, the search can be repeated without `--assembly-level complete`.
- **Strains and "sp." entries.** Many rows are strains or unnamed species ("sp.") rather than named species.
- **Phylum name.** The table uses the current NCBI name Pseudomonadota, which replaced Proteobacteria. They are the same group.
- **Anaerobic methane oxidisers (ANME archaea)** were not included, because they do not use MMO.
- **Date of the data.** The NCBI database changes over time. All data was collected on 14 November 2026.

## Glossary

| Term | Meaning |
| --- | --- |
| Methanotroph | A bacterium that uses methane as its source of carbon and energy. |
| MMO | Methane monooxygenase, the enzyme that starts the breakdown of methane. |
| pMMO | Particulate (membrane-bound) MMO. Its genes are *pmoA, pmoB, pmoC*. NCBI often names them "ammonia monooxygenase subunit AmoA/B/C". |
| sMMO | Soluble MMO. Its genes are *mmoX, mmoY, mmoB, mmoZ, mmoD, mmoC*. Only some methanotrophs have it. |
| NCBI | National Center for Biotechnology Information, the US public database that stores genome data. |
| Genome ID / assembly accession | The code that identifies one genome in NCBI, such as `GCF_000008325.1`. |
| `GCF_` and `GCA_` | `GCF_` is the RefSeq (curated) copy of a genome and `GCA_` is the GenBank (original submission) copy. They are the same genome. |
| Complete genome | A genome assembled into whole chromosomes with no gaps, as opposed to a draft genome in pieces. |
| Taxonomy ID | The number NCBI gives to each organism or group, such as 511745 for *Methylacidiphilum*. |
| Protein file (`protein.faa`) | The list of all proteins that a genome is predicted to make, with their names. |
| `.tsv` and `.csv` | Plain-text tables where columns are separated by tabs (tsv) or commas (csv). Excel can open both. |
| BLAST | A tool that compares a known gene or protein sequence against a genome to find similar ones. |
| Pseudomonadota | The current name of the phylum formerly called Proteobacteria. |
