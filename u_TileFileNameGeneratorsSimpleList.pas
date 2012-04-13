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

{
  ��� ������ ������ �����. ������ ��������� ������� ����� ��������� �� �������.
}
unit u_TileFileNameGeneratorsSimpleList;

interface

uses
  i_TileFileNameGenerator,
  u_GlobalCahceConfig,
  i_TileFileNameGeneratorsList;

type
  TTileFileNameGeneratorsSimpleList = class(TInterfacedObject, ITileFileNameGeneratorsList)
  private
    FGlobalCacheConfig: TGlobalCahceConfig;
    FItems: array of ITileFileNameGenerator;
  public
    constructor Create(AGlobalCacheConfig: TGlobalCahceConfig);
    destructor Destroy; override;
    function GetGenerator(CacheType: Byte): ITileFileNameGenerator;
  end;

implementation

uses
  u_TileFileNameSAS,
  u_TileFileNameGMV,
  u_TileFileNameES,
  u_TileFileNameGM1,
  u_TileFileNameGM2;

{ TTileFileNameGeneratorsSimpleList }

constructor TTileFileNameGeneratorsSimpleList.Create(
  AGlobalCacheConfig: TGlobalCahceConfig
);
begin
  FGlobalCacheConfig := AGlobalCacheConfig;
  SetLength(FItems, 5);
  FItems[0] := TTileFileNameGMV.Create;
  FItems[1] := TTileFileNameSAS.Create;
  FItems[2] := TTileFileNameES.Create;
  FItems[3] := TTileFileNameGM1.Create;
  FItems[4] := TTileFileNameGM2.Create;
end;

destructor TTileFileNameGeneratorsSimpleList.Destroy;
var
  i: integer;
begin
  for i := 0 to Length(FItems) - 1 do begin
    FItems[i] := nil;
  end;
  FItems := nil;
  inherited;
end;

function TTileFileNameGeneratorsSimpleList.GetGenerator(
  CacheType: Byte): ITileFileNameGenerator;
var
  VCacheType: Byte;
begin
  if CacheType = 0 then begin
    VCacheType := FGlobalCacheConfig.DefCache;
  end else begin
    VCacheType := CacheType;
  end;
  case VCacheType of
    c_File_Cache_Id_GMV:
    begin
      Result := FItems[0];
    end;
    c_File_Cache_Id_SAS:
    begin
      Result := FItems[1];
    end;
    c_File_Cache_Id_ES:
    begin
      Result := FItems[2];
    end;
    c_File_Cache_Id_GM:
    begin
      Result := FItems[3];
    end;
    c_File_Cache_Id_GM_Aux:
    begin
      Result := FItems[4];
    end;
  else begin
    Result := FItems[3]; // as for GM
  end;
  end;
end;

end.
 