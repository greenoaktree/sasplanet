unit UThreadExportYaMaps;

interface

uses
  Windows,
  Types,
  SysUtils,
  Classes,
  GR32,
  UMapType,
  UGeoFun,
  UResStrings,
  UYaMobile,
  t_GeoTypes,
  u_ExportThreadAbstract;

type
  TThreadExportYaMaps = class(TThreadExportAbstract)
  private
    FMapTypeArr:array of TMapType;
    FIsReplace:boolean;
    FExportPath: string;
    csat,cmap,chib:byte;
  protected
    procedure ExportRegion; override;
  public
    constructor Create(
      APath: string;
      APolygon: TExtendedPointArray;
      Azoomarr: array of boolean;
      Atypemaparr: array of TMapType;
      Areplace: boolean;
      Acsat: byte;
      Acmap: byte;
      Achib: byte
    );
  end;

implementation

uses
  
  i_ICoordConverter,
  u_CoordConverterMercatorOnEllipsoid,
  i_BitmapTileSaveLoad,
  u_BitmapTileJpegSaverIJL,
  u_BitmapTileVampyreSaver;

constructor TThreadExportYaMaps.Create(
  APath: string;
  APolygon: TExtendedPointArray;
  Azoomarr: array of boolean;
  Atypemaparr: array of TMapType;
  Areplace: boolean;
  Acsat, Acmap, Achib: byte
);
var i:integer;
begin
  inherited Create(APolygon, Azoomarr);
  cSat:=Acsat;
  cMap:=Acmap;
  cHib:=Achib;
  FExportPath:=APath;
  FIsReplace:=AReplace;
  setlength(FMapTypeArr,length(Atypemaparr));
  for i:=1 to length(Atypemaparr) do
    FMapTypeArr[i-1]:=Atypemaparr[i-1];
end;


procedure TThreadExportYaMaps.ExportRegion;
var
  p_x,p_y,i,j,xi,yi,hxyi,sizeim:integer;
  polyg:TPointArray;
  max,min:TPoint;
  bmp32,bmp322,bmp32crop:TBitmap32;
  TileStream : TMemoryStream;
  tc:cardinal;
  VGeoConvert: ICoordConverter;
  JPGSaver,PNGSaver:IBitmapTileSaver;
  VTile: TPoint;
begin
    if (FMapTypeArr[0]=nil)and(FMapTypeArr[1]=nil)and(FMapTypeArr[2]=nil) then exit;
    bmp32:=TBitmap32.Create;
    bmp322:=TBitmap32.Create;
    try
      hxyi:=1;
      sizeim:=128;
      JPGSaver:=TJpegBitmapTileSaverIJL.create(cSat);
      PNGSaver:=TVampyreBasicBitmapTileSaverPNGPalette.create(cMap);
      TileStream:=TMemoryStream.Create;
      bmp32.DrawMode:=dmBlend;
      bmp322.DrawMode:=dmBlend;
      bmp32crop:=TBitmap32.Create;
      bmp32crop.Width:=sizeim;
      bmp32crop.Height:=sizeim;
      VGeoConvert := TCoordConverterMercatorOnEllipsoid.Create(6378137, 6356752);
      FTilesToProcess:=0;
      SetLength(polyg,length(FPolygLL));
      for i:=0 to length(FMapTypeArr)-1 do begin
        if FMapTypeArr[i]<>nil then begin
          for j:=0 to 23 do begin
            if FZoomArr[j] then begin
              polyg := FMapTypeArr[i].GeoConvert.LonLatArray2PixelArray(FPolygLL, j);
              FTilesToProcess:=FTilesToProcess+GetDwnlNum(min,max,Polyg,true);
            end;
          end;
        end;
      end;
      FTilesProcessed:=0;

      ProgressFormUpdateCaption(SAS_STR_ExportTiles, SAS_STR_AllSaves+' '+inttostr(FTilesToProcess)+' '+SAS_STR_files);
      ProgressFormUpdateOnProgress;

      tc:=GetTickCount;
      for i:=0 to 23 do begin
        if FZoomArr[i] then begin
          for j:=0 to 2 do begin
            if (FMapTypeArr[j]<>nil)and(not((j=0)and(FMapTypeArr[2]<>nil))) then begin
              polyg := VGeoConvert.LonLatArray2PixelArray(FPolygLL, i);
              GetDwnlNum(min,max,Polyg,false);
              p_x:=min.x;
              while p_x<max.x do begin
                VTile.X := p_x shr 8;
                p_y:=min.Y;
                while p_y<max.Y do begin
                  VTile.Y := p_y shr 8;
                  if (IsCancel)or(not(RgnAndRgn(Polyg,p_x,p_y,false))) then begin
                    inc(p_y,256);
                    CONTINUE;
                  end;
                  bmp322.Clear;
                  if (j=2)and(FMapTypeArr[0]<>nil) then begin
                    FMapTypeArr[0].LoadTileUni(bmp322, VTile, i, False, VGeoConvert, False, False, True);
                  end;
                  bmp32.Clear;
                  if FMapTypeArr[j].LoadTileUni(bmp32, VTile, i, False, VGeoConvert, False, False, True) then begin
                    if (j=2)and(FMapTypeArr[0]<>nil) then begin
                      bmp322.Draw(0,0,bmp32);
                      bmp32.Draw(0,0,bmp322);
                    end;
                    if (j=2)or(j=0) then begin
                      for xi:=0 to hxyi do begin
                        for yi:=0 to hxyi do begin
                          bmp32crop.Clear;
                          bmp32crop.Draw(0,0,bounds(sizeim*xi,sizeim*yi,sizeim,sizeim),bmp32);
                          TileStream.Clear;
                          JPGSaver.SaveToStream(bmp32crop,TileStream);
                          WriteTileInCache(p_x div 256,p_y div 256,i,2,(yi*2)+xi,FExportPath, TileStream,FIsReplace)
                        end;
                      end;
                    end;
                    if j=1 then begin
                      for xi:=0 to hxyi do begin
                        for yi:=0 to hxyi do begin
                          bmp32crop.Clear;
                          bmp32crop.Draw(0,0,bounds(sizeim*xi,sizeim*yi,sizeim,sizeim),bmp32);
                          TileStream.Clear;
                          PNGSaver.SaveToStream(bmp32crop,TileStream);
                          WriteTileInCache(p_x div 256,p_y div 256,i,1,(yi*2)+xi,FExportPath, TileStream,FIsReplace)
                        end;
                      end;
                    end;
                  end;
                  inc(FTilesProcessed);
                  if (GetTickCount-tc>1000) then begin
                    tc:=GetTickCount;
                    ProgressFormUpdateOnProgress
                  end;
                  inc(p_y,256);
                end;
                inc(p_x,256);
              end;
            end;
          end;
        end;
      end;
      ProgressFormUpdateOnProgress
    finally
      bmp32.Free;
      bmp322.Free;
    end;
end;

end.
