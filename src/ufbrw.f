C> @file
C> @author WOOLLEN @date 1994-01-06
      
C> THIS SUBROUTINE WRITES OR READS SPECIFIED VALUES TO OR FROM
C>   THE CURRENT BUFR DATA SUBSET WITHIN INTERNAL ARRAYS, WITH THE
C>   DIRECTION OF THE DATA TRANSFER DETERMINED BY THE CONTEXT OF IO
C>   (I.E., IF IO INDICATES LUN POINTS TO A BUFR FILE THAT IS OPEN FOR
C>   INPUT, THEN DATA VALUES ARE READ FROM THE INTERNAL DATA SUBSET;
C>   OTHERWISE, DATA VALUES ARE WRITTEN TO THE INTERNAL DATA SUBSET).
C>   THE DATA VALUES CORRESPOND TO INTERNAL ARRAYS REPRESENTING PARSED
C>   STRINGS OF MNEMONICS WHICH ARE PART OF A DELAYED-REPLICATION
C>   SEQUENCE, OR FOR WHICH THERE IS NO REPLICATION AT ALL.
C>
C>   THIS SUBROUTINE SHOULD NEVER BE CALLED BY ANY APPLICATION PROGRAM;
C>   INSTEAD, APPLICATION PROGRAMS SHOULD ALWAYS CALL BUFR ARCHIVE
C>   LIBRARY SUBROUTINE UFBINT.
C>
C> PROGRAM HISTORY LOG:
C> 1994-01-06  J. WOOLLEN -- ORIGINAL AUTHOR
C> 1996-12-11  J. WOOLLEN -- REMOVED A HARD ABORT FOR USERS WHO TRY TO
C>                           WRITE NON-EXISTING MNEMONICS
C> 1998-07-08  J. WOOLLEN -- IMPROVED MACHINE PORTABILITY
C> 1998-10-27  J. WOOLLEN -- MODIFIED TO CORRECT PROBLEMS CAUSED BY IN-
C>                           LINING CODE WITH FPP DIRECTIVES
C> 1999-11-18  J. WOOLLEN -- THE NUMBER OF BUFR FILES WHICH CAN BE
C>                           OPENED AT ONE TIME INCREASED FROM 10 TO 32
C>                           (NECESSARY IN ORDER TO PROCESS MULTIPLE
C>                           BUFR FILES UNDER THE MPI)
C> 2002-05-14  J. WOOLLEN -- REMOVED OLD CRAY COMPILER DIRECTIVES
C> 2003-11-04  S. BENDER  -- ADDED REMARKS/BUFRLIB ROUTINE
C>                           INTERDEPENDENCIES
C> 2003-11-04  D. KEYSER  -- MAXJL (MAXIMUM NUMBER OF JUMP/LINK ENTRIES)
C>                           INCREASED FROM 15000 TO 16000 (WAS IN
C>                           VERIFICATION VERSION); UNIFIED/PORTABLE FOR
C>                           WRF; ADDED DOCUMENTATION (INCLUDING
C>                           HISTORY)
C> 2007-01-19  J. ATOR    -- USE FUNCTION IBFMS
C> 2009-03-31  J. WOOLLEN -- ADD DOCUMENTATION
C> 2009-04-21  J. ATOR    -- USE ERRWRT; USE LSTJPB INSTEAD OF LSTRPS
C> 2014-12-10  J. ATOR    -- USE MODULES INSTEAD OF COMMON BLOCKS
C>
C> USAGE:    CALL UFBRW (LUN, USR, I1, I2, IO, IRET)
C>   INPUT ARGUMENT LIST:
C>     LUN      - INTEGER: I/O STREAM INDEX INTO INTERNAL MEMORY ARRAYS
C>     USR      - ONLY IF BUFR FILE OPEN FOR OUTPUT:
C>                   REAL*8: (I1,I2) STARTING ADDRESS OF DATA VALUES
C>                   WRITTEN TO DATA SUBSET
C>     I1       - INTEGER: LENGTH OF FIRST DIMENSION OF USR
C>     I2       - INTEGER: LENGTH OF SECOND DIMENSION OF USR
C>     IO       - INTEGER: STATUS INDICATOR FOR BUFR FILE ASSOCIATED
C>                WITH LUN:
C>                       0 = input file
C>                       1 = output file
C>
C>   OUTPUT ARGUMENT LIST:
C>     USR      - ONLY IF BUFR FILE OPEN FOR INPUT:
C>                   REAL*8: (I1,I2) STARTING ADDRESS OF DATA VALUES
C>                   READ FROM DATA SUBSET
C>     IRET     - INTEGER:
C>                  - IF BUFR FILE OPEN FOR INPUT: NUMBER OF "LEVELS" OF
C>                    DATA VALUES READ FROM DATA SUBSET (MUST BE NO
C>                    LARGER THAN I2)
C>                      -1 = NONE OF THE MNEMONICS IN THE STRING PASSED
C>                           TO UFBINT WERE FOUND IN THE SUBSET TEMPLATE
C>                  - IF BUFR FILE OPEN FOR OUTPUT: NUMBER OF "LEVELS"
C>                    OF DATA VALUES WRITTEN TO DATA SUBSET (SHOULD BE
C>                    SAME AS I2)
C>                      -1 = NONE OF THE MNEMONICS IN THE STRING PASSED
C>                           TO UFBINT WERE FOUND IN THE SUBSET TEMPLATE
C>
C> REMARKS:
C>    THIS ROUTINE CALLS:        CONWIN   DRSTPL   ERRWRT   GETWIN
C>                               IBFMS    INVWIN   LSTJPB   NEWWIN
C>                               NXTWIN
C>    THIS ROUTINE IS CALLED BY: TRYBUMP  UFBINT
C>                               Normally not called by any application
C>                               programs (they should call UFBINT).
C>
      SUBROUTINE UFBRW(LUN,USR,I1,I2,IO,IRET)



      USE MODA_USRINT
      USE MODA_TABLES

      INCLUDE 'bufrlib.inc'

      COMMON /USRSTR/ NNOD,NCON,NODS(20),NODC(10),IVLS(10),KONS(10)
      COMMON /QUIET / IPRT

      CHARACTER*128 ERRSTR
      REAL*8       USR(I1,I2)

