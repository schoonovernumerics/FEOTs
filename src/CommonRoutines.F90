! CommonRoutines.f90
!
! Author : Joseph Schoonover
! E-mail : jschoonover@lanl.gov, schoonover.numerics@gmail.com
!
! Copyright 2017 Joseph Schoonover, Los Alamos National Laboratory
! 
! Redistribution and use in source and binary forms, with or without
! modification,
! are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice, this
! list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
! this list of conditions and the following disclaimer in the 
! documentation and/or other materials provided with the distribution.
! 
! 3. Neither the name of the copyright holder nor the names of its contributors
! may be used to endorse or promote products derived from this 
!  software without specific prior written permission.
! 
! THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
! AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
! TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
! PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
! CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
! EXEMPLARY,  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
! BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
! LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
! NEGLIGENCE  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
! SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
!
! ////////////////////////////////////////////////////////////////////////////////////////////////


MODULE CommonRoutines

USE ModelPrecision
USE ConstantsDictionary
USE HDF5

! netcdf
USE netcdf

IMPLICIT NONE
#ifdef HAVE_MPI
INCLUDE 'mpif.h'
#endif


   INTERFACE Invert
      MODULE PROCEDURE :: Invert_2x2
   END INTERFACE

   INTERFACE ForwardShift
      MODULE PROCEDURE :: ForwardShift_Integer
   END INTERFACE

   INTERFACE CompareArray
      MODULE PROCEDURE :: CompareArray_Integer
   END INTERFACE

   CHARACTER( * ), PRIVATE, PARAMETER :: upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
   CHARACTER( * ), PRIVATE, PARAMETER :: lower = 'abcdefghijklmnopqrstuvwxyz'

CONTAINS
 FUNCTION Int2Str( aNumber ) RESULT( aString )
   IMPLICIT NONE
   INTEGER :: aNumber
   CHARACTER(12) :: aString

     WRITE(aString, '(I9)') aNumber

 END FUNCTION Int2Str
 FUNCTION Float2Str( aNumber ) RESULT( aString )
   IMPLICIT NONE
   REAL(prec) :: aNumber
   CHARACTER(12) :: aString

     WRITE(aString, '(E12.4)') aNumber

 END FUNCTION Float2Str


 FUNCTION AlmostEqual( a, b ) RESULT( AisB )
 !
 ! This FUNCTION takes in two REAL(prec) values (a and b) and
 ! returns a logical which tells if a is approximately b in 
 ! floating point aritmetic.
 !
 ! 
 ! Input : 
 !       REAL(prec) :: a
 !       REAL(prec) :: b
 ! 
 ! Output :
 !       logical :: AisB
 !
 !=============================================================
  IMPLICIT NONE
  REAL(prec) :: a, b
  logical :: AisB


    if( a == 0.0_prec .OR. b == 0.0_prec )then

       if( abs(a-b) <= epsilon(1.0_prec) )then 
          AisB = .TRUE.
       else
          AisB = .FALSE.
       ENDif

    else

       if( (abs(a-b) <= epsilon(1.0_prec)*abs(a)) .OR. (abs(a-b) <= epsilon(1.0_prec)*abs(b)) )then
          AisB = .TRUE.
       else
          AisB = .FALSE.
       ENDif

    ENDif

 END FUNCTION AlmostEqual
!
!
!
 SUBROUTINE InsertionSort( inArray, outArray, N )
 ! S/R InsertionSort
 !
 !   Sorts array from smallest to largest. 
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   INTEGER, INTENT(in)  :: N
   INTEGER, INTENT(in)  :: inArray(1:N)
   INTEGER, INTENT(out) :: outArray(1:N)
   ! LOCAL
   INTEGER :: i, j
   INTEGER :: temp

    outArray = inArray

    DO i = 2,  N
       j = i
       DO WHILE( j > 1 .AND. outArray(j-1) > outArray(j) )
          !Swap outArray(j) outArray(j-1)
          temp          = outArray(j)
          outArray(j)   = outArray(j-1)
          outArray(j-1) = temp 
        
          j = j-1
       ENDDO
    ENDDO

 END SUBROUTINE InsertionSort
!
!
!
 SUBROUTINE SortAndSum( myArray, low, high, arraysum)
 !
 ! 
 !
 !=============================================================
 INTEGER, INTENT(in)       :: low, high
 REAL(prec), INTENT(inout) :: myArray(low:high)
 REAL(prec), INTENT(out)   :: arraysum
 
 ! LOCAL
 INTEGER :: ind


    CALL SortArray( myArray, low, high )

    arraysum = 0.0_prec

    DO ind = low, high

       arraysum = arraysum + myArray(ind)

    ENDDO
    

 END SUBROUTINE SortAndSum
