{******************************************************************************}
{* SAS.Planet (SAS.�������)                                                   *}
{* Copyright (C) 2007-2011, SAS.Planet development team.                      *}
{* This program is free software: you can redistribute it and/or modify       *}
{* it under the terms of the GNU General Public License as published by       *}
{* the Free Software Foundation, either version 3 of the License, or          *}
{* (at your option) any later version.                                        *}
{*                                                                            *}
{* This program is distributed in the hope that it will be useful,            *}
{* but WITHOUT ANY WARRANTY; without even the implied warranty of             *}
{* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *}
{* GNU General Public License for more details.                               *}
{*                                                                            *}
{* You should have received a copy of the GNU General Public License          *}
{* along with this program.  If not, see <http://www.gnu.org/licenses/>.      *}
{*                                                                            *}
{* http://sasgis.ru                                                           *}
{* az@sasgis.ru                                                               *}
{******************************************************************************}

unit u_BmpUtil;

interface

uses
  i_OperationNotifier;

type
  TBGR= record
   b,g,r:byte;
  end;

  PlineRGBb = ^TlineRGBb;
  TlineRGBb = array[0..0] of TBGR;

  TBMPRead = procedure(Line:cardinal;InputArray:PLineRGBb) of object;

  procedure SaveBMP(
    AOperationID: Integer;
    ACancelNotifier: IOperationNotifier;
    W, H : integer;
    tPath : string;
    readcallback:TBMPRead
  );

implementation

type
  bmFileHeader = record	{��������� �����}
    //Typf : word;        {��������� }
    Size : longint;     {����� ����� � ������}
    Res1 : word;        {���������������}
    Res2 : word;        {���������������}
    OfBm : longint;     {�������� ����������� � ������ (1078) = $36}
  end;
  bmInfoHeader = record   {�������������� ���������}
    Size : longint;       {����� ��������� � ������ (40) = $28}
    Widt : longint;       {������ ����������� (� ������)}
    Heig : longint;       {������ ����������� (� ������)}
    Plan : word;          {����� ���������� (1)}
    BitC : word;          {������� ����� (��� �� �����) (8)}
    Comp : longint;       {��� ���������� (0 - ���)}
    SizI : longint;       {������ ����������� � ������}
    XppM : longint;       {�������������� ����������}
 		          {(����� �� ���� - ������ 0)}
    YppM : longint;       {������������ ����������}
		          {(����� �� ���� - ������ 0)}
    NCoL : longint;       {����� ������}
		          {(���� ����������� ���������� - 0)}
    NCoI : longint;       {����� �������� ������}
  end;
  bmHeader = record       {������ ��������� �����}
    f : bmFileHeader;     {��������� �����}
    i : bmInfoHeader;     {�������������� ���������}
    //p : array[0..255,0..3]of byte; {������� �������}
  end;

function SaveBMPHeader(filename:string;W : longint;H : longint): bmHeader;
begin
   Result.i.Size:=$28; //40;
   Result.i.Widt:=W;
   Result.i.Heig:=H;
   Result.i.Plan:=1;
   Result.i.BitC:=$18;    // ���������� ������ 24
   Result.i.Comp:=0;

   Result.i.SizI:=W * H * 3 + (W mod 4)*H;// ������ �������
   Result.i.XppM:=0;
   Result.i.YppM:=0;
   Result.i.NCoL:=0;
   Result.i.NCoI:=0;

   Result.f.Res1:=0;
   Result.f.Res2:=0;
   Result.f.OfBm:=$36;        // $36 = 54  // �������� ������� �� ������ �����
   Result.f.Size:=Result.i.SizI + Result.f.OfBm;   // ������ ������ �����
end;

procedure SaveBMP(
  AOperationID: Integer;
  ACancelNotifier: IOperationNotifier;
  W, H : integer;
  tPath : string;
  readcallback:TBMPRead
);  // ������ �� ���� �����
Var f : file;
    nNextLine: integer;
    InputArray:PlineRGBb;
    TypeBmp:Word;
    Header: bmHeader;
  BMPRead:TBMPRead;
begin
   Header:=SaveBMPHeader(tPath,W,H);
   AssignFile(f,tPath);
   ReWrite(f,1);
   TypeBmp  := $4D42;

   BlockWrite(f,TypeBmp,sizeof(TypeBmp));
   BlockWrite(f,Header,sizeof(Header));

   BMPRead:=readcallback;
   getmem(InputArray,W*3);

   for nNextLine:=0 to h-1 do begin
     if ACancelNotifier.IsOperationCanceled(AOperationID) then begin
       break;
     end;
     BMPRead(nNextLine,InputArray);
     seek(f,(h-nNextLine-1)*(W*3+ (w mod 4) )+54);
     BlockWrite(f,InputArray^,(W*3+ (w mod 4) ));
    end;

   FreeMem(InputArray);
   CloseFile(F);
end;

end.

