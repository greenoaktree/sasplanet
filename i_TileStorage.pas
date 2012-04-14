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

unit i_TileStorage;

interface

uses
  Classes,
  GR32,
  i_BinaryData,
  i_OperationNotifier,
  i_TileRectUpdateNotifier,
  i_MapVersionInfo,
  i_StorageState,
  i_TileInfoBasic,
  i_FillingMapColorer,
  i_TileStorageInfo;

type
  ITileStorage = interface
    ['{80A0246E-68E0-4EA0-9B0F-3338472FDB3C}']
    function GetInfo: ITileStorageInfo;
    property Info: ITileStorageInfo read GetInfo;

    function GetNotifierByZoom(AZoom: Byte): ITileRectUpdateNotifier;
    property NotifierByZoom[AZoom: Byte]: ITileRectUpdateNotifier read GetNotifierByZoom;

    function GetState: IStorageStateChangeble;
    property State: IStorageStateChangeble read GetState;

    function GetTileFileName(
      const AXY: TPoint;
      Azoom: byte;
      const AVersion: IMapVersionInfo
    ): string;
    function GetTileInfo(
      const AXY: TPoint;
      Azoom: byte;
      const AVersion: IMapVersionInfo
    ): ITileInfoBasic;

    function LoadTile(
      const AXY: TPoint;
      Azoom: byte;
      const AVersionInfo: IMapVersionInfo;
      out ATileInfo: ITileInfoBasic
    ): IBinaryData;
    function DeleteTile(
      const AXY: TPoint;
      Azoom: byte;
      const AVersion: IMapVersionInfo
    ): Boolean;
    function DeleteTNE(
      const AXY: TPoint;
      Azoom: byte;
      const AVersion: IMapVersionInfo
    ): Boolean;
    procedure SaveTile(
      const AXY: TPoint;
      Azoom: byte;
      const AVersion: IMapVersionInfo;
      const AData: IBinaryData
    );
    procedure SaveTNE(
      const AXY: TPoint;
      Azoom: byte;
      const AVersion: IMapVersionInfo
    );
  end;


implementation

end.