!
!
!
 SUBROUTINE SortArray( myArray, low, high )
 !
 ! 
 !       
 !
 !=============================================================
 INTEGER, INTENT(in)       :: low, high
 REAL(prec), INTENT(inout) :: myArray(low:high)
 
 ! LOCAL
 INTEGER :: locOfMin
 INTEGER :: ind


    DO ind = low, high-1

       locOfMin = MINLOC( abs(myArray(ind:high)),1 ) + low - 1 + ind

       CALL SwapIndices( myArray, low, high, ind, locOfMin )

    ENDDO
    

 END SUBROUTINE SortArray
!
!
!
 SUBROUTINE SwapIndices( myArray, low, high, ind1, ind2 )
 !=============================================================
 ! 
 !
 ! 
 ! Input : 
 !       
 ! 
 ! Output :
 !       
 !
 !=============================================================
 INTEGER, INTENT(in)       :: low, high
 REAL(prec), INTENT(inout) :: myArray(low:high)
 INTEGER, INTENT(in)       :: ind1, ind2
 ! LOCAL
 REAL(prec) :: temp


    temp = myArray(ind1)

    myArray(ind1) = myArray(ind2)

    myArray(ind2) = temp


 END SUBROUTINE SwapIndices
!
!
!
 SUBROUTINE ReverseArray( myArray, low, high )
 !=============================================================
 ! 
 !
 ! 
 ! Input : 
 !       
 ! 
 ! Output :
 !       
 !
 !=============================================================
 INTEGER, INTENT(in)       :: low, high
 REAL(prec), INTENT(inout) :: myArray(low:high)
 ! LOCAL
 REAL(prec) :: temp(low:high)
 INTEGER    :: i, j


    temp = myArray
    j = high

    DO i = low,high

       myArray(i) = temp(j)
       j = j-1

    ENDDO


 END SUBROUTINE ReverseArray
!
!
!
 SUBROUTINE ForwardShift_Integer( myArray, N )
 !
 ! Shifts the array entries as follows :
 !  myArray(1) <-- myArray(N)
 !  myArray(2) <-- myArray(1)
 !  myArray(3) <-- myArray(2)
 !  .
 !  .
 !  .
 !  myArray(N) <-- myArray(N-1)
 !
 ! So that entries are shifted to one index higher.
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE  
   INTEGER, INTENT(in)    :: N
   INTEGER, INTENT(inout) :: myArray(1:N)
   ! 
   INTEGER :: temp(1:N)

      temp = myArray
      myArray(1)   = temp(N)
      myArray(2:N) = temp(1:N-1)

 END SUBROUTINE ForwardShift_Integer
!
!
!
 FUNCTION CompareArray_Integer( arrayOne, arrayTwo, N ) RESULT( arraysMatch )
 !
 ! 
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE  
   INTEGER :: N
   INTEGER :: arrayOne(1:N), arrayTwo(1:N)
   LOGICAL :: arraysMatch
   ! Local
   INTEGER :: i, theSumOfDiffs

      theSumOfDiffs = 0

      DO i = 1, N
         theSumOfDiffs = theSumOfDiffs + arrayOne(i) - arrayTwo(i)
      ENDDO

      IF( theSumOfDiffs == 0 )THEN
         arraysMatch = .TRUE. ! They are the same
      ELSE
         arraysMatch = .FALSE. ! They are not the same
      ENDIF

 END FUNCTION CompareArray_Integer
!
!
!
 INTEGER FUNCTION NewUnit(thisunit)
 ! This FUNCTION searches for a new FILE UNIT that is not currently in USE.
 !
 !=========================================================================!
 ! DECLARATIONS
  INTEGER, INTENT(out), optional :: thisunit
 ! LOCAL
  INTEGER, PARAMETER :: unitMin=100, unitMax=1000
  logical :: isopened
  INTEGER :: iUnit


     newunit=-1

     DO iUnit=unitMin, unitMax

        ! Check to see if this UNIT is opened
        INQUIRE(UNIT=iUnit,opened=isopened)

        if( .not. isopened )then

           newunit=iUnit
           EXIT

        ENDif

     ENDDO

     if (PRESENT(thisunit)) thisunit = newunit
 
END FUNCTION NewUnit
!
!
!
 FUNCTION UniformPoints( a, b, N ) RESULT( xU )
 !
 !
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   REAL(prec) :: a, b
   INTEGER    :: N
   REAL(prec) :: xU(0:N)
   ! LOCAL
   REAL(prec)    :: dx
   INTEGER :: i
   
      dx = (b-a)/REAL(N,prec)
   
      DO i = 0,N
      
         xU(i) = a + dx*REAL(i,prec)
      
      ENDDO   
   
 END FUNCTION UniformPoints
