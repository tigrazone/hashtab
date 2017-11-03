program filltest;

{$APPTYPE CONSOLE}

uses
  hashtabs,SysUtils;

const z='01234567890abcdefghijklmnopqrstuvwxyz';
total_els = 10000000; //10m
//total_els = 20;

var _post:hashtab;
    i,ii,j,a:longword;
    k,v:string;
    heapstat: THeapStatus;
    tim1,tim2,tim3:tTimeStamp;


procedure show_keys_vals;
begin
 writeln('i ordr[i] key val:');
 for i:=0 to _post.total-1 do begin
  ii:=_post.ordr[i];
 writeln('[',i,'] ',ii,' [',_post.keys[ii],']=>',_post.vals[ii]);
 end;
end;

begin
  _post:=hashtab.init;
  ii:=length(z);
  tim1:=DateTimeToTimeStamp(Time);
  
 heapstat:=GetHeapStatus;
 writeln('all free mem: ',heapstat.TotalFree,
 ' FreeSmall: ',heapstat.FreeSmall,
 ' FreeBig: ',heapstat.FreeBig);

 a:=0;
 tim1:=DateTimeToTimeStamp(Time);
 tim2:=tim1;
 while a<=total_els do begin
    a:=a+1;

    i:=random(10)+1;//êîëè÷ ñèìâîëîâ â êëþ÷å
    k:='';
    //for j:=1 to i do k:=k+z[random(ii)+1];
    str(a,k);
    i:=random(50)+1;//êîëè÷ ñèìâîëîâ â çíà÷åíèè
    v:='';
    for j:=1 to i do v:=v+z[random(ii)+1];

     _post.setval(k,v);
    if a mod 100=0 then begin writeln(a);
    tim3:=tim2;
    tim2:=DateTimeToTimeStamp(Time);
    writeln('delta time ',(tim2.time-tim3.time),' total time ',(tim3.time-tim1.time));
    heapstat:=GetHeapStatus;
 writeln('all free mem: ',heapstat.TotalFree,
 ' FreeSmall: ',heapstat.FreeSmall,
 ' FreeBig: ',heapstat.FreeBig);
 writeln('total=',_post.total,' lll=',_post.lll);
    end;
 end;

 readln;
 
 show_keys_vals;
 readln;
 _post.sort_vals;

 show_keys_vals;
 readln;
end.
