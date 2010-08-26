unit u_MapCombineThreadKMZ;

interface

uses
  Windows,
  Types,
  SysUtils,
  Classes,
  GR32,
  ijl,
  UMapType,
  UImgFun,
  UGeoFun,
  bmpUtil,
  t_GeoTypes,
  UResStrings,
  u_MapCombineThreadBase;

type
  PArrayBGR = ^TArrayBGR;
  TArrayBGR = array [0..0] of TBGR;

  P256ArrayBGR = ^T256ArrayBGR;
  T256ArrayBGR = array[0..255] of PArrayBGR;

  TMapCombineThreadKMZ = class(TMapCombineThreadBase)
  private
    FArray256BGR: P256ArrayBGR;
    sx,ex,sy,ey:integer;
    btmm:TBitmap32;
    btmh:TBitmap32;
    FQuality: Integer;

    procedure ReadLineBMP(Line:cardinal;LineRGB:PLineRGBb);
  protected
    procedure saveRECT; override;
  public
    constructor Create(
      AMapCalibrationList: IInterfaceList;
      AFileName: string;
      APolygon: TPointArray;
      ASplitCount: TPoint;
      Azoom: byte;
      Atypemap: TMapType;
      AHtypemap: TMapType;
      AusedReColor,
      AusedMarks: boolean;
      AQuality: Integer
    );
  end;

implementation

uses
  KAZip,
  i_ICoordConverter,
  u_GlobalState;

constructor TMapCombineThreadKMZ.Create(
  AMapCalibrationList: IInterfaceList;
  AFileName:string;
  APolygon:TPointArray;
  ASplitCount: TPoint;
  Azoom:byte;
  Atypemap,AHtypemap:TMapType;
  AusedReColor,AusedMarks:boolean;
  AQuality: Integer
);
begin
  inherited Create(AMapCalibrationList, AFileName, APolygon, ASplitCount,
    Azoom, Atypemap, AHtypemap, AusedReColor, AusedMarks);
  FQuality := AQuality;
end;

procedure TMapCombineThreadKMZ.ReadLineBMP(Line: cardinal;
  LineRGB: PLineRGBb);
var
  i,j,rarri,lrarri,p_x,p_y,Asx,Asy,Aex,Aey,starttile:integer;
  p_h:TPoint;
  p:PColor32array;
  VTileRect: TRect;
begin
  if line<(256-sy) then begin
    starttile:=sy+line
  end else begin
    starttile:=(line-(256-sy)) mod 256;
  end;
  if (starttile=0)or(line=0) then begin
    FProgressOnForm:=line;
    Synchronize(UpdateProgressFormBar);
    if line=0 then begin
      FShowOnFormLine1:=SAS_STR_CreateFile
    end else begin
      FShowOnFormLine1:=SAS_STR_Processed+': '+inttostr(Round((FProgressOnForm/(FMapPieceSize.Y))*100))+'%';
    end;
    Synchronize(UpdateProgressFormStr2);
    p_y:=(FCurrentPieceRect.Top+line)-((FCurrentPieceRect.Top+line) mod 256);
    p_x:=FCurrentPieceRect.Left-(FCurrentPieceRect.Left mod 256);
    p_h := FTypeMap.GeoConvert.PixelPos2OtherMap(Point(p_x,p_y), Fzoom, FHTypeMap.GeoConvert);
    lrarri:=0;
    if line>(255-sy) then Asy:=0 else Asy:=sy;
    if (p_y div 256)=(FCurrentPieceRect.Bottom div 256) then Aey:=ey else Aey:=255;
    Asx:=sx;
    Aex:=255;
    while p_x<=FCurrentPieceRect.Right do begin
      if not(RgnAndRgn(FPoly, p_x+128, p_y+128, false)) then begin
        btmm.Clear(Color32(GState.BGround))
      end else begin
        btmm.Clear(Color32(GState.BGround));
        FLastTile := Point(p_x shr 8, p_y shr 8);
        VTileRect := FTypeMap.GeoConvert.TilePos2PixelRect(FLastTile, FZoom);
        FTypeMap.LoadTileOrPreZ(btmm, FLastTile, FZoom, false, True);
        if FHTypeMap<>nil then begin
          btmh.Clear($FF000000);
          FHTypeMap.LoadTileUni(btmh, FLastTile, FZoom, False, FTypeMap.GeoConvert, True, True, True);
          btmh.DrawMode:=dmBlend;
          btmm.Draw(0,0,btmh);
        end;
        if FUsedMarks then begin
          GState.MarksBitmapProvider.GetBitmapRect(btmm, FTypeMap.GeoConvert, VTileRect, FZoom);
        end;
      end;
      if FUsedReColor then Gamma(btmm);
      if (p_x+256)>FCurrentPieceRect.Right then Aex:=ex;
      for j:=Asy to Aey do begin
        p:=btmm.ScanLine[j];
        rarri:=lrarri;
        for i:=Asx to Aex do begin
          CopyMemory(@FArray256BGR[j]^[rarri],Pointer(integer(p)+(i*4)),3);
          inc(rarri);
        end;
      end;
      lrarri:=rarri;
      Asx:=0;
      inc(p_x,256);
      inc(p_h.x,256);
    end;
  end;
  CopyMemory(LineRGB,FArray256BGR^[starttile],(FCurrentPieceRect.Right-FCurrentPieceRect.Left)*3);
