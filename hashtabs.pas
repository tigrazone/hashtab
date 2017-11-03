unit hashtabs;

interface

type hvt=record val,idx:longword; end;
     tforeachproc=procedure(k,v:string);

	 hashtab=class(tobject)
	   private
	   procedure setl(l:longword);

     
    procedure sort_hv_del;
    procedure sort_hv_add(var idx_idx:longword);

     procedure rev_ordr;
		 function isexists1(key:string;before_unfinded:boolean=true):boolean;

	   public
		hash_val:array of hvt;
		keys:array of string;
		vals:array of string;
		ordr:array of longword;
		
		//srch - last find hashed
		total,lll,c,srch,iii:longword;
		
		//c == c, != h(то есть следующий за требуемым элемент) 1 3 8 12 15 при поиске 10 вернет 4 то есть элемент с значением 12
		//last_val - последнее значение сравниваемого элемента, hash_val[c].val / hash_val[h].val
		last_val:longword;

		constructor init;
		function isexists(key:string):boolean;
		procedure setval(key,val:string);
		function getval(key:string):string;
    procedure sort_keys;
    procedure sort_vals;
    procedure sort_keys_bk;
    procedure sort_vals_bk;
    procedure unset(key:string);
    procedure shhash;
    procedure foreach(tfp:tforeachproc;start:string='';stop:string='';goback:boolean=false);

	 end;

procedure show_key_val(k,v:string);

var showdebug:boolean=false;

implementation

const
  delta_arr=100;
  
var ______tmp:hashtab;

function started_from(s1,s2:string):boolean;
var i,i1,i2:longword;
begin
     i1:=length(s1);
     i2:=length(s2);
     result:=false;
     if i2>i1 then exit //length of substring > length of string
     else
       begin
            i1:=0;
            for i:=1 to i2 do
               if s1[i]=s2[i] then inc(i1) else break;
            if i1=i2 then result:=true;
       end;
end;


Function X31Hash(const s:string):LongWord;
var i,h:longword;
begin
  if length(s)<1 then
  begin
    result:=0;
    exit;
  end;

  h:=ord(s[1]);
  for i:=2 to length(s) do begin
    h:=(h shl 5) - h + ord(s[i]);
  end;

  result:=h;
end;


procedure hashtab.setl(l:longword);
begin
	 total:=l;
   if l>lll then begin
      lll:=l+delta_arr;
	    setlength(hash_val,lll);
	    setlength(keys,lll);
      setlength(vals,lll);
	    setlength(ordr,lll);
   end;
end;

//reverse ordr
procedure hashtab.rev_ordr;
var i,t:longword;
begin
     c:=total shr 1;
     for i:=0 to c-1 do begin
         t:=ordr[i];
         ordr[i]:=ordr[total-i-1];
         ordr[total-i-1]:=t;
     end;
end;


//вызывается всегда после удаления и после добавления элемента
//shall's sort hash_val by val
procedure hashtab.sort_hv_del;
var mx:longword;
    f:longint;
    h:hvt;
begin
      c:=total shr 1;
      while c>0 do begin
           mx:=1;
           while mx<=(total-c) do begin
                 f:=mx;
                 while f>0 do begin
	                   if hash_val[f-1].val>hash_val[f+c-1].val then begin
                        h:=hash_val[f-1];
                        hash_val[f-1]:=hash_val[f+c-1];
                        hash_val[f+c-1]:=h;
                     end;
                dec(f,c);
                end;
           inc(mx);
           end;
       c:=c shr 1;
       end;
end;


//del Можно и оставить, но add можно и
procedure hashtab.sort_hv_add(var idx_idx:longword);
var i:longword;
    h:hvt;
begin

       {
    sort_hv_del;
    Exit;
      }

	if idx_idx = 0 then exit;

	if idx_idx = 1 then begin
		if hash_val[0].val>hash_val[1].val then
		begin
			//переставить местами
			h:=hash_val[0];
			hash_val[0]:=hash_val[1];
			hash_val[1]:=h;
		end;
	end
	else
	begin

	  //после вставки элемента с индексом idx_idx, total++. [idx_idx] - последний вставленный
	  //с - c from last bin search (c если найдено, но у меня всегда не найдено и c = h, надо сдвинуть всех начиная с h на 1 элемент правее. место уже зарезервировано. в [h] записать новый хэш)

	  h:=hash_val[idx_idx];

	  for i:=idx_idx downto c-1 do hash_val[i]:=hash_val[i-1];

	  hash_val[c]:=h;
	end;

end;



//shall's sort keys - ordr
procedure hashtab.sort_keys;
var mx,i1,i2:longword;
    f:longint;
    h:longword;
begin
      c:=total shr 1;
      while c>0 do begin
           mx:=1;
           while mx<=(total-c) do begin
                 f:=mx;
                 while f>0 do begin
                     i1:=ordr[f-1];
                     i2:=ordr[f+c-1];
	                   if keys[i1]>keys[i2] then begin
                        h:=i1;
                        ordr[f-1]:=i2;
                        ordr[f+c-1]:=h;
                     end;
                dec(f,c);
                end;
           inc(mx);
           end;
       c:=c shr 1;
       end;
