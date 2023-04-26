#!/bin/bash

#### Setup y preparación de los datos #### 

### Exportar bwa y angsd para usarlo dentro del ambiente### 

### Bienvenida y Creación de un directorio para todo el análisis ### 

echo "Nuevo análisis con ANGSD"
read -p "Escribe el nombre del Nuevo Análisis sin espacios ni caracteres especiales " analysis_name
read -p "Escribe el path del directorio donde se encuentra la carpeta de tu genoma de referencia " path_GenRef 
cd $path_GenRef
mkdir $analysis_name 
read -p "Ahora escribe el nombre de la carpeta donde se encuentra tu genoma de referencia " GenRefDir

for filename in $GenRefDir/*.fasta
do 
    echo $filename
done 

read -p "Escribe el nombre del archivo del genoma de referencia como se encuentra en la lista anterior" GenomRef

mv "$GenomRef" "$analysis_name/"
cd "$analysis_name"
bwa index "$path_GenRef/$analysis_name/$GenomRef"


### Burrows Willer Alignment ###
read -p "Escribe el path del directorio donde se encuentran los archivos .fastq de los genomas a analizar" pathfastq
read -p "Escribe el nombre del directorio donde se encuentran los archivos .fastq de los genomas a analizar" dirfastq

mv "$pathfastq/$dirfastq" "$analysis_name/"

cd "$path_GenRef"
cd "$analysis_name"

printf '%s\n' *.fastq.gz | sed 's/^\([^_]*_[^_]*\).*/\1/' | uniq |
while read prefix; do
    bwa mem "$path_GenRef/$analysis_name/$GenomRef" "${prefix}_R1.fastq.gz" "${prefix}_R2.fastq.gz" -o "${prefix}".1.sam
done

### Transformar .sam a .bam ###

printf '%s\n' *.1.sam | sed 's/^\([^_]*_[^_]*\).*/\1/' | uniq |
while read prefix; do
    samtools view "${prefix}".1.sam -o "${prefix}".1.bam
done

### Sortear los documentos .bam ###

printf '%s\n' *.1.bam | sed 's/^\([^_]*_[^_]*\).*/\1/' | uniq |
while read prefix; do
    samtools sort "${prefix}".1.bam -o "${prefix}".1.sorted.bam
done

### Indexar los documentos .bam y crear listas de .bam ###
## Crear un directorio para los bams ##

mkdir bams_sorted

for i in bams_sorted/*.bam; do samtools index $; done 

ls bams/*.sorted.bam > bam.filelist 

nano bam_sorted.filelist 

/your/path/Genom.1_sorted.bam
