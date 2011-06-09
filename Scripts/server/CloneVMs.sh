#!/bin/bash
echo script started

# Determines how many copies of the VM image you want to make
for ((i = 0; i <= 20; i++))
do

	echo $i iteration

	#Figure out what name to give the new node
	nodeName=
	FLAG=10
	if [ $i -lt $FLAG ] ; then
		nodeName="FreeNet Node 0$i"
		echo less than 10
	else
		nodeName="FreeNet Node $i"
		echo greater than 10
	fi
	echo $nodeName

	if [ $i != 2 ]; then
		mkdir "$nodeName"

		##########!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		# The first hard coded parameter to cp is the source VM image folder
		# this is the image that will be used as a template for all of the other images
		# example "FreeNet Node 02" must be changed every place that is show up in this script
		cp "FreeNet Node 02"/* "$nodeName"/
		cd "$nodeName"

		echo entering directory $nodeName

		sed -e "s/FreeNet Node 02/$nodeName/g" "FreeNet Node 02.vmdk" > "$nodeName.vmdk"
		sed -e "s/FreeNet Node 02/$nodeName/g" "FreeNet Node 02.vmx" > "$nodeName.vmx"
		sed -e "s/FreeNet Node 02/$nodeName/g" "FreeNet Node 02.vmxf" > "$nodeName.vmxf"

		echo sed complete

		#Don't run sed on this files, just rename (otherwise it copies the file and takes forever)
		mv 'FreeNet Node 02-flat.vmdk' "$nodeName-flat.vmdk"
		mv 'FreeNet Node 02.vmsd' "$nodeName.vmsd"
		mv 'FreeNet Node 02.nvram' "$nodeName.nvram"

		#remove old files sed copied
		rm "FreeNet Node 02"*

		echo move complete

       		vmware-cmd -s register "$nodeName.vmx"
		echo registered node        

		cd ..
	fi
done

echo script completed
