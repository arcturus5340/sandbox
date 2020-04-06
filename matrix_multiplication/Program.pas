uses OpenCL;
uses NumLibABC;
uses System;
uses System.Runtime.InteropServices;

const
  MatrW = 1000;
  
  VecByteSize = MatrW*8;
  MatrL = MatrW*MatrW;
  MatrByteSize = MatrL*8;

var
  A: array [,] of real;
  B: array [,] of real;
  B_transposed: array [,] of real;
  C: array [,] of real;
  C_thread: array [,] of real;  
  
procedure ThMatrMul(obj: object); 
begin
  var data := integer(obj);
  for var j := 0 to MatrW-1 do
  begin  
     var cc := 0.0;
     for var l := 0 to MatrW-1 do
        cc += A[data, l]*B_transposed[j, l];
     C_thread[data, j] := cc;   
  end;
end;   
  
begin
  Randomize(0);
  A := MatrRandomReal(MatrW, MatrW, 0, 1);
  B := MatrRandomReal(MatrW, MatrW, 0, 1);
  
  var opencl_init_start := Milliseconds;
  var ec: ErrorCode;
  
  // Инициализация
  var platform: cl_platform_id;
  cl.GetPlatformIDs(1, platform, IntPtr.Zero).RaiseIfError;
  var device: cl_device_id;
  cl.GetDeviceIDs(platform, DeviceType.DEVICE_TYPE_DEFAULT, 1, device, IntPtr.Zero).RaiseIfError;
