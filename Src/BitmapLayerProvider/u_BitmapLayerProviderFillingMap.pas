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
{* http://sasgis.org                                                          *}
{* info@sasgis.org                                                            *}
{******************************************************************************}

unit u_BitmapLayerProviderFillingMap;

interface

uses
  Types,
  i_NotifierOperation,
  i_Bitmap32Static,
  i_Bitmap32BufferFactory,
  i_ProjectionInfo,
  i_CoordConverterFactory,
  i_TileStorage,
  i_MapVersionRequest,
  i_BitmapLayerProvider,
  i_FillingMapColorer,
  u_BaseInterfacedObject;

type
  TBitmapLayerProviderFillingMap = class(TBaseInterfacedObject, IBitmapTileUniProvider)
  private
    FBitmap32StaticFactory: IBitmap32StaticFactory;
    FProjectionFactory: IProjectionInfoFactory;
    FStorage: ITileStorage;
    FVersion: IMapVersionRequest;
    FUseRelativeZoom: Boolean;
    FZoom: Integer;
    FColorer: IFillingMapColorer;

    function GetActualProjection(
      const AProjection: IProjectionInfo
    ): IProjectionInfo;
    function GetFillingMapBitmap(
      AOperationID: Integer;
      const ACancelNotifier: INotifierOperation;
      const AProjection: IProjectionInfo;
      const AMapRect: TRect;
      const ASourceProjection: IProjectionInfo;
      const AVersion: IMapVersionRequest;
      const AColorer: IFillingMapColorer
    ): IBitmap32Static;
  private
    function GetTile(
      AOperationID: Integer;
      const ACancelNotifier: INotifierOperation;
      const AProjectionInfo: IProjectionInfo;
      const ATile: TPoint
    ): IBitmap32Static;
  public
    constructor Create(
      const ABitmap32StaticFactory: IBitmap32StaticFactory;
      const AProjectionFactory: IProjectionInfoFactory;
      const AStorage: ITileStorage;
      const AVersion: IMapVersionRequest;
      AUseRelativeZoom: Boolean;
      AZoom: Integer;
      const AColorer: IFillingMapColorer
    );
  end;

implementation

uses
  GR32,
  t_GeoTypes,
  i_CoordConverter,
  i_TileRect,
  i_TileIterator,
  i_TileInfoBasic,
  u_TileRect,
  u_GeoFunc,
  u_TileIteratorByRect,
  u_Bitmap32ByStaticBitmap;

{ TBitmapLayerProviderFillingMap }

constructor TBitmapLayerProviderFillingMap.Create(
  const ABitmap32StaticFactory: IBitmap32StaticFactory;
  const AProjectionFactory: IProjectionInfoFactory;
  const AStorage: ITileStorage;
  const AVersion: IMapVersionRequest;
  AUseRelativeZoom: Boolean;
  AZoom: Integer;
  const AColorer: IFillingMapColorer
);
begin
  Assert(Assigned(ABitmap32StaticFactory));
  Assert(Assigned(AProjectionFactory));
  Assert(Assigned(AStorage));
  Assert(Assigned(AVersion));
  Assert(Assigned(AColorer));
  inherited Create;
  FBitmap32StaticFactory := ABitmap32StaticFactory;
  FProjectionFactory := AProjectionFactory;
  FStorage := AStorage;
  FVersion := AVersion;
  FUseRelativeZoom := AUseRelativeZoom;
  FZoom := AZoom;
  FColorer := AColorer;
end;

function TBitmapLayerProviderFillingMap.GetActualProjection(
  const AProjection: IProjectionInfo
): IProjectionInfo;
var
  VConverter: ICoordConverter;
  VZoom: Integer;
  VResultZoom: Byte;
begin
  VConverter := AProjection.GeoConverter;
  VZoom := FZoom;
  if FUseRelativeZoom then begin
    VZoom := VZoom + AProjection.Zoom;
  end;
  if VZoom < 0 then begin
    Result := FProjectionFactory.GetByConverterAndZoom(VConverter, 0);
  end else begin
    VResultZoom := VZoom;
    VConverter.ValidateZoom(VResultZoom);
    Result := FProjectionFactory.GetByConverterAndZoom(VConverter, VResultZoom);
  end;
end;

function TBitmapLayerProviderFillingMap.GetTile(
  AOperationID: Integer;
  const ACancelNotifier: INotifierOperation;
  const AProjectionInfo: IProjectionInfo;
  const ATile: TPoint
): IBitmap32Static;
var
  VSourceProjection: IProjectionInfo;
begin
  VSourceProjection := GetActualProjection(AProjectionInfo);
  if AProjectionInfo.Zoom > VSourceProjection.Zoom then begin
    Result := nil;
  end else begin
    Result :=
      GetFillingMapBitmap(
        AOperationID,
        ACancelNotifier,
        AProjectionInfo,
        AProjectionInfo.GeoConverter.TilePos2PixelRect(ATile, AProjectionInfo.Zoom),
        VSourceProjection,
        FVersion,
        FColorer
      );
  end;
end;

function TBitmapLayerProviderFillingMap.GetFillingMapBitmap(
  AOperationID: Integer;
  const ACancelNotifier: INotifierOperation;
  const AProjection: IProjectionInfo;
  const AMapRect: TRect;
  const ASourceProjection: IProjectionInfo;
  const AVersion: IMapVersionRequest;
  const AColorer: IFillingMapColorer
): IBitmap32Static;
var
  VBitmap: TBitmap32ByStaticBitmap;
  VSize: TPoint;
  VSourceTileRect: TRect;
  VSourceRelativeRect: TDoubleRect;
  VSourceConverter: ICoordConverter;
  VTargetConverter: ICoordConverter;
  VSameSourceAndTarget: Boolean;
  VSourceZoom: Byte;
  VTargetZoom: Byte;
  VLonLatRect: TDoubleRect;
  VIterator: ITileIterator;
  VRelativeRectOfTile: TDoubleRect;
  VLonLatRectOfTile: TDoubleRect;
  VSolidDrow: Boolean;
  VTileRectInfo: ITileRectInfo;
  VEnumTileInfo: IEnumTileInfo;
  VTileInfo: TTileInfo;
  VMapPixelRectOfTile: TDoubleRect;
  VLocalPixelRectOfTile: TRect;
  VTileColor: TColor32;
  VTileRect: ITileRect;
begin
  VBitmap := TBitmap32ByStaticBitmap.Create(FBitmap32StaticFactory);
  try
    VSize := Types.Point(AMapRect.Right - AMapRect.Left, AMapRect.Bottom - AMapRect.Top);
    VBitmap.SetSize(VSize.X, VSize.Y);
    VBitmap.Clear(0);

    VSourceConverter := FStorage.CoordConverter;
    VTargetConverter := AProjection.GeoConverter;
    VTargetZoom := AProjection.Zoom;
    VSourceZoom := ASourceProjection.Zoom;

    VSameSourceAndTarget := VSourceConverter.IsSameConverter(VTargetConverter);
    if VSameSourceAndTarget then begin
      VSourceRelativeRect := VSourceConverter.PixelRect2RelativeRect(AMapRect, VTargetZoom);
    end else begin
      VLonLatRect := VTargetConverter.PixelRect2LonLatRect(AMapRect, VTargetZoom);
      VSourceConverter.ValidateLonLatRect(VLonLatRect);
      VSourceRelativeRect := VSourceConverter.LonLatRect2RelativeRect(VLonLatRect);
    end;
    VSourceTileRect :=
      RectFromDoubleRect(
        VSourceConverter.RelativeRect2TileRectFloat(VSourceRelativeRect, VSourceZoom),
        rrOutside
      );
    VSolidDrow :=
      (VSize.X <= (VSourceTileRect.Right - VSourceTileRect.Left) * 2) or
      (VSize.Y <= (VSourceTileRect.Bottom - VSourceTileRect.Top) * 2);
    VTileRectInfo := FStorage.GetTileRectInfo(AOperationID, ACancelNotifier, VSourceTileRect, VSourceZoom, AVersion);
    if ACancelNotifier.IsOperationCanceled(AOperationID) then begin
      Result := nil;
      Exit;
    end;

    if VTileRectInfo <> nil then begin
      VTileRect := TTileRect.Create(ASourceProjection, VSourceTileRect);
      VIterator := TTileIteratorByRect.Create(VTileRect);
      VEnumTileInfo := VTileRectInfo.GetEnum(VIterator);
      while VEnumTileInfo.Next(VTileInfo) do begin
        VTileColor := AColorer.GetColor(VTileInfo);
        if VTileColor <> 0 then begin
          if VSameSourceAndTarget then begin
            VRelativeRectOfTile := VSourceConverter.TilePos2RelativeRect(VTileInfo.FTile, VSourceZoom);
          end else begin
            VLonLatRectOfTile := VSourceConverter.TilePos2LonLatRect(VTileInfo.FTile, VSourceZoom);
            VTargetConverter.ValidateLonLatRect(VLonLatRectOfTile);
            VRelativeRectOfTile := VTargetConverter.LonLatRect2RelativeRect(VLonLatRectOfTile);
          end;
          VMapPixelRectOfTile := VTargetConverter.RelativeRect2PixelRectFloat(VRelativeRectOfTile, VTargetZoom);
          VLocalPixelRectOfTile.Left := Trunc(VMapPixelRectOfTile.Left - AMapRect.Left);
          VLocalPixelRectOfTile.Top := Trunc(VMapPixelRectOfTile.Top - AMapRect.Top);
          VLocalPixelRectOfTile.Right := Trunc(VMapPixelRectOfTile.Right - AMapRect.Left);
          VLocalPixelRectOfTile.Bottom := Trunc(VMapPixelRectOfTile.Bottom - AMapRect.Top);
          if not VSolidDrow then begin
            Dec(VLocalPixelRectOfTile.Right);
            Dec(VLocalPixelRectOfTile.Bottom);
          end;
          VBitmap.FillRectS(VLocalPixelRectOfTile, VTileColor);
        end;
      end;
    end;
    Result := VBitmap.MakeAndClear;
  finally
    VBitmap.Free;
  end;
end;

end.