!
!
!
  RECURSIVE FUNCTION Determinant( A, N ) RESULT( D )
 ! FUNCTION Determinant
 !
 !  Computes the determinant of the N X N matrix, A.
 !
 ! =================================================
 ! DECLARATIONS
   integer    :: N
   real(prec) :: A(1:N,1:N)
   real(prec) :: D
   ! LOCAL
   real(prec) :: M(1:N-1,1:N-1)
   integer    :: j


      if(  N == 2 )then
     !    print*, 'N=',N
         D = A(1,1)*A(2,2) - A(1,2)*A(2,1)
     !    print*, D
         RETURN

      else
        ! print*, 'N=',N
         D = 0.0_prec

         do j = 1, N

            M = GetMinor( A, 1, j, N )
        !    print*, M(1,:)
        !    print*, M(2,:)

            D = D + A(1,j)*Determinant( M, N-1 )

         enddo

      endif
      
 
 END FUNCTION Determinant
!
!
!
 FUNCTION GetMinor( A, i, j, N ) RESULT( M )
 ! FUNCTION GetMinor
 !
 !  Returns the minor matrix of the N X N matrix A.
 !  The minor matrix of A is an (N-1)X(N-1) matrix.
 !
 ! =================================================
 ! DECLARATIONS
   integer    :: i, j, N
   real(prec) :: A(1:N,1:N)
   real(prec) :: M(1:N-1,1:N-1)
   ! LOCAL
   integer :: row, col
   integer :: thisRow, thisCol
      

      thisRow = 0
      

      do row = 1, N ! loop over the rows of A
  
         if( row /= i ) then

            thisRow = thisRow + 1      

            thisCol = 0
            do col = 1, N ! loop over the columns of A

               if( col /= j ) then

                  thisCol = thisCol + 1

                  M(thisRow,thisCol) = (-1.0_prec)**(i+j)*A(row, col)

               endif

            enddo ! col, loop over the columns of A

         endif 

      enddo ! row, loop over the rows of A


 END FUNCTION GetMinor
!
!
!
 FUNCTION Invert_2x2( A ) RESULT( Ainv )
 !
 ! =============================================================================================== !
   IMPLICIT NONE
   REAL(prec) :: A(1:2,1:2)
   REAL(prec) :: Ainv(1:2,1:2)
   ! LOCAL
   REAL(prec) :: detA
   
      detA = Determinant( A, 2 )
      
      Ainv(1,1) = A(2,2)/detA
      Ainv(2,2) = A(1,1)/detA
      Ainv(1,2) = -A(1,2)/detA
      Ainv(2,1) = -A(2,1)/detA

 END FUNCTION Invert_2x2
!
!
!
 FUNCTION Invert_3x3( A ) RESULT( Ainv )
 !
 ! =============================================================================================== !
   IMPLICIT NONE
   REAL(prec) :: A(1:3,1:3)
   REAL(prec) :: Ainv(1:3,1:3)
   ! LOCAL
   REAL(prec) :: detA
   REAL(prec) :: submat(1:2,1:2)
   REAL(prec) :: detSubmat
   
      detA = Determinant( A, 3 )
      
      ! Row 1 column 1 of inverse (use submatrix neglecting row 1 and column 1 of A)
      submat    =  A(2:3,2:3)
      detSubmat = Determinant( submat, 2 )
      Ainv(1,1) = detSubmat/detA
      
      ! Row 1 column 2 of inverse (use submatrix neglecting row 2 and column 1 of A)
      submat    =  A(1:3:2,2:3)
      detSubmat = Determinant( submat, 2 )
      Ainv(1,2) = -detSubmat/detA
      
      ! Row 1 column 3 of inverse (use submatrix neglecting row 3 and column 1 of A)
      submat    =  A(1:2,2:3)
      detSubmat = Determinant( submat, 2 )
      Ainv(1,3) = detSubmat/detA

      ! Row 2 column 1 of inverse (use submatrix neglecting row 1 and column 2 of A)
      submat    =  A(2:3,1:3:2)
      detSubmat = Determinant( submat, 2 )
      Ainv(2,1) = -detSubmat/detA
      
      ! Row 2 column 2 of inverse (use submatrix neglecting row 2 and column 2 of A)
      submat    =  A(1:3:2,1:3:2)
      detSubmat = Determinant( submat, 2 )
      Ainv(2,2) = -detSubmat/detA
      
      ! Row 2 column 3 of inverse (use submatrix neglecting row 3 and column 2 of A)
      submat    =  A(1:2,1:3:2)
      detSubmat = Determinant( submat, 2 )
      Ainv(2,3) = -detSubmat/detA
      
      ! Row 3 column 1 of inverse (use submatrix neglecting row 1 and column 3 of A)
      submat    =  A(2:3,1:2)
      detSubmat = Determinant( submat, 2 )
      Ainv(3,1) = detSubmat/detA
      
      ! Row 3 column 2 of inverse (use submatrix neglecting row 2 and column 3 of A)
      submat    =  A(1:3:2,1:2)
      detSubmat = Determinant( submat, 2 )
      Ainv(3,2) = -detSubmat/detA
      
      ! Row 3 column 3 of inverse (use submatrix neglecting row 3 and column 3 of A)
      submat    =  A(1:2,1:2)
      detSubmat = Determinant( submat, 2 )
      Ainv(3,3) = detSubmat/detA

 END FUNCTION Invert_3x3 
