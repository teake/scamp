dnl
dnl				acx_blas.m4
dnl
dnl Figure out if the (C)BLAS library and header files are installed.
dnl
dnl %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dnl
dnl	This file part of:	AstrOmatic software
dnl
dnl	Copyright:		(C) 2016 IAP/CNRS/UPMC
dnl
dnl	License:		GNU General Public License
dnl
dnl	AstrOmatic software is free software: you can redistribute it and/or
dnl	modify it under the terms of the GNU General Public License as
dnl	published by the Free Software Foundation, either version 3 of the
dnl	License, or (at your option) any later version.
dnl	AstrOmatic software is distributed in the hope that it will be useful,
dnl	but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl	GNU General Public License for more details.
dnl	You should have received a copy of the GNU General Public License
dnl	along with AstrOmatic software.
dnl	If not, see <http://www.gnu.org/licenses/>.
dnl
dnl	Last modified:		30/09/2016
dnl
dnl %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dnl
dnl @synopsis ACX_BLAS([BLAS_LIBSDIR, BLAS_INCDIR, BLASP_FLAG,
dnl                  BLAS64_FLAG, [ACTION-IF-FOUND[, ACTION-IF-NOT-FOUND]]])
dnl
dnl You may wish to use these variables in your default LIBS:
dnl
dnl        LIBS="$BLAS_LIBS $LIBS"
dnl
dnl ACTION-IF-FOUND is a list of shell commands to run if BLAS
dnl is found (HAVE_BLAS is defined first), and ACTION-IF-NOT-FOUND
dnl is a list of commands to run it if it is not found.

AC_DEFUN([ACX_BLAS], [
AC_REQUIRE([AC_CANONICAL_HOST])

dnl --------------------
dnl Search include files
dnl --------------------

acx_blas_ok=no
if test x$2 = x; then
dnl We give our preference to OpenBLAS
  AC_CHECK_HEADER(
    [openblas/cblas.h],
    [
      [acx_blas_ok=yes]
      AC_DEFINE_UNQUOTED(BLAS_H, ["openblas/cblas.h"], [cBLAS header filename.])
    ],
    [AC_CHECK_HEADER(
      [cblas.h],
      [
        [acx_blas_ok=yes]
        AC_DEFINE_UNQUOTED(BLAS_H, ["cblas.h"], [cBLAS header filename.])
      ],
      [BLAS_ERROR="cBLAS include files not found!"]
    )]
  )
else
  AC_CHECK_HEADER(
    [$2/cblas.h],
    [
      [acx_blas_ok=yes]
      AC_DEFINE_UNQUOTED(BLAS_H, ["$2/cblas.h"], [cBLAS header filename.])
    ],
    [AC_CHECK_HEADER(
      [$2/include/cblas.h],
      [
        [acx_blas_ok=yes]
        AC_DEFINE_UNQUOTED(BLAS_H, ["$2/include/cblas.h"],
		[cBLAS header filename.])
      ],
      [BLAS_ERROR="cBLAS include files not found in $2!"]
    )]
  )
fi

dnl -------------------------
dnl Search BLAS library files
dnl -------------------------

if test x$acx_blas_ok = xyes; then
  acx_blas_ok=no
  OLIBS="$LIBS"
  LIBS=""
  if test x$4 = xyes; then
    blas_suffix="64"
  else
    blas_suffix=""
  fi
  if test x$1 = x; then
    blas_libopt=""
  else
    blas_libopt="-L$1"
  fi
  if test x$3 = x; then
    AC_SEARCH_LIBS(
      cblas_dgemm, ["openblasp"$blas_suffix],
      [acx_blas_ok=yes],
      [AC_SEARCH_LIBS(
        cblas_dgemm, ["openblas"$blas_suffix],
        [acx_blas_ok=yes]
		[BLAS_WARN="parallel OpenBLAS"$blas_suffix" not found, reverting to scalar OpenBLAS"$blas_suffix"!"],
        [AC_SEARCH_LIBS(
          cblas_dgemm, ["blas"$blas_suffix],
          [acx_blas_ok=yes]
		[BLAS_WARN="parallel OpenBLAS"$blas_suffix" not found, reverting to scalar BLAS"$blas_suffix"!"],
          [BLAS_ERROR="CBLAS"$blas_suffix" library files not found!"],
          $blas_libopt
        )],
        $blas_libopt
      )],
      $blas_libopt
    )
  else
    AC_SEARCH_LIBS(
      cblas_dgemm, ["openblas"$blas_suffix],
      [acx_blas_ok=yes],
      [AC_SEARCH_LIBS(
        cblas_dgemm, ["blas"$blas_suffix],
        [acx_blas_ok=yes]
		[BLAS_WARN="OpenBLAS"$blas_suffix" not found, reverting to scalar BLAS"$blas_suffix"!"],
        [BLAS_ERROR="CBLAS"$blas_suffix" library files not found!"],
        $blas_libopt
      )],
      $blas_libopt
    )
  fi
  LIBS="$OLIBS"
fi

dnl -------------------------------------------------------------------------
dnl Finally execute ACTION-IF-FOUND/ACTION-IF-NOT-FOUND
dnl -------------------------------------------------------------------------

if test x"$acx_blas_ok" = xyes; then
  AC_DEFINE(HAVE_BLAS,1, [Define if you have the BLAS libraries and header files.])
  BLAS_LIBS="$blas_libopt $ac_cv_search_cblas_dgemm"
  AC_SUBST(BLAS_CFLAGS)
  AC_SUBST(BLAS_LIBS)
  AC_SUBST(BLAS_WARN)
  $5
else
  AC_SUBST(BLAS_ERROR)
  $6
fi

])dnl ACX_BLAS
