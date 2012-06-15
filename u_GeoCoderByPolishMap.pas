{******************************************************************************}
{* SAS.Planet (SAS.�������)                                                   *}
{* Copyright (C) 2007-2012, SAS.Planet development team.                      *}
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

unit u_GeoCoderByPolishMap;

interface

uses
  Classes,
  sysutils,
  i_OperationNotifier,
  i_LocalCoordConverter,
  u_GeoCoderLocalBasic;

type
  EGeoCoderERR = class(Exception);
  EDirNotExist = class(EGeoCoderERR);

  TGeoCoderByPolishMap = class(TGeoCoderLocalBasic)
  private
    FLock: IReadWriteSync;
  procedure SearchInMapFile(
   const ACancelNotifier: IOperationNotifier;
   AOperationID: Integer;
   const AFile : string ;
   const ASearch : widestring;
   Alist : IInterfaceList;
   var Acnt : integer
   );
  protected
    function DoSearch(
      const ACancelNotifier: IOperationNotifier;
      AOperationID: Integer;
      const ASearch: WideString
    ): IInterfaceList; override;

  public
  constructor Create();
  end;

implementation

uses
  ActiveX,
  windows,
  StrUtils,
  t_GeoTypes,
  i_GeoCoder,
  i_BinaryData,
  i_StringlistStatic,
  u_ResStrings,
  u_GeoCodePlacemark,
  u_GeoCodeResult,
  u_BinaryDataByMemStream,
  u_StringListStatic,
  u_GeoToStr;

{ TGeoCoderByPolishMap }

function getType(
  const Asection:string;
  const Atype:integer
  ):string;
