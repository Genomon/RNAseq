#! /bin/bash
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


cnt=`echo $(( $RANDOM % 120 ))`
echo "sleep ${cnt} start"
date
sleep ${cnt}
date
echo "sleep ${cnt} end"
 
