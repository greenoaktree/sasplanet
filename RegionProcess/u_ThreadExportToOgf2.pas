unit u_ThreadExportToOgf2;

interface

uses
  Types,
  SysUtils,
  Classes,
  i_OperationNotifier,
  i_BitmapTileSaveLoad,
  i_BitmapLayerProvider,
  i_BinaryData,
  i_RegionProcessProgressInfo,
  i_VectorItemLonLat,
  i_CoordConverter,
  i_CoordConverterFactory,
  i_LocalCoordConverterFactorySimpe,
  i_VectorItmesFactory,
  u_MapType,
  u_ResStrings,
  u_ThreadExportAbstract;

type
  TOgf2TileFormat = (tfBMP = 0, tfPNG = 1, tfJPEG = 2);
  TOgf2TileResolution = (tr128 = 0, tr256 = 1);

  TThreadExportToOgf2 = class(TThreadExportAbstract)
  private
    FMapType: TMapType;
    FOverlayMapType: TMapType;
    FOgf2TileWidth: Integer;
    FOgf2TileHeight: Integer;
    FOgf2TileFormat: TOgf2TileFormat;
    FJpegQuality: Byte;
    FTargetFile: string;
    FImageProvider: IBitmapLayerProvider;
    FCoordConverterFactory: ICoordConverterFactory;
    FLocalConverterFactory: ILocalCoordConverterFactorySimpe;
    FProjectionFactory: IProjectionInfoFactory;
    FVectorItmesFactory: IVectorItmesFactory;
    function GetMapPreview(
      const ABitmapSaver: IBitmapTileSaver;
      out AMapPreviewWidth: Integer;
      out AMapPreviewHeight: Integer
    ): IBinaryData;
    function GetEmptyTile(
      const ABitmapSaver: IBitmapTileSaver
    ): IBinaryData;
    procedure SaveOziCalibrationMap(
      const AGeoConvert: ICoordConverter;
      const ATileRect: TRect;
      const AZoom: Byte
    );
  protected
    procedure ProcessRegion; override;
  public
    constructor Create(
      const ACancelNotifier: IOperationNotifier;
      AOperationID: Integer;
      const AProgressInfo: IRegionProcessProgressInfo;
      const ACoordConverterFactory: ICoordConverterFactory;
      const ALocalConverterFactory: ILocalCoordConverterFactorySimpe;
      const AProjectionFactory: IProjectionInfoFactory;
      const AVectorItmesFactory: IVectorItmesFactory;
      const ATargetFile: string;
      const APolygon: ILonLatPolygon;
      const AZoomArr: array of Boolean;
      AMapType: TMapType;
      AOverlayMapType: TMapType;
      AUsePrevZoom: Boolean;
      AOgf2TileResolution: TOgf2TileResolution;
      AOgf2TileFormat: TOgf2TileFormat;
      AJpegQuality: Byte
    );
  end;

implementation

uses
  GR32,
  GR32_Resamplers,
  Ogf2Writer,
  t_GeoTypes,
  c_CoordConverter,
  i_Bitmap32Static,
  i_TileIterator,
  i_VectorItemProjected,
  u_BitmapLayerProviderSimpleForCombine,
  u_BinaryDataByMemStream,
  u_BitmapTileVampyreSaver,
  u_TileIteratorByRect,
  u_MapCalibrationOzi,
  u_ARGBToPaletteConverter,
  u_GeoFun;

const
  cBackGroundColor = $CCCCCCCC;

{ TThreadExportToOgf2 }

constructor TThreadExportToOgf2.Create(
  const ACancelNotifier: IOperationNotifier;
  AOperationID: Integer;
  const AProgressInfo: IRegionProcessProgressInfo;
  const ACoordConverterFactory: ICoordConverterFactory;
  const ALocalConverterFactory: ILocalCoordConverterFactorySimpe;
  const AProjectionFactory: IProjectionInfoFactory;
  const AVectorItmesFactory: IVectorItmesFactory;
  const ATargetFile: string;
  const APolygon: ILonLatPolygon;
  const AZoomArr: array of Boolean;
  AMapType: TMapType;
  AOverlayMapType: TMapType;
  AUsePrevZoom: Boolean;
  AOgf2TileResolution: TOgf2TileResolution;
  AOgf2TileFormat: TOgf2TileFormat;
  AJpegQuality: Byte
);
begin
  inherited Create(
    ACancelNotifier,
    AOperationID,
    AProgressInfo,
    APolygon,
    AZoomArr
  );
  FTargetFile := ATargetFile;
  FMapType := AMapType;
  FOverlayMapType := AOverlayMapType;
  FCoordConverterFactory := ACoordConverterFactory;
  FLocalConverterFactory := ALocalConverterFactory;
  FProjectionFactory := AProjectionFactory;
  FVectorItmesFactory := AVectorItmesFactory;
  FOgf2TileFormat := AOgf2TileFormat;
  FJpegQuality := AJpegQuality;

  FImageProvider :=
    TBitmapLayerProviderSimpleForCombine.Create(
      nil,
      FMapType,
      FOverlayMapType,
      nil,
      AUsePrevZoom,
      AUsePrevZoom
    );

  case AOgf2TileResolution of
    tr128:
      begin
        FOgf2TileWidth := 128;
        FOgf2TileHeight := 128;
      end;
  else
      begin
        FOgf2TileWidth := 256;
        FOgf2TileHeight := 256;
      end;
  end;