begin
result := '';
if ASection = 'POI' then begin
case AType of
$0100: result := '��������� (����� 10 ���.)';
$0200: result := '��������� (5-10 ���.)';
$0300: result := '������� ����� (2-5 ���.)';
$0400: result := '������� ����� (1-2 ���.)';
$0500: result := '������� ����� (0.5-1 ���.)';
$0600: result := '����� (200-500 ���.)';
$0700: result := '����� (100-200 ���.)';
$0800: result := '����� (50-100 ���.)';
$0900: result := '����� (20-50 ���.)';
$0a00: result := '����� (10-20 ���.)';
$0b00: result := '��������� ����� (5-10 ���.)';
$0c00: result := '��������� ����� (2-5 ���.)';
$0d00: result := '��������� ����� (1-2 ���.)';
$0e00: result := '������� (500-1000)';
$0f00: result := '������� (200-500)';
$1000: result := '������� (100-200)';
$1100: result := '������� (����� 100)';
$1200: result := '�������� � ���������������';
$1400: result := '�������� �������� �����������';
$1500: result := '�������� ������ �����������';
$1e00: result := '�������� �������, ���������, �����';
$1f00: result := '�������� ������, ������';
$2800: result := '�������';
$1c00: result := '������ ��������';
$1c01: result := '������� ���������������';
$1c02: result := '����������� �������, �������';
$1c03: result := '����������� �������, �� �������';
$1c04: result := '�������, ��������� ������';
$1c05: result := '��������, ������� ��� ������� ����';
$1c06: result := '�������� �� ������ ����';
$1c07: result := '�������� ���� ������ ����';
$1c08: result := '��������, ��������� ������';
$1c09: result := '���� �� ������ ����';
$1c0a: result := '��������� ����';
$1c0b: result := '����';
$1d00: result := '���������� ��������';
$2000: result := '����� � �����';
$2100: result := '����� � ����� � ���������������';
$210F: result := '����� � �������';
$2200: result := '����� � �������';
$2300: result := '����� � ��������';
$2400: result := '����� � ������� �������';
$2500: result := '����� �������';
$2600: result := '����� � ����������';
$2700: result := '����� � �����';
$2900: result := '������ �����������';
$2a00: result := '����������� �������';
$2a01: result := '�������� (������������ �����)';
$2a02: result := '�������� (��������� �����)';
$2a03: result := '�������� (������)';
$2a04: result := '�������� (��������� �����)';
$2a05: result := '�������� (����������, �����, ��������)';
$2a06: result := '�������� (����������������� �����)';
$2a07: result := '�������� �������� �������';
$2a08: result := '�������� (����������� �����)';
$2a09: result := '�������� (������������ �����)';
$2a0a: result := '��������';
$2a0b: result := '�������� (������������)';
$2a0c: result := '�������� (�����)';
$2a0d: result := '������� (������������ �������)';
$2a0e: result := '����';
$2a0f: result := '�������� (����������� �����)';
$2a10: result := '�������� (�������� �����)';
$2a11: result := '�������� (���������� ��������� �����)';
$2a12: result := '����������� ������� ��������';
$2b00: result := '���������';
$2b01: result := '����� ��� ������';
$2b02: result := '����� � ���������';
$2b03: result := '�������';
$2b04: result := '��������� �����, ��� ������';
$2c00: result := '������ ��������, ������';
$2c01: result := '����';
$2c02: result := '�����';
$2c03: result := '����������';
$2c04: result := '���������������������';
$2c05: result := '�����';
$2c06: result := '����/���';
$2c07: result := '�������/��������';
$2c08: result := '�������';
$2c09: result := '���';
$2c0a: result := '���������� ���';
$2c0b: result := '����/������/��������';
$2d00: result := '��������������� ���������';
$2d01: result := '�����';
$2d02: result := '���/������ ����';
$2d03: result := '���������';
$2d04: result := '������';
$2d05: result := '�����-����';
$2d06: result := '������ �����/������';
$2d07: result := '�������-�����';
$2d08: result := '�����';
$2d09: result := '�������';
$2d0a: result := '��������/������-�����';
$2d0b: result := '���������� ��������';
$2e00: result := '�������� ������';
$2e01: result := '���������';
$2e02: result := '����������������� �������';
$2e03: result := '�������� �����';
$2e04: result := '�������� �����';
$2e05: result := '������';
$2e06: result := '������ ������������� ������';
$2e07: result := '������';
$2e08: result := '������ ��� ���� � ����';
$2e09: result := '������';
$2e0a: result := '������������������ �������';
$2e0b: result := '����������/��';
$2f00: result := '������';
$2f01: result := '���';
$2f02: result := '������ �����������';
$2f03: result := '����������';
$2f04: result := '����������';
$2f05: result := '�������� ���������';
$2f06: result := '����';
$2f07: result := '�����������';
$2f08: result := '�������/��������� ��������� ����������';
$2f09: result := '������ �����, �������, ���';
$2f0a: result := '��������� ������, ���������';
$2f0b: result := '�����������';
$2f0c: result := '���� ������, ���������� ��� ��������';
$2f0d: result := '��������';
$2f0e: result := '���������';
$2f0f: result := '����� ����� Garmin';
$2f10: result := '������ ���� (���������, ���������)';
$2f11: result := '������-������';
$2f12: result := '����� �����';
$2f13: result := '���� �������';
$2f14: result := '�����';
$2f15: result := '������������ ������';
$2f16: result := '������� ����������';
$2f17: result := '��������� ������������� ����������';
$3000: result := '��������������� ��� ���������� ������';
$3001: result := '��������� �������';
$3002: result := '��������';
$3003: result := '�����';
$3004: result := '���';
$3005: result := '��������� ��� ���������� ������������ �����������';
$3006: result := '����������� �����';
$3007: result := '��������������� ����������';
$3008: result := '�������� �����';
$4000: result := '�����-����';
$4100: result := '����� ��� �������';
$4200: result := '�������, ���������';
$4300: result := '�������� ��� ���';
$4400: result := '���';
$4500: result := '��������';
$4600: result := '���';
$4700: result := '�������� ������';
$4800: result := '�������';
$4900: result := '����';
$4a00: result := '����� ��� �������';
$4b00: result := '��������';
$4c00: result := '����������';
$4d00: result := '�����������';
$4e00: result := '������';
$4f00: result := '���';
$5000: result := '�������� ����';
$5100: result := '�������';
$5200: result := '�������� ���';
$5300: result := '������ ����';
$5400: result := '����� ��� �������';
$5500: result := '�����, �������';
$5600: result := '��������� ����';
$5700: result := '������� ����';
$5800: result := '������������ ������';
$5900: result := '��������';
$5901: result := '������� ��������';
$5902: result := '������� ��������';
$5903: result := '����� ��������';
$5904: result := '����������� ��������';
$5905: result := '��������';
$5a00: result := '������������ �����';
$5b00: result := '�������';
$5c00: result := '����� ��� ��������';
$5d00: result := '������� ���� (������ �������)';
$5e00: result := '������� ���� (������� �����������)';
$6000: result := '����������������';
$6100: result := '���';
$6200: result := '������� �������';
$6300: result := '������� ������';
$6400: result := '������������� ����������';
$6401: result := '����';
$6402: result := '������';
$6403: result := '��������';
$6404: result := '����/������/��������';
$6405: result := '������������ ������';
$6406: result := '�����������, ���������, �������';
$6407: result := '�������';
$6408: result := '��������';
$6409: result := '�������, ����������';
$640a: result := '���������';
$640b: result := '������� ������';
$640c: result := '�����, ������';
$640d: result := '������������� �����';
$640e: result := '����';
$640f: result := '�����';
$6410: result := '�����';
$6411: result := '�����, �����';
$6412: result := '������ �����';
$6413: result := '������/��������� �������';
$6414: result := '�������� ����, ������, �������';
$6415: result := '����������� �����';
$6416: result := '����������';
$6500: result := '������ �����������';
$6501: result := '������, �������� �����';
$6502: result := '�������� ������';
$6503: result := '�����';
$6504: result := '�������� ����';
$6505: result := '������������� �����';
$6506: result := '������';
$6507: result := '�����';
$6508: result := '�������';
$6509: result := '������';
$650a: result := '������';
$650b: result := '������';
$650c: result := '������';
$650d: result := '�����';
$650e: result := '������';
$650f: result := '�������������';
$6510: result := '����';
$6511: result := '������';
$6512: result := '�����';
$6513: result := '������';
$6600: result := '��������� �������� ������';
$6601: result := '����';
$6602: result := '�����, �������';
$6603: result := '���������';
$6604: result := '�����';
$6605: result := '������, �����';
$6606: result := '���';
$6607: result := '����';
$6608: result := '������';
$6609: result := '�����';
$660a: result := '���';
$660b: result := '������, ��������';
$660c: result := '����� ������';
$660d: result := '��������';
$660e: result := '����';
$660f: result := '�����, �������';
$6610: result := '�������';
$6611: result := '�����';
$6612: result := '����������';
$6613: result := '������';
$6614: result := '�����';
$6615: result := '�����';
$6616: result := '������� ����� ��� ����';
$6617: result := '������';
$6618: result := '���';
$1600: result := '����';
$1601: result := '�������� �����';
$1602: result := '���������';
$1603: result := '��������';
$1604: result := '������� ���� (������� �����������)';
$1605: result := '������� ���� (������ �������)';
$1606: result := '������� ���� (����� ����)';
$1607: result := '������������ ���� �����';
$1608: result := '������������ ���� �������';
$1609: result := '������������ ���� ������';
$160a: result := '������������ ���� ������';
$160b: result := '������������ ���� ������';
$160c: result := '������������ ���� ��������';
$160d: result := '������������ ���� ������������';
$160e: result := '���������� ����';
$160f: result := '���������� ���� �����';
$1610: result := '���������� ���� �������';
$1611: result := '���������� ���� ������';
$1612: result := '���������� ���� ������';
$1613: result := '���������� ���� ���������';
$1614: result := '���������� ���� ����������';
$1615: result := '���������� ���� �����';
$1616: result := '���������� ���� ������������';
end;
   end else
