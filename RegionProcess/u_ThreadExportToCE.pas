unit u_ThreadExportToCE;

interface

uses
  SysUtils,
  Classes,
  i_OperationNotifier,
  i_RegionProcessProgressInfo,
  i_VectorItemLonLat,
  i_CoordConverterFactory,
  i_VectorItmesFactory,
  u_MapType,
  u_ResStrings,
  u_ThreadExportAbstract;

type
  TThreadExportToCE = class(TThreadExportAbstract)
  private
    FMapType: TMapType;
    FTargetFile: string;
    FCoordConverterFactory: ICoordConverterFactory;
    FProjectionFactory: IProjectionInfoFactory;
    FVectorItmesFactory: IVectorItmesFactory;
    FMaxSize: Integer;
    FComment: string;
    FRecoverInfo: Boolean;
  protected
    procedure ProcessRegion; override;
  public
    constructor Create(
      ACancelNotifier: IOperationNotifier;
      AOperationID: Integer;
      AProgressInfo: IRegionProcessProgressInfo;
      ACoordConverterFactory: ICoordConverterFactory;
      AProjectionFactory: IProjectionInfoFactory;
      AVectorItmesFactory: IVectorItmesFactory;
      ATargetFile: string;
      APolygon: ILonLatPolygon;
      Azoomarr: array of boolean;
      AMapType: TMapType;
      AMaxSize: Integer;
      AComment: string;
      ARecoverInfo: Boolean
    );
  end;

implementation

uses
  Types,
  GR32,
  SAS4WinCE,
  i_TileIterator,
  i_TileInfoBasic,
  i_BinaryData,
  i_VectorItemProjected,
  u_TileIteratorByPolygon,
  u_TileStorageAbstract,
  u_StreamReadOnlyByBinaryData;

{ TThreadExportToCE }

constructor TThreadExportToCE.Create(
  ACancelNotifier: IOperationNotifier;
  AOperationID: Integer;
  AProgressInfo: IRegionProcessProgressInfo;
  ACoordConverterFactory: ICoordConverterFactory;
  AProjectionFactory: IProjectionInfoFactory;
  AVectorItmesFactory: IVectorItmesFactory;
  ATargetFile: string;
  APolygon: ILonLatPolygon;
  Azoomarr: array of boolean;
  AMapType: TMapType;
  AMaxSize: Integer;
  AComment: string;
  ARecoverInfo: Boolean
);
begin
  inherited Create(
    ACancelNotifier,
    AOperationID,
    AProgressInfo,
    APolygon,
    Azoomarr
  );
  FTargetFile := ATargetFile;
  FMapType := AMapType;
  FCoordConverterFactory := ACoordConverterFactory;
  FProjectionFactory := AProjectionFactory;
  FVectorItmesFactory := AVectorItmesFactory;
  FMaxSize := AMaxSize;
  FComment  := AComment;
  FRecoverInfo := ARecoverInfo;
end;

procedure TThreadExportToCE.ProcessRegion;
var
  i: integer;
  VExt: string;
  VZoom: Byte;
  VTile: TPoint;
  VTileIterators: array of ITileIterator;
  VTileIterator: ITileIterator;
  VTileStorage: TTileStorageAbstract;
  VSAS4WinCE:  TSAS4WinCE;
  VProjectedPolygon: IProjectedPolygon;
  VTilesToProcess: Int64;
  VTilesProcessed: Int64;
  VData: IBinaryData;
  VTileInfo: ITileInfoBasic;
begin
  inherited;
  VTilesToProcess := 0;
  ProgressInfo.Caption := SAS_STR_ExportTiles;
  ProgressInfo.FirstLine := 'Preparing tiles to export..';
  SetLength(VTileIterators, Length(FZooms));
  for i := 0 to Length(FZooms) - 1 do begin
    VZoom := FZooms[i];
    VProjectedPolygon :=
      FVectorItmesFactory.CreateProjectedPolygonByLonLatPolygon(
        FProjectionFactory.GetByConverterAndZoom(
          FMapType.GeoConvert,
          VZoom
        ),
        PolygLL
      );
    VTileIterators[i] := TTileIteratorByPolygon.Create(VProjectedPolygon);
    VTilesToProcess := VTilesToProcess + VTileIterators[i].TilesTotal;
  end;

  //�������� ������� �������� ������ � ���� fname (��� ����������!);
  //maxsize - ����������� ���������� ������ ������ ������ (���� <0, �� �����
  //�������� �� ���������); cmt - ���������� ����������� � ����� ������ �����������;
  //info - ���������� �� � ����� ������ �������������� ���������� ��
  //����� (12-15+ ������) � �������� � ����� ������ � ���� �������.
  //�������� �������� ����� ���������� ������� �������������� ���� � ������ ������!

  VSAS4WinCE := TSAS4WinCE.Create(FTargetFile, FMaxSize, FComment, FRecoverInfo);
  try
    try
      ProgressInfo.FirstLine := SAS_STR_AllSaves + ' ' + inttostr(VTilesToProcess) + ' ' + SAS_STR_Files;
      VTileStorage := FMapType.TileStorage;
      VTilesProcessed := 0;
      ProgressFormUpdateOnProgress(VTilesProcessed, VTilesToProcess);
      for i := 0 to Length(FZooms) - 1 do begin
        VZoom := FZooms[i];
        VTileIterator := VTileIterators[i];
        while VTileIterator.Next(VTile) do begin
          if CancelNotifier.IsOperationCanceled(OperationID) then begin
            exit;
          end;
          VExt := FMapType.StorageConfig.TileFileExt;
          VData := VTileStorage.LoadTile(VTile, VZoom, nil, VTileInfo);
          if VData <> nil then begin
            VSAS4WinCE.Add(
              VZoom + 1,
              VTile.X,
              VTile.Y,
              VData.Buffer,
              VData.Size,
              VExt
            );
          end;
          inc(VTilesProcessed);
          if VTilesProcessed mod 50 = 0 then begin
            ProgressInfo.Processed := VTilesProcessed/VTilesToProcess;
            if VSAS4WinCE.DataNum>0 then
            VExt := inttostr(VSAS4WinCE.DataNum) else
            VExt := '0';
            if VSAS4WinCE.DataNum<10 then VExt := '0' + VExt;
            ProgressInfo.SecondLine := SAS_STR_Processed + ' ' + inttostr(VTilesProcessed) +  '    (.d'+VExt+')';
          end;
        end;
      end;
      ProgressInfo.FirstLine := 'Making .inx file ..';
      ProgressInfo.SecondLine := '';
      VSAS4WinCE.SaveINX(FTargetFile);
    finally
      for i := 0 to Length(FZooms) - 1 do begin
        VTileIterators[i] := nil;
      end;
      VTileIterators := nil;
    end;
  finally
    VSAS4WinCE.Free;
  end;
end;

end.