end;

procedure TThreadExportToOgf2.SaveOziCalibrationMap(
  const AGeoConvert: ICoordConverter;
  const ATileRect: TRect;
  const AZoom: Byte
);
var
  VOziCalibrationMap: TMapCalibrationOzi;
begin
  VOziCalibrationMap := TMapCalibrationOzi.Create;
  try
    VOziCalibrationMap.SaveCalibrationInfo(
      FTargetFile,
      ATileRect.TopLeft,
      ATileRect.BottomRight,
      AZoom,
      AGeoConvert
    );
  finally
    VOziCalibrationMap.Free;
  end;
end;


function TThreadExportToOgf2.GetMapPreview(
  const ABitmapSaver: IBitmapTileSaver;
  out AMapPreviewWidth: Integer;
  out AMapPreviewHeight: Integer
): IBinaryData;
var
  VBitmap: TCustomBitmap32;
  VStream: TMemoryStream;
begin
  VBitmap := TCustomBitmap32.Create;
  try
    //TODO: generate some preview and make it sizeble

    AMapPreviewWidth := 256;
    AMapPreviewHeight := 256;

    VBitmap.SetSize(AMapPreviewWidth, AMapPreviewHeight);
    VBitmap.Clear(cBackGroundColor);

    VStream := TMemoryStream.Create;
    try
      ABitmapSaver.SaveToStream(VBitmap, VStream);
      VStream.Position := 0;
      Result := TBinaryDataByMemStream.CreateWithOwn(VStream);
      VStream := nil;
    finally
      VStream.Free;
    end;
  finally
    VBitmap.Free;
  end;
end;

function TThreadExportToOgf2.GetEmptyTile(
  const ABitmapSaver: IBitmapTileSaver
): IBinaryData;
var
  VBitmap: TCustomBitmap32;
  VStream: TMemoryStream;
begin
  VBitmap := TCustomBitmap32.Create;
  try
    VStream := TMemoryStream.Create;
    try
      VBitmap.SetSize(FOgf2TileWidth, FOgf2TileHeight);
      VBitmap.Clear(cBackGroundColor);
      ABitmapSaver.SaveToStream(VBitmap, VStream);
      VStream.Position := 0;
      Result := TBinaryDataByMemStream.CreateWithOwn(VStream);
      VStream := nil;
    finally
      VStream.Free;
    end;
  finally
    VBitmap.Free;
  end;
end;

procedure TThreadExportToOgf2.ProcessRegion;
var
  VOfg2FileStream: TFileStream;
  VPreviewImageWidth: Integer;
  VPreviewImageHeight: Integer;
  VPreviewImageData: IBinaryData;
  VEmptyTile: IBinaryData;    
  VTileStream: TMemoryStream;
  VBitmap: TCustomBitmap32;
  VBitmapTile: IBitmap32Static;
  VZoom: Byte;
  VTile: TPoint;
  VTileIterator: ITileIterator;
  VSaver: IBitmapTileSaver;
  VGeoConvert: ICoordConverter;
  VWriter: TOgf2Writer;
  VTilesToProcess: Int64;
  VTilesProcessed: Int64;
  VProjected: IProjectedPolygon;
  VLine: IProjectedPolygonLine;
  VBounds: TDoubleRect;
  VPixelRect: TRect;
  VTileRect: TRect;
  I,J: Integer;