//  cl.GetDeviceIDs(platform, DeviceType.DEVICE_TYPE_ALL, 1,device,IntPtr.Zero).RaiseIfError;


  var context := cl.CreateContext(nil, 1, device, nil, IntPtr.Zero, ec);
  ec.RaiseIfError;
  
  var command_queue := cl.CreateCommandQueueWithProperties(context, device, nil, ec);
  ec.RaiseIfError;
  
  // Чтение и компиляция .cl файла
  {$resource Program.cl}
  var prog_str := System.IO.StreamReader.Create(
    System.Reflection.Assembly.GetCallingAssembly.GetManifestResourceStream('Program.cl')
  ).ReadToEnd;
  var prog := cl.CreateProgramWithSource(
    context,
    1,
    new string[](prog_str),
    nil,
    ec
  );
  ec.RaiseIfError;
  
  cl.BuildProgram(prog, 1,device, nil, nil, IntPtr.Zero).RaiseIfError;
  
  var MatrMltMatrKernel := cl.CreateKernel(prog, 'MatrMltMatr', ec);
  ec.RaiseIfError;
  
  // Подготовка параметров
  var A_buf := cl.CreateBuffer(context, MemFlags.MEM_READ_WRITE, new UIntPtr(MatrByteSize),IntPtr.Zero, ec);
  ec.RaiseIfError;
  cl.EnqueueWriteBuffer(command_queue, A_buf, Bool.BLOCKING, new UIntPtr(0),new UIntPtr(MatrByteSize), A[0,0], 0,nil,IntPtr.Zero).RaiseIfError;
  
  var B_buf := cl.CreateBuffer(context, MemFlags.MEM_READ_WRITE, new UIntPtr(MatrByteSize),IntPtr.Zero, ec);
  ec.RaiseIfError;
  cl.EnqueueWriteBuffer(command_queue, B_buf, Bool.BLOCKING, new UIntPtr(0),new UIntPtr(MatrByteSize), B[0,0], 0,nil,IntPtr.Zero).RaiseIfError;
  
  var C_buf := cl.CreateBuffer(context, MemFlags.MEM_READ_WRITE, new UIntPtr(MatrByteSize),IntPtr.Zero, ec);
  ec.RaiseIfError;
  
  var MatrWParam := MatrW;
  var W_buf := cl.CreateBuffer(context, MemFlags.MEM_READ_WRITE or MemFlags.MEM_USE_HOST_PTR, new UIntPtr(sizeof(integer)),new IntPtr(@MatrWParam), ec);
  ec.RaiseIfError;
  
  // Выполнение C := A*B
  cl.SetKernelArg(MatrMltMatrKernel, 0, new UIntPtr(UIntPtr.Size), A_buf).RaiseIfError;
  cl.SetKernelArg(MatrMltMatrKernel, 1, new UIntPtr(UIntPtr.Size), B_buf).RaiseIfError;
  cl.SetKernelArg(MatrMltMatrKernel, 2, new UIntPtr(UIntPtr.Size), C_buf).RaiseIfError;
  cl.SetKernelArg(MatrMltMatrKernel, 3, new UIntPtr(UIntPtr.Size), W_buf).RaiseIfError;
  
  var opencl_init_end := Milliseconds;
  println(format('Инициализация OpenCl: {0} сек', (opencl_init_end-opencl_init_start)/1000));
  var opencl_start := Milliseconds;
  
  var k1_ev: cl_event;
  cl.EnqueueNDRangeKernel(command_queue, MatrMltMatrKernel, 2, nil, new UIntPtr[](new UIntPtr(MatrW),new UIntPtr(MatrW)),nil, 0,nil,k1_ev).RaiseIfError;

  // Чтение и вывод результата
  cl.EnqueueReadBuffer(command_queue, C_buf,  Bool.BLOCKING, new UIntPtr(0), new UIntPtr(MatrByteSize), A[0,0], 1,k1_ev,IntPtr.Zero).RaiseIfError;
  var opencl_end := Milliseconds;
  println(format('Время работы OpenCl: {0} сек', (opencl_end-opencl_start)/1000));
  println;
  
  var numlib_init_start := Milliseconds;
  var numlib_A := new NumLibABC.Matrix(A);
  var numlib_B := new NumLibABC.Matrix(B);
  var numlib_init_end := Milliseconds;
  println(format('Инициализация матриц NumLibABC: {0} сек', (numlib_init_end-numlib_init_start)/1000));
  
  var numlib_start := Milliseconds;
  var C_numlib := numlib_A * numlib_B;
  var numlib_end := Milliseconds;
  println(format('Время работы матриц NumLibABC: {0} сек', (numlib_end-numlib_start)/1000));
  println;
  
  var openmp_init_start := Milliseconds;
  var C_openmp := new real[MatrW, MatrW];
  B_transposed := new real[MatrW, MatrW];
  {$omp parallel for }
  for var i:=0 to MatrW-1 do
    for var j:=0 to MatrW-1 do
      B_transposed[i, j] := B[i, j];
    
  var openmp_init_end := Milliseconds;
  println(format('Инициализация OpenMP: {0} сек', (openmp_init_end-openmp_init_start)/1000));
  var openmp_start := Milliseconds;
      
  {$omp parallel for }
  for var i := 0 to MatrW-1 do
    for var j := 0 to i-1 do
      Swap(B_transposed[i,j], b_transposed[j,i]);
  {$omp parallel for }
  for var i:=0 to MatrW-1 do
    for var j:=0 to MatrW-1 do
    begin  
       var cc := 0.0;
       for var l:=0 to MatrW-1 do
          cc += A[i,l]*B_transposed[j,l];
       C_openmp[i,j] := cc;   
    end;

  var openmp_end := Milliseconds;
  println(format('Время работы OpenMP: {0} сек', (openmp_end-openmp_start)/1000));
  println;

  var thread_init_start := Milliseconds;
  B_transposed := new real[MatrW, MatrW];
  for var i:=0 to MatrW-1 do
    for var j:=0 to MatrW-1 do
      B_transposed[i, j] := B[i, j];
  C_thread := new real[MatrW, MatrW];
  
  var thread_array := new System.Threading.Thread[MatrW];
  for var index := 0 to MatrW-1 do
    thread_array[index] := new System.Threading.Thread(() -> ThMatrMul(index));
        
  var thread_init_end := Milliseconds;
  println(format('Инициализация System.Threading: {0} сек', (thread_init_end-thread_init_start)/1000));
  var thread_start := Milliseconds;
  
  for var index := 0 to MatrW-1 do
    thread_array[index].Start();
  
  for var index := 0 to MatrW-1 do
    thread_array[index].Join();
  
  var thread_end := Milliseconds;
  println(format('Время работы System.Threading: {0} сек', (thread_end-thread_start)/1000));
  println;
  
end.