end;

//shall's sort vals - ordr
procedure hashtab.sort_vals;
var mx,i1,i2:longword;
    f:longint;
    h:longword;
begin
      c:=total shr 1;
      while c>0 do begin
           mx:=1;
           while mx<=(total-c) do begin
                 f:=mx;
                 while f>0 do begin
                     i1:=ordr[f-1];
                     i2:=ordr[f+c-1];
	                   if vals[i1]>vals[i2] then begin
                        h:=i1;
                        ordr[f-1]:=i2;
                        ordr[f+c-1]:=h;
                     end;
                dec(f,c);
                end;
           inc(mx);
           end;
       c:=c shr 1;
       end;
end;

//shall's sort vals descent - ordr
procedure hashtab.sort_vals_bk;
begin
     sort_vals;
     rev_ordr;
end;

//shall's sort keys descent - ordr
procedure hashtab.sort_keys_bk;
begin
     sort_keys;
     rev_ordr;
end;

constructor hashtab.init;
begin
	 total:=0;
   lll:=0;
end;

function hashtab.isexists(key:string):boolean;
var l,h,e:longword;
    fnd:boolean;
    s:string;
begin
   l:=0;h:=total-1;
   fnd:=false;
 
   //srch:=adler32s(key);
   srch:=X31Hash(key);

   if showdebug then begin
   writeln;
   writeln(key,' hash=',srch);
   end;
   if total>0 then
   begin
   e:=hash_val[l].val;
   if e=srch then begin fnd:=true;c:=l;end
   else begin  //binary search into hash_val's
	 repeat
	     c:=(l+h) shr 1;
		   e:=hash_val[c].val;
       if showdebug then writeln('c=',c,' e=',e);
		   if e>srch then h:=c
		   else
		   if e<srch then l:=c
		   else begin fnd:=true;break;end;
	 until ((h-l)<=1);
   end;
   if showdebug then writeln('fnd=',fnd);

	 if fnd then
	   begin
			fnd:=false;
			while (e=srch) and (c<=h) do begin
				  iii:=hash_val[c].idx;
				  if keys[iii]=key then begin fnd:=true; break; end;
				  inc(c);
				  e:=hash_val[c].val;
				  last_val:=hash_val[c].val;
			end;
	   end
     else begin
          c:=h;
          e:=hash_val[h].val;
          last_val:=hash_val[h].val;
          if e=srch then begin fnd:=true;iii:=h;		  
		  end
     end;
   end;
	 result:=fnd;
end;

function hashtab.isexists1(key:string;before_unfinded:boolean=true):boolean;
//before_unfinded - if we not find, find
//=true next after unfinded
//=false before next after unfinded - for find first element in group
var l,h,e:longword;
    fnd:boolean;
    s:string;
begin
   l:=0;h:=total-1;
   fnd:=false;
   
   //srch:=adler32s(key);
   srch:=X31Hash(key);

   if showdebug then begin
   writeln;
   writeln(key,' hash=',srch);
   end;
   if total>0 then
   begin
   e:=hash_val[l].val;
   if e=srch then begin fnd:=true;c:=l;end
   else begin  //binary search into hash_val's
	 repeat
	     c:=(l+h) shr 1;
		   e:=hash_val[c].val;
       if showdebug then writeln('c=',c,' e=',e);
		   if e>srch then h:=c
		   else
		   if e<srch then l:=c
		   else begin fnd:=true;break;end;
	 until ((h-l)<=1);
   end;
   if showdebug then writeln('fnd=',fnd);

	 if fnd then
	   begin
			fnd:=false;
			while (e=srch) and (c<=h) do begin
				  iii:=hash_val[c].idx;
				  if keys[iii]=key then begin fnd:=true; break; end;
				  inc(c);
				  e:=hash_val[c].val;
				  last_val:=hash_val[c].val;
			end;
	   end
     else begin
          e:=hash_val[h].val;    //maybe e?
		  last_val:=hash_val[h].val;
		  
          if e=srch then begin fnd:=true;iii:=hash_val[h].idx;end
          else begin //binary search into keys, keys must be sorted
          l:=0;h:=total-1;
          repeat
	           c:=(l+h) shr 1;
		         s:=keys[ordr[c]];
             if showdebug then writeln('c=',c,' s=',s);
		         if s>key then h:=c
		         else
		         if s<key then l:=c
		         else begin fnd:=true;break;end;
	        until ((h-l)<=1);
          if fnd then iii:=c else
            begin
                 iii:=h;
                 if showdebug then writeln('key=',key,' keys[',h,']=',keys[ordr[h]]);
                 if (keys[ordr[h]]>key) and before_unfinded then
                    begin
                         if h>0 then dec(iii);
                         if showdebug then writeln('h=',iii);
                    end;
            end;
          iii:=ordr[iii];
          if showdebug then writeln('s=',keys[iii]);
          end;
     end;
   end;
   if showdebug then writeln('e=',e,' iii=',iii);
	 result:=fnd;
