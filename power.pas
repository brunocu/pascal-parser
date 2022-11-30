PROGRAM sumofpowers(input, output);
VAR
  n, x, power, i, sum : integer;
BEGIN
  write("N = ");
  read(n);
sum := 1;
  FOR x := 1 TO n DO
    BEGIN
      power := 1;
      FOR i := 1 TO x DO
        power := power * x;
      sum := sum + power
    END;
    sum := sum - 1;
  writeln("Sum = ", sum)
END.