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

unit u_MapLayerGridsConfig;

interface

uses
  i_MapLayerGridsConfig,
  u_ConfigDataElementComplexBase;

type
  TMapLayerGridsConfig = class(TConfigDataElementComplexBase, IMapLayerGridsConfig)
  private
    FTileGrid: ITileGridConfig;
    FGenShtabGrid: IGenShtabGridConfig;
    FDegreeGrid: IDegreeGridConfig;
  protected
    function GetTileGrid: ITileGridConfig;
    function GetGenShtabGrid: IGenShtabGridConfig;
    function GetDegreeGrid: IDegreeGridConfig;
  public
    constructor Create;
  end;

implementation

uses
  u_ConfigSaveLoadStrategyBasicProviderSubItem,
  u_TileGridConfig,
  u_GenShtabGridConfig,
  u_DegreeGridConfig;

{ TMapLayerGridsConfig }

constructor TMapLayerGridsConfig.Create;
begin
  inherited;
  FTileGrid := TTileGridConfig.Create;
  Add(FTileGrid, TConfigSaveLoadStrategyBasicProviderSubItem.Create('TileGrid'));
  FGenShtabGrid := TGenShtabGridConfig.Create;
  Add(FGenShtabGrid, TConfigSaveLoadStrategyBasicProviderSubItem.Create('GenShtabGrid'));
  FDegreeGrid := TDegreeGridConfig.Create;
  Add(FDegreeGrid, TConfigSaveLoadStrategyBasicProviderSubItem.Create('DegreeGrid'));
end;

function TMapLayerGridsConfig.GetGenShtabGrid: IGenShtabGridConfig;
begin
  Result := FGenShtabGrid;
end;

function TMapLayerGridsConfig.GetDegreeGrid: IDegreeGridConfig;
begin
  Result := FDegreeGrid;
end;

function TMapLayerGridsConfig.GetTileGrid: ITileGridConfig;
begin
  Result := FTileGrid;
end;

end.
