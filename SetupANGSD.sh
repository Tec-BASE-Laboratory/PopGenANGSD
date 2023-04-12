#
#### Setup y preparación de los datos #### 

### Bienvenida y Creación de un directorio para todo el análisis ### 

echo "Nuevo análisis con ANGSD"
read -p "Escribe el nombre del Nuevo Análisis sin espacios ni caracteres especiales " analysis_name
read -p "Escribe el path de la carpeta donde se encuentra tu genoma de referencia " path_GenRef 
cd $path_GenRef
read -p "Ahora escribe el nombre de la carpeta donde se encuentra tu genoma de referencia " GenRefDir


mkdir $analysis_name 

for filename in $GenRefDir/*.fasta
 do echo $filename
done 

read -p "Escribe el nombre del archivo del genoma de referencia como se encuentra en la lista anterior" GenomRef

### Se indexa el genoma de referencia ###

bwa index GenomRef

### Burrows Willer Alignment ###
 read -p "Escribe el path del directorio donde se encuentran los fasta q de los genomas a analizar" pathfastq




bwa mem GenomRef Genom1.1.fasta Genom1.2.fasta -o Genom.1.sam

### Transformar .sam a .bam ###

samtools view Genom.1.sam -o Genom.1.bam 

### Sortear los documentos .bam ###

samtools sort Genom.1.bam -o Genom.1_sorted.bam

### Indexar los documentos .bam y crear listas de .bam ###

## Crear un directorio para los bams ##

mkdir bams_sorted

for i in bams_sorted/*.bam; do samtools index $; done 

ls bams/*.bam > bam.filelist 

nano bam_sorted.filelist 

/your/path/Genom.1_sorted.bam