if ASection = 'POLYGON' then begin
 case AType of
 $01: result := '�����c��� ��������� (>200 ��)';
 $02: result := '�����c��� ��������� (<200 ��)';
 $03: result := '��������� ��������� ����';
 $04: result := '������� ����';
 $05: result := '�����������';
 $06: result := '������';
 $07: result := '��������';
 $08: result := '����� ��� ��������';
 $09: result := '��������';
 $0a: result := '���������� ������������ ��� ��������';
 $0b: result := '��������';
 $0c: result := '������������ ����';
 $0d: result := '����������, ����������';
 $0e: result := '�������-���������� ������';
 $13: result := '������, ������������� ����������';
 $14: result := '������������ ����';
 $15: result := '������������ ����';
 $16: result := '������������ ����';
 $17: result := '��������� ����';
 $18: result := '���� ��� ������';
 $19: result := '���������� ��������';
 $1a: result := '��������';
 $1e: result := '��������������� ����';
 $1f: result := '��������������� ����';
 $20: result := '��������������� ����';
 $28: result := '����/�����';
 $29: result := '�����';
 $32: result := '����';
 $3b: result := '�����';
 $3c: result := '����� ������� (250-600 ��2)';
 $3d: result := '����� ������� (77-250 ��2)';
 $3e: result := '����� ������� (25-77 ��2)';
 $3f: result := '����� ������� (11-25 ��2)';
 $40: result := '����� ����� (0.25-11 ��2)';
 $41: result := '����� ����� (<0.25 ��2)';
 $42: result := '����� ������� (>3.3 �.��2)';
 $43: result := '����� ������� (1.1-3.3 �.��2)';
 $44: result := '����� ������� (0.6-1.1 �.��2)';
 $45: result := '�����';
 $46: result := '���� ������� (>1 ��)';
 $47: result := '���� ������� (200 �-1 ��)';
 $48: result := '���� ������� (40-200 �)';
 $49: result := '���� ����� (<40 �)';
 $4a: result := '������� ��������� �����';
 $4b: result := '������� �������� �����';
 $4c: result := '������������ ���� ��� �����';
 $4d: result := '������';
 $4e: result := '��������� ��� ��� ������';
 $4f: result := '���������';
 $50: result := '���';
 $51: result := '������';
 $52: result := '������';
 $53: result := '������';
 end end else
