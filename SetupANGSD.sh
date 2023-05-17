#!/bin/bash

#### Setup y preparación de los datos #### 

### Exportar bwa y angsd para usarlo dentro del ambiente### 

### Bienvenida y Creación de un directorio para todo el análisis ### 

echo "Setup para nuevo análisis con ANGSD"

# Validación de datos para comenzar el análisis 
while true; do
    read -p "Escriba el nombre que desea asignar al nuevo análisis. Escribalo solamente usando números, letras o guiones bajos (_): " analysis_name
    if echo "$analysis_name" | grep -qE '^[[:alnum:]_]+$'; then
        break
    else
        echo "Nombre inválido. Por favor, utilice solo números, letras o guiones bajos (_)."
    fi
done

while true; do
    read -p "Escribe el path del directorio donde se encuentra tu genoma de referencia: " path_GenRef
    if [ -d "$path_GenRef" ]; then
        break
    else
        echo "Ruta de directorio inválida. Por favor, introduce una ruta válida hacia un directorio."
    fi
done

cd "$path_GenRef"
mkdir "$analysis_name"

for filename in "$path_GenRef"/*.fasta; do
    echo "$filename"
done

for filename in "$path_GenRef"/*.fna; do
    echo "$filename"
done

read -p "Escribe el nombre del archivo del genoma de referencia como se encuentra en la lista anterior: " GenomRef

cp "$GenomRef" "$analysis_name/"
cd "$analysis_name"

# Check if the reference genome is already indexed
if [[ ! -f "$path_GenRef/$analysis_name/$GenomRef.bwt" ]]; then
    bwa index "$path_GenRef/$analysis_name/$GenomRef"
else
    echo "El genoma de referencia ya ha sido indexado."
fi


### Burrows Willer Alignment ###
while true; do
    read -p "Escribe el path del directorio donde se encuentran los archivos .fastq de los genomas a analizar:  " pathfastq
    if [ -d "$path_GenRef" ]; then
        break
    else
        echo "Ruta de directorio inválida. Por favor, introduce una ruta válida hacia un directorio."
    fi
done

cp -r "$pathfastq/" "$analysis_name/"

cd "$path_GenRef/$analysis_name"

printf '%s\n' *.fastq.gz | sed 's/^\([^_]*_[^_]*\).*/\1/' | uniq | ## Cambiar el .fastq.gz dependiendo de la extensión que tenga el documento
while read prefix; do
    bwa mem "$path_GenRef/$analysis_name/$GenomRef" "${prefix}_R1.fastq.gz" "${prefix}_R2.fastq.gz" -o "${prefix}".1.sam
done

# Convert .sam files to .bam
for samfile in "$path_GenRef/$analysis_name"/*.sam; do
    bamfile="${samfile%.sam}.bam"
    samtools view -b "$samfile" > "$bamfile"
done

# Sort the .bam files
for bamfile in "$path_GenRef/$analysis_name"/*.bam; do
    sorted_bam="${bamfile%.bam}.sorted.bam"
    samtools sort "$bamfile" -o "$sorted_bam"
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


# Filter and process .fq.gz files
for fq1 in *_1.fq.gz; do
    prefix="${fq1%%_1.fq.gz}"  # Extract the prefix
    
    # Skip processing if either .1. or .2. file is missing
    if [[ ! -f "$fq1" || ! -f "${prefix}_2.fq.gz" ]]; then
        echo "Missing .fq.gz files for prefix: $prefix"
        continue
    fi
    
    # Process .fq.gz files
    bwa mem "$path_GenRef/$analysis_name/$GenomRef" "$fq1" "${prefix}_2.fq.gz" -o "${prefix}.sam"

    # Convert .sam file to .bam
    samfile="${prefix}.sam"
    bamfile="${samfile%.sam}.bam"
    samtools view -b "$samfile" > "$bamfile"

    # Sort the .bam file
    sorted_bam="${bamfile%.bam}.sorted.bam"
    samtools sort "$bamfile" -o "$sorted_bam"
done

