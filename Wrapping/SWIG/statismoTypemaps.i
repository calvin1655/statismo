/*
 * This file is part of the statismo library.
 *
 * Author: Marcel Luethi (marcel.luethi@unibas.ch)
 *
 * Copyright (c) 2011 University of Basel
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */
 
#if defined(SWIGPYTHON)

	%{
	#include "vtkPythonUtil.h"
	#define SWIG_FILE_WITH_INIT
	%}
	%include "numpy.i"
	%init %{
	import_array();
	%}
		
	
	
	%typemap (out) statismo::MatrixType
	{
		npy_intp dims[2];
		dims[0] = $1.rows();
		dims[1] = $1.cols();
		PyObject* c = PyArray_SimpleNew(2, dims, NPY_FLOAT);		
		memcpy(PyArray_DATA(c), $1.data(), dims[0] * dims[1] * sizeof(float));
		$result = c;
		  
	}
	
	
	%typemap (out) statismo::MatrixType&
	{
		npy_intp dims[2];
		dims[0] = $1->rows();
		dims[1] = $1->cols();
		PyObject* c = PyArray_SimpleNew(2, dims, NPY_FLOAT);
		memcpy(PyArray_DATA(c), $1->data(), dims[0] * dims[1] * sizeof(float));
		$result = c;
	}

	
	%typemap (out) statismo::VectorType&
	{
		npy_intp dims[1];
		dims[0] = $1->rows();
		$result= PyArray_SimpleNewFromData(1, dims, NPY_FLOAT, $1->data());  
	}

	%typemap (out) statismo::VectorType
	{
		npy_intp dims[1];
		dims[0] = $1.rows();
		PyObject* c = PyArray_SimpleNew(1, dims, NPY_FLOAT);		
		memcpy(PyArray_DATA(c), $1.data(), dims[0] * sizeof(float));
		$result= c;  
	}


	%typemap (in) (statismo::VectorType&)
	{
		int is_new_object1 = 0;
		PyArrayObject* array = (PyArrayObject*) PyArray_ContiguousFromObject($input, PyArray_DOUBLE, 0, 100);
		unsigned dim = array->dimensions[0];
		
		VectorType* v = new VectorType(dim);
		for (unsigned i = 0; i < dim; i++) { 
			(*v)(i) = (float) ((double*) array->data)[i];
		}		 
		$1= v ;
	}

	// the typecheck is needed to disambiguate overloaded function
	%typecheck(SWIG_TYPECHECK_POINTER) vtkPolyData * {
	  vtkPolyData *ptr;
	  if (dynamic_cast<vtkPolyData*>(vtkPythonUtil::GetPointerFromObject($input, "vtkPolyData")) == 0) {
	    $1 = 0;
	    PyErr_Clear();
	  } else {
	    $1 = 1;
	  }
	}


	%typemap (out) vtkPoint
	{
        $result = PyTuple_New(3);
        vtkPoint pt = $1;
    	PyTuple_SetItem($result,0,PyFloat_FromDouble(pt[0]));
    	PyTuple_SetItem($result,1,PyFloat_FromDouble(pt[1]));
    	PyTuple_SetItem($result,2,PyFloat_FromDouble(pt[2]));            	
	}

	
	// convert vtkPolyData To Corresponding type
	%typemap (in) vtkPolyData*
	{
	    $1 =  static_cast<vtkPolyData*>(vtkPythonUtil::GetPointerFromObject($input, "vtkPolyData"));
	}
	%typemap (out) const vtkPolyData*
	{
	PyImport_ImportModule("vtk");
	    $result =  vtkPythonUtil::GetObjectFromPointer((vtkPolyData*) $1);
	}

	%typemap (out) vtkPolyData*
	{
	PyImport_ImportModule("vtk");
	    $result =  vtkPythonUtil::GetObjectFromPointer((vtkPolyData*) $1);
	}
	

	
	// the typecheck is needed to disambiguate char* from vtkPolyData* in overloaded method
	%typecheck(SWIG_TYPECHECK_POINTER) vtkPolyData * {
	  vtkPolyData *ptr;
	  if (dynamic_cast<vtkPolyData*>(vtkPythonUtil::GetPointerFromObject($input, "vtkPolyData")) == 0) {
	    $1 = 0;
	    PyErr_Clear();
	  } else {
	    $1 = 1;
	  }
	}
	

	// convert vtkStructuredPoints To Corresponding type
	%typemap (in) vtkStructuredPoints*
	{
	    $1 =  static_cast<vtkStructuredPoints*>(vtkPythonUtil::GetPointerFromObject($input, "vtkStructuredPoints"));
	}
	%typemap (out) const vtkStructuredPoints*
	{
	PyImport_ImportModule("vtk");
	    $result =  vtkPythonUtil::GetObjectFromPointer((vtkStructuredPoints*) $1);
	}
	
	// the typecheck is needed to disambiguate char* from vtkStructuredPoints* in overloaded method
	%typecheck(SWIG_TYPECHECK_POINTER) vtkStructuredPoints * {
	  vtkStructuredPoints *ptr;
	  if (dynamic_cast<vtkStructuredPoints*>(vtkPythonUtil::GetPointerFromObject($input, "vtkStructuredPoints")) == 0) {
	    $1 = 0;
	    PyErr_Clear();
	  } else {
	    $1 = 1;
	  }
	}
	

	
	// Grab a 3 element array as a Python 3-tuple
	%typemap(in) double[3](double temp[3]) {   // temp[3] becomes a local variable
	  if (PyTuple_Check($input)) {
	    if (!PyArg_ParseTuple($input,"ddd",temp,temp+1,temp+2)) {
	      PyErr_SetString(PyExc_TypeError,"tuple must have 3 elements");
	      return NULL;
	    }
	    $1 = &temp[0];
	  } else {
	    PyErr_SetString(PyExc_TypeError,"expected a tuple.");
	    return NULL;
	  }
	}

#else
  #warning no "in" typemap defined
#endif

