PROGRAM FEOTSDriver


! src/POP/
USE POP_FEOTS_Class
USE POP_Params_Class


IMPLICIT NONE

   TYPE( POP_FEOTS ) :: feots
   CHARACTER(10) :: ncFileTag
   INTEGER       :: recordID, fileID, i, nIODumps
   REAL(prec)    :: tn

      CALL feots % Build( )

      recordID = 1
      IF( feots % params % runMode == FORWARD )THEN 

         fileID   = feots % params % iterInit
         ! /////////////////////////// Load in the initial conditions //////////////////// !
         WRITE( ncfileTag, '(I10.10)' ) fileID
         ! For now, the record ID is 1. In the future, this will need to be
         ! calculated as a function of the initial iterate, the dump frequency,
         ! and the number of records per netcdf file
         
        ! Tracer.init.nc is read for the mask and source terms
         CALL feots % nativeSol % InitializeForNetCDFRead( feots % params % TracerModel,'Tracer.init.nc' )
         CALL feots % nativeSol % ReadSourceEtcNetCDF( feots % mesh )
         CALL feots % nativeSol % ReadNetCDFRecord( feots % mesh, recordID )
         CALL feots % nativeSol % FinalizeNetCDF( )
   
         IF( feots % params % iterInit == 0 )THEN
            tn = 0.0_prec
         ELSE
   
            ! This pickup file is read for the correct "initial condition"
            CALL feots % nativeSol % InitializeForNetCDFRead( feots % params % TracerModel,'Tracer.'//ncFileTag//'.nc' )
            CALL feots % nativeSol % ReadNetCDFRecord( feots % mesh, recordID )
            CALL feots % nativeSol % FinalizeNetCDF( )
            tn = REAL(feots % params % iterInit,prec)*feots % params % dt
   
         ENDIF
   
         ! /////////////////////////////////////////////////////////////////////////////// !
         
         ! Transfer the data from the native storage to the FEOTS storage
         CALL feots % MapAllToDOF( )
   
   
         ! //// Forward Mode //// !
         PRINT*, '  Starting ForwardStepAB3'
   
         DO i = feots % params % iterInit, feots % params % iterInit + feots % params % nTimeSteps -1, feots % params % nStepsPerDump
   
            CALL feots % ForwardStepAB3( tn, feots % params % nStepsPerDump )
   
            CALL feots % MapTracerFromDOF( )
   
            WRITE( ncfileTag, '(I10.10)' ) i + feots % params % nStepsPerDump
            CALL feots % nativeSol % InitializeForNetCDFWrite( feots % params % TracerModel, &
                                                                  feots % mesh, &
                                                                 'Tracer.'//ncFileTag//'.nc' )
            CALL feots % nativeSol % WriteNetCDFRecord( feots % mesh, recordID )
            CALL feots % nativeSol % FinalizeNetCDF( )
   
         ENDDO

      ELSEIF( feots % params % runMode == EQUILIBRIUM )THEN

        ! Tracer.init.nc is read for the mask and source terms
         CALL feots % nativeSol % InitializeForNetCDFRead( feots % params % TracerModel,'Tracer.init.nc' )
         CALL feots % nativeSol % ReadSourceEtcNetCDF( feots % mesh )
         CALL feots % nativeSol % ReadNetCDFRecord( feots % mesh, recordID )
         CALL feots % nativeSol % FinalizeNetCDF( )
   
  
         IF( feots % params % isPickupRun )THEN  
            CALL feots % nativeSol % InitializeForNetCDFRead( feots % params % TracerModel,'Tracer.pickup.nc' )
            CALL feots % nativeSol % ReadNetCDFRecord( feots % mesh, recordID )
            CALL feots % nativeSol % FinalizeNetCDF( )
            tn = REAL(feots % params % iterInit,prec)*feots % params % dt
   
         ENDIF
   
         ! /////////////////////////////////////////////////////////////////////////////// !
         
         ! Transfer the data from the native storage to the FEOTS storage
         CALL feots % MapAllToDOF( )

         CALL feots % JFNK( )

      ENDIF

      CALL feots % Trash( )


END PROGRAM FEOTSDriver
