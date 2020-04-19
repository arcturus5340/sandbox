// Память выделяется динамически через создание объекта класса System.Array
// Обращение к памяти производится встроенным геттером, но в качестве 
// цикла используется конструкция while ... do ... 
begin
    
  var arr := new byte[16];
//  IL_0001:  ldc.i4.s   16
//  IL_0003:  newarr     [mscorlib]System.Byte
//  IL_0008:  stloc.0

  var index := 0;
//  IL_0009:  ldc.i4.0
//  IL_000a:  stloc.1

  while index < 16 do
//  IL_000b:  ldloc.1
//  IL_000c:  ldc.i4.s   16
//  IL_000e:  clt
//  IL_0010:  brfalse    IL_0024
    begin
    arr[index] := index;
//  IL_0016:  ldloc.0
//  IL_0017:  ldloc.1
//  IL_0018:  ldloc.1
//  IL_0019:  conv.u1
//  IL_001a:  stelem.i1
    index += 1;
//  IL_001b:  ldloc.1
//  IL_001c:  ldc.i4.1
//  IL_001d:  add
//  IL_001e:  stloc.1

//  IL_001f:  br         IL_000b
    end;
//  IL_0024:  ret
end.