if ASection = 'POLYLINE' then begin
 case AType of
 $00: result := '������';
 $01: result := '��������������';
 $02: result := '����� ��������';
 $03: result := '������ ���������� ������';
 $04: result := '��������� ����������';
 $05: result := '����� �������';
 $06: result := '����� �����';
 $07: result := '��������, ����������������� ������';
 $08: result := '��������� ����� � �����������';
 $09: result := '��������� ����� � ����������� ����������';
 $0a: result := '��������� ������';
 $0b: result := '�������������� �����';
 $0c: result := '�������� ��������';
 $16: result := '�����, �����';
 $14: result := '�������� ������';
 $1a: result := '�����';
 $1b: result := '�����';
 $19: result := '������� �������� �����';
 $1e: result := '������������� �������';
 $1c: result := '������� �������';
 $1d: result := '������� ������, ������';
 $15: result := '��������� �����';
 $18: result := '�����';
 $1f: result := '����';
 $26: result := '������������ ����, ����� ��� ������';
 $20: result := '����������� ���������������';
 $21: result := '����������� ��������';
 $22: result := '����������� ����������';
 $23: result := '������� ���������������';
 $24: result := '������� ��������';
 $25: result := '������� ����������';
 $27: result := '�������-���������� ������';
 $28: result := '�����������';
 $29: result := '����� ���������������';
 $2a: result := '������� �������';
 $2b: result := '������� ���������';
 end;
end;
end;
function ItemExist(
  AValue:IGeoCodePlacemark;
  AList:igeocoderesult
  ):boolean;
var
i: Cardinal;
skip : boolean;
VPlacemark: IGeoCodePlacemark;
VEnum: IEnumUnknown;
j : integer;
str1,str2 : string;
begin
 skip := false;
 venum := Alist.GetPlacemarks;
 i := 0;
  while (VEnum.Next(1, VPlacemark, @i) = S_OK )and( skip = false )do
  begin
   j:= posex(')',VPlacemark.GetAddress);
   str1 := copy(VPlacemark.GetAddress,j,length(VPlacemark.GetAddress)-(j+1));
   j:= posex(')',Avalue.GetAddress);
   str2 := copy(Avalue.GetAddress,j,length(Avalue.GetAddress)-(j+1));
   if str1=str2 then
    if
      abs(VPlacemark.GetPoint.x-avalue.GetPoint.x) +
      abs(VPlacemark.GetPoint.Y-avalue.GetPoint.Y) < 0.05  then
    skip := true
  end;
result := skip;
end;

procedure TGeoCoderByPolishMap.SearchInMapFile(
  const ACancelNotifier: IOperationNotifier;
  AOperationID: Integer;
  const AFile : string ;
  const ASearch : widestring;
  Alist : IInterfaceList;
  var Acnt : integer
  );
var
 VFormatSettings : TFormatSettings;
 VPlace : IGeoCodePlacemark;
 VPoint : TDoublePoint;
 slat, slon, sname, sdesc, sfulldesc : string;
 VLinkErr : boolean;
 i, j, k, l: integer;
 VStr: string;
 VSearch : widestring;
 VTemplist : TStringlist;
 VCityList : IStringListStatic;
 Vcity : string;

 V_SectionType,
 V_Label,
 V_CityName,
 V_RegionName,
 V_StreetDesc,
 V_HouseNumber,
 V_CountryName : string;
 V_Type : integer;
 Skip: boolean;
 VStream: TFileStream;
