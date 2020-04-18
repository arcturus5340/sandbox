// Память выделяется динамически через создание объекта класса System.Array
// Обращение к памяти производится через указатели. Заголовок объекта
// затирается новыми данными. Фактически вместо выделяемой памяти под элементы 
// массива мы используем всю память, выделенную под объект

begin
    
  var tmp := new byte[16];
//  IL_0001:  ldc.i4.s   16
//  IL_0003:  newarr     [mscorlib]System.Byte
//  IL_0008:  stloc.0
  
  var tmp_ptr: ^integer := pointer(@tmp);
//  IL_0009:  ldloca.s   'tmp:2:13'
//  IL_000b:  dup
//  IL_000c:  ldind.ref
//  IL_000d:  call       valuetype [mscorlib]System.Runtime.InteropServices.GCHandle PABCSystem.PABCSystem::__FixPointer(object)
//  IL_0012:  pop
//  IL_0013:  stloc.1
  
  var arr_ptr: ^byte := pointer(tmp_ptr^);
//  IL_0014:  ldloc.1
//  IL_0015:  ldind.i4
//  IL_0016:  stloc.2  

  for var i := 0 to 15 do
//  IL_0018:  ldc.i4.0
//  IL_0019:  stloc.3
//  IL_001a:  ldc.i4.s   15
//  IL_001c:  stloc.s    '$tfr_1:8:12'
//  IL_001e:  ldc.i4.0
//  IL_001f:  stloc.3
//  IL_0020:  ldloc.3
//  IL_0021:  ldloc.s    '$tfr_1:8:12'
//  IL_0023:  cgt
//  IL_0025:  ldc.i4.0
//  IL_0026:  ceq
//  IL_0028:  brfalse    IL_004b
    begin
    var elem_ptr: ^byte := pointer(integer(arr_ptr)+i);
//  IL_002e:  ldloc.2
//  IL_002f:  ldloc.3
//  IL_0030:  add
//  IL_0031:  stloc.s    'elem_ptr:9:12'
    elem_ptr^ := i;
//  IL_0033:  ldloc.s    'elem_ptr:9:12'
//  IL_0035:  ldloc.3
//  IL_0036:  conv.u1
//  IL_0037:  stind.i1

//  IL_0038:  ldloc.3
//  IL_0039:  ldloc.s    '$tfr_1:8:12'
//  IL_003b:  clt
//  IL_003d:  brfalse    IL_004b
//  IL_0042:  ldloc.3
//  IL_0043:  ldc.i4.1
//  IL_0044:  add
//  IL_0045:  stloc.3
//  IL_0046:  br         IL_002d
    end;
//  IL_004b:  ret  
end.