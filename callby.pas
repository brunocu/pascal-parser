program exCallbyValue(input, output);
var
   a, b : integer;
procedure swap(x, y: integer);
var
   temp: integer;
begin
   temp := x;
   x:= y;
   y := temp
end;
begin
   a := 100;
   b := 200;
   writeln("Before swap, value of a : ", a );
   writeln("Before swap, value of b : ", b );
   swap(a, b);
   writeln("After swap, value of a : ", a );
   writeln("After swap, value of b : ", b )
end.