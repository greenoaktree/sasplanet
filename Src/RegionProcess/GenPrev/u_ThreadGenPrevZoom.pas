{******************************************************************************}
{* SAS.Planet (SAS.�������)                                                   *}
{* Copyright (C) 2007-2014, SAS.Planet development team.                      *}
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

unit u_ThreadGenPrevZoom;

interface

uses
  Types,
  SysUtils,
  Classes,
  t_Bitmap32,
  t_GeoTypes,
  i_NotifierOperation,
  i_RegionProcessProgressInfo,
  i_CoordConverterFactory,
  i_ContentTypeInfo,
  i_Bitmap32BufferFactory,
  i_GeometryProjectedFactory,
  i_GeometryLonLat,
  i_MapVersionRequest,
  i_ImageResamplerFactory,
  i_MapType,
  u_ThreadRegionProcessAbstract;

type
  TThreadGenPrevZoom = class(TThreadRegionProcessAbstract)
  private
    FIsReplace: boolean;
    FIsSaveFullOnly: boolean;
    FGenFormFirstZoom: boolean;
    FUsePrevTiles: boolean;
    FZooms: TByteDynArray;
    FContentType: IContentTypeInfoBitmap;
    FMapType: IMapType;
    FVersion: IMapVersionRequest;
    FResamplerFactory: IImageResamplerFactory;
    FProjectionFactory: IProjectionInfoFactory;
    FBitmapFactory: IBitmap32StaticFactory;
    FVectorGeometryProjectedFactory: IGeometryProjectedFactory;

    FTileInProc: integer;
    FBackGroundColor: TColor32;
  protected
    procedure ProcessRegion; override;
    procedure ProgressFormUpdateOnProgress(const AProcessed, AToProcess: Int64);
  public
    constructor Create(
      const AProgressInfo: IRegionProcessProgressInfoInternal;
      const AProjectionFactory: IProjectionInfoFactory;
      const AVectorItemsFactory: IGeometryProjectedFactory;
      const ABitmapFactory: IBitmap32StaticFactory;
      const AZooms: TByteDynArray;
      const APolygLL: IGeometryLonLatPolygon;
      const AContentType: IContentTypeInfoBitmap;
      const AMapType: IMapType;
      const AVersion: IMapVersionRequest;
      AReplace: boolean;
      Asavefull: boolean;
      AGenFormFirstZoom: boolean;
      AUsePrevTiles: boolean;
      ABackGroundColor: TColor32;
      const AResamplerFactory: IImageResamplerFactory
    );
  end;

implementation

uses
  GR32,
  i_CoordConverter,
  i_Bitmap32Static,
  i_ProjectionInfo,
  i_GeometryProjected,
  i_BinaryData,
  i_BitmapTileSaveLoad,
  i_TileInfoBasic,
  i_TileStorage,
  i_TileIterator,
  u_GeoFunc,
  u_BitmapFunc,
  u_ResStrings,
  u_TileIteratorByPolygon,
  u_TileIteratorByRect;

constructor TThreadGenPrevZoom.Create(
  const AProgressInfo: IRegionProcessProgressInfoInternal;
  const AProjectionFactory: IProjectionInfoFactory;
  const AVectorItemsFactory: IGeometryProjectedFactory;
  const ABitmapFactory: IBitmap32StaticFactory;
  const AZooms: TByteDynArray;
  const APolygLL: IGeometryLonLatPolygon;
  const AContentType: IContentTypeInfoBitmap;
  const AMapType: IMapType;
  const AVersion: IMapVersionRequest;
  AReplace: boolean;
  Asavefull: boolean;
  AGenFormFirstZoom: boolean;
  AUsePrevTiles: boolean;
  ABackGroundColor: TColor32;
  const AResamplerFactory: IImageResamplerFactory
);
begin
  inherited Create(
    AProgressInfo,
    APolygLL,
    Self.ClassName
  );
  if Length(AZooms) <= 1 then begin
    raise Exception.Create('�� ������� ������� ���������');
  end;
  FProjectionFactory := AProjectionFactory;
  FVectorGeometryProjectedFactory := AVectorItemsFactory;
  FBitmapFactory := ABitmapFactory;
  FIsReplace := AReplace;
  FIsSaveFullOnly := Asavefull;
  FGenFormFirstZoom := AGenFormFirstZoom;
  FUsePrevTiles := AUsePrevTiles;
  FZooms := AZooms;
  FTileInProc := 0;
  FContentType := AContentType;
  FMapType := AMapType;
  FVersion := AVersion;
  FResamplerFactory := AResamplerFactory;
  FBackGroundColor := ABackGroundColor;
