#!/bin/bash

#### Setup y preparación de los datos #### 

### Exportar bwa y angsd para usarlo dentro del ambiente### 

### Bienvenida y Creación de un directorio para todo el análisis ### 

echo "Setup para nuevo análisis con ANGSD"

# Validación de datos para comenzar el análisis 
while true; do
    read -p "Escriba el nombre que desea asignar al nuevo análisis. Escribalo solamente usando números, letras o guiones bajos (_): " analysis_name
    if [[ $analysis_name =~ ^[a-zA-Z0-9_]+$ ]]; then
        break
    else
        echo "Nombre inválido. Por favor, utilice solo números, letras o guiones bajos (_)."
    fi
done

read -p "Escribe el path del directorio donde se encuentra tu genoma de referencia: " path_GenRef

while true; do
    if [[ -d "$path_GenRef" ]]; then
        break
    else
        echo "Ruta de directorio inválida. Por favor, introduce una ruta válida hacia un directorio."
        read -p "Escribe el path del directorio donde se encuentra tu genoma de referencia: " path_GenRef
    fi
done

cd "$path_GenRef"
mkdir "$analysis_name"

for filename in "$path_GenRef"/*.fasta; do
    echo "$filename"
done

read -p "Escribe el nombre del archivo del genoma de referencia como se encuentra en la lista anterior: " GenomRef

cp "$GenomRef" "$analysis_name/"
cd "$analysis_name"
bwa index "$path_GenRef/$analysis_name/$GenomRef"

### Burrows Willer Alignment ###
read -p "Escribe el path del directorio donde se encuentran los archivos .fastq de los genomas a analizar: " pathfastq

cp -r "$pathfastq/" "$analysis_name/"

cd "$path_GenRef/$analysis_name"

printf '%s\n' *.fastq.gz | sed 's/^\([^_]*_[^_]*\).*/\1/' | uniq |
while read prefix; do
    bwa mem "$path_GenRef/$analysis_name/$GenomRef" "${prefix}_R1.fastq.gz" "${prefix}_R2.fastq.gz" -o "${prefix}".1.sam
done

### Transformar .sam a .bam ###
while read prefix; do
    samtools view "${prefix}".1.sam -o "${prefix}".1.bam
done

### Sortear los documentos .bam ###
while read prefix; do
    samtools sort "${prefix}".1.bam -o "${prefix}".1.sorted.bam
done

### Indexar los documentos .bam y crear listas de .bam ###
## Crear un directorio para los bams ##

mkdir bams_sorted

for i in bams_sorted/*.bam; do
    samtools index "$i"
done 

ls bams/*.sorted.bam > bam.filelist 

# Open bam_sorted.filelist with a text editor if needed
nano bam_sorted.filelist 

