dicom2dti
=========

Matlab tools to process diffusion MRI studies (DICOM)
into manageable DTI (NIfTI). Currently, it supports simple Matlab visualization,
plus some custom processing tools that.

Dependencies
============

You'll need [DTK](http://trackvis.org/dtk) and
[MRICron](http://www.mccauslandcenter.sc.edu/mricro/mricron/) in order to run
DICOM to DTI conversion. 

For all NIfTI handling in Matlab you will need these [tools for NIfTI and ANALYZE
image](http://www.mathworks.es/matlabcentral/fileexchange/8797).


Usage
=====

There is a
[bootstrap](https://github.com/fbeeper/dicom2dti/blob/master/bootstrap.m) script
for you to start and go through all the steps covered by this tool.


ATENTION: There is no example data included. You will need
your own DICOM folder with a diffusion study in order to test it.


Licensing
=========

I kept references in-line with the code to the work of
others. Relative to my work, MIT licensing applies:

<pre>Copyright (C) 2012 Ferran Poveda

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.</pre>


Contact
=======

I'd be pleased to hear any comments, ideas, code, questions, or whatever you may
want to say!

You'll easily find me at: [github.com/fbeeper](https://github.com/fbeeper), or
[@fbeeper](http://twitter.com/fbeeper).