end;

procedure TMapCombineThreadKMZ.saveRECT;
var
  iNChannels, iWidth, iHeight: integer;
  k,i,j: integer;
  jcprops: TJPEG_CORE_PROPERTIES;
  Ckml:TMapCalibrationKml;
  BufRect:TRect;
  FileName:string;

  kmlm,jpgm:TMemoryStream;
  LL1, LL2: TExtendedPoint;
  str: UTF8String;
  VFileName: String;
  bFMapPieceSizey:integer;
  nim:TPoint;

  Zip:TKaZip;
begin
  nim.X:=(FMapPieceSize.X div 1024)+1;
  nim.Y:=(FMapPieceSize.Y div 1024)+1;

  bFMapPieceSizey:=FMapPieceSize.y;

  iWidth  := FMapPieceSize.X div (nim.X);
  iHeight := FMapPieceSize.y div (nim.Y);

  FMapPieceSize.y:=iHeight;

  FProgressForm.ProgressBar1.Max := iHeight;

  if ((nim.X*nim.Y)>100)and(FNumImgsSaved=0) then begin
    FMessageForShow:=SAS_MSG_GarminMax1Mp;
    Synchronize(SynShowMessage);
  end;
  BufRect:=FCurrentPieceRect;

  Zip:=TKaZip.Create(nil);
  Zip.FileName:=ChangeFileExt(FCurrentFileName,'.kmz');
  Zip.CreateZip(ChangeFileExt(FCurrentFileName,'.kmz'));
  Zip.CompressionType:=ctFast;
  Zip.Active := true;
  //Zip.Open(ChangeFileExt(FCurrentFileName,'.kmz'));

  kmlm:=TMemoryStream.Create;
  str := ansiToUTF8('<?xml version="1.0" encoding="UTF-8"?>' + #13#10+'<kml xmlns="http://earth.google.com/kml/2.2">'+#13#10+'<Folder>'+#13#10+'<name>'+ExtractFileName(FCurrentFileName)+'</name>'+#13#10);

  for i:=1 to nim.X do begin
    for j:=1 to nim.Y do begin
      FShowOnFormLine0:=SAS_STR_Resolution+': '+inttostr(FMapPieceSize.X)+'x'+inttostr(bFMapPieceSizey)+' ('+inttostr((i-1)*nim.Y+j)+'/'+inttostr(nim.X*nim.Y)+')';
      jpgm:=TMemoryStream.Create;
      FileName:=ChangeFileExt(FCurrentFileName,inttostr(i)+inttostr(j)+'.jpg');
      VFileName:='files/'+ExtractFileName(FileName);
      try
        str := str + ansiToUTF8('<GroundOverlay>'+#13#10+'<name>' + ExtractFileName(FileName) + '</name>'+#13#10+'<drawOrder>75</drawOrder>'+#13#10);
        str := str + ansiToUTF8('<Icon><href>' + VFileName + '</href>' + '<viewBoundScale>0.75</viewBoundScale></Icon>'+#13#10);

        FCurrentPieceRect.Left := BufRect.Left + iWidth * (i-1);
        FCurrentPieceRect.Right := BufRect.Left + iWidth * i;
        FCurrentPieceRect.Top := BufRect.Top + iHeight * (j-1);
        FCurrentPieceRect.Bottom := BufRect.Top + iHeight * j;

        Synchronize(UpdateProgressFormStr1);

        sx:=(FCurrentPieceRect.Left mod 256);
        sy:=(FCurrentPieceRect.Top mod 256);
        ex:=(FCurrentPieceRect.Right mod 256);
        ey:=(FCurrentPieceRect.Bottom mod 256);

        LL1 := FTypeMap.GeoConvert.PixelPos2LonLat(FCurrentPieceRect.TopLeft, FZoom);
        LL2 := FTypeMap.GeoConvert.PixelPos2LonLat(FCurrentPieceRect.BottomRight, FZoom);
        str := str + ansiToUTF8('<LatLonBox>'+#13#10);
        str := str + ansiToUTF8('<north>' + R2StrPoint(LL1.y) + '</north>' + #13#10);
        str := str + ansiToUTF8('<south>' + R2StrPoint(LL2.y) + '</south>' + #13#10);
        str := str + ansiToUTF8('<east>' + R2StrPoint(LL2.x) + '</east>' + #13#10);
        str := str + ansiToUTF8('<west>' + R2StrPoint(LL1.x) + '</west>' + #13#10);
        str := str + ansiToUTF8('</LatLonBox>'+#13#10+'</GroundOverlay>'+#13#10);

        getmem(FArray256BGR,256*sizeof(P256ArrayBGR));
        for k:=0 to 255 do getmem(FArray256BGR[k],(iWidth+1)*3);
        btmm:=TBitmap32.Create;
        btmh:=TBitmap32.Create;
        btmm.Width:=256;
        btmm.Height:=256;
        btmh.Width:=256;
        btmh.Height:=256;

        ijlInit(@jcprops);
        iNChannels := 3;
        jcprops.DIBWidth := iWidth;
        jcprops.DIBHeight := -iHeight;
        jcprops.DIBChannels := iNChannels;
        jcprops.DIBColor := IJL_BGR;
        jcprops.DIBPadBytes := ((((iWidth*iNChannels)+3) div 4)*4)-(iWidth*3);
        new(jcprops.DIBBytes);
        GetMem(jcprops.DIBBytes,(iWidth*3+ (iWidth mod 4))*iHeight);
        jcprops.JPGSizeBytes := iWidth*iHeight * 3;
        GetMem(jcprops.JPGBytes, jcprops.JPGSizeBytes);
        if jcprops.DIBBytes<>nil then begin
          for k:=0 to iHeight-1 do begin
            ReadLineBMP(k,Pointer(integer(jcprops.DIBBytes)+(((iWidth*3+ (iWidth mod 4))*iHeight)-(iWidth*3+ (iWidth mod 4))*(k+1))));
            if IsCancel then break;
          end;
        end else begin
          FMessageForShow:=SAS_ERR_Memory+'.'+#13#10+SAS_ERR_UseADifferentFormat;
          Synchronize(SynShowMessage);
          exit;
        end;
        jcprops.JPGWidth := iWidth;
        jcprops.JPGHeight := iHeight;
        jcprops.JPGChannels := 3;
        jcprops.JPGColor := IJL_YCBCR;
        jcprops.jquality := FQuality;
        ijlWrite(@jcprops, IJL_JBUFF_WRITEWHOLEIMAGE);
        jpgm.Write(jcprops.JPGBytes^, jcprops.JPGSizeBytes);
        jpgm.Position:=0;
        Zip.AddStream(VFileName,jpgm);
      Finally
        freemem(jcprops.DIBBytes,iWidth*iHeight*3);
        for k:=0 to 255 do freemem(FArray256BGR[k],(iWidth+1)*3);
        freemem(FArray256BGR,256*((iWidth+1)*3));
        ijlFree(@jcprops);
        btmm.Free;
        btmh.Free;
        jpgm.Free;
      end;
    end;
  end;
  FMapPieceSize.y:=bFMapPieceSizey;
  str := str + ansiToUTF8('</Folder>'+#13#10+'</kml>');
  kmlm.Write(str[1],length(str));
  kmlm.Position:=0;
  Zip.AddStream('doc.kml',kmlm);
  Zip.Active := false;
  Zip.Close;
  Zip.Free;
  kmlm.Free;
  inc(FNumImgsSaved);
end;

end.
