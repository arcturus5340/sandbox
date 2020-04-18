// Память выделяется динамически через создание объекта класса System.Array
// Обращение к памяти производится через указатели
begin
  var arr := new byte[16];
//  IL_0001:  ldc.i4.s   16
//  IL_0003:  newarr     [mscorlib]System.Byte
//  IL_0008:  stloc.0
 
  var arr_ptr: ^byte := pointer(@arr[0]);
//  IL_0009:  ldloc.0
//  IL_000a:  dup
//  IL_000b:  call       valuetype [mscorlib]System.Runtime.InteropServices.GCHandle PABCSystem.PABCSystem::__FixPointer(object)
//  IL_0010:  pop
//  IL_0011:  ldc.i4.0
//  IL_0012:  ldelema    [mscorlib]System.Byte
//  IL_0017:  stloc.1

  for var i := 0 to 15 do
//  IL_0019:  ldc.i4.0
//  IL_001a:  stloc.2
//  IL_001b:  ldc.i4.s   15
//  IL_001d:  stloc.3
//  IL_001e:  ldc.i4.0
//  IL_001f:  stloc.2
//  IL_0020:  ldloc.2
//  IL_0021:  ldloc.3
//  IL_0022:  cgt
//  IL_0024:  ldc.i4.0
//  IL_0025:  ceq
//  IL_0027:  brfalse    IL_0047
    begin
    arr_ptr^ := i;
//  IL_002d:  ldloc.1
//  IL_002e:  ldloc.2
//  IL_002f:  conv.u1
//  IL_0030:  stind.i1
    arr_ptr := pointer(integer(arr_ptr) + 1);
//  IL_0031:  ldloc.1
//  IL_0032:  ldc.i4.1
//  IL_0033:  add
//  IL_0034:  stloc.1
  
//  IL_0035:  ldloc.2
//  IL_0036:  ldloc.3
//  IL_0037:  clt
//  IL_0039:  brfalse    IL_0047
//  IL_003e:  ldloc.2
//  IL_003f:  ldc.i4.1
//  IL_0040:  add
//  IL_0041:  stloc.2
//  IL_0042:  br         IL_002c
    end;
//  IL_0047:  ret  
end.