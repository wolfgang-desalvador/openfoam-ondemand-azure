#!/bin/bash

#   From https://github.com/Azure/woc-benchmarking/blob/main/apps/hpc/utils/azure_process_pinning.sh

#   MIT License

#   Copyright (c) Microsoft Corporation.

#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:

#   The above copyright notice and this permission notice shall be included in all
#   copies or substantial portions of the Software.

#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#   SOFTWARE


PPN=${1:-96}
NTHREADS=${2:-1}

VM_SKU=$(curl --connect-timeout 10 -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2018-04-02" | jq '.compute.vmSize')
VM_SKU="${VM_SKU%\"}"
VM_SKU="${VM_SKU#\"}"
echo "VM SKU: $VM_SKU"

hostname=`hostname`
echo "hostname: $hostname"
echo "VM SKU: $VM_SKU"

TOTAL_CORES_PER_NODE=$(( PPN * NTHREADS ))

if [[ $VM_SKU == "Standard_HB176rs_v4" ]]; then
    if [[ "$NTHREADS" -eq "1" ]]; then
        if [ "$PPN" == "24" ]; then
            export AZURE_PROCESSOR_LIST="0,6,12,20,28,36,44,50,56,64,72,80,88,94,100,108,116,124,132,138,144,152,160,168"
        elif [ "$PPN" == "48" ]; then
            export AZURE_PROCESSOR_LIST="0,1,6,7,12,13,20,21,28,29,36,37,44,45,50,51,56,57,64,65,72,73,80,81,88,89,94,95,100,101,108,109,116,117,124,125,132,133,138,139,144,145,152,153,160,161,168,169"
        elif [ "$PPN" == "96" ]; then
            export AZURE_PROCESSOR_LIST="0,1,2,3,6,7,8,9,12,13,14,15,20,21,22,23,28,29,30,31,36,37,38,39,44,45,46,47,50,51,52,53,56,57,58,59,64,65,66,67,72,73,74,75,80,81,82,83,88,89,90,91,94,95,96,97,100,101,102,103,108,109,110,111,116,117,118,119,124,125,126,127,132,133,134,135,138,139,140,141,144,145,146,147,152,153,154,155,160,161,162,163,168,169,170,171"
	elif [ "$PPN" == "120" ]; then
            export AZURE_PROCESSOR_LIST="0,1,2,3,4,6,7,8,9,10,12,13,14,15,16,20,21,22,23,24,28,29,30,31,32,36,37,38,39,40,44,45,46,47,48,50,51,52,53,54,56,57,58,59,60,64,65,66,67,68,72,73,74,75,76,80,81,82,83,84,88,89,90,91,92,94,95,96,97,98,100,101,102,103,104,108,109,110,111,112,116,117,118,119,120,124,125,126,127,128,132,133,134,135,136,138,139,140,141,142,144,145,146,147,148,152,153,154,155,156,160,161,162,163,164,168,169,170,171,172"
        elif [ "$PPN" == "144" ]; then
            export AZURE_PROCESSOR_LIST="0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,20,21,22,23,24,25,28,29,30,31,32,33,36,37,38,39,40,41,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,64,65,66,67,68,69,72,73,74,75,76,77,80,81,82,83,84,85,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,108,109,110,111,112,113,116,117,118,119,120,121,124,125,126,127,128,129,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,152,153,154,155,156,157,160,161,162,163,164,165,168,169,170,171,172,173"
        elif [ "$PPN" == "176" ]; then
            export AZURE_PROCESSOR_LIST="0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175"
        else
            echo "No defined setting for Core count: $PPN"
            exit -1
        fi
    elif [[ "$NTHREADS" -gt "1" && "$NTHREADS" -lt "7" && "$TOTAL_CORES_PER_NODE" -lt "145" ]]; then
        if [[ "$NTHREADS" -eq "2" ]]; then
            if [ "$PPN" == "24" ]; then
                AZURE_IMPI_EXCLUDE_CORES="2,3,4,5,6,7,10,11,12,13,14,15,18,19,20,21,22,23,26,27,28,29,30,31,34,35,36,37,40,41,42,43,46,47,48,49,50,51,54,55,56,57,58,59,62,63,64,65,66,67,70,71,72,73,74,75,78,79,80,81,84,85,86,87,90,91,92,93,94,95,98,99,100,101,102,103,106,107,108,109,110,111,114,115,116,117,118,119,122,123,124,125,128,129,130,131,134,135,136,137,138,139,142,143,144,145,146,147,150,151,152,153,154,155,158,159,160,161,162,163,166,167,168,169,172,173,174,175"
                AZURE_IMPI_HYBRID_OPTIONS="-genv I_MPI_PIN_DOMAIN $NTHREADS:compact -genv I_MPI_PIN=on -genv I_MPI_PIN_PROCESSOR_EXCLUDE_LIST=$AZURE_IMPI_EXCLUDE_CORES"
                AZURE_HPCX_HYBRID_OPTIONS=""
            elif [ "$PPN" == "48" ]; then
                AZURE_IMPI_EXCLUDE_CORES="4,5,6,7,12,13,14,15,20,21,22,23,28,29,30,31,36,37,42,43,48,49,50,51,56,57,58,59,64,65,66,67,72,73,74,75,80,81,86,87,92,93,94,95,100,101,102,103,108,109,110,111,116,117,118,119,124,125,130,131,136,137,138,139,144,145,146,147,152,153,154,155,160,161,162,163,168,169,174,175"
                AZURE_IMPI_HYBRID_OPTIONS="-genv I_MPI_PIN_DOMAIN $NTHREADS:compact -genv I_MPI_PIN=on -genv I_MPI_PIN_PROCESSOR_EXCLUDE_LIST=$AZURE_IMPI_EXCLUDE_CORES"
                AZURE_HPCX_HYBRID_OPTIONS=""
            elif [ "$PPN" == "72" ]; then
                AZURE_IMPI_EXCLUDE_CORES="6,7,14,15,22,23,28,29,50,51,58,59,66,67,74,75,94,95,102,103,110,111,118,119,138,139,146,147,154,155,162,163"
                AZURE_IMPI_HYBRID_OPTIONS="-genv I_MPI_PIN_DOMAIN $NTHREADS:compact -genv I_MPI_PIN=on -genv I_MPI_PIN_PROCESSOR_EXCLUDE_LIST=$AZURE_IMPI_EXCLUDE_CORES"
                AZURE_HPCX_HYBRID_OPTIONS=""
            else
                echo "PPN: $PPN, Threads: $NTHREADS, Is not supported on $VM_SKU"
	    fi
        elif [[ "$NTHREADS" -eq "3" ]]; then
            if [ "$PPN" == "24" ]; then
                AZURE_IMPI_EXCLUDE_CORES="3,4,5,6,7,11,12,13,14,15,19,20,21,22,23,27,28,29,30,31,35,36,37,41,42,43,47,48,49,50,51,55,56,57,58,59,63,64,65,66,67,71,72,73,74,75,79,80,81,85,86,87,91,92,93,94,95,99,100,101,102,103,107,108,109,110,111,115,116,117,118,119,123,124,125,129,130,131,135,136,137,138,139,143,144,145,146,147,151,152,153,154,155,159,160,161,162,163,167,168,169,173,174,175"
                AZURE_IMPI_HYBRID_OPTIONS="-genv I_MPI_PIN_DOMAIN $NTHREADS:compact -genv I_MPI_PIN=on -genv I_MPI_PIN_PROCESSOR_EXCLUDE_LIST=$AZURE_IMPI_EXCLUDE_CORES"
                AZURE_HPCX_HYBRID_OPTIONS=""
            elif [ "$PPN" == "48" ]; then
                AZURE_IMPI_EXCLUDE_CORES="6,7,14,15,22,23,30,31,50,51,58,59,66,67,74,75,94,95,102,103,110,111,118,119,138,139,146,147,154,155,162,163"
                AZURE_IMPI_HYBRID_OPTIONS="-genv I_MPI_PIN_DOMAIN $NTHREADS:compact -genv I_MPI_PIN=on -genv I_MPI_PIN_PROCESSOR_EXCLUDE_LIST=$AZURE_IMPI_EXCLUDE_CORES"
                AZURE_HPCX_HYBRID_OPTIONS=""
            else
                echo "PPN: $PPN, Threads: $NTHREADS, Is not supported on $VM_SKU"
	    fi
        elif [[ "$NTHREADS" -eq "4" ]]; then
            if [ "$PPN" == "24" ]; then
                AZURE_IMPI_EXCLUDE_CORES="4,5,6,7,12,13,14,15,20,21,22,23,28,29,30,31,36,37,42,43,48,49,50,51,56,57,58,59,64,65,66,67,72,73,74,75,80,81,86,87,92,93,94,95,100,101,102,103,108,109,110,111,116,117,118,119,124,125,130,131,136,137,138,139,144,145,146,147,152,153,154,155,160,161,162,163,168,169,174,175"
                AZURE_IMPI_HYBRID_OPTIONS="-genv I_MPI_PIN_DOMAIN $NTHREADS:compact -genv I_MPI_PIN=on -genv I_MPI_PIN_PROCESSOR_EXCLUDE_LIST=$AZURE_IMPI_EXCLUDE_CORES"
                AZURE_HPCX_HYBRID_OPTIONS=""
            else
                echo "PPN: $PPN, Threads: $NTHREADS, Is not supported on $VM_SKU"
	    fi
        elif [[ "$NTHREADS" -eq "6" ]]; then
            if [ "$PPN" == "24" ]; then
                AZURE_IMPI_EXCLUDE_CORES="6,7,14,15,22,23,28,29,50,51,58,59,66,67,74,75,94,95,102,103,110,111,118,119,138,139,146,147,154,155,162,163"
                AZURE_IMPI_HYBRID_OPTIONS="-genv I_MPI_PIN_DOMAIN $NTHREADS:compact -genv I_MPI_PIN=on -genv I_MPI_PIN_PROCESSOR_EXCLUDE_LIST=$AZURE_IMPI_EXCLUDE_CORES"
                AZURE_HPCX_HYBRID_OPTIONS=""
            
            else
                echo "Threading is not setup for PPN: $PPN and $NTHREADS at this time for $VM_SKU"
	    fi
        fi
    else
        echo "Case not recognized for PPN: $PPN and $NTHREADS at this time for $VM_SKU"
    fi
elif [[ $VM_SKU == "Standard_HB120rs_v3" ]]; then
    echo "VM SKU: $VM_SKU"
    if [[ "$NTHREADS" -eq "1" ]]; then
        if [ "$PPN" == "16" ]; then
            export AZURE_PROCESSOR_LIST="0,8,16,24,30,38,46,54,60,68,76,84,90,98,106,114"
        elif [ "$PPN" == "32" ]; then
            export AZURE_PROCESSOR_LIST="0,1,8,9,16,17,24,25,30,31,38,39,46,47,54,55,60,61,68,69,76,77,84,85,90,91,98,99,106,107,114,115"
        elif [ "$PPN" == "64" ]; then
            export AZURE_PROCESSOR_LIST="0,1,2,3,8,9,10,11,16,17,18,19,24,25,26,27,30,31,32,33,38,39,40,41,46,47,48,49,54,55,56,57,60,61,62,63,68,69,70,71,76,77,78,79,84,85,86,87,90,91,92,93,98,99,100,101,106,107,108,109,114,115,116,117"
        elif [ "$PPN" == "96" ]; then
            export AZURE_PROCESSOR_LIST="0,1,2,3,4,5,8,9,10,11,12,13,16,17,18,19,20,21,24,25,26,27,28,29,30,31,32,33,34,35,38,39,40,41,42,43,46,47,48,49,50,51,54,55,56,57,58,59,60,61,62,63,64,65,68,69,70,71,72,75,76,77,78,79,80,81,84,85,86,87,88,89,90,91,92,93,94,95,98,99,100,101,102,103,106,107,108,109,110,111,114,115,116,117,118,119"
    	elif [ "$PPN" == "120" ]; then
            export AZURE_PROCESSOR_LIST="0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119"
        fi
    elif [[ "$NTHREADS" -gt "1" ]]; then
        if [[ "$NTHREADS" -eq "2" ]]; then
            if [ "$PPN" == "16" ]; then
                AZURE_IMPI_EXCLUDE_CORES="2,3,4,5,10,11,12,13,14,15,18,19,20,21,22,23,26,27,28,29,6,7,32,33,34,35,40,41,42,43,44,45,48,49,50,51,52,53,56,57,58,59,36,37,62,63,64,65,70,71,72,73,74,75,78,79,80,81,82,83,86,87,88,89,66,67,92,93,94,95,100,101,102,103,104,105,108,109,110,111,112,113,116,117,118,119,96,97"
                AZURE_IMPI_HYBRID_OPTIONS="-genv I_MPI_PIN_DOMAIN $NTHREADS:compact -genv I_MPI_PIN=on -genv I_MPI_PIN_PROCESSOR_EXCLUDE_LIST=$AZURE_IMPI_EXCLUDE_CORES"
                AZURE_HPCX_HYBRID_OPTIONS=""
            elif [ "$PPN" == "32" ]; then
                AZURE_IMPI_EXCLUDE_CORES="4,5,12,13,14,15,20,21,22,23,28,29,6,7,34,35,42,43,44,45,50,51,52,53,58,59,36,37,64,65,72,73,74,75,80,81,82,83,88,89,66,67,94,95,102,103,104,105,110,111,112,113,118,119,96,97"
                AZURE_IMPI_HYBRID_OPTIONS="-genv I_MPI_PIN_DOMAIN $NTHREADS:compact -genv I_MPI_PIN=on -genv I_MPI_PIN_PROCESSOR_EXCLUDE_LIST=$AZURE_IMPI_EXCLUDE_CORES"
                AZURE_HPCX_HYBRID_OPTIONS=""
            elif [ "$PPN" == "48" ]; then
                AZURE_IMPI_EXCLUDE_CORES="14,15,22,23,6,7,44,45,52,53,36,37,74,75,82,83,66,67,104,105,112,113,96,97"
                AZURE_IMPI_HYBRID_OPTIONS="-genv I_MPI_PIN_DOMAIN $NTHREADS:compact -genv I_MPI_PIN=on -genv I_MPI_PIN_PROCESSOR_EXCLUDE_LIST=$AZURE_IMPI_EXCLUDE_CORES"
                AZURE_HPCX_HYBRID_OPTIONS=""
            else
                echo "PPN: $PPN, Threads: $NTHREADS, Is not supported on $VM_SKU"
            fi
        elif [[ "$NTHREADS" -eq "3" ]]; then
            if [ "$PPN" == "32" ]; then
                AZURE_IMPI_EXCLUDE_CORES="14,15,22,23,6,7,44,45,52,53,36,37,74,75,82,83,66,67,104,105,112,113,96,97"
                AZURE_IMPI_HYBRID_OPTIONS="-genv I_MPI_PIN_DOMAIN $NTHREADS:compact -genv I_MPI_PIN=on -genv I_MPI_PIN_PROCESSOR_EXCLUDE_LIST=$AZURE_IMPI_EXCLUDE_CORES"
                AZURE_HPCX_HYBRID_OPTIONS=""
            else
                echo "PPN: $PPN, Threads: $NTHREADS, Is not supported on $VM_SKU"
            fi
        elif [[ "$NTHREADS" -eq "4" ]]; then
            if [ "$PPN" == "16" ]; then
                AZURE_IMPI_EXCLUDE_CORES="4,5,12,13,14,15,20,21,22,23,28,29,6,7,34,35,42,43,44,45,50,51,52,53,58,59,36,37,64,65,72,73,74,75,80,81,82,83,88,89,66,67,94,95,102,103,104,105,110,111,112,113,118,119,96,97"
                AZURE_IMPI_HYBRID_OPTIONS="-genv I_MPI_PIN_DOMAIN $NTHREADS:compact -genv I_MPI_PIN=on -genv I_MPI_PIN_PROCESSOR_EXCLUDE_LIST=$AZURE_IMPI_EXCLUDE_CORES"
                AZURE_HPCX_HYBRID_OPTIONS=""
            else
                echo "PPN: $PPN, Threads: $NTHREADS, Is not supported on $VM_SKU"
            fi
        elif [[ "$NTHREADS" -eq "6" ]]; then
            if [ "$PPN" == "16" ]; then
                AZURE_IMPI_EXCLUDE_CORES="14,15,22,23,6,7,44,45,52,53,36,37,74,75,82,83,66,67,104,105,112,113,96,97"
                AZURE_IMPI_HYBRID_OPTIONS="-genv I_MPI_PIN_DOMAIN $NTHREADS:compact -genv I_MPI_PIN=on -genv I_MPI_PIN_PROCESSOR_EXCLUDE_LIST=$AZURE_IMPI_EXCLUDE_CORES"
                AZURE_HPCX_HYBRID_OPTIONS=""
            else
                echo "PPN: $PPN, Threads: $NTHREADS, Is not supported on $VM_SKU"
            fi
        else
            echo "PPN: $PPN, Threads: $NTHREADS, Is not supported on $VM_SKU at this time"

        fi
    fi
elif [[ $VM_SKU == "Standard_HB120rs_v2" ]]; then
    echo "VM SKU: $VM_SKU"
    if [[ "$NTHREADS" -eq "1" ]]; then
        if [ "$PPN" == "16" ]; then
            export AZURE_PROCESSOR_LIST="0,8,16,24,30,38,46,54,60,68,76,84,90,98,106,114"
        elif [ "$PPN" == "32" ]; then
            export AZURE_PROCESSOR_LIST="0,1,8,9,16,17,24,25,30,31,38,39,46,47,54,55,60,61,68,69,76,77,84,85,90,91,98,99,106,107,114,115"
        elif [ "$PPN" == "64" ]; then
            export AZURE_PROCESSOR_LIST="0,1,2,3,8,9,10,11,16,17,18,19,24,25,26,27,30,31,32,33,38,39,40,41,46,47,48,49,54,55,56,57,60,61,62,63,68,69,70,71,76,77,78,79,84,85,86,87,90,91,92,93,98,99,100,101,106,107,108,109,114,115,116,117"
        elif [ "$PPN" == "96" ]; then
            export AZURE_PROCESSOR_LIST="0,1,2,3,4,5,8,9,10,11,12,13,16,17,18,19,20,21,24,25,26,27,28,29,30,31,32,33,34,35,38,39,40,41,42,43,46,47,48,49,50,51,54,55,56,57,58,59,60,61,62,63,64,65,68,69,70,71,72,75,76,77,78,79,80,81,84,85,86,87,88,89,90,91,92,93,94,95,98,99,100,101,102,103,106,107,108,109,110,111,114,115,116,117,118,119"
	elif [ "$PPN" == "120" ]; then
            export AZURE_PROCESSOR_LIST="0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119"
        fi
    elif [[ "$NTHREADS" -gt "1" && "$NTHREADS" -lt "4" && "$TOTAL_CORES_PER_NODE" -lt "97" ]]; then
        AZURE_IMPI_HYBRID_OPTIONS="-genv I_MPI_PIN_DOMAIN cache3 -genv I_MPI_PIN=on -genv OMP_NUM_THREADS=$NTHREADS"
        AZURE_HPCX_HYBRID_OPTIONS="--bind-to core --map-by ppr:1:l3cache:pe=$NTHREADS -x OMP_NUM_THREADS=$NTHREADS"
    fi
elif [[ $VM_SKU == "Standard_HB60rs" ]]; then
    echo "VM SKU: $VM_SKU"
    if [[ "$NTHREADS" -eq "1" ]]; then
        if [ "$PPN" == "15" ]; then
            export AZURE_PROCESSOR_LIST="0,4,8,12,16,20,24,28,32,36,40,44,48,52,56"
        elif [ "$PPN" == "30" ]; then
            export AZURE_PROCESSOR_LIST="0,1,4,5,8,9,12,13,16,17,20,21,24,25,28,29,32,33,36,37,40,41,44,45,48,49,52,53,56,57"
        elif [ "$PPN" == "45" ]; then
            export AZURE_PROCESSOR_LIST="0,1,2,4,5,6,8,9,10,12,13,14,16,17,18,20,21,22,24,25,26,28,29,30,32,33,34,36,37,38,40,41,42,44,45,46,48,49,50,52,53,54,56,57,58"
        elif [ "$PPN" == "60" ]; then
            export AZURE_PROCESSOR_LIST="0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59"
        fi
    elif [[ "$NTHREADS" -gt "1" && "$NTHREADS" -lt "5" ]]; then
        AZURE_IMPI_HYBRID_OPTIONS="-genv I_MPI_PIN_DOMAIN cache3 -genv I_MPI_PIN=on -genv OMP_NUM_THREADS=$NTHREADS"
        AZURE_HPCX_HYBRID_OPTIONS="--bind-to core --map-by ppr:1:l3cache:pe=$NTHREADS -x OMP_NUM_THREADS=$NTHREADS"
    fi
elif [[ $VM_SKU == "Standard_HC44rs" ]]; then
    echo "VM SKU: $VM_SKU"
    if [[ "$NTHREADS" -eq "1" ]]; then
        if [ "$PPN" == "24" ]; then
            export AZURE_PROCESSOR_LIST="0,1,2,3,4,5,6,7,8,9,10,11,23,24,25,26,27,28,29,30,31,32,33,34"
        elif [ "$PPN" == "32" ]; then
            export AZURE_PROCESSOR_LIST="0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38"
        elif [ "$PPN" == "36" ]; then
            export AZURE_PROCESSOR_LIST="0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40"
        elif [ "$PPN" == "44" ]; then
            export AZURE_PROCESSOR_LIST="0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43"
        fi
    elif [[ "$NTHREADS" -gt "1" && "$NTHREADS" -lt "23" ]]; then
        AZURE_IMPI_HYBRID_OPTIONS="-genv I_MPI_PIN_DOMAIN cache3 -genv I_MPI_PIN=on -genv OMP_NUM_THREADS=$NTHREADS"
        AZURE_HPCX_HYBRID_OPTIONS="--bind-to core --map-by ppr:1:l3cache:pe=$NTHREADS -x OMP_NUM_THREADS=$NTHREADS"
    fi
else
    echo "Undefined VM SKU: $VM_SKU"
fi

if [[ "$NTHREADS" -eq "1" ]]; then
    echo "NTHREADS: $NTHREADS == 1"
    export AZURE_OPENMPI_FLAGS="--bind-to cpulist:ordered --cpu-set $AZURE_PROCESSOR_LIST --rank-by slot --report-bindings "
    export AZURE_IMPI_FLAGS="-genv I_MPI_PIN_PROCESSOR_LIST=$AZURE_PROCESSOR_LIST -genv I_MPI_DEBUG=5 -genv I_MPI_FABRICS=shm -genv I_MPI_PIN=1"
elif [[ "$NTHREADS" -gt "1" ]]; then
    echo "NTHREADS: $NTHREADS > 1"
    export AZURE_OPENMPI_FLAGS="--bind-to --rank-by slot --report-bindings "
    export AZURE_IMPI_FLAGS="-genv "
    export AZURE_IMPI_HYBRID_FLAGS="-genv I_MPI_PIN_DOMAIN $NTHREADS:compact -genv I_MPI_PIN=on -genv I_MPI_PIN_PROCESSOR_EXCLUDE_LIST=$AZURE_IMPI_EXCLUDE_CORES"
else
    echo "NTHREADS: $NTHREADS < 1"
    echo "Unsupported value for NTHREADS: $NTHREADS"
fi