﻿uses OpenCL;
uses System;
uses System.Runtime.InteropServices;

const
  MatrW = 5000;
  
  VecByteSize = MatrW*8;
  MatrL = MatrW*MatrW;
  MatrByteSize = MatrL*8;
  
begin
  Randomize(0);
  var A := MatrRandomReal(MatrW,MatrW,0,1);
  var B := MatrRandomReal(MatrW,MatrW,0,1);
  
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
  
end.