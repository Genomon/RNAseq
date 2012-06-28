#! /bin/sh
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

num=$1
num=`expr ${num} - 1`

array=( a b c d e f g h i j k l m n o p q r s t u v w x y z )

DIGIT1=`expr ${num} / 676`
num1=`expr ${num} % 676`

DIGIT2=`expr ${num1} / 26`
DIGIT3=`expr ${num1} % 26`

echo ${array[$DIGIT1]}${array[$DIGIT2]}${array[$DIGIT3]} 

