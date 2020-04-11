unit generators;

interface 

function generator(arr: array of integer): function(): integer;


implementation

type
  __Generator_class = class
    arr: array of integer;
    index: integer;
    
    function next(): integer;
    begin
      result := arr[index];
      index += 1;
      if index = arr.Length then
        index := 0;
    end;
  
  end;
  
function generator(arr: array of integer): function(): integer;
begin
  var obj := new __Generator_class;
  obj.arr := arr;
  obj.index := 0;
  Result := obj.next;
end;

begin
end.