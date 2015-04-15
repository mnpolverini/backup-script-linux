#!/bin/bash


if [ -z "$1" -o -z "$2" -o -z "$3" ]
then
	echo
	echo "Attenzione! Argomenti non sufficienti indicare, in ordine, tipo di backup, directory sorgente, directory di destinazione"
	exit 8
fi

elencoFile=`ls $2`

if [ $? -gt 0 ]
then
	echo
	echo "Attenzione! Directory sorgente non disponibile!"
	exit 1
fi

if [ `ls $2 | wc -l` -eq 0 ]
then
	echo
	echo "Attenzione! La directory sorgente è vuota!"
	exit 2
fi

elencoDirectory=`ls $3`
if [ $? -gt 0 ]
then
	echo "Attenzione! Directory di destinazione non disponibile!"
	exit 3
fi

if [ $1 == 'completo' ]
then

	ultima_data=0
else
	
	if [ $1 == 'incrementale' ]
	then
		elencoDirectory=`ls $3`
		ultima_data=0
		for i in $elencoDirectory
		do
			dataIndice=`stat -c %Y $3/$i`
			if [ $dataIndice -gt $ultima_data ]
			then
				ultima_data=$dataIndice
			fi
		done
			if [ $ultima_data -eq 0 ]
				then
					echo
					echo "Errore! Nella directory di destinazione non è stato trovato alcun backup! Eseguire un backup, quindi riprovare!"
					exit 6
				fi
		else
			
			if [ $1 == 'differenziale' ]
			then
				ultima_data=0
				for i in $elencoDirectory
				do 
					if [ ${i:13:8} == 'completo' ]
					then
						dataIndice=`stat -c %Y $3/$i`
						if [ $dataIndice -gt $ultima_data ]
						then
							ultima_data=$dataIndice
						fi
					fi
				done
				if [ $ultima_data -eq 0 ]
				then
					echo
					echo "Errore! Nella directory di destinazione non è stato trovato alcun backup completo! Eseguire un backup completo, quindi riprovare!"
					exit 5
				fi
			else
				echo
				echo "Errore! Tipo di backup non riconosciuto!"
				exit 7
			fi
		fi
fi

nomiFileDaCopiare=`ls $2`
nomeCartellaBackup=`date +%Y%m%d%H%M`

total=0
success=0
err=0
mkdir $3/${nomeCartellaBackup}_$1

for i in $nomiFileDaCopiare
do
	data_file=`stat -c %Y $2/$i`
	if [ $data_file -gt $ultima_data ]
	then
		total=$((total+1))
		cp $2/$i $3/${nomeCartellaBackup}_$1
		if [ $? -gt 0 ]
		then
			echo 
			echo "Impossibile eseguire il backup di $i" >&2
			err=$((err+1))
		else
			echo
			echo "Backup di: $i avvenuto con successo"
			success=$((success+1))
		fi
	fi
done

if [ $total -eq 0 ]
then
	echo
	echo "Attenzione! Nessun file cambiato dall'ultimo backup, backup non necessario"
	rmdir $3/${nomeCartellaBackup}_$1
	exit 9

else
	echo
	echo "Backup Completato, numero di file copiati: $success su $total, numero di file per cui non è stato possibile eseguire il backup: $err"
	
	if [ $err -eq 0 ]
	then
		exit 0
	else
		
		exit 4
	fi
fi