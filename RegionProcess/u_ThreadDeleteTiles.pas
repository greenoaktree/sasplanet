unit u_ThreadDeleteTiles;

interface

uses
  Windows,
  SysUtils,
  Classes,
  t_GeoTypes,
  u_MapType,
  u_ThreadRegionProcessAbstract,
  u_ResStrings;

type
  TThreadDeleteTiles = class(TThreadRegionProcessAbstract)
  private
    FZoom: byte;
    FMapType: TMapType;
    FDeletedCount: integer;
    DelBytes: boolean;
    DelBytesNum: integer;
  protected
    procedure ProcessRegion; override;
    procedure ProgressFormUpdateOnProgress;
  public
    constructor Create(
      APolyLL: TArrayOfDoublePoint;
      Azoom: byte;
      Atypemap: TMapType;
      ADelByte: boolean;
      ADelBytesNum: integer
    );
  end;

implementation

uses
  i_TileIterator,
  u_TileIteratorStuped;

constructor TThreadDeleteTiles.Create(
  APolyLL: TArrayOfDoublePoint;
  Azoom: byte;
  Atypemap: TMapType;
  ADelByte: boolean;
  ADelBytesNum: integer
);
begin
  inherited Create(APolyLL);
  FDeletedCount := 0;
  FZoom := Azoom;
  FMapType := Atypemap;
  DelBytes := ADelByte;
  DelBytesNum := ADelBytesNum;
end;

procedure TThreadDeleteTiles.ProcessRegion;
var
  VTile: TPoint;
  VTileIterator: ITileIterator;
begin
  inherited;
  VTileIterator := TTileIteratorStuped.Create(FZoom, FPolygLL, FMapType.GeoConvert);
  try
    FTilesToProcess := VTileIterator.TilesTotal;
    ProgressFormUpdateCaption(
      '',
      SAS_STR_Deleted + ' ' + inttostr(FTilesToProcess) + ' ' + SAS_STR_files + ' (x' + inttostr(FZoom + 1) + ')'
    );
    while VTileIterator.Next(VTile) do begin
      if CancelNotifier.IsOperationCanceled(OperationID) then begin
        exit;
      end;
      if (not DelBytes or (DelBytesNum = FMapType.TileSize(VTile, FZoom))) then begin
        if FMapType.DeleteTile(VTile, FZoom) then begin
          inc(FDeletedCount);
        end;
        ProgressFormUpdateOnProgress;
      end;
      inc(FTilesProcessed);
    end;
  finally
    VTileIterator := nil;
  end;
end;

procedure TThreadDeleteTiles.ProgressFormUpdateOnProgress;
begin
  ProgressFormUpdateProgressLine0AndLine1(
    round((FTilesProcessed / FTilesToProcess) * 100),
    SAS_STR_AllDelete + ' ' + inttostr(FDeletedCount) + ' ' + SAS_STR_files,
    SAS_STR_Processed + ' ' + inttostr(FTilesProcessed)
  );
end;

end.
