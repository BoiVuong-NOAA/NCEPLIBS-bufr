C> @file
C> @brief Converts a descriptor from its bit-wise (integer) representation to
C> its five or six character ascii representation.
C> @author WOOLLEN @date 1994-01-06

C> @author WOOLLEN @date 1994-01-06
C>
C> This function converts a descriptor from its bit-wise
c> (integer) representation to its five or six character ascii
C> representation.
C>
C> Program History Log:
C> - 1994-01-06  J. WOOLLEN -- ORIGINAL AUTHOR
C> - 1998-07-08  J. WOOLLEN -- REPLACED CALL TO CRAY LIBRARY ROUTINE
C>                           "ABORT" WITH CALL TO NEW INTERNAL BUFRLIB
C>                           ROUTINE "BORT"
C> - 2003-11-04  S. BENDER  -- ADDED REMARKS/BUFRLIB ROUTINE
C>                           INTERDEPENDENCIES
C> - 2003-11-04  D. KEYSER  -- UNIFIED/PORTABLE FOR WRF; ADDED
C>                           DOCUMENTATION (INCLUDING HISTORY); OUTPUTS
C>                           MORE COMPLETE DIAGNOSTIC INFO WHEN ROUTINE
C>                           TERMINATES ABNORMALLY
C>
C> @param[in] IDN - INTEGER: BIT-WISE REPRESENTATION OF DESCRIPTOR (FXY)
C>                VALUE
C> @param[in] L30 - INTEGER: LENGTH OF ADN30 (NUMBER OF CHARACTERS, 5 OR
C>                6)
C> @return CHARACTER*(*): CHARACTER FORM OF DESCRIPTOR (FXY VALUE)
C>
C> This routine calls: bort()
C> this routine is called by: cadn30() dxinit() igetrfel() istdesc()
C> nemtbd() numtab() rdmtbb() rdmtbd() rdmtbf() reads3() seqsdx() sntbde()
C> sntbfe() ufbqcd() upds3() wrdxtb()
C> Normally not called by any application programs.
C>
      
      FUNCTION ADN30(IDN,L30)

      COMMON /HRDWRD/ NBYTW,NBITW,IORD(8)

      CHARACTER*(*) ADN30
      CHARACTER*128 BORT_STR

C----------------------------------------------------------------------
C----------------------------------------------------------------------

      IF(LEN(ADN30).LT.L30         ) GOTO 900
      IF(IDN.LT.0 .OR. IDN.GT.65535) GOTO 901
      IF(L30.EQ.5) THEN
         WRITE(ADN30,'(I5)') IDN
      ELSEIF(L30.EQ.6) THEN
         IDF = ISHFT(IDN,-14)
         IDX = ISHFT(ISHFT(IDN,NBITW-14),-(NBITW-6))
         IDY = ISHFT(ISHFT(IDN,NBITW- 8),-(NBITW-8))
         WRITE(ADN30,'(I1,I2,I3)') IDF,IDX,IDY
      ELSE
         GOTO 902
      ENDIF

      DO I=1,L30
      IF(ADN30(I:I).EQ.' ') ADN30(I:I) = '0'
      ENDDO

C  EXITS
C  -----

      RETURN
900   CALL BORT('BUFRLIB: ADN30 - FUNCTION RETURN STRING TOO SHORT')
901   CALL BORT('BUFRLIB: ADN30 - INTEGER REPRESENTATION OF '//
     . 'DESCRIPTOR OUT OF 16-BIT RANGE')
902   WRITE(BORT_STR,'("BUFRLIB: ADN30 - CHARACTER LENGTH (",I4,") '//
     . 'MUST BE EITHER 5 OR 6")') L30
      CALL BORT(BORT_STR)
      END