C----------------------------------------------------------------------
C----------------------------------------------------------------------

      IRET = 0

C  LOOP OVER COND WINDOWS
C  ----------------------

      INC1 = 1
      INC2 = 1

1     CALL CONWIN(LUN,INC1,INC2)
      IF(NNOD.EQ.0) THEN
         IRET = I2
         GOTO 100
      ELSEIF(INC1.EQ.0) THEN
         GOTO 100
      ELSE
         DO I=1,NNOD
         IF(NODS(I).GT.0) THEN
            INS2 = INC1
            CALL GETWIN(NODS(I),LUN,INS1,INS2)
            IF(INS1.EQ.0) GOTO 100
            GOTO 2
         ENDIF
         ENDDO
         IRET = -1
         GOTO 100
      ENDIF

C  LOOP OVER STORE NODES
C  ---------------------

2     IRET = IRET+1

      IF(IPRT.GE.2)  THEN
      CALL ERRWRT('++++++++++++++BUFR ARCHIVE LIBRARY+++++++++++++++++')
         WRITE ( UNIT=ERRSTR, FMT='(5(A,I7))' )
     .      'BUFRLIB: UFBRW - IRET:INS1:INS2:INC1:INC2 = ',
     .      IRET, ':', INS1, ':', INS2, ':', INC1, ':', INC2
         CALL ERRWRT(ERRSTR)
         KK = INS1
         DO WHILE ( ( INS2 - KK ) .GE. 5 )
            WRITE ( UNIT=ERRSTR, FMT='(5A10)' )
     .         (TAG(INV(I,LUN)),I=KK,KK+4)
            CALL ERRWRT(ERRSTR)
            KK = KK+5
         ENDDO
         WRITE ( UNIT=ERRSTR, FMT='(5A10)' )
     .      (TAG(INV(I,LUN)),I=KK,INS2)
         CALL ERRWRT(ERRSTR)
      CALL ERRWRT('++++++++++++++BUFR ARCHIVE LIBRARY+++++++++++++++++')
      CALL ERRWRT(' ')
      ENDIF

C  WRITE USER VALUES
C  -----------------

      IF(IO.EQ.1 .AND. IRET.LE.I2) THEN
         DO I=1,NNOD
         IF(NODS(I).GT.0) THEN
            IF(IBFMS(USR(I,IRET)).EQ.0) THEN
               INVN = INVWIN(NODS(I),LUN,INS1,INS2)
               IF(INVN.EQ.0) THEN
                  CALL DRSTPL(NODS(I),LUN,INS1,INS2,INVN)
                  IF(INVN.EQ.0) THEN
                     IRET = 0
                     GOTO 100
                  ENDIF
                  CALL NEWWIN(LUN,INC1,INC2)
                  VAL(INVN,LUN) = USR(I,IRET)
               ELSEIF(LSTJPB(NODS(I),LUN,'RPS').EQ.0) THEN
                  VAL(INVN,LUN) = USR(I,IRET)
               ELSEIF(IBFMS(VAL(INVN,LUN)).NE.0) THEN
                  VAL(INVN,LUN) = USR(I,IRET)
               ELSE
                  CALL DRSTPL(NODS(I),LUN,INS1,INS2,INVN)
                  IF(INVN.EQ.0) THEN
                     IRET = 0
                     GOTO 100
                  ENDIF
                  CALL NEWWIN(LUN,INC1,INC2)
                  VAL(INVN,LUN) = USR(I,IRET)
               ENDIF
            ENDIF
         ENDIF
         ENDDO
      ENDIF

C  READ USER VALUES
C  ----------------

      IF(IO.EQ.0 .AND. IRET.LE.I2) THEN
         DO I=1,NNOD
         USR(I,IRET) = BMISS
         IF(NODS(I).GT.0) THEN
            INVN = INVWIN(NODS(I),LUN,INS1,INS2)
            IF(INVN.GT.0) USR(I,IRET) = VAL(INVN,LUN)
         ENDIF
         ENDDO
      ENDIF

C  DECIDE WHAT TO DO NEXT
C  ----------------------

      IF(IO.EQ.1.AND.IRET.EQ.I2) GOTO 100
      CALL NXTWIN(LUN,INS1,INS2)
      IF(INS1.GT.0 .AND. INS1.LT.INC2) GOTO 2
      IF(NCON.GT.0) GOTO 1

C  EXIT
C  ----

100   RETURN
      END
