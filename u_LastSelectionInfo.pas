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

unit u_LastSelectionInfo;

interface

uses
  i_ConfigDataProvider,
  i_ConfigDataWriteProvider,
  i_LastSelectionInfo,
  i_VectorItemLonLat,
  i_VectorItemsFactory,
  u_ConfigDataElementBase;

type
  TLastSelectionInfo = class(TConfigDataElementBaseEmptySaveLoad, ILastSelectionInfo)
  private
    FVectorItemsFactory: IVectorItemsFactory;
    // ������� ���������� ��������� ��� ��������� � ��������.
    FPolygon: ILonLatPolygon;
    // �������, �� ������� ���� ��������� ���������
    FZoom: Byte;
  private
    function GetZoom: Byte;
    function GetPolygon: ILonLatPolygon;
    procedure SetPolygon(
      const ALonLatPolygon: ILonLatPolygon;
      AZoom: Byte
    );
  public
    constructor Create(const AVectorItemsFactory: IVectorItemsFactory);
  end;

implementation

uses
  u_ConfigProviderHelpers;

{ TLastSelectionInfo }

constructor TLastSelectionInfo.Create(const AVectorItemsFactory: IVectorItemsFactory);
begin
  inherited Create;
  FVectorItemsFactory := AVectorItemsFactory;
  FPolygon := AVectorItemsFactory.CreateLonLatPolygon(nil, 0);
  FZoom := 0;
end;

function TLastSelectionInfo.GetPolygon: ILonLatPolygon;
begin
  LockRead;
  try
    Result := FPolygon;
  finally
    UnlockRead;
  end;
end;

function TLastSelectionInfo.GetZoom: Byte;
begin
  LockRead;
  try
    Result := FZoom;
  finally
    UnlockRead;
  end;
end;

procedure TLastSelectionInfo.SetPolygon(
  const ALonLatPolygon: ILonLatPolygon;
  AZoom: Byte
);
begin
  LockWrite;
  try
    FPolygon := ALonLatPolygon;
    FZoom := AZoom;
    SetChanged;
  finally
    UnlockWrite;
  end;
end;

end.