begin
  inherited;
  VTilesProcessed := 0;
  VTilesToProcess := 0;

  VZoom := FZooms[0];

  case FOgf2TileFormat of
    tfBMP:
      VSaver := TVampyreBasicBitmapTileSaverBMP.Create;

    tfPNG:
      VSaver := TVampyreBasicBitmapTileSaverPNGRGB.Create;
  else
      VSaver := TVampyreBasicBitmapTileSaverJPG.Create(FJpegQuality);
  end;

  VGeoConvert :=
    FCoordConverterFactory.GetCoordConverterByCode(
      CGoogleProjectionEPSG, // Merkator, WSG84, EPSG = 3785
      CTileSplitQuadrate256x256
    );

  VProjected :=
    FVectorItmesFactory.CreateProjectedPolygonByLonLatPolygon(
      FProjectionFactory.GetByConverterAndZoom(
        VGeoConvert,
        VZoom
      ),
      Self.PolygLL
    );

  VLine := VProjected.Item[0];
  VBounds := VLine.Bounds;
  VPixelRect := RectFromDoubleRect(VBounds, rrOutside);
  VTileRect := VGeoConvert.PixelRect2TileRect(VPixelRect, VZoom);

  SaveOziCalibrationMap(
    VGeoConvert,
    VPixelRect,
    VZoom
  );

  VTileIterator := TTileIteratorByRect.Create(VTileRect);
  try
    VTilesToProcess := VTilesToProcess + VTileIterator.TilesTotal;

    ProgressInfo.Caption := SAS_STR_ExportTiles;
    ProgressInfo.FirstLine :=
      SAS_STR_AllSaves + ' ' +
      IntToStr(VTilesToProcess) + ' ' +
      SAS_STR_Files;

    ProgressFormUpdateOnProgress(VTilesProcessed, VTilesToProcess);

    VTileStream := TMemoryStream.Create;
    try
      VPreviewImageData :=
        GetMapPreview(
          VSaver,
          VPreviewImageWidth,
          VPreviewImageHeight
        );

      VEmptyTile := GetEmptyTile(VSaver);

      if (VPreviewImageData <> nil) and (VEmptyTile <> nil) then begin

        VOfg2FileStream := TFileStream.Create(FTargetFile, fmCreate);
        try
          VWriter := TOgf2Writer.Create(
            VOfg2FileStream,
            (VTileRect.Right - VTileRect.Left) * 256,
            (VTileRect.Bottom - VTileRect.Top) * 256,
            FOgf2TileWidth,
            FOgf2TileHeight,
            VPreviewImageWidth,
            VPreviewImageHeight,
            VPreviewImageData.Buffer,
            VPreviewImageData.Size,
            VEmptyTile.Buffer,
            VEmptyTile.Size
          );
          try
            VBitmap := TCustomBitmap32.Create;
            try
              VBitmap.Width := FOgf2TileWidth;
              VBitmap.Height := FOgf2TileHeight;

              while VTileIterator.Next(VTile) do begin
                if CancelNotifier.IsOperationCanceled(OperationID) then begin
                  Exit;
                end;

                VBitmapTile :=
                  FImageProvider.GetBitmapRect(
                    OperationID,
                    CancelNotifier,
                    FLocalConverterFactory.CreateForTile(
                      VTile,
                      VZoom,
                      VGeoConvert
                    )
                  );

                for I := 0 to (256 div FOgf2TileWidth) - 1 do begin
                  for J := 0 to (256 div FOgf2TileHeight) - 1 do begin
                    if VBitmapTile <> nil then begin
                      VBitmap.Clear(cBackGroundColor);

                      BlockTransfer(
                        VBitmap,
                        0,
                        0,
                        VBitmap.ClipRect,
                        VBitmapTile.Bitmap,
                        Bounds(
                          FOgf2TileWidth  * I,
                          FOgf2TileHeight * J,
                          FOgf2TileWidth,
                          FOgf2TileHeight
                        ),
                        dmOpaque
                      );

                      VTileStream.Clear;
                      VSaver.SaveToStream(VBitmap, VTileStream);
                      VTileStream.Position := 0;

                      VWriter.Add(
                        (VTile.X * 2) + I,
                        (VTile.Y * 2) + J,
                        VTileStream.Memory,
                        VTileStream.Size
                      );
                    end else begin
                      VWriter.AddEmpty(
                        (VTile.X * 2) + I,
                        (VTile.Y * 2) + J
                      );
                    end;
                  end;
                end;

                Inc(VTilesProcessed);

                if VTilesProcessed mod 100 = 0 then begin
                  ProgressFormUpdateOnProgress(VTilesProcessed, VTilesToProcess);
                end;
              end;

              VWriter.SaveAllocationTable; // finalize export

            finally
              VBitmap.Free;
            end;
          finally
            VWriter.Free;
          end;
        finally
          VOfg2FileStream.Free;
        end;
      end;
    finally
      VTileStream.Free;
    end;
  finally
    VTileIterator := nil;
  end;
end;

end.