begin
 V_Type := -1;
 VFormatSettings.DecimalSeparator := '.';
 VSearch := AnsiUpperCase(ASearch);
 FLock.BeginRead;
 try
  VStream := TFileStream.Create(AFile, fmOpenRead);
   try
    SetLength(Vstr,VStream.Size);
    VStream.ReadBuffer(VStr[1],VStream.Size);
   finally
   VStream.Free;
   end;
  finally
  FLock.EndRead;
 end;
  Vstr := AnsiUpperCase(Vstr);

  i := PosEx('[CITIES]', VStr);
  k :=  PosEx('[END', VStr, i);
  VTempList := TStringList.Create;
  VTemplist.Clear;
  while (PosEx('CITY', VStr, i) > i) and (k > i) do begin
   j := i;
   i := PosEx('CITY', VStr, j);
   i := PosEx('=', VStr, i);
   j := PosEx(#$D#$A+'REGIONIDX', VStr, i);
   sname := (Copy(VStr, i + 1, j - (i + 1)));
   VTemplist.add(sname);
  end;// ��������� ������ �������, ���� ��� ������ � ������ �����
  if ACancelNotifier.IsOperationCanceled(AOperationID) then begin
    Exit;
  end;
  if VTemplist.Count>0 then VCityList := TStringListStatic.CreateWithOwn(VTemplist);
  // ���� ���������, ����� ����� ����� �� ������ �����
  if k=0 then i:=1 else i := k;
  VSearch := 'LABEL='+VSearch;
  while (PosEx(VSearch, VStr, i)>i) {and (i>0) }do begin
    VLinkErr := false;
    i := PosEx(VSearch, VStr, i);
    k := PosEx('[END]', VStr, i); // ����� ����� ��������� ������.
    l := i;
    while (copy(Vstr,l,1)<>'[') and (l>0) do dec(l); // ������ ����� � ���������� �������

    i := PosEx(']', VStr, l);
    if i>0 then begin
     if i<k then begin
       V_SectionType := Copy(Vstr, l + 1, i - (l + 1));
      end else
       V_SectionType := '';
    end;

     i := PosEx('LABEL=' , VStr, l);
     if (i>0) then
      if (i<k) then begin
       j := PosEx(#$D#$A , VStr, i);
       V_Label := Copy(VStr, i+6 , j - (i+6));
       V_Label := ReplaceStr(V_Label,'~[0X1F]',' ');
      end else
     V_Label := '';

      i := PosEx('CITYIDX=', VStr, l);
      if i>0 then
      if i<k then begin
       j := PosEx(#$D#$A , VStr, i);
       vcity := Copy(Vstr, i + 8, j - (i + 8));
       if  strtoint(vcity)<VCityList.Count then
       V_CityName := VCityList.items[strtoint(vcity)-1]
       else V_CityName := '';
      end else
      V_CityName := '';

      i := PosEx('CITYNAME=', VStr, l);
      if i>0 then begin
       if i<k then begin
       j := PosEx(#$D#$A , VStr, i);
       V_CityName := Copy(Vstr, i + 9, j - (i + 9));
       end else
       V_CityName := '';
      end;

      i := PosEx('REGIONNAME=', VStr, l);
      if i<k then begin
       j := PosEx(#$D#$A , VStr, i);
       V_RegionName := Copy(Vstr, i + 11, j - (i + 11));
      end else
      V_RegionName := '';

      i := PosEx('COUNTRYNAME=', VStr, l);
      if i>0 then
      if i<k then begin
       j := PosEx(#$D#$A , VStr, i);
       V_CountryName := Copy(Vstr, i + 12, j - (i + 12));
      end else
      V_CountryName := '';

      i := PosEx('TYPE=', VStr, l);
      if i>0 then
      if i<k then begin
       j := PosEx(#$D#$A , VStr, i);
       V_Type := strtoint(Copy(Vstr, i + 5, j - (i + 5)));
      end else
      V_Type  := -1;

      i := PosEx('STREETDESC=', VStr, l);
      if i>0 then
      if i<k then begin
       j := PosEx(#$D#$A , VStr, i);
       V_StreetDesc := Copy(Vstr, i + 11, j - (i + 11));
      end else
      V_StreetDesc  := '';

      i := PosEx('HOUSENUMBER=', VStr, l);
      if i>0 then
      if i<k then begin
       j := PosEx(#$D#$A , VStr, i);
       V_HouseNumber := Copy(Vstr, i + 12, j - (i + 12));
      end else
      V_HouseNumber := '';

      i := PosEx('DATA', VStr, l);
      i := PosEx('(', VStr, i);
      j := PosEx(',', VStr, i);
      slat := Copy(Vstr, i + 1, j - (i + 1));
      i := PosEx(')', VStr, i);
      slon := Copy(Vstr, j + 1, i - (j + 1));

    if (slat='') or (slon='') then VLinkErr := true;
    if V_Label='' then VLinkErr := true;
    if Acnt mod 5 =0 then
     if ACancelNotifier.IsOperationCanceled(AOperationID) then
       Exit;

    if VLinkErr <> true then begin
     try
       VPoint.Y := StrToFloat(slat, VFormatSettings);
       VPoint.X := StrToFloat(slon, VFormatSettings);
     except
       raise EParserError.CreateFmt(SAS_ERR_CoordParseError, [slat, slon]);
     end;
      sdesc := '';
      sname := inttostr(Acnt)+') '+V_Label;
      if V_Type<> -1 then sdesc := getType(V_SectionType,V_Type)+ #$D#$A;
      if V_CountryName <> '' then sdesc := sdesc + V_CountryName + ', ' else sdesc := '';
      if V_RegionName <> '' then sdesc := sdesc + V_RegionName;
      if V_CityName <> '' then sdesc := sdesc + #$D#$A+ V_CityName ;
      if sdesc <> '' then sdesc := sdesc + #$D#$A;
      sdesc := sdesc + '[ ' + slon + ' , ' + slat + ' ]';
      sdesc := sdesc + #$D#$A + ExtractFileName(AFile);
      sfulldesc :=  ReplaceStr( sname + #$D#$A+ sdesc,#$D#$A,'<br>');

      if V_HouseNumber <>'' then sname := inttostr(Acnt)+') '+V_StreetDesc+' �'+V_HouseNumber;
      VPlace := TGeoCodePlacemark.Create(VPoint, sname, sdesc, sfulldesc, 4);

      V_Label := '';
      V_CityName := '';
      V_RegionName := '';
      V_StreetDesc := '';
      V_HouseNumber := '';
      V_CountryName := '';
      V_Type := -1;

      // ���� �������������� ������� �� �� ����� ������������� ���������� ���������� ���������
      skip := ItemExist(Vplace,TGeoCodeResult.Create(VSearch, 200, '', AList));
      if skip = false then
       begin
        inc(Acnt);
        AList.Add(VPlace);
       end;
    end;
    i:=k;
  end;
end;

constructor TGeoCoderByPolishMap.Create();
begin
   inherited Create;
   if not DirectoryExists(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))+'userdata\mp')) then
    raise EDirNotExist.Create('not found .\userdata\mp\! skip GeoCoderByPolishMap');
  FLock := TMultiReadExclusiveWriteSynchronizer.Create;
end;

function TGeoCoderByPolishMap.DoSearch(
  const ACancelNotifier: IOperationNotifier;
  AOperationID: Integer;
  const ASearch: WideString
  ): IInterfaceList;
var
VList: IInterfaceList;
vpath : string;
Vcnt : integer;
VFolder: string;
SearchRec: TSearchRec;
MySearch : string;
begin
 Vcnt := 1;
 MySearch := Asearch;
 while PosEx('  ',MySearch)>0 do MySearch := ReplaceStr(MySearch,'  ',' ');
 VList := TInterfaceList.Create;
 VFolder := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))+'userdata\mp\');
 if FindFirst(VFolder + '*.mp', faAnyFile, SearchRec) = 0 then begin
  repeat
    if (SearchRec.Attr and faDirectory) = faDirectory then begin
      continue;
    end;
    vpath:= VFolder+SearchRec.Name;
    SearchInMapFile(ACancelNotifier, AOperationID, Vpath , MySearch, vlist , Vcnt);
    if ACancelNotifier.IsOperationCanceled(AOperationID) then begin
      Exit;
    end;
  until FindNext(SearchRec) <> 0;
 end;
 Result := VList;
end;
end.