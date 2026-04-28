#!/bin/bash

pandoc cv.md --template=cv-template.latex --lua-filter=multicols.lua -o cv.pdf