end;

procedure hashtab.setval(key,val:string);
var i:longword;
heapstat: THeapStatus;
begin
	 if not isexists(key) then
	   begin
      i:=total;
	    setl(total+1);

			ordr[i]:=i;
			keys[i]:=key;
			hash_val[i].val:=srch;
			hash_val[i].idx:=i;
			sort_hv_add(i);
      iii:=i;
	   end;
   //writeln('seting [',key,'] to ',val,'...');
   {writeln('total=',total,' lll=',lll);
    heapstat:=GetHeapStatus;
 writeln('all free mem: ',heapstat.TotalFree,
 ' FreeSmall: ',heapstat.FreeSmall,
 ' FreeBig: ',heapstat.FreeBig); }
	 vals[iii]:=val;
end;

function hashtab.getval(key:string):string;
begin
	 if not isexists(key) then result:=''
	 else
		begin
			 result:=vals[iii];
	    end;
end;

procedure hashtab.unset(key:string);
var i,ikill,ilst,lst,tokill,aa,bb:longword;
begin
     if isexists(key) then
	    begin
			 ikill:=iii;
       ilst:=total-1;
       lst:=total;
	     tokill:=total;
       for i:=0 to ilst do
          if ordr[i]=ikill then begin tokill:=i;break; end;

       //ikill - индекс в keys
       //tokill - индекс в ordr
       //lst - в keys
       //ilst - в ordr

       for i:=tokill to ilst-1 do ordr[i]:=ordr[i+1];
       for i:=0 to ilst do
          if ordr[i]=ilst then begin lst:=i;break; end;
       if showdebug then writeln('ikill=',ikill,' ilst=',ilst,' lst=',lst,' tokill=',tokill);

       aa:=total;

       for i:=0 to total-1 do
           if hash_val[i].idx=ikill then begin aa:=i;break; end;

       hash_val[aa].val:=hash_val[total-1].val;
       keys[ikill]:=keys[ilst];
       vals[ikill]:=vals[ilst];
       dec(total);
       sort_hv_del;
       ordr[lst]:=ikill;
	    end;
end;

procedure hashtab.shhash;
var i:longword;
begin
      writeln;
      writeln('total=',total);
      writeln('keys & hashes:');

      //for i:=0 to total-1 do writeln (i,' ',keys[i],' ',adler32s(keys[i]));
      for i:=0 to total-1 do writeln (i,' ',keys[i],' ',x31hash(keys[i]));

      writeln('hash_val:');
      for i:=0 to total-1 do writeln(i,' val=',hash_val[i].val,' idx=',hash_val[i].idx);
end;

procedure hashtab.foreach(tfp:tforeachproc;start:string='';stop:string='';goback:boolean=false);
var i,i1,i2,i0,ii:longword;
begin
     //start and stop are '' - all array
     if (start=stop) and (start='') then begin i1:=0;i2:=total; end
     else
         begin
               //find 1st
               if isexists1(start,false) then ;
               i1:=iii;
               i0:=total;
               for i:=0 to total-1 do
                  if ordr[i]=i1 then begin i0:=i;break; end;
               i1:=i0;

               if start=stop then
                 begin  //one group, find end of group
                      i0:=0; //elements
                      for ii:=i1+1 to total-1 do
                         begin
                              if started_from(keys[ordr[ii]],stop) then inc(i0)
                              else break;
                         end;

                      if goback then //search backward?
                        begin
                             i:=0; //elements
                             for ii:=i1-1 downto 0 do
                                begin
                                     if started_from(keys[ordr[ii]],stop) then inc(i)
                                     else break;
                                end;
                             if i>i0 then i0:=ii;
                        end;
                      i2:=i1+i0;
                 end
               else
               if stop<>'' then
                 begin
                      if isexists1(stop) then ;
                      i2:=iii;
                      i0:=total;
                      for i:=0 to total-1 do
                         if ordr[i]=i2 then begin i0:=i;break; end;
                      i2:=i0;
                 end else i2:=total;
               {
               if i1>i2 then begin
                  i:=i1;
                  i1:=i2;
                  i2:=i;
               end;
               }
         end;

     if i2>=total then i2:=total-1;
     if i1>=total then i1:=total-1;
     if showdebug then writeln('i1=',i1,' i2=',i2);
     if i2>i1 then begin
        for i:=i1 to i2 do
           begin
                i0:=ordr[i];
                tfp(keys[i0],vals[i0]);
           end;
     end else
     begin
        for i:=i1 downto i2 do
           begin
                i0:=ordr[i];
                tfp(keys[i0],vals[i0]);
           end;
     end;
end;

procedure show_key_val(k,v:string);
begin
     writeln('[',k,']=>',v);
end;
end.
