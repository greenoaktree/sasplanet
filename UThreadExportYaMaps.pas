unit UThreadExportYaMaps;

interface

uses
  Windows,
  Forms,
  SysUtils,
  Classes,
  Graphics,
  gifimage,
  PNGImage,
  GR32,
  UMapType,
  UGeoFun,
  unit4,
  UResStrings,
  UYaMobile,
  t_GeoTypes;

type
  TThreadExportYaMaps = class(TThread)
  private
    PolygLL:TExtendedPointArray;
    Zoomarr:array [0..23] of boolean;
    typemaparr:array of TMapType;
    Fprogress: TFprogress2;
    Replace:boolean;
    Path:string;
    csat,cmap,chib:byte;
    procedure export2YaMaps(APolyLL:TExtendedPointArray);
  protected
    procedure Execute; override;
  public
    constructor Create(
      APath: string;
      APolygon_: TExtendedPointArray;
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
  u_GeoToStr,
  i_ICoordConverter,
  u_GlobalState,
  u_CoordConverterMercatorOnEllipsoid,
  i_BitmapTileSaveLoad,
  u_BitmapTileJpegSaverIJL,
  u_BitmapTilePngNBitdepthSaver;

constructor TThreadExportYaMaps.Create(
  APath: string;
  APolygon_: TExtendedPointArray;
  Azoomarr: array of boolean;
  Atypemaparr: array of TMapType;
  Areplace: boolean;
  Acsat, Acmap, Achib: byte
);
var i:integer;
begin
  inherited Create(false);
  Priority := tpLowest;
  FreeOnTerminate:=true;
  Application.CreateForm(TFProgress2, FProgress);
  cSat:=Acsat;
  cMap:=Acmap;
  cHib:=Achib;
  FProgress.Visible:=true;
  Path:=APath;
  Replace:=AReplace;
  setlength(PolygLL,length(APolygon_));
  for i:=1 to length(APolygon_) do
    PolygLL[i-1]:=Apolygon_[i-1];
  for i:=0 to 23 do
    zoomarr[i]:=Azoomarr[i];
  setlength(typemaparr,length(Atypemaparr));
  for i:=1 to length(Atypemaparr) do
    typemaparr[i-1]:=Atypemaparr[i-1];
end;


procedure TThreadExportYaMaps.Execute;
begin
  export2YaMaps(PolygLL);
  FProgress.Close;
end;

function UniLoadTile(var bmp:TBitmap32; ATypeMap: TmapType; ATargetProjection: byte; p_h:TPoint;p_x,p_y:integer; zoom:byte):boolean;
var
  bmp2,bmp1:TBitmap32;
  res1,res2:boolean;
begin
  res2:=false;
  bmp.width:=256;
  bmp.Height:=256;
  bmp.Clear(Color32(GState.BGround));
  bmp1:=TBitmap32.Create;
  try
    bmp1.DrawMode:=dmBlend;
    bmp2:=TBitmap32.Create;
    try
      bmp2.DrawMode:=dmBlend;
      res1:=true;
      if (not(ATypeMap.LoadTile(bmp1,p_h.x, p_h.y, zoom+1,false))) then begin
        res1:=false;
        bmp1.width:=256;
        bmp1.Height:=256;
        bmp1.Clear(Color32(GState.BGround));
      end;
      if p_h.Y<0 then begin
        bmp.Draw(0,((((p_Y-(p_y mod 256)) mod 256)+256)-(p_h.Y mod 256)),bmp1);
      end else begin
        bmp.Draw(0,(((p_Y-(p_y mod 256)) mod 256)-(p_h.Y mod 256)),bmp1);
      end;

      if ATargetProjection<>ATypeMap.projection then begin
        res2:=true;
        if (not(ATypeMap.LoadTile(bmp2,p_h.x,p_h.y+256,zoom+1,false))) then begin
          res2:=false;
          bmp2.width:=256;
          bmp2.Height:=256;
          bmp2.Clear(Color32(GState.BGround));
        end;
        if p_h.Y<0 then begin
          bmp.Draw(0,(((p_Y-(p_y mod 256)) mod 256)-(p_h.Y mod 256)),bmp2);
        end else begin
          bmp.Draw(0,((((p_Y-(p_y mod 256)) mod 256)+256)-(p_h.Y mod 256)),bmp2);
        end;
      end;
      result:=(res1 or res2);
    finally
      bmp2.Free;
    end;
  finally
    bmp1.Free;
  end;
end;

procedure TThreadExportYaMaps.export2YaMaps(APolyLL:TExtendedPointArray);
var
  p_x,p_y,i,j,xi,yi,hxyi,sizeim:integer;
  num_dwn,obrab:integer;
  polyg:TPointArray;
  max,min,p_h:TPoint;
  bmp32,bmp322,bmp32crop:TBitmap32;
  TileStream : TMemoryStream;
  tc:cardinal;
  VGeoConvert: ICoordConverter;
  VMainMapType: TMapType;
  JPGSaver,PNGSaver:IBitmapTileSaver;
begin
  try
    if (TypeMapArr[0]=nil)and(TypeMapArr[1]=nil)and(TypeMapArr[2]=nil) then exit;
    try
      hxyi:=1;
      sizeim:=128;
      JPGSaver:=TJpegBitmapTileSaverIJL.create(cSat);
      PNGSaver:=TPngBitmapTileNBitdepthSaver.create(cMap,8);
      TileStream:=TMemoryStream.Create;
      bmp32:=TBitmap32.Create;
      bmp32.DrawMode:=dmBlend;
      bmp322:=TBitmap32.Create;
      bmp322.DrawMode:=dmBlend;
      bmp32crop:=TBitmap32.Create;
      bmp32crop.Width:=sizeim;
      bmp32crop.Height:=sizeim;
      VGeoConvert := TCoordConverterMercatorOnEllipsoid.Create(6378137, 6356752);
      num_dwn:=0;
      SetLength(polyg,length(APolyLL));
      for i:=0 to length(TypeMapArr)-1 do begin
        if TypeMapArr[i]<>nil then begin
          for j:=0 to 23 do begin
            if zoomarr[j] then begin
              polyg := TypeMapArr[i].GeoConvert.PoligonProject(j + 8, APolyLL);
              num_dwn:=num_dwn+GetDwnlNum(min,max,Polyg,true);
            end;
          end;
        end;
      end;
      fprogress.MemoInfo.Lines[0]:=SAS_STR_ExportTiles;
      fprogress.Caption:=SAS_STR_AllSaves+' '+inttostr(num_dwn)+' '+SAS_STR_files;
      FProgress.ProgressBar1.Progress1:=0;
      FProgress.ProgressBar1.Max:=100;
      fprogress.MemoInfo.Lines[1]:=SAS_STR_Processed+' '+inttostr(FProgress.ProgressBar1.Progress1)+'%';
      obrab:=0;
      tc:=GetTickCount;
      for i:=0 to 23 do begin //�� ��������
        if zoomarr[i] then begin
          for j:=0 to 2 do begin//�� ����
            if (TypeMapArr[j]<>nil)and(not((j=0)and(TypeMapArr[2]<>nil))) then begin
              polyg := VGeoConvert.PoligonProject(i + 8, APolyLL);
              GetDwnlNum(min,max,Polyg,false);
              p_x:=min.x;
              while p_x<max.x do begin
                p_y:=min.Y;
                while p_y<max.Y do begin
                  if (FProgress.Visible=false)or(not(RgnAndRgn(Polyg,p_x,p_y,false))) then begin
                    inc(p_y,256);
                    CONTINUE;
                  end;
                  bmp322.Clear;
                  if (j=2)and(TypeMapArr[0]<>nil) then begin
                    p_h := VGeoConvert.Pos2OtherMap(Point(p_x,p_y-(p_y mod 256)), i + 8, TypeMapArr[0].GeoConvert);
                    UniLoadTile(bmp322,TypeMapArr[0],2,p_h,p_x,p_y,i);
                  end;
                  bmp32.Clear;
                  p_h := VGeoConvert.Pos2OtherMap(Point(p_x,p_y-(p_y mod 256)), i + 8, TypeMapArr[j].GeoConvert);
                  if UniLoadTile(bmp32,TypeMapArr[j],2,p_h,p_x,p_y,i) then begin
                    if (j=2)and(TypeMapArr[0]<>nil) then begin
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
                          WriteTileInCache(p_x div 256,p_y div 256,i+1,2,(yi*2)+xi,path, TileStream,Replace)
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
                          WriteTileInCache(p_x div 256,p_y div 256,i+1,1,(yi*2)+xi,path, TileStream,Replace)
                        end;
                      end;
                    end;
                  end;
                  inc(obrab);
                  if (GetTickCount-tc>1000) then begin
                    tc:=GetTickCount;
                    FProgress.ProgressBar1.Progress1:=round((obrab/num_dwn)*100);
                    fprogress.MemoInfo.Lines[1]:=SAS_STR_Processed+' '+inttostr(FProgress.ProgressBar1.Progress1)+'%';
                  end;
                  inc(p_y,256);
                end;
                inc(p_x,256);
              end;
            end;
          end;
        end;
      end;
      FProgress.ProgressBar1.Progress1:=round((obrab/num_dwn)*100);
      fprogress.MemoInfo.Lines[1]:=SAS_STR_Processed+' '+inttostr(obrab);
    finally
      FProgress.Close;
      bmp32.Free;
      bmp322.Free;
    end;
  except
    on e:Exception do begin
      Application.ShowException(e);
    end;
  end;
end;

end.
