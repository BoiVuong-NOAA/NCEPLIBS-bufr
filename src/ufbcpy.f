C> @file
C> @author WOOLLEN @date 1994-01-06
      
C> THIS SUBROUTINE COPIES A COMPLETE SUBSET BUFFER, UNPACKED
C>   INTO INTERNAL MEMORY FROM LOGICAL UNIT LUBIN BY A PREVIOUS CALL
C>   TO BUFR ARCHIVE LIBRARY SUBROUTINE READSB OR READNS, TO
C>   LOGICAL UNIT LUBOT.  BUFR ARCHIVE LIBRARY SUBROUTINE OPENMG OR
C>   OPENMB MUST HAVE BEEN PREVIOUSLY CALLED TO OPEN AND INITIALIZE A
C>   BUFR MESSAGE WITHIN MEMORY FOR LOGICAL UNIT LUBOT.  BOTH FILES MUST
C>   HAVE BEEN OPENED TO THE INTERFACE (VIA A CALL TO BUFR ARCHIVE
C>   LIBRARY SUBROUTINE OPENBF) WITH IDENTICAL BUFR TABLES.
C>
C> PROGRAM HISTORY LOG:
C> 1994-01-06  J. WOOLLEN -- ORIGINAL AUTHOR
C> 1998-07-08  J. WOOLLEN -- REPLACED CALL TO CRAY LIBRARY ROUTINE
C>                           "ABORT" WITH CALL TO NEW INTERNAL BUFRLIB
C>                           ROUTINE "BORT"
C> 1999-11-18  J. WOOLLEN -- THE NUMBER OF BUFR FILES WHICH CAN BE
C>                           OPENED AT ONE TIME INCREASED FROM 10 TO 32
C>                           (NECESSARY IN ORDER TO PROCESS MULTIPLE
C>                           BUFR FILES UNDER THE MPI)
C> 2003-11-04  S. BENDER  -- ADDED REMARKS/BUFRLIB ROUTINE
C>                           INTERDEPENDENCIES
C> 2003-11-04  D. KEYSER  -- MAXJL (MAXIMUM NUMBER OF JUMP/LINK ENTRIES)
C>                           INCREASED FROM 15000 TO 16000 (WAS IN
C>                           VERIFICATION VERSION); UNIFIED/PORTABLE FOR
C>                           WRF; ADDED DOCUMENTATION (INCLUDING
C>                           HISTORY); OUTPUTS MORE COMPLETE DIAGNOSTIC
C>                           INFO WHEN ROUTINE TERMINATES ABNORMALLY
C> 2009-06-26  J. ATOR    -- USE IOK2CPY
C> 2009-08-11  J. WOOLLEN -- ADD COMMON UFBCPL TO REMEMBER WHICH UNIT 
C>                           IS COPIED TO WHAT SUBSET BUFFER IN ORDER TO
C>                           TRANSFER LONG STRINGS VIA UFBCPY AND WRTREE
C> 2014-12-10  J. ATOR    -- USE MODULES INSTEAD OF COMMON BLOCKS
C>
C> USAGE:    CALL UFBCPY (LUBIN, LUBOT)
C>   INPUT ARGUMENT LIST:
C>     LUBIT    - INTEGER: FORTRAN LOGICAL UNIT NUMBER FOR INPUT BUFR
C>                FILE
C>     LUBOT    - INTEGER: FORTRAN LOGICAL UNIT NUMBER FOR OUTPUT BUFR
C>                FILE
C>
C> REMARKS:
C>    THIS ROUTINE CALLS:        BORT     IOK2CPY  STATUS
C>    THIS ROUTINE IS CALLED BY: COPYSB
C>                               Also called by application programs.
C>
      SUBROUTINE UFBCPY(LUBIN,LUBOT)



      USE MODA_USRINT
      USE MODA_MSGCWD
      USE MODA_UFBCPL
      USE MODA_TABLES

      INCLUDE 'bufrlib.inc'

C----------------------------------------------------------------------
C----------------------------------------------------------------------

C  CHECK THE FILE STATUSES AND I-NODE
C  ----------------------------------

      CALL STATUS(LUBIN,LUI,IL,IM)
      IF(IL.EQ.0) GOTO 900
      IF(IL.GT.0) GOTO 901
      IF(IM.EQ.0) GOTO 902
      IF(INODE(LUI).NE.INV(1,LUI)) GOTO 903

      CALL STATUS(LUBOT,LUO,IL,IM)
      IF(IL.EQ.0) GOTO 904
      IF(IL.LT.0) GOTO 905
      IF(IM.EQ.0) GOTO 906

      IF(INODE(LUI).NE.INODE(LUO)) THEN
        IF( (TAG(INODE(LUI)).NE.TAG(INODE(LUO))) .OR.
     .     (IOK2CPY(LUI,LUO).NE.1) ) GOTO 907
      ENDIF

C  EVERYTHING OKAY COPY USER ARRAY FROM LUI TO LUO
C  -----------------------------------------------

      NVAL(LUO) = NVAL(LUI)

      DO N=1,NVAL(LUI)
      INV(N,LUO) = INV(N,LUI)
      NRFELM(N,LUO) = NRFELM(N,LUI)
      VAL(N,LUO) = VAL(N,LUI)
      ENDDO

      LUNCPY(LUO)=LUBIN

C  EXITS
C  -----

      RETURN
900   CALL BORT('BUFRLIB: UFBCPY - INPUT BUFR FILE IS CLOSED, IT MUST'//
     . ' BE OPEN FOR INPUT')
901   CALL BORT('BUFRLIB: UFBCPY - INPUT BUFR FILE IS OPEN FOR '//
     . 'OUTPUT, IT MUST BE OPEN FOR INPUT')
902   CALL BORT('BUFRLIB: UFBCPY - A MESSAGE MUST BE OPEN IN INPUT '//
     . 'BUFR FILE, NONE ARE')
903   CALL BORT('BUFRLIB: UFBCPY - LOCATION OF INTERNAL TABLE FOR '//
     . 'INPUT BUFR FILE DOES NOT AGREE WITH EXPECTED LOCATION IN '//
     . 'INTERNAL SUBSET ARRAY')
904   CALL BORT('BUFRLIB: UFBCPY - OUTPUT BUFR FILE IS CLOSED, IT '//
     . 'MUST BE OPEN FOR OUTPUT')
905   CALL BORT('BUFRLIB: UFBCPY - OUTPUT BUFR FILE IS OPEN FOR '//
     . 'INPUT, IT MUST BE OPEN FOR OUTPUT')
906   CALL BORT('BUFRLIB: UFBCPY - A MESSAGE MUST BE OPEN IN OUTPUT '//
     . 'BUFR FILE, NONE ARE')
907   CALL BORT('BUFRLIB: UFBCPY - INPUT AND OUTPUT BUFR FILES MUST '//
     . 'HAVE THE SAME INTERNAL TABLES, THEY ARE DIFFERENT HERE')
      END
