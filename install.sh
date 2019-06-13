#!/bin/sh

# Author : Debanjan Basu <debanjanbasu2006@gmail.com>
# Copyright (c) Debanjan Basu
# Script follows here:

echo "Please ensure that you have wifi configured"

# Part for running sfdisk
echo "Partinioning disk now..."
sfdisk /dev/sda < xps256gbssd.sfdisk
