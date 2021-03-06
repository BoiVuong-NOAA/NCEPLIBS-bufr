C> @file
C> @author WOOLLEN @date 1998-07-08
      
C> THIS FUNCTION CONVERTS AN EIGHT DIGIT INTEGER DATE
C>   (YYMMDDHH) TO TEN DIGITS (YYYYMMDDHH) USING THE Y2K "WINDOWING"
C>   TECHNIQUE.  ALL TWO-DIGIT YEARS GREATER THAN "40" ARE ASSUMED TO
C>   HAVE A FOUR-DIGIT YEAR BEGINNING WITH "19" (1941-1999) AND ALL TWO-
C>   DIGIT YEARS LESS THAN OR EQUAL TO "40" ARE ASSUMED TO HAVE A FOUR-
C>   DIGIT YEAR BEGINNING WITH "20" (2000-2040).  IF THE INPUT DATE IS
C>   ALREADY TEN DIGITS, THIS ROUTINE JUST RETURNS ITS VALUE.
C>
C> PROGRAM HISTORY LOG:
C> 1998-07-08  J. WOOLLEN -- ORIGINAL AUTHOR
C> 1998-11-24  J. WOOLLEN -- MODIFIED TO CONFORM TO THE NCEP 2-DIGIT
C>                           YEAR TIME WINDOW OF 1921-2020 (BUT
C>                           INADVERTENTLY SET TO 1911-2010)
C> 1998-12-14  J. WOOLLEN -- MODIFIED TO USE 20 AS THE 2-DIGIT YEAR FOR
C>                           WINDOWING TO A 4-DIGIT YEAR (00-20 ==> ADD
C>                           2000; 21-99 ==> ADD 1900), THIS WINDOWING
C>                           TECHNIQUE WAS INADVERTENTLY CHANGED TO 10
C>                           IN THE PREVIOUS IMPLEMENTATION OF I4DY
C>                           (1998-11-24)
C> 2003-11-04  S. BENDER  -- ADDED REMARKS/BUFRLIB ROUTINE
C>                           INTERDEPENDENCIES
C> 2003-11-04  D. KEYSER  -- MODIFIED DATE CALCULATIONS TO NO LONGER USE
C>                           FLOATING POINT ARITHMETIC SINCE THIS CAN
C>                           LEAD TO ROUND OFF ERROR AND AN IMPROPER
C>                           RESULTING DATE ON SOME MACHINES (E.G.,
C>                           NCEP IBM FROST/SNOW), INCREASES
C>                           PORTABILITY; UNIFIED/PORTABLE FOR WRF;
C>                           ADDED DOCUMENTATION (INCLUDING HISTORY)
C> 2018-06-29  J. ATOR    -- CHANGED 2-DIGIT->4-DIGIT YEAR WINDOW RANGE 
C>                           TO (00-40 ==> ADD 2000; 41-99 ==> ADD 1900)
C>
C> USAGE:    I4DY (IDATE)
C>   INPUT ARGUMENT LIST:
C>     IDATE    - INTEGER: DATE (EITHER YYMMDDHH OR YYYYMMDDHH),
C>                DEPENDING ON DATELEN() VALUE 
C>
C>   OUTPUT ARGUMENT LIST:
C>     I4DY     - INTEGER: DATE (YYYYMMDDHH)
C>
C> REMARKS:
C>    THIS ROUTINE CALLS:        None
C>    THIS ROUTINE IS CALLED BY: CKTABA   CMSGINI  DATEBF   DUMPBF
C>                               IUPBS01  OPENMB   OPENMG   REWNBF 
C>                               Also called by application programs.
C>
      FUNCTION I4DY(IDATE)



      IF(IDATE.LT.10**8) THEN
         IY = IDATE/10**6
         IF(IY.GT.40) THEN
            I4DY = IDATE + 19*100000000
         ELSE
            I4DY = IDATE + 20*100000000
         ENDIF
      ELSE
         I4DY = IDATE
      ENDIF

      RETURN
      END
