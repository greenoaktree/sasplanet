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

unit u_ConfigDataProviderByIniFileSection;

interface

uses
  Classes,
  SysUtils,
  IniFiles,
  i_StringListStatic,
  i_BinaryData,
  i_ConfigDataProvider;

type
  TConfigDataProviderByIniFileSection = class(TInterfacedObject, IConfigDataProvider)
  protected
    FIniFile: TCustomIniFile;
    FSection: string;
    FParent: IConfigDataProvider;
    FFormatSettings: TFormatSettings;
    function GetSubItemSectionName(const AIdent: string): string;
  protected
    function GetSubItem(const AIdent: string): IConfigDataProvider; virtual;
    function ReadBinary(const AIdent: string): IBinaryData; virtual;
    function ReadString(const AIdent: string; const ADefault: string): string; virtual;
    function ReadInteger(const AIdent: string; const ADefault: Longint): Longint; virtual;
    function ReadBool(const AIdent: string; const ADefault: Boolean): Boolean; virtual;
    function ReadDate(const AIdent: string; const ADefault: TDateTime): TDateTime; virtual;
    function ReadDateTime(const AIdent: string; const ADefault: TDateTime): TDateTime; virtual;
    function ReadFloat(const AIdent: string; const ADefault: Double): Double; virtual;
    function ReadTime(const AIdent: string; const ADefault: TDateTime): TDateTime; virtual;

    function ReadSubItemsList: IStringListStatic;
    function ReadValuesList: IStringListStatic;
  public
    constructor Create(AIniFile: TCustomIniFile; ASection: string; AParent: IConfigDataProvider);
    destructor Destroy; override;
  end;


implementation

uses
  StrUtils,
  u_StringListStatic,
  u_BinaryDataByMemStream;

{ TConfigDataProviderByIniFileSection }

constructor TConfigDataProviderByIniFileSection.Create(AIniFile: TCustomIniFile;
  ASection: string; AParent: IConfigDataProvider);
begin
  FIniFile := AIniFile;
  FSection := ASection;
  FParent := AParent;
  FFormatSettings.DecimalSeparator := '.';
  FFormatSettings.DateSeparator := '.';
  FFormatSettings.ShortDateFormat := 'dd.MM.yyyy';
  FFormatSettings.TimeSeparator := ':';
  FFormatSettings.LongTimeFormat := 'HH:mm:ss';
  FFormatSettings.ShortTimeFormat := 'HH:mm:ss';
  FFormatSettings.ListSeparator := ';';
  FFormatSettings.TwoDigitYearCenturyWindow := 50;
end;

destructor TConfigDataProviderByIniFileSection.Destroy;
begin
  FIniFile := nil;
  FSection := '';
  FParent := nil;
  inherited;
end;

function TConfigDataProviderByIniFileSection.GetSubItemSectionName(
  const AIdent: string): string;
begin
  Result := FSection + '_' + AIdent;
end;

function TConfigDataProviderByIniFileSection.GetSubItem(
  const AIdent: string): IConfigDataProvider;
var
  VSectionName: string;
begin
  Result := nil;
  VSectionName := GetSubItemSectionName(AIdent);
  if FIniFile.SectionExists(VSectionName) then begin
    Result:= TConfigDataProviderByIniFileSection.Create(FIniFile, VSectionName, Self);
  end;
end;

function TConfigDataProviderByIniFileSection.ReadBinary(const AIdent: string): IBinaryData;
var
  VMemStream: TMemoryStream;
begin
  VMemStream := TMemoryStream.Create;
  try
    FIniFile.ReadBinaryStream(FSection, AIdent, VMemStream);
    Result := TBinaryDataByMemStream.CreateWithOwn(VMemStream);
    VMemStream := nil;
  finally
    VMemStream.Free;
  end;
end;

function TConfigDataProviderByIniFileSection.ReadBool(const AIdent: string;
  const ADefault: Boolean): Boolean;
begin
  Result := FIniFile.ReadBool(FSection, AIdent, ADefault);
end;

function TConfigDataProviderByIniFileSection.ReadDate(const AIdent: string;
  const ADefault: TDateTime): TDateTime;
var
  DateStr: string;
begin
  Result := ADefault;
  DateStr := FIniFile.ReadString(FSection, AIdent, '');
  if DateStr <> '' then
  try
    Result := StrToDate(DateStr, FFormatSettings);
  except
    on EConvertError do
      // Ignore EConvertError exceptions
    else
      raise;
  end;
end;

function TConfigDataProviderByIniFileSection.ReadDateTime(const AIdent: string;
  const ADefault: TDateTime): TDateTime;
var
  DateStr: string;
begin
  DateStr := FIniFile.ReadString(FSection, AIdent, '');
  Result := ADefault;
  if DateStr <> '' then
  try
    Result := StrToDateTime(DateStr, FFormatSettings);
  except
    on EConvertError do
      // Ignore EConvertError exceptions
    else
      raise;
  end;
end;

function TConfigDataProviderByIniFileSection.ReadFloat(const AIdent: string;
  const ADefault: Double): Double;
var
  FloatStr: string;
begin
  FloatStr := FIniFile.ReadString(FSection, AIdent, '');
  Result := ADefault;
  if FloatStr <> '' then
  try
    Result := StrToFloat(FloatStr, FFormatSettings);
  except
    on EConvertError do
      // Ignore EConvertError exceptions
    else
      raise;
  end;
end;

function TConfigDataProviderByIniFileSection.ReadInteger(const AIdent: string;
  const ADefault: Integer): Longint;
begin
  Result := FIniFile.ReadInteger(FSection, AIdent, ADefault);
end;

function TConfigDataProviderByIniFileSection.ReadString(const AIdent,
  ADefault: string): string;
begin
  Result := FIniFile.ReadString(FSection, AIdent, ADefault);
end;

function TConfigDataProviderByIniFileSection.ReadSubItemsList: IStringListStatic;
var
  VList: TStringList;
  i: Integer;
  VSection: string;
  VSectionLen: Integer;
  VcurSect: string;
  VCurSectLen: Integer;
begin
  VList := TStringList.Create;
  try
    FIniFile.ReadSections(VList);
    VcurSect := FSection + '_';
    VCurSectLen := Length(VcurSect);
    for i := VList.Count - 1 downto 0 do begin
      VSection := VList.Strings[i];
      VSectionLen := Length(VSection);
      if VSectionLen <= VCurSectLen then begin
        VList.Delete(i);
      end else if LeftStr(VSection, VCurSectLen) <> VcurSect then begin
        VList.Delete(i);
      end else begin
        VList.Strings[i] := RightStr(VSection, VCurSectLen - VSectionLen);
      end;
    end;
    Result := TStringListStatic.CreateWithOwn(VList);
    VList := nil;
  finally
    VList.Free;
  end;
end;

function TConfigDataProviderByIniFileSection.ReadTime(const AIdent: string;
  const ADefault: TDateTime): TDateTime;
var
  TimeStr: string;
begin
  TimeStr := FIniFile.ReadString(FSection, AIdent, '');
  Result := ADefault;
  if TimeStr <> '' then
  try
    Result := StrToTime(TimeStr, FFormatSettings);
  except
    on EConvertError do
      // Ignore EConvertError exceptions
    else
      raise;
  end;
end;

function TConfigDataProviderByIniFileSection.ReadValuesList: IStringListStatic;
var
  VList: TStringList;
begin
  VList := TStringList.Create;
  try
    FIniFile.ReadSection(FSection, VList);
    Result := TStringListStatic.CreateWithOwn(VList);
    VList := nil;
  finally
    VList.Free;
  end;
end;

end.
