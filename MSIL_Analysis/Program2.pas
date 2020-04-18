// Память выделяется динамически через создание объекта класса System.Array
// Обращение к памяти производится встроенным геттером
begin
    
  var arr := new byte[16];
//  IL_0001:  ldc.i4.s   16
//  IL_0003:  newarr     [mscorlib]System.Byte
//  IL_0008:  stloc.0  
  
  for var i := 0 to 15 do
//  IL_000a:  ldc.i4.0
//  IL_000b:  stloc.1
//  IL_000c:  ldc.i4.s   15
//  IL_000e:  stloc.2
//  IL_000f:  ldc.i4.0
//  IL_0010:  stloc.1
//  IL_0011:  ldloc.1
//  IL_0012:  ldloc.2
//  IL_0013:  cgt
//  IL_0015:  ldc.i4.0
//  IL_0016:  ceq
//  IL_0018:  brfalse    IL_0034
  arr[i] := i;
//  IL_001d:  ldloc.0
//  IL_001e:  ldloc.1
//  IL_001f:  ldloc.1
//  IL_0020:  conv.u1
//  IL_0021:  stelem.i1
  
//  IL_0022:  ldloc.1
//  IL_0023:  ldloc.2
//  IL_0024:  clt
//  IL_0026:  brfalse    IL_0034
//  IL_002b:  ldloc.1
//  IL_002c:  ldc.i4.1
//  IL_002d:  add
//  IL_002e:  stloc.1
//  IL_002f:  br         IL_001d
//  IL_0034:  ret
end.