!
!
! 
 FUNCTION Map3Dto1D( array3D, N, M, P, N1D ) RESULT( array1D )
 ! 
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   INTEGER    :: N, M, P, N1D
   REAL(prec) :: array3D(0:N,0:M,0:P)
   REAL(prec) :: array1D(1:N1D)
   ! Local
   INTEGER    :: i, j, k, ind1D

      DO k = 0, P
         DO j = 0, M
            DO i = 0, N
               ind1D = i + 1 + (j + k*(M+1))*(N+1)
               array1D(ind1D) = array3D(i,j,k)
            ENDDO
         ENDDO
      ENDDO
            
 END FUNCTION Map3Dto1D
!
!
! 
 FUNCTION Map1Dto3D( array1D, N, M, P, N1D ) RESULT( array3D )
 ! 
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   INTEGER    :: N, M, P, N1D
   REAL(prec) :: array1D(1:N1D)
   REAL(prec) :: array3D(0:N,0:M,0:P)
   ! Local
   INTEGER    :: i, j, k, ind1D

      DO k = 0, P
         DO j = 0, M
            DO i = 0, N
               ind1D = i + 1 + (j + k*(M+1))*(N+1)
               array3D(i,j,k) = array1D(ind1D)
            ENDDO
         ENDDO
      ENDDO
            
 END FUNCTION Map1Dto3D 

 FUNCTION GetFlagForChar( mychar ) RESULT( intflag )

   IMPLICIT NONE
   CHARACTER(*) :: mychar
   INTEGER      :: intflag

      IF( LowerCase( TRIM(myChar) ) == 'dyemodel' ) THEN
         intFlag = DyeModel   
      ELSEIF( LowerCase( TRIM(myChar) ) == 'radionuclidemodel' )THEN
         intFlag = RadionuclideModel
      ELSEIF( LowerCase( TRIM(myChar) ) == 'settlingmodel' )THEN
         intFlag = SettlingModel
      ELSEIF( LowerCase( TRIM(myChar) ) == 'forward' )THEN
         intFlag = forward
      ELSEIF( LowerCase( TRIM(myChar) ) == 'equilibrium' )THEN
         intFlag = equilibrium
      ELSEIF( LowerCase( TRIM(myChar) ) == 'laxwendroffoverlap' )THEN
         intFlag = LaxWendroffOverlap
      ELSEIF( LowerCase( TRIM(myChar) ) == 'laxwendroff' )THEN
         intFlag = LaxWendroff
      ELSEIF( LowerCase( TRIM(myChar) ) == 'laxwendroff27overlap' )THEN
         intFlag = LaxWendroff27Overlap
      ELSEIF( LowerCase( TRIM(myChar) ) == 'laxwendroff27' )THEN
         intFlag = LaxWendroff27
      ELSEIF( LowerCase( TRIM(myChar) ) == 'upwind3overlap' )THEN
         intFlag = Upwind3Overlap
      ELSEIF( LowerCase( TRIM(myChar) ) == 'upwind3' )THEN
         intFlag = Upwind3
      ELSEIF( LowerCase( TRIM(myChar) ) == 'periodictripole') THEN
         intFlag = PeriodicTripole
      ELSEIF( LowerCase( TRIM(myChar) ) == 'dipole') THEN
         intFlag = Dipole
      ELSEIF( LowerCase( TRIM(myChar) ) == 'temperature') THEN
         intFlag = Temperature
      ELSEIF( LowerCase( TRIM(myChar) ) == 'salinity') THEN
         intFlag = Salinity
      ELSEIF( LowerCase( TRIM(myChar) ) == 'density') THEN
         intFlag = Density
      ELSEIF( LowerCase( TRIM(myChar) ) == 'euler') THEN
         intFlag = Euler
      ELSEIF( LowerCase( TRIM(myChar) ) == 'ab2') THEN
         intFlag = AB2
      ELSEIF( LowerCase( TRIM(myChar) ) == 'ab3') THEN
         intFlag = AB3
      ELSE
         PRINT*, 'Unknown Character Option : '//TRIM(myChar)
      ENDIF

 END FUNCTION GetFlagForChar

 FUNCTION LowerCase( inputChar ) RESULT( lowerCaseChar )
   IMPLICIT NONE
   CHARACTER(*) :: inputChar
   CHARACTER( LEN(inputChar) ) :: lowerCaseChar
   ! Local
   INTEGER :: i, n

      lowerCaseChar = inputChar
      DO i = 1, LEN(lowerCaseChar)
         n = INDEX( upper , lowerCaseChar(i:i) ) ! find the index in the "upper" parameter
         IF( n/=0 ) lowerCaseChar(i:i) = lower( n:n )           
      ENDDO
  
 END FUNCTION LowerCase