end;

procedure TThreadGenPrevZoom.ProcessRegion;
var
  bmp_ex: TCustomBitmap32;
  i, VSubTileCount: integer;
  VSubTilesSavedCount: integer;
  VZoomPrev: Byte;
  VZoom: Byte;
  VTile: TPoint;
  VSubTile: TPoint;
  VGeoConvert: ICoordConverter;
  VProjection: IProjectionInfo;
  VTileIterators: array of ITileIterator;
  VTileIterator: ITileIterator;
  VZoomDelta: Integer;
  VRectOfSubTiles: TRect;
  VCurrentTilePixelRect: TRect;
  VRelativeRect: TDoubleRect;
  VSubTileBounds: TRect;
  VSubTileInTargetBounds: TRect;
  VSubTileIterator: TTileIteratorByRectRecord;
  VProjectedPolygon: IGeometryProjectedPolygon;
  VTilesToProcess: Int64;
  VTilesProcessed: Int64;
  VResampler: TCustomResampler;
  VBitmapSourceTile: IBitmap32Static;
  VBitmap: IBitmap32Static;
  VTileInfo: ITileInfoBasic;
  VResultData: IBinaryData;
  VTileSaver: IBitmapTileSaver;
begin
  inherited;
  VTilesToProcess := 0;
  VTileSaver := FContentType.GetSaver;
  VGeoConvert := FMapType.GeoConvert;
  SetLength(VTileIterators, Length(FZooms) - 1);
  for i := 1 to Length(FZooms) - 1 do begin
    VZoom := FZooms[i];
    VProjection := FProjectionFactory.GetByConverterAndZoom(VGeoConvert, VZoom);
    VProjectedPolygon :=
      FVectorGeometryProjectedFactory.CreateProjectedPolygonByLonLatPolygon(
        VProjection,
        PolygLL
      );
    VTileIterator := TTileIteratorByPolygon.Create(VProjection, VProjectedPolygon);
    VTileIterators[i - 1] := VTileIterator;
    if FGenFormFirstZoom then begin
      VZoomDelta := FZooms[0] - VZoom;
    end else begin
      VZoomDelta := FZooms[i - 1] - VZoom;
    end;
    VTilesToProcess := VTilesToProcess + VTileIterator.TilesTotal * (1 shl (2 * VZoomDelta));
  end;
  try
    ProgressInfo.SetCaption(
      SAS_STR_ProcessedNoMore + ': ' + inttostr(VTilesToProcess) + ' ' + SAS_STR_Files
    );

    bmp_ex := TCustomBitmap32.Create;
    VResampler := FResamplerFactory.CreateResampler;
    try
      FTileInProc := 0;
      VTilesProcessed := 0;
      for i := 1 to Length(FZooms) - 1 do begin
        if FGenFormFirstZoom then begin
          VZoomPrev := FZooms[0];
        end else begin
          VZoomPrev := FZooms[i - 1];
        end;
        VZoom := FZooms[i];
        VTileIterator := VTileIterators[i - 1];
        while VTileIterator.Next(VTile) do begin
          if CancelNotifier.IsOperationCanceled(OperationID) then begin
            exit;
          end;
          VCurrentTilePixelRect := VGeoConvert.TilePos2PixelRect(VTile, VZoom);
          if not (FIsReplace) then begin
            VTileInfo := FMapType.TileStorage.GetTileInfoEx(VTile, VZoom, FVersion, gtimAsIs);
            if VTileInfo.GetIsExists then begin
              continue;
            end;
          end;
          VBitmapSourceTile := nil;
          if FUsePrevTiles then begin
            VBitmapSourceTile := FMapType.LoadTileUni(VTile, VZoom, FVersion, VGeoConvert, True, True, True);
          end;
            if VBitmapSourceTile = nil then begin
              bmp_ex.SetSize(
                VCurrentTilePixelRect.Right - VCurrentTilePixelRect.Left,
                VCurrentTilePixelRect.Bottom - VCurrentTilePixelRect.Top
              );
              bmp_ex.Clear(FBackGroundColor);
            end else begin
              AssignStaticToBitmap32(bmp_ex, VBitmapSourceTile);
            end;

            VRelativeRect := VGeoConvert.TilePos2RelativeRect(VTile, VZoom);
            VRectOfSubTiles :=
              RectFromDoubleRect(
                VGeoConvert.RelativeRect2TileRectFloat(VRelativeRect, VZoomPrev),
                rrToTopLeft
              );
            VSubTileIterator.Init(VRectOfSubTiles);
            VSubTileCount := VSubTileIterator.TilesTotal;
            VSubTilesSavedCount := 0;
            while VSubTileIterator.Next(VSubTile) do begin
              VBitmapSourceTile := FMapType.LoadTile(VSubTile, VZoomPrev, FVersion, True);
              if VBitmapSourceTile <> nil then begin
                VSubTileBounds := VGeoConvert.TilePos2PixelRect(VSubTile, VZoomPrev);
                VSubTileBounds.Right := VSubTileBounds.Right - VSubTileBounds.Left;
                VSubTileBounds.Bottom := VSubTileBounds.Bottom - VSubTileBounds.Top;
                VSubTileBounds.Left := 0;
                VSubTileBounds.Top := 0;
                VRelativeRect := VGeoConvert.TilePos2RelativeRect(VSubTile, VZoomPrev);
                VSubTileInTargetBounds :=
                  RectFromDoubleRect(
                    VGeoConvert.RelativeRect2PixelRectFloat(VRelativeRect, VZoom),
                    rrToTopLeft
                  );
                VSubTileInTargetBounds.Left := VSubTileInTargetBounds.Left - VCurrentTilePixelRect.Left;
                VSubTileInTargetBounds.Top := VSubTileInTargetBounds.Top - VCurrentTilePixelRect.Top;
                VSubTileInTargetBounds.Right := VSubTileInTargetBounds.Right - VCurrentTilePixelRect.Left;
                VSubTileInTargetBounds.Bottom := VSubTileInTargetBounds.Bottom - VCurrentTilePixelRect.Top;
                StretchTransfer(
                  bmp_ex,
                  VSubTileInTargetBounds,
                  VBitmapSourceTile,
                  VSubTileBounds,
                  VResampler,
                  dmOpaque
                );
                inc(VSubTilesSavedCount);
              end else begin
                if FIsSaveFullOnly then begin
                  Break;
                end;
              end;
              inc(VTilesProcessed);
              if (VTilesProcessed mod 30 = 0) then begin
                ProgressFormUpdateOnProgress(VTilesProcessed, VTilesToProcess);
              end;
            end;
            VBitmap := nil;
            if ((not FIsSaveFullOnly) or (VSubTilesSavedCount = VSubTileCount)) and (VSubTilesSavedCount > 0) then begin
              VBitmap :=
                FBitmapFactory.Build(
                  Point(bmp_ex.Width, bmp_ex.Height),
                  bmp_ex.Bits
              );
            end;
          if VBitmap <> nil then begin
            VResultData := VTileSaver.Save(VBitmap);
            if Assigned(VResultData) then begin
              FMapType.TileStorage.SaveTile(
                VTile,
                VZoom,
                FVersion.BaseVersion,
                Now,
                FContentType,
                VResultData,
                True
              );
              VResultData := nil;
              inc(FTileInProc);
            end;
            VBitmap := nil;
          end;
        end;
      end;
    finally
      VResampler.Free;
      bmp_ex.Free;
    end;
  finally
    for i := 0 to Length(VTileIterators) - 1 do begin
      VTileIterators[i] := nil;
    end;
    VTileIterators := nil;
  end;
end;

procedure TThreadGenPrevZoom.ProgressFormUpdateOnProgress(
  const AProcessed, AToProcess: Int64
);
begin
  ProgressInfo.SetProcessedRatio(AProcessed / AToProcess);
  ProgressInfo.SetSecondLine(SAS_STR_Processed + ' ' + inttostr(AProcessed));
end;

end.
