#!/bin/sh
#Yousef Ghanem 1172333
#Asaad Halayqa 1172102
#

#ask the user to choose between decryption and encryption
echo "Choose between Encryption (enter e) and Decryption (enter d): "
read ch
echo

#if the user chooses encryption
if [ $ch = 'e' ]; then
    echo "Please input the name of the plain text file: "
#if user chooses decryption
elif [ $ch = 'd' ]; then
    echo "Please enter the name of the cipher text file: "
#if the user enter invalid value program exits
else
    echo "invalid input!!"
    exit 1
fi

read file
echo
#check if the file exists
if [ ! -f $file ]; then
    echo "this file doesn't exist!"
    exit 1
fi
echo "these are the contents of the file:"
cat $file
echo

#delete un-alphabatic chars and converting to lower case letters
progress=$(tr -d '[0-9!-/:-@[-`{-~]' <$file | tr '[A-Z]' '[a-z]')
if [ $ch = 'e' ]; then
    echo "proccesed file content :"
    echo $progress
    echo
fi

wordcount=1
shiftvalue=0
numofwords=$(echo "$progress" | wc -w)

#seperate words
while [ $numofwords -ne 0 ]; do
    lettercount=1 #reset letter index to 1
    word=$(echo "$progress" | cut -d' ' -f $wordcount)
    letter=$(echo "$word" | cut -c $lettercount)
    total=0
    #seperate letters and calculate frequency of the word
    until [ -z $letter ]; do
        count=$(echo "$progress" | tr -cd $letter | wc -c)
        lettercount=$(($lettercount + 1))
        total=$(($total + $count))
        letter=$(echo "$word" | cut -c $lettercount)
    done

    #getting the maximum frequency as shift value
    freq=$(($total % 26))
    if [ $freq -gt $shiftvalue ]; then
        shiftvalue=$freq
    fi
    echo "the frquency for $word : $freq"
    wordcount=$(($wordcount + 1))
    numofwords=$(($numofwords - 1))
done
echo "Shift value is $shiftvalue"

#if the user chose encryption
if [ $ch = 'e' ]; then
    echo
    echo "enter the name of the cipher text file: "
    read out
    if [ ! -f $out ]; then
        echo "this file doesn't exist!"
        exit 1
    fi
    echo -n "" >$out #clears the output file

    numofchars=$(echo "$progress" | wc -c)
    for i in $(seq 1 $(($numofchars - 1))); do
        char=$(echo "$progress" | cut -c $i)
        if [ "$char" = " " ]; then
            printf ' ' >>$out
            continue
        fi
        ascii=$(printf "%d" \'$char)
        v=$(($ascii + $shiftvalue)) #ascii value of shifted character
        if [ $v -gt 122 ]; then     #if ascii > z then return to a..
            v=$(($v - 26))
        fi
        v=$(printf '%x' $v)
        echo $v | xxd -p -r >>$out #converts from hexa ascii to character and prints to file
    done
    echo "File has been encrypted!!"
    echo
    echo "The encrypted content is:"
    cat $out
    echo
    exit 0

#if user chose decryption
else
    echo
    echo "enter the name of the plain text file: "
    read out
    if [ ! -f $out ]; then
        echo "this file doesn't exist!"
        exit 1
    fi
    echo -n "" >$out #clears the output file

    #do as encryption but with shifting backward
    numofchars=$(echo "$progress" | wc -c)
    for i in $(seq 1 $numofchars); do
        char=$(echo "$progress" | cut -c $i)
        if [ "$char" = " " ]; then
            printf ' ' >>$out
            continue
        fi
        ascii=$(printf "%d" \'$char)
        v=$(($ascii - $shiftvalue))
        if [ $v -lt 97 ]; then
            v=$(($v + 26))
        fi
        v=$(printf '%x' $v)
        echo $v | xxd -p -r >>$out
    done
    echo "File has been decrypted!!"
    echo
    echo "The decrypted content is:"
    cat $out
fi
echo
exit 0