!
 SUBROUTINE Check(status)
   IMPLICIT NONE
   INTEGER, INTENT (in) :: status
    
    IF(status /= nf90_noerr) THEN 
      PRINT *, trim(nf90_strerror(status))
      STOP "NetCDF Error, Stopped"
    ENDIF
 END SUBROUTINE Check 

 SUBROUTINE Add_IntObj_to_HDF5( rank, dimensions, variable_name,variable, file_id )
   IMPLICIT NONE
   INTEGER, INTENT(in)          :: rank
   INTEGER(HSIZE_T), INTENT(in) :: dimensions(1:rank)
   CHARACTER(*)                 :: variable_name
   INTEGER, INTENT(in)          :: variable(*)
   INTEGER(HID_T), INTENT(in)   :: file_id
   ! local
   INTEGER(HID_T)   :: memspace, dataset_id
   INTEGER          :: error

       CALL h5screate_simple_f(rank, dimensions, memspace, error)
       CALL h5dcreate_f( file_id, TRIM(variable_name), H5T_STD_I32LE, memspace,dataset_id, error)
       CALL h5dwrite_f( dataset_id, H5T_STD_I32LE , variable, dimensions,error)
       CALL h5dclose_f( dataset_id, error )
       CALL h5sclose_f( memspace, error )

 END SUBROUTINE Add_IntObj_to_HDF5

 SUBROUTINE Add_FloatObj_to_HDF5( rank, dimensions, variable_name, variable, file_id )
   IMPLICIT NONE
   INTEGER, INTENT(in)          :: rank
   INTEGER(HSIZE_T), INTENT(in) :: dimensions(1:rank)
   CHARACTER(*)                 :: variable_name
   REAL(prec), INTENT(in)       :: variable(*)
   INTEGER(HID_T), INTENT(in)   :: file_id
   ! local
   INTEGER(HID_T)   :: memspace, dataset_id
   INTEGER          :: error

       CALL h5screate_simple_f(rank, dimensions, memspace, error)
       CALL h5dcreate_f( file_id, TRIM(variable_name), H5T_IEEE_F32LE, memspace, dataset_id, error)
       CALL h5dwrite_f( dataset_id, H5T_IEEE_F32LE, variable, dimensions,error)
       CALL h5dclose_f( dataset_id, error )
       CALL h5sclose_f( memspace, error )

 END SUBROUTINE Add_FloatObj_to_HDF5

 SUBROUTINE Get_HDF5_Obj_Dimensions( file_id, variable_name, rank, dimensions )
   IMPLICIT NONE
   INTEGER(HID_T), INTENT(in)    :: file_id
   CHARACTER(*)                  :: variable_name
   INTEGER, INTENT(in)           :: rank
   INTEGER(HSIZE_T), INTENT(out) :: dimensions(1:rank)
   ! Local
   INTEGER          :: error
   INTEGER(HID_T)   :: dataset_id
   INTEGER(HSIZE_T) :: maxdims(1:rank)
   INTEGER(HID_T)   :: filespace

        CALL h5dopen_f(file_id, TRIM(variable_name), dataset_id, error)
        CALL h5dget_space_f(dataset_id, filespace, error)
        CALL h5sget_simple_extent_dims_f(filespace, dimensions, maxdims, error)
        CALL h5dclose_f(dataset_id, error)
        CALL h5sclose_f(filespace, error)

 END SUBROUTINE Get_HDF5_Obj_Dimensions


END MODULE CommonRoutines
