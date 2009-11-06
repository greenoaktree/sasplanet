unit u_CoordConverterAbstract;

interface

uses
  Types,
  i_ICoordConverter,
  t_GeoTypes;

type
  TCoordConverterAbstract = class(TInterfacedObject, ICoordConverter)
  protected
    FValidLonLatRect: TExtendedRect;
    function GetValidLonLatRect: TExtendedRect; virtual;

    procedure CheckZoomInternal(var AZoom: Byte); virtual;
    procedure CheckTilePosInternal(var XY: TPoint; var Azoom: byte); virtual;
    procedure CheckTilePosStrictInternal(var XY: TPoint; var Azoom: byte); virtual;
    procedure CheckTileRectInternal(var XY: TRect; var Azoom: byte); virtual;

    procedure CheckPixelPosInternal(var XY: TPoint; var Azoom: byte); virtual;
    procedure CheckPixelPosStrictInternal(var XY: TPoint; var Azoom: byte); virtual;
    procedure CheckPixelRectInternal(var XY: TRect; var Azoom: byte); virtual;

    procedure CheckRelativePosInternal(var XY: TExtendedPoint); virtual;
    procedure CheckRelativeRectInternal(var XY: TExtendedRect); virtual;

    procedure CheckLonLatPosInternal(var XY: TExtendedPoint); virtual;
    procedure CheckLonLatRectInternal(var XY: TExtendedRect); virtual;

    function Pos2LonLatInternal(const XY: TPoint; Azoom: byte): TExtendedPoint; virtual; stdcall;
    function LonLat2PosInternal(const Ll: TExtendedPoint; Azoom: byte): Tpoint; virtual; stdcall;
    function LonLat2MetrInternal(const Ll: TExtendedPoint): TExtendedPoint; virtual; stdcall; abstract;

    function TilesAtZoomInternal(AZoom: byte): Longint; virtual; stdcall;
    function PixelsAtZoomInternal(AZoom: byte): Longint; virtual; stdcall;


    function TilePos2PixelPosInternal(const XY: TPoint; Azoom: byte): TPoint; virtual; stdcall;
    function TilePos2PixelRectInternal(const XY: TPoint; Azoom: byte): TRect; virtual; stdcall;
    function TilePos2LonLatRectInternal(const XY: TPoint; Azoom: byte): TExtendedRect; virtual; stdcall;
    function TilePos2LonLatInternal(const XY: TPoint; Azoom: byte): TExtendedPoint; virtual; stdcall;
    function TilePos2RelativeInternal(const XY: TPoint; Azoom: byte): TExtendedPoint; virtual; stdcall;
    function TilePos2RelativeRectInternal(const XY: TPoint; Azoom: byte): TExtendedRect; virtual; stdcall;
    function TileRect2PixelRectInternal(const XY: TRect; AZoom: byte): TRect; virtual; stdcall;
    function TileRect2RelativeRectInternal(const XY: TRect; AZoom: byte): TExtendedRect; virtual; stdcall;
    function TileRect2LonLatRectInternal(const XY: TRect; Azoom: byte): TExtendedRect; virtual; stdcall;

    function PixelPos2LonLatInternal(const XY: TPoint; Azoom: byte): TExtendedPoint; virtual; stdcall;
    function PixelPos2TilePosInternal(const XY: TPoint; Azoom: byte): TPoint; virtual; stdcall;
    function PixelPos2RelativeInternal(const XY: TPoint; Azoom: byte): TExtendedPoint; virtual; stdcall;
    function PixelRect2TileRectInternal(const XY: TRect; AZoom: byte): TRect; virtual; stdcall;
    function PixelRect2RelativeRectInternal(const XY: TRect; AZoom: byte): TExtendedRect; virtual; stdcall;
    function PixelRect2LonLatRectInternal(const XY: TRect; AZoom: byte): TExtendedRect; virtual; stdcall;

    function Relative2PixelInternal(const XY: TExtendedPoint; Azoom: byte): TPoint; virtual; stdcall;
    function Relative2TileInternal(const XY: TExtendedPoint; Azoom: byte): TPoint; virtual; stdcall;
    function Relative2LonLatInternal(const XY: TExtendedPoint): TExtendedPoint; virtual; stdcall; abstract;
    function RelativeRect2LonLatRectInternal(const XY: TExtendedRect): TExtendedRect; virtual; stdcall;
    function RelativeRect2TileRectInternal(const XY: TExtendedRect; Azoom: byte): TRect; virtual; stdcall;
    function RelativeRect2PixelRectInternal(const XY: TExtendedRect; Azoom: byte): TRect; virtual; stdcall;


    function LonLat2PixelPosInternal(const Ll: TExtendedPoint; Azoom: byte): Tpoint; virtual; stdcall;
    function LonLat2PixelPosfInternal(const Ll: TExtendedPoint; Azoom: byte): TExtendedPoint; virtual; stdcall;
    function LonLat2TilePosInternal(const Ll: TExtendedPoint; Azoom: byte): Tpoint; virtual; stdcall;
    function LonLat2TilePosfInternal(const Ll: TExtendedPoint; Azoom: byte): TExtendedPoint; virtual; stdcall;
    function LonLat2RelativeInternal(const XY: TExtendedPoint): TExtendedPoint; virtual; stdcall; abstract;
    function LonLatRect2RelativeRectInternal(const XY: TExtendedRect): TExtendedRect; virtual; stdcall;
    function LonLatRect2PixelRectInternal(const XY: TExtendedRect; Azoom: byte): TRect; virtual; stdcall;//TODO: ��������
    function LonLatRect2TileRectInternal(const XY: TExtendedRect; Azoom: byte): TRect; virtual; stdcall;//TODO: ��������
  public
    function Pos2LonLat(const AXY: TPoint; Azoom: byte): TExtendedPoint; virtual; stdcall;
    function LonLat2Pos(const AXY: TExtendedPoint; Azoom: byte): Tpoint; virtual; stdcall;
    function LonLat2Metr(const AXY: TExtendedPoint): TExtendedPoint; virtual; stdcall;

    function TilesAtZoom(AZoom: byte): Longint; virtual; stdcall;
    function PixelsAtZoom(AZoom: byte): Longint; virtual; stdcall;


    function TilePos2PixelPos(const AXY: TPoint; Azoom: byte): TPoint; virtual; stdcall;
    function TilePos2PixelRect(const AXY: TPoint; Azoom: byte): TRect; virtual; stdcall;
    function TilePos2LonLatRect(const AXY: TPoint; Azoom: byte): TExtendedRect; virtual; stdcall;
    function TilePos2LonLat(const AXY: TPoint; Azoom: byte): TExtendedPoint; virtual; stdcall;
    function TilePos2Relative(const AXY: TPoint; Azoom: byte): TExtendedPoint; virtual; stdcall;
    function TilePos2RelativeRect(const AXY: TPoint; Azoom: byte): TExtendedRect; virtual; stdcall;
    function TileRect2PixelRect(const AXY: TRect; AZoom: byte): TRect; virtual; stdcall;
    function TileRect2RelativeRect(const AXY: TRect; AZoom: byte): TExtendedRect; virtual; stdcall;
    function TileRect2LonLatRect(const AXY: TRect; Azoom: byte): TExtendedRect; virtual; stdcall;

    function PixelPos2LonLat(const AXY: TPoint; Azoom: byte): TExtendedPoint; virtual; stdcall;
    function PixelPos2TilePos(const AXY: TPoint; Azoom: byte): TPoint; virtual; stdcall;
    function PixelPos2Relative(const AXY: TPoint; Azoom: byte): TExtendedPoint; virtual; stdcall;
    function PixelRect2TileRect(const AXY: TRect; AZoom: byte): TRect; virtual; stdcall;
    function PixelRect2RelativeRect(const AXY: TRect; AZoom: byte): TExtendedRect; virtual; stdcall;
    function PixelRect2LonLatRect(const AXY: TRect; AZoom: byte): TExtendedRect; virtual; stdcall;


    function LonLat2PixelPos(const AXY: TExtendedPoint; Azoom: byte): Tpoint; virtual; stdcall;
    function LonLat2PixelPosf(const AXY: TExtendedPoint; Azoom: byte): TExtendedPoint; virtual; stdcall;
    function LonLat2TilePos(const AXY: TExtendedPoint; Azoom: byte): Tpoint; virtual; stdcall;
    function LonLat2TilePosf(const AXY: TExtendedPoint; Azoom: byte): TExtendedPoint; virtual; stdcall;
    function LonLat2Relative(const AXY: TExtendedPoint): TExtendedPoint; virtual; stdcall;
    function LonLatRect2RelativeRect(const AXY: TExtendedRect): TExtendedRect; virtual; stdcall;
    function LonLatRect2PixelRect(const AXY: TExtendedRect; Azoom: byte): TRect; virtual; stdcall;//TODO: ��������
    function LonLatRect2TileRect(const AXY: TExtendedRect; Azoom: byte): TRect; virtual; stdcall;//TODO: ��������

    function Relative2Pixel(const AXY: TExtendedPoint; Azoom: byte): TPoint; virtual; stdcall;
    function Relative2Tile(const AXY: TExtendedPoint; Azoom: byte): TPoint; virtual; stdcall;
    function Relative2LonLat(const AXY: TExtendedPoint): TExtendedPoint; virtual; stdcall;
    function RelativeRect2LonLatRect(const AXY: TExtendedRect): TExtendedRect; virtual; stdcall;
    function RelativeRect2TileRect(const AXY: TExtendedRect; Azoom: byte): TRect; virtual; stdcall;
    function RelativeRect2PixelRect(const AXY: TExtendedRect; Azoom: byte): TRect; virtual; stdcall;

    function Pos2OtherMap(XY: TPoint; Azoom: byte; AOtherMapCoordConv: ICoordConverter):TPoint; virtual;
    function CalcPoligonArea(polygon:TExtendedPointArray): Extended; virtual;
    function PoligonProject(AZoom:byte; APolyg: TExtendedPointArray): TPointArray; virtual;
    function CalcDist(AStart: TExtendedPoint; AFinish: TExtendedPoint): Extended; virtual; abstract;

    procedure CheckZoom(var AZoom: Byte); virtual; stdcall;
    procedure CheckTilePos(var XY: TPoint; var Azoom: byte; ACicleMap: Boolean); virtual; stdcall;
    procedure CheckTilePosStrict(var XY: TPoint; var Azoom: byte; ACicleMap: Boolean); virtual; stdcall;
    procedure CheckTileRect(var XY: TRect; var Azoom: byte; ACicleMap: Boolean); virtual; stdcall;

    procedure CheckPixelPos(var XY: TPoint; var Azoom: byte; ACicleMap: Boolean); virtual; stdcall;
    procedure CheckPixelPosStrict(var XY: TPoint; var Azoom: byte; ACicleMap: Boolean); virtual; stdcall;
    procedure CheckPixelRect(var XY: TRect; var Azoom: byte; ACicleMap: Boolean); virtual; stdcall;

    procedure CheckRelativePos(var XY: TExtendedPoint); virtual; stdcall;
    procedure CheckRelativeRect(var XY: TExtendedRect); virtual; stdcall;

    procedure CheckLonLatPos(var XY: TExtendedPoint); virtual; stdcall;
    procedure CheckLonLatRect(var XY: TExtendedRect); virtual; stdcall;

    procedure AfterConstruction; override;
  end;

const
  CTileRelativeEpsilon = (1/(1 shl 30 + (1 shl 30 - 1)))/2;

implementation

uses
  SysUtils,
  Math;

{ TCoordConverterAbstract }

function TCoordConverterAbstract.GetValidLonLatRect: TExtendedRect;
begin
  Result := TilePos2LonLatRectInternal(Point(0, 0), 0);
end;

procedure TCoordConverterAbstract.AfterConstruction;
begin
  inherited;
  FValidLonLatRect := GetValidLonLatRect;
end;

function TCoordConverterAbstract.CalcPoligonArea(
  polygon: TExtendedPointArray): extended;
var
  L,i:integer;
  LLPrev, LLCurr: TExtendedPoint;
begin
  result:=0;
  l:=length(polygon);
  LLPrev := LonLat2MetrInternal(polygon[0]);
  for i:=1 to L-1 do begin
    LLCurr := LonLat2MetrInternal(polygon[i]);
    result := result + (LLPrev.x + LLCurr.x)*(LLPrev.y - LLCurr.y);
    LLPrev := LLCurr;
  end;
  result := 0.5*abs(result)/1000000;
end;

function TCoordConverterAbstract.PoligonProject(AZoom: byte;
  APolyg: TExtendedPointArray): TPointArray;
var
  i:integer;
  VTilesAtZoom: Integer;
begin
  VTilesAtZoom := TilesAtZoomInternal(AZoom);
  SetLength(Result, length(APolyg));
  for i:=0 to length(APolyg)-1 do begin
    Result[i] := LonLat2PosInternal(Apolyg[i], AZoom);
    if Result[i].y < 0 then Result[i].y:=1;
    if Result[i].y > VTilesAtZoom then Result[i].y := VTilesAtZoom - 1;
  end;
end;

function TCoordConverterAbstract.Pos2OtherMap(XY: TPoint; Azoom: byte;
  AOtherMapCoordConv: ICoordConverter): TPoint;
begin
  if (Self = nil) or (AOtherMapCoordConv = nil) then begin
    Result := XY;
  end else begin
    Result := AOtherMapCoordConv.LonLat2Pos(Pos2LonLatInternal(XY, Azoom), Azoom);
  end;
end;


//------------------------------------------------------------------------------
procedure TCoordConverterAbstract.CheckZoomInternal(var AZoom: Byte);
begin
  Exit;
  if AZoom > 23 then begin
    Assert(False, '������� ������� ��� ' + IntToStr(AZoom));
    AZoom := 23;
  end;
end;
procedure TCoordConverterAbstract.CheckTilePosInternal(var XY: TPoint; var Azoom: byte);
var
  VTilesAtZoom: Integer;
begin
  Exit;
  if AZoom > 23 then begin
    Assert(False, '������� ������� ��� ' + IntToStr(AZoom));
    AZoom := 23;
  end;
  VTilesAtZoom := TilesAtZoomInternal(Azoom);
  if XY.X < 0 then begin
    Assert(False, '���������� X ����� �� ����� ���� ������ ����');
    XY.X := 0;
  end else begin
    if XY.X > VTilesAtZoom then begin
      Assert(False, '���������� X ����� �� ���� ���� �� ����� ���� ������ ' + IntToStr(VTilesAtZoom));
      XY.X := VTilesAtZoom;
    end;
  end;

  if XY.Y < 0 then begin
    Assert(False, '���������� Y ����� �� ����� ���� ������ ����');
    XY.Y := 0;
  end else begin
    if XY.Y > VTilesAtZoom then begin
      Assert(False, '���������� Y ����� �� ���� ���� �� ����� ���� ������ ' + IntToStr(VTilesAtZoom));
      XY.Y := VTilesAtZoom;
    end;
  end;
end;
procedure TCoordConverterAbstract.CheckTileRectInternal(var XY: TRect; var Azoom: byte);
var
  VTilesAtZoom: Integer;
begin
  Exit;
  if AZoom > 23 then begin
    Assert(False, '������� ������� ��� ' + IntToStr(AZoom));
    AZoom := 23;
  end;
  VTilesAtZoom := TilesAtZoomInternal(Azoom);
  if XY.Left < 0 then begin
    Assert(False, '���������� X ����� �� ����� ���� ������ ����');
    XY.Left := 0;
  end else begin
    if XY.Left >= VTilesAtZoom then begin
      Assert(False, '���������� X ����� �� ���� ���� �� ����� ���� ������ ��� ����� ' + IntToStr(VTilesAtZoom));
      XY.Left := VTilesAtZoom - 1;
    end;
  end;
  if XY.Top < 0 then begin
    Assert(False, '���������� Y ����� �� ����� ���� ������ ����');
    XY.Top := 0;
  end else begin
    if XY.Top >= VTilesAtZoom then begin
      Assert(False, '���������� Y ����� �� ���� ���� �� ����� ���� ������ ��� ����� ' + IntToStr(VTilesAtZoom));
      XY.Top := VTilesAtZoom - 1;
    end;
  end;
  if XY.Right < 0 then begin
    Assert(False, '���������� X ����� �� ����� ���� ������ ����');
    XY.Right := 0;
  end else begin
    if XY.Right >= VTilesAtZoom then begin
      Assert(False, '���������� X ����� �� ���� ���� �� ����� ���� ������ ��� ����� ' + IntToStr(VTilesAtZoom));
      XY.Right := VTilesAtZoom - 1;
    end;
  end;
  if XY.Bottom < 0 then begin
    Assert(False, '���������� Y ����� �� ����� ���� ������ ����');
    XY.Bottom := 0;
  end else begin
    if XY.Bottom >= VTilesAtZoom then begin
      Assert(False, '���������� Y ����� �� ���� ���� �� ����� ���� ������ ��� ����� ' + IntToStr(VTilesAtZoom));
      XY.Bottom := VTilesAtZoom - 1;
    end;
  end;
end;

procedure TCoordConverterAbstract.CheckTilePosStrictInternal(var XY: TPoint; var Azoom: byte);
var
  VTilesAtZoom: Integer;
begin
  Exit;
  if AZoom > 23 then begin
    Assert(False, '������� ������� ��� ' + IntToStr(AZoom));
    AZoom := 23;
  end;
  VTilesAtZoom := TilesAtZoomInternal(Azoom);
  if XY.X < 0 then begin
    Assert(False, '���������� X ����� �� ����� ���� ������ ����');
    XY.X := 0;
  end else begin
    if XY.X >= VTilesAtZoom then begin
      Assert(False, '���������� X ����� �� ���� ���� �� ����� ���� ������ ��� ������ ' + IntToStr(VTilesAtZoom));
      XY.X := VTilesAtZoom - 1;
    end;
  end;
  if XY.Y < 0 then begin
    Assert(False, '���������� Y ����� �� ����� ���� ������ ����');
    XY.Y := 0;
  end else begin
    if XY.Y >= VTilesAtZoom then begin
      Assert(False, '���������� Y ����� �� ���� ���� �� ����� ���� ������ ��� ������ ' + IntToStr(VTilesAtZoom));
      XY.Y := VTilesAtZoom - 1;
    end;
  end;
end;

procedure TCoordConverterAbstract.CheckPixelPosInternal(var XY: TPoint; var Azoom: byte);
var
  VPixelsAtZoom: Integer;
begin
  Exit;
  if AZoom > 23 then begin
    Assert(False, '������� ������� ��� ' + IntToStr(AZoom));
    AZoom := 23;
  end;
  VPixelsAtZoom := PixelsAtZoomInternal(Azoom);

  if XY.X < 0 then begin
    if (Azoom < 23) or (XY.X <> VPixelsAtZoom) then begin
      Assert(False, '���������� X ������� �� ����� ���� ������ ����');
      XY.X := 0;
    end;
  end else begin
    if (Azoom < 23) and (XY.X > VPixelsAtZoom) then begin
      Assert(False, '���������� X ������� �� ���� ���� �� ����� ���� ������ ' + IntToStr(VPixelsAtZoom));
      XY.X := VPixelsAtZoom;
    end;
  end;

  if XY.Y < 0 then begin
    if (Azoom < 23) or (XY.Y <> VPixelsAtZoom) then begin
      Assert(False, '���������� Y ������� �� ����� ���� ������ ����');
      XY.Y := 0;
    end;
  end else begin
    if (Azoom < 23) and (XY.Y > VPixelsAtZoom) then begin
      Assert(False, '���������� Y ������� �� ���� ���� �� ����� ���� ������ ' + IntToStr(VPixelsAtZoom));
      XY.Y := VPixelsAtZoom;
    end;
  end;

end;
procedure TCoordConverterAbstract.CheckPixelRectInternal(var XY: TRect; var Azoom: byte);
var
  VPixelsAtZoom: Integer;
begin
  Exit;
  if AZoom > 23 then begin
    Assert(False, '������� ������� ��� ' + IntToStr(AZoom));
    AZoom := 23;
  end;
  VPixelsAtZoom := PixelsAtZoomInternal(Azoom);

  if XY.Left < 0 then begin
    Assert(False, '���������� X ������� �� ����� ���� ������ ����');
    XY.Left := 0;
  end else begin
    if (Azoom < 23) and (XY.Left >= VPixelsAtZoom) then begin
      Assert(False, '���������� X ������� �� ���� ���� �� ����� ���� ������ ��� ����� ' + IntToStr(VPixelsAtZoom));
      XY.Left := VPixelsAtZoom - 1;
    end;
  end;

  if XY.Top < 0 then begin
    Assert(False, '���������� Y ������� �� ����� ���� ������ ����');
    XY.Top := 0;
  end else begin
    if (Azoom < 23) and (XY.Top > VPixelsAtZoom) then begin
      Assert(False, '���������� Y ������� �� ���� ���� �� ����� ���� ������ ��� �����' + IntToStr(VPixelsAtZoom));
      XY.Top := VPixelsAtZoom - 1;
    end;
  end;

  if XY.Right < 0 then begin
    Assert(False, '���������� X ������� �� ����� ���� ������ ����');
    XY.Right := 0;
  end else begin
    if (Azoom < 23) and (XY.Right >= VPixelsAtZoom) then begin
      Assert(False, '���������� X ������� �� ���� ���� �� ����� ���� ������ ��� ����� ' + IntToStr(VPixelsAtZoom));
      XY.Right := VPixelsAtZoom - 1;
    end;
  end;

  if XY.Bottom < 0 then begin
    Assert(False, '���������� Y ������� �� ����� ���� ������ ����');
    XY.Bottom := 0;
  end else begin
    if (Azoom < 23) and (XY.Bottom > VPixelsAtZoom) then begin
      Assert(False, '���������� Y ������� �� ���� ���� �� ����� ���� ������ ��� �����' + IntToStr(VPixelsAtZoom));
      XY.Bottom := VPixelsAtZoom - 1;
    end;
  end;
end;
procedure TCoordConverterAbstract.CheckPixelPosStrictInternal(var XY: TPoint; var Azoom: byte);
var
  VPixelsAtZoom: Integer;
begin
  Exit;
  if AZoom > 23 then begin
    Assert(False, '������� ������� ��� ' + IntToStr(AZoom));
    AZoom := 23;
  end;
  VPixelsAtZoom := PixelsAtZoomInternal(Azoom);
  if XY.X < 0 then begin
    Assert(False, '���������� X ������� �� ����� ���� ������ ����');
    XY.X := 0;
  end else begin
    if (Azoom < 23) and (XY.X >= VPixelsAtZoom) then begin
      Assert(False, '���������� X ������� �� ���� ���� �� ����� ���� ������ ��� ����� ' + IntToStr(VPixelsAtZoom));
      XY.X := VPixelsAtZoom - 1;
    end;
  end;

  if XY.Y < 0 then begin
    Assert(False, '���������� Y ������� �� ����� ���� ������ ����');
    XY.Y := 0;
  end else begin
    if (Azoom < 23) and (XY.Y > VPixelsAtZoom) then begin
      Assert(False, '���������� Y ������� �� ���� ���� �� ����� ���� ������ ��� �����' + IntToStr(VPixelsAtZoom));
      XY.Y := VPixelsAtZoom - 1;
    end;
  end;
end;

procedure TCoordConverterAbstract.CheckRelativePosInternal(var XY: TExtendedPoint);
begin
  Exit;
  if XY.X < 0 then begin
    Assert(False, '������������� ���������� X �� ����� ���� ������ ����');
    XY.X := 0;
  end else begin
    if XY.X > 1 then begin
      Assert(False, '������������� ���������� X �� ����� ���� ������ �������');
      XY.X := 1;
    end;
  end;

  if XY.Y < 0 then begin
    Assert(False, '������������� ���������� Y �� ����� ���� ������ ����');
    XY.Y := 0;
  end else begin
    if XY.Y > 1 then begin
      Assert(False, '������������� ���������� Y �� ����� ���� ������ �������');
      XY.Y := 1;
    end;
  end;
end;
procedure TCoordConverterAbstract.CheckRelativeRectInternal(var XY: TExtendedRect);
begin
  Exit;
  if XY.Left < 0 then begin
    Assert(False, '������������� ���������� X �� ����� ���� ������ ����');
    XY.Left := 0;
  end else begin
    if XY.Left > 1 then begin
      Assert(False, '������������� ���������� X �� ����� ���� ������ �������');
      XY.Left := 1;
    end;
  end;

  if XY.Top < 0 then begin
    Assert(False, '������������� ���������� Y �� ����� ���� ������ ����');
    XY.Top := 0;
  end else begin
    if XY.Top > 1 then begin
      Assert(False, '������������� ���������� Y �� ����� ���� ������ �������');
      XY.Top := 1;
    end;
  end;

  if XY.Right < 0 then begin
    Assert(False, '������������� ���������� X �� ����� ���� ������ ����');
    XY.Right := 0;
  end else begin
    if XY.Right > 1 then begin
      Assert(False, '������������� ���������� X �� ����� ���� ������ �������');
      XY.Right := 1;
    end;
  end;

  if XY.Bottom < 0 then begin
    Assert(False, '������������� ���������� Y �� ����� ���� ������ ����');
    XY.Bottom := 0;
  end else begin
    if XY.Bottom > 1 then begin
      Assert(False, '������������� ���������� Y �� ����� ���� ������ �������');
      XY.Bottom := 1;
    end;
  end;
end;

procedure TCoordConverterAbstract.CheckLonLatPosInternal(var XY: TExtendedPoint);
begin
  Exit;
  if XY.X < FValidLonLatRect.Left then begin
    Assert(False, '������� �� ����� ���� ������ ��� ' + FloatToStr(FValidLonLatRect.Left));
    XY.X := FValidLonLatRect.Left;
  end else begin
    if XY.X > FValidLonLatRect.Right then begin
      Assert(False, '������� �� ����� ���� ������ ��� ' + FloatToStr(FValidLonLatRect.Right));
      XY.X := FValidLonLatRect.Right;
    end;
  end;
  if XY.Y < FValidLonLatRect.Bottom then begin
    Assert(False, '������ �� ����� ���� ������ ��� ' + FloatToStr(FValidLonLatRect.Bottom));
    XY.Y := FValidLonLatRect.Bottom;
  end else begin
    if XY.Y > FValidLonLatRect.Top then begin
      Assert(False, '������ �� ����� ���� ������ ��� ' + FloatToStr(FValidLonLatRect.Top));
      XY.Y := FValidLonLatRect.Top;
    end;
  end;
end;
procedure TCoordConverterAbstract.CheckLonLatRectInternal(var XY: TExtendedRect);
begin
  Exit;
  if XY.Left < FValidLonLatRect.Left then begin
    Assert(False, '������� �� ����� ���� ������ ��� ' + FloatToStr(FValidLonLatRect.Left));
    XY.Left := FValidLonLatRect.Left;
  end else begin
    if XY.Left > FValidLonLatRect.Right then begin
      Assert(False, '������� �� ����� ���� ������ ��� ' + FloatToStr(FValidLonLatRect.Right));
      XY.Left := FValidLonLatRect.Right;
    end;
  end;
  if XY.Bottom < FValidLonLatRect.Bottom then begin
    Assert(False, '������ �� ����� ���� ������ ��� ' + FloatToStr(FValidLonLatRect.Bottom));
    XY.Bottom := FValidLonLatRect.Bottom;
  end else begin
    if XY.Bottom > FValidLonLatRect.Top then begin
      Assert(False, '������ �� ����� ���� ������ ��� ' + FloatToStr(FValidLonLatRect.Top));
      XY.Bottom := FValidLonLatRect.Top;
    end;
  end;

  if XY.Right < FValidLonLatRect.Right then begin
    Assert(False, '������� �� ����� ���� ������ ��� ' + FloatToStr(FValidLonLatRect.Right));
    XY.Right := FValidLonLatRect.Right;
  end else begin
    if XY.Right > FValidLonLatRect.Right then begin
      Assert(False, '������� �� ����� ���� ������ ��� ' + FloatToStr(FValidLonLatRect.Right));
      XY.Right := FValidLonLatRect.Right;
    end;
  end;
  if XY.Top < FValidLonLatRect.Top then begin
    Assert(False, '������ �� ����� ���� ������ ��� ' + FloatToStr(FValidLonLatRect.Top));
    XY.Top := FValidLonLatRect.Top;
  end else begin
    if XY.Top > FValidLonLatRect.Top then begin
      Assert(False, '������ �� ����� ���� ������ ��� ' + FloatToStr(FValidLonLatRect.Top));
      XY.Top := FValidLonLatRect.Top;
    end;
  end;
end;


//------------------------------------------------------------------------------
procedure TCoordConverterAbstract.CheckZoom(var AZoom: Byte);
begin
  if AZoom > 23 then begin
    AZoom := 23;
  end;
end;
procedure TCoordConverterAbstract.CheckTilePos(var XY: TPoint; var Azoom: byte; ACicleMap: Boolean);
var
  VTilesAtZoom: Integer;
begin
  if AZoom > 23 then begin
    AZoom := 23;
  end;
  VTilesAtZoom := TilesAtZoom(Azoom);

  if XY.X < 0 then begin
    if ACicleMap  then begin
      XY.X := XY.X mod VTilesAtZoom + VTilesAtZoom;
    end else begin
      XY.X := 0;
    end;
  end else begin
    if XY.X > VTilesAtZoom then begin
      if ACicleMap  then begin
        XY.X := XY.X mod VTilesAtZoom;
      end else begin
        XY.X := VTilesAtZoom;
      end;
    end;
  end;

  if XY.Y < 0 then begin
    XY.Y := 0;
  end else begin
    if XY.Y > VTilesAtZoom then begin
      XY.Y := VTilesAtZoom;
    end;
  end;
end;
procedure TCoordConverterAbstract.CheckTileRect(var XY: TRect; var Azoom: byte; ACicleMap: Boolean);
var
  VTilesAtZoom: Integer;
begin
  if AZoom > 23 then begin
    AZoom := 23;
  end;
  VTilesAtZoom := TilesAtZoom(Azoom);

  if XY.Left < 0 then begin
    if ACicleMap  then begin
      XY.Left := XY.Left mod VTilesAtZoom + VTilesAtZoom;
    end else begin
      XY.Left := 0;
    end;
  end else begin
    if XY.Left >= VTilesAtZoom then begin
      if ACicleMap  then begin
        XY.Left := XY.Left mod VTilesAtZoom;
      end else begin
        XY.Left := VTilesAtZoom - 1;
      end;
    end;
  end;

  if XY.Top < 0 then begin
    XY.Top := 0;
  end else begin
    if XY.Top >= VTilesAtZoom then begin
      XY.Top := VTilesAtZoom - 1;
    end;
  end;

  if XY.Right < 0 then begin
    if ACicleMap  then begin
      XY.Right := XY.Right mod VTilesAtZoom + VTilesAtZoom;
    end else begin
      XY.Right := 0;
    end;
  end else begin
    if XY.Right >= VTilesAtZoom then begin
      if ACicleMap  then begin
        XY.Right := XY.Right mod VTilesAtZoom;
      end else begin
        XY.Right := VTilesAtZoom - 1;
      end;
    end;
  end;

  if XY.Bottom < 0 then begin
    XY.Bottom := 0;
  end else begin
    if XY.Bottom >= VTilesAtZoom then begin
      XY.Bottom := VTilesAtZoom - 1;
    end;
  end;
end;

procedure TCoordConverterAbstract.CheckTilePosStrict(var XY: TPoint; var Azoom: byte; ACicleMap: Boolean);
var
  VTilesAtZoom: Integer;
begin
  if AZoom > 23 then begin
    AZoom := 23;
  end;
  VTilesAtZoom := TilesAtZoom(Azoom);

  if XY.X < 0 then begin
    if ACicleMap  then begin
      XY.X := XY.X mod VTilesAtZoom + VTilesAtZoom;
    end else begin
      XY.X := 0;
    end;
  end else begin
    if XY.X >= VTilesAtZoom then begin
      if ACicleMap  then begin
        XY.X := XY.X mod VTilesAtZoom;
      end else begin
        XY.X := VTilesAtZoom - 1;
      end;
    end;
  end;

  if XY.Y < 0 then begin
    XY.Y := 0;
  end else begin
    if XY.Y >= VTilesAtZoom then begin
      XY.Y := VTilesAtZoom - 1;
    end;
  end;
end;

procedure TCoordConverterAbstract.CheckPixelPos(var XY: TPoint; var Azoom: byte; ACicleMap: Boolean);
var
  VPixelsAtZoom: Integer;
begin
  if AZoom > 23 then begin
    AZoom := 23;
  end;
  VPixelsAtZoom := PixelsAtZoom(Azoom);

  if XY.X < 0 then begin
    if (Azoom < 23) then begin
      if ACicleMap  then begin
        XY.X := XY.X mod VPixelsAtZoom + VPixelsAtZoom;
      end else begin
        XY.X := 0;
      end;
    end else begin
      if (XY.X <> VPixelsAtZoom) then begin
        if ACicleMap  then begin
          XY.X := VPixelsAtZoom - XY.X;
        end else begin
          XY.X := 0;
        end;
      end;
    end;
  end else begin
    if (Azoom < 23) and (XY.X > VPixelsAtZoom) then begin
      XY.X := VPixelsAtZoom;
    end;
  end;

  if XY.Y < 0 then begin
    if (Azoom < 23) or (XY.Y <> VPixelsAtZoom) then begin
      XY.Y := 0;
    end;
  end else begin
    if (Azoom < 23) and (XY.Y > VPixelsAtZoom) then begin
      if ACicleMap  then begin
        XY.X := XY.X mod VPixelsAtZoom;
      end else begin
        XY.X := VPixelsAtZoom;
      end;
    end;
  end;
end;

procedure TCoordConverterAbstract.CheckPixelRect(var XY: TRect; var Azoom: byte; ACicleMap: Boolean);
var
  VPixelsAtZoom: Integer;
begin
  if AZoom > 23 then begin
    AZoom := 23;
  end;
  VPixelsAtZoom := PixelsAtZoom(Azoom);

  if XY.Left < 0 then begin
    if ACicleMap then begin
      XY.Left := XY.Left mod VPixelsAtZoom + VPixelsAtZoom;
    end else begin
      XY.Left := 0;
    end;
  end else begin
    if (Azoom < 23) and (XY.Left >= VPixelsAtZoom) then begin
      if ACicleMap then begin
        XY.Left := XY.Left mod VPixelsAtZoom;
      end else begin
        XY.Left := VPixelsAtZoom - 1;
      end;
    end;
  end;

  if XY.Top < 0 then begin
    XY.Top := 0;
  end else begin
    if (Azoom < 23) and (XY.Top > VPixelsAtZoom) then begin
      XY.Top := VPixelsAtZoom - 1;
    end;
  end;

  if XY.Right < 0 then begin
    if ACicleMap then begin
      XY.Right := XY.Right mod VPixelsAtZoom + VPixelsAtZoom;
    end else begin
      XY.Right := 0;
    end;
  end else begin
    if (Azoom < 23) and (XY.Right >= VPixelsAtZoom) then begin
      if ACicleMap then begin
        XY.Right := XY.Right mod VPixelsAtZoom;
      end else begin
        XY.Right := VPixelsAtZoom - 1;
      end;
    end;
  end;

  if XY.Bottom < 0 then begin
    XY.Bottom := 0;
  end else begin
    if (Azoom < 23) and (XY.Bottom > VPixelsAtZoom) then begin
      XY.Bottom := VPixelsAtZoom - 1;
    end;
  end;
end;

procedure TCoordConverterAbstract.CheckPixelPosStrict(var XY: TPoint; var Azoom: byte; ACicleMap: Boolean);
var
  VPixelsAtZoom: Integer;
begin
  if AZoom > 23 then begin
    AZoom := 23;
  end;
  VPixelsAtZoom := PixelsAtZoom(Azoom);
  if XY.X < 0 then begin
    if ACicleMap  then begin
      XY.X := XY.X mod VPixelsAtZoom + VPixelsAtZoom;
    end else begin
      XY.X := 0;
    end;
  end else begin
    if (Azoom < 23) and (XY.X >= VPixelsAtZoom) then begin
      if ACicleMap  then begin
        XY.X := XY.X mod VPixelsAtZoom;
      end else begin
        XY.X := VPixelsAtZoom - 1;
      end;
    end;
  end;

  if XY.Y < 0 then begin
    XY.Y := 0;
  end else begin
    if (Azoom < 23) and (XY.Y > VPixelsAtZoom) then begin
      XY.Y := VPixelsAtZoom - 1;
    end;
  end;
end;

procedure TCoordConverterAbstract.CheckRelativePos(var XY: TExtendedPoint);
begin
  if XY.X < 0 then begin
    XY.X := 0;
  end else begin
    if XY.X > 1 then begin
      XY.X := 1;
    end;
  end;

  if XY.Y < 0 then begin
    XY.Y := 0;
  end else begin
    if XY.Y > 1 then begin
      XY.Y := 1;
    end;
  end;
end;

procedure TCoordConverterAbstract.CheckRelativeRect(var XY: TExtendedRect);
begin
  if XY.Left < 0 then begin
    XY.Left := 0;
  end else begin
    if XY.Left > 1 then begin
      XY.Left := 1;
    end;
  end;

  if XY.Top < 0 then begin
    XY.Top := 0;
  end else begin
    if XY.Top > 1 then begin
      XY.Top := 1;
    end;
  end;

  if XY.Right < 0 then begin
    XY.Right := 0;
  end else begin
    if XY.Right > 1 then begin
      XY.Right := 1;
    end;
  end;

  if XY.Bottom < 0 then begin
    XY.Bottom := 0;
  end else begin
    if XY.Bottom > 1 then begin
      XY.Bottom := 1;
    end;
  end;
end;

procedure TCoordConverterAbstract.CheckLonLatPos(var XY: TExtendedPoint);
begin
  if XY.X < FValidLonLatRect.Left then begin
    XY.X := FValidLonLatRect.Left;
  end else begin
    if XY.X > FValidLonLatRect.Right then begin
      XY.X := FValidLonLatRect.Right;
    end;
  end;
  if XY.Y < FValidLonLatRect.Bottom then begin
    XY.Y := FValidLonLatRect.Bottom;
  end else begin
    if XY.Y > FValidLonLatRect.Top then begin
      XY.Y := FValidLonLatRect.Top;
    end;
  end;
end;

procedure TCoordConverterAbstract.CheckLonLatRect(var XY: TExtendedRect);
begin
  if XY.Left < FValidLonLatRect.Left then begin
    XY.Left := FValidLonLatRect.Left;
  end else begin
    if XY.Left > FValidLonLatRect.Right then begin
      XY.Left := FValidLonLatRect.Right;
    end;
  end;
  if XY.Bottom < FValidLonLatRect.Bottom then begin
    XY.Bottom := FValidLonLatRect.Bottom;
  end else begin
    if XY.Bottom > FValidLonLatRect.Top then begin
      XY.Bottom := FValidLonLatRect.Top;
    end;
  end;

  if XY.Right < FValidLonLatRect.Right then begin
    XY.Right := FValidLonLatRect.Right;
  end else begin
    if XY.Right > FValidLonLatRect.Right then begin
      XY.Right := FValidLonLatRect.Right;
    end;
  end;
  if XY.Top < FValidLonLatRect.Top then begin
    XY.Top := FValidLonLatRect.Top;
  end else begin
    if XY.Top > FValidLonLatRect.Top then begin
      XY.Top := FValidLonLatRect.Top;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TCoordConverterAbstract.TilePos2PixelRectInternal(const XY: TPoint;
  Azoom: byte): TRect;
begin
  Result.Left := XY.X shl 8;
  Result.Top := XY.Y shl 8;
  Result.Right := Result.Left + ((1 shl 8) - 1);
  Result.Bottom := Result.Top + ((1 shl 8) - 1);
end;

function TCoordConverterAbstract.TilePos2LonLatRectInternal(const XY: TPoint;
  Azoom: byte): TExtendedRect;
begin
  Result := RelativeRect2LonLatRectInternal(TilePos2RelativeRectInternal(XY, Azoom));
end;

function TCoordConverterAbstract.PixelsAtZoomInternal(AZoom: byte): Longint;
begin
  Result := 1 shl (AZoom + 8);
end;

function TCoordConverterAbstract.TilesAtZoomInternal(AZoom: byte): Longint;
begin
  Result := 1 shl AZoom;
end;

function TCoordConverterAbstract.PixelPos2RelativeInternal(const XY: TPoint;
  Azoom: byte): TExtendedPoint;
var
  VPixelsAtZoomExt: Extended;
  VPixelsAtZoom: Integer;
begin
  VPixelsAtZoom := PixelsAtZoomInternal(Azoom);
  VPixelsAtZoomExt := VPixelsAtZoom;
  VPixelsAtZoomExt := abs(VPixelsAtZoomExt);
  if XY.X = VPixelsAtZoom then
    Result.X := 1
  else
    Result.X := XY.X / VPixelsAtZoomExt;

  if XY.Y = VPixelsAtZoom then
    Result.Y := 1
  else
    Result.Y := XY.Y / VPixelsAtZoomExt;
end;

function TCoordConverterAbstract.Relative2PixelInternal(const XY: TExtendedPoint;
  Azoom: byte): TPoint;
var
  VPixelsAtZoom: Extended;
begin
  VPixelsAtZoom := PixelsAtZoomInternal(Azoom);
  VPixelsAtZoom := abs(VPixelsAtZoom);
  Result.X := Trunc(RoundTo(XY.X * VPixelsAtZoom, -2));
  Result.Y := Trunc(RoundTo(XY.Y * VPixelsAtZoom, -2));
end;

function TCoordConverterAbstract.LonLat2PixelPosInternal(const Ll: TExtendedPoint;
  Azoom: byte): Tpoint;
begin
  Result := Relative2PixelInternal(LonLat2RelativeInternal(LL), AZoom);
end;

function TCoordConverterAbstract.LonLat2PixelPosfInternal(const Ll: TExtendedPoint;
  Azoom: byte): TExtendedPoint;
var
  VPixelsAtZoom: Extended;
begin
  VPixelsAtZoom := PixelsAtZoomInternal(Azoom);
  VPixelsAtZoom := abs(VPixelsAtZoom);

  Result := LonLat2RelativeInternal(LL);
  Result.X := Result.X * VPixelsAtZoom;
  Result.Y := Result.Y * VPixelsAtZoom;
end;

function TCoordConverterAbstract.LonLat2TilePosInternal(const Ll: TExtendedPoint;
  Azoom: byte): Tpoint;
begin
  Result := Relative2TileInternal(LonLat2RelativeInternal(LL), AZoom);
end;

function TCoordConverterAbstract.PixelPos2LonLatInternal(const XY: TPoint;
  Azoom: byte): TExtendedPoint;
begin
  Result := Relative2LonLatInternal(PixelPos2RelativeInternal(XY, Azoom));
end;

function TCoordConverterAbstract.TilePos2LonLatInternal(const XY: TPoint;
  Azoom: byte): TExtendedPoint;
begin
  Result := Relative2LonLatInternal(TilePos2RelativeInternal(XY, Azoom));
end;

function TCoordConverterAbstract.TilePos2RelativeInternal(const XY: TPoint;
  Azoom: byte): TExtendedPoint;
var
  VTilesAtZoom: Extended;
begin
  VTilesAtZoom := TilesAtZoomInternal(Azoom);
  Result.X := XY.X / VTilesAtZoom;
  Result.Y := XY.Y / VTilesAtZoom;
end;

function TCoordConverterAbstract.TilePos2RelativeRectInternal(const XY: TPoint;
  Azoom: byte): TExtendedRect;
var
  VTilesAtZoom: Extended;
begin
  VTilesAtZoom := TilesAtZoomInternal(Azoom);
  Result.Left := XY.X / VTilesAtZoom;
  Result.Top := XY.Y / VTilesAtZoom;
  Result.Right := (XY.X + 1) / VTilesAtZoom;
  Result.Bottom := (XY.Y + 1) / VTilesAtZoom;
end;

function TCoordConverterAbstract.LonLatRect2RelativeRectInternal(
  const XY: TExtendedRect): TExtendedRect;
begin
  Result.TopLeft := LonLat2RelativeInternal(XY.TopLeft);
  Result.BottomRight := LonLat2RelativeInternal(XY.BottomRight);
end;

function TCoordConverterAbstract.Relative2TileInternal(const XY: TExtendedPoint;
  Azoom: byte): TPoint;
var
  VTilesAtZoom: Extended;
begin
  VTilesAtZoom := TilesAtZoomInternal(Azoom);
  Result.X := Trunc(RoundTo(XY.X * VTilesAtZoom, -2));
  Result.Y := Trunc(RoundTo(XY.Y * VTilesAtZoom, -2));
end;

function TCoordConverterAbstract.RelativeRect2LonLatRectInternal(
  const XY: TExtendedRect): TExtendedRect;
begin
  Result.TopLeft := Relative2LonLatInternal(XY.TopLeft);
  Result.BottomRight := Relative2LonLatInternal(XY.BottomRight);
end;

function TCoordConverterAbstract.RelativeRect2PixelRectInternal(const XY: TExtendedRect;
  Azoom: byte): TRect;
var
  VPixelsAtZoom: Extended;
begin
  VPixelsAtZoom := PixelsAtZoomInternal(Azoom);
  VPixelsAtZoom := abs(VPixelsAtZoom);

  Result.Left := Trunc((XY.Left + CTileRelativeEpsilon) * VPixelsAtZoom);
  Result.Top := Trunc((XY.Top + CTileRelativeEpsilon) * VPixelsAtZoom);

  Result.Right := Trunc((XY.Right - CTileRelativeEpsilon) * VPixelsAtZoom);
  Result.Bottom := Trunc((XY.Bottom - CTileRelativeEpsilon) * VPixelsAtZoom);
end;

function TCoordConverterAbstract.RelativeRect2TileRectInternal(const XY: TExtendedRect;
  Azoom: byte): TRect;
var
  VTilesAtZoom: Extended;
begin
  VTilesAtZoom := TilesAtZoomInternal(Azoom);

  Result.Left := Trunc((XY.Left + CTileRelativeEpsilon) * VTilesAtZoom);
  Result.Top := Trunc((XY.Top + CTileRelativeEpsilon) * VTilesAtZoom);

  Result.Right := Trunc((XY.Right - CTileRelativeEpsilon) * VTilesAtZoom);
  Result.Bottom := Trunc((XY.Bottom - CTileRelativeEpsilon) * VTilesAtZoom);
end;

function TCoordConverterAbstract.PixelPos2TilePosInternal(const XY: TPoint;
  Azoom: byte): TPoint;
begin
  Result.X := XY.X shr 8;
  Result.Y := XY.Y shr 8;
end;

function TCoordConverterAbstract.PixelRect2TileRectInternal(const XY: TRect;
  AZoom: byte): TRect;
begin
  Result.Left := XY.Left shr 8;
  Result.Top := XY.Top shr 8;
  Result.Right := XY.Right shr 8;
  Result.Bottom := XY.Bottom shr 8;
end;

function TCoordConverterAbstract.TileRect2PixelRectInternal(const XY: TRect;
  AZoom: byte): TRect;
begin
  Result.Left := XY.Left shl 8;
  Result.Top := XY.Top shl 8;
  Result.Right := (XY.Right + 1) shl 8 - 1;
  Result.Bottom := (XY.Bottom + 1) shl 8 - 1;
end;

function TCoordConverterAbstract.LonLatRect2PixelRectInternal(
  const XY: TExtendedRect; Azoom: byte): TRect;
begin
  Result := RelativeRect2PixelRectInternal(LonLatRect2RelativeRectInternal(XY), Azoom);
end;


function TCoordConverterAbstract.LonLatRect2TileRectInternal(
  const XY: TExtendedRect; Azoom: byte): TRect;
begin
  Result := RelativeRect2TileRectInternal(LonLatRect2RelativeRectInternal(XY), Azoom);
end;

function TCoordConverterAbstract.TileRect2LonLatRectInternal(
  const XY: TRect; Azoom: byte): TExtendedRect;
begin
  Result := RelativeRect2LonLatRectInternal(TileRect2RelativeRectInternal(XY, Azoom));
end;

function TCoordConverterAbstract.TileRect2RelativeRectInternal(
  const XY: TRect; AZoom: byte): TExtendedRect;
var
  VTilesAtZoom: Extended;
begin
  VTilesAtZoom := TilesAtZoomInternal(Azoom);
  Result.Left := XY.Left / VTilesAtZoom;
  Result.Top := XY.Top / VTilesAtZoom;
  Result.Right := XY.Right / VTilesAtZoom;
  Result.Bottom := XY.Bottom / VTilesAtZoom;
end;

function TCoordConverterAbstract.PixelRect2RelativeRectInternal(const XY: TRect;
  AZoom: byte): TExtendedRect;
var
  VBottomRight: TPoint;
begin
  Result.TopLeft := PixelPos2RelativeInternal(XY.TopLeft, AZoom);
  VBottomRight.X := XY.Right + 1;
  VBottomRight.Y := XY.Bottom + 1;
  Result.BottomRight := PixelPos2RelativeInternal(VBottomRight, AZoom);
end;

function TCoordConverterAbstract.PixelRect2LonLatRectInternal(
  const XY: TRect; AZoom: byte): TExtendedRect;
begin
  Result := RelativeRect2LonLatRectInternal(PixelRect2RelativeRectInternal(XY, AZoom));
end;

function TCoordConverterAbstract.TilePos2PixelPosInternal(const XY: TPoint;
  Azoom: byte): TPoint;
begin
  Result.X := XY.X shl 8;
  Result.Y := XY.Y shl 8;
end;

function TCoordConverterAbstract.LonLat2TilePosfInternal(const Ll: TExtendedPoint;
  Azoom: byte): TExtendedPoint;
var
  VTilesAtZoom: Extended;
begin
  VTilesAtZoom := TilesAtZoomInternal(Azoom);
  Result := LonLat2RelativeInternal(Ll);
  Result.X := Result.X * VTilesAtZoom;
  Result.Y := Result.Y * VTilesAtZoom;
end;

function TCoordConverterAbstract.LonLat2PosInternal(const Ll: TExtendedPoint;
  Azoom: byte): Tpoint;
begin
  if Azoom > 23 then begin
    Result := LonLat2PixelPosInternal(Ll, Azoom - 8);
  end else begin
    Result := LonLat2TilePosInternal(Ll, Azoom);
  end;
end;

function TCoordConverterAbstract.Pos2LonLatInternal(const XY: TPoint;
  Azoom: byte): TExtendedPoint;
begin
  if Azoom > 23 then begin
    Result := PixelPos2LonLatInternal(XY, Azoom - 8);
  end else begin
    Result := TilePos2LonLatInternal(XY, Azoom);
  end;
end;

//------------------------------------------------------------------------------
function TCoordConverterAbstract.TilePos2PixelRect(const AXY: TPoint;
  Azoom: byte): TRect;
var
  VXY: TPoint;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckTilePosStrictInternal(VXY, VZoom);
  Result := TilePos2PixelRectInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.TilePos2LonLatRect(const AXY: TPoint;
  Azoom: byte): TExtendedRect;
var
  VXY: TPoint;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckTilePosStrictInternal(VXY, VZoom);
  Result := TilePos2LonLatRectInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.PixelsAtZoom(AZoom: byte): Longint;
var
  VZoom: Byte;
begin
  VZoom := AZoom;
  CheckZoomInternal(VZoom);
  Result := PixelsAtZoomInternal(Vzoom);
end;

function TCoordConverterAbstract.TilesAtZoom(AZoom: byte): Longint;
var
  VZoom: Byte;
begin
  VZoom := AZoom;
  CheckZoomInternal(VZoom);
  Result := TilesAtZoomInternal(Vzoom);
end;

function TCoordConverterAbstract.PixelPos2Relative(const AXY: TPoint;
  Azoom: byte): TExtendedPoint;
var
  VXY: TPoint;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckPixelPosInternal(VXY, VZoom);
  Result := PixelPos2RelativeInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.Relative2LonLat(
  const AXY: TExtendedPoint): TExtendedPoint;
var
  VXY: TExtendedPoint;
begin
  VXY := AXY;
  CheckRelativePosInternal(VXY);
  Result := Relative2LonLatInternal(VXY);
end;

function TCoordConverterAbstract.Relative2Pixel(const AXY: TExtendedPoint;
  Azoom: byte): TPoint;
var
  VXY: TExtendedPoint;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckRelativePosInternal(VXY);
  CheckZoomInternal(VZoom);
  Result := Relative2PixelInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.LonLat2Metr(
  const AXY: TExtendedPoint): TExtendedPoint;
var
  VXY: TExtendedPoint;
begin
  VXY := AXY;
  CheckLonLatPosInternal(VXY);
  Result := LonLat2MetrInternal(VXY);
end;

function TCoordConverterAbstract.LonLat2PixelPos(const AXY: TExtendedPoint;
  Azoom: byte): Tpoint;
var
  VXY: TExtendedPoint;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckLonLatPosInternal(VXY);
  Result := LonLat2PixelPosInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.LonLat2PixelPosf(const AXY: TExtendedPoint;
  Azoom: byte): TExtendedPoint;
var
  VXY: TExtendedPoint;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckLonLatPosInternal(VXY);
  CheckZoomInternal(VZoom);
  Result := LonLat2PixelPosfInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.PixelPos2LonLat(const AXY: TPoint;
  Azoom: byte): TExtendedPoint;
var
  VXY: TPoint;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckPixelPosInternal(VXY, VZoom);
  Result := PixelPos2LonLatInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.TilePos2LonLat(const AXY: TPoint;
  Azoom: byte): TExtendedPoint;
var
  VXY: TPoint;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckTilePosInternal(VXY, VZoom);
  Result := TilePos2LonLatInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.TilePos2Relative(const AXY: TPoint;
  Azoom: byte): TExtendedPoint;
var
  VXY: TPoint;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckTilePosInternal(VXY, VZoom);
  Result := TilePos2RelativeInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.TilePos2RelativeRect(const AXY: TPoint;
  Azoom: byte): TExtendedRect;
var
  VXY: TPoint;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckTilePosStrictInternal(VXY, VZoom);
  Result := TilePos2RelativeRectInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.LonLatRect2RelativeRect(
  const AXY: TExtendedRect): TExtendedRect;
var
  VXY: TExtendedRect;
begin
  VXY := AXY;
  CheckLonLatRectInternal(VXY);
  Result := LonLatRect2RelativeRectInternal(VXY);
end;

function TCoordConverterAbstract.Relative2Tile(const AXY: TExtendedPoint;
  Azoom: byte): TPoint;
var
  VXY: TExtendedPoint;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckRelativePosInternal(VXY);
  CheckZoomInternal(VZoom);
  Result := Relative2TileInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.RelativeRect2LonLatRect(
  const AXY: TExtendedRect): TExtendedRect;
var
  VXY: TExtendedRect;
begin
  VXY := AXY;
  CheckRelativeRectInternal(VXY);
  Result := RelativeRect2LonLatRectInternal(VXY);
end;

function TCoordConverterAbstract.RelativeRect2PixelRect(const AXY: TExtendedRect;
  Azoom: byte): TRect;
var
  VXY: TExtendedRect;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckRelativeRectInternal(VXY);
  CheckZoomInternal(VZoom);
  Result := RelativeRect2PixelRectInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.RelativeRect2TileRect(const AXY: TExtendedRect;
  Azoom: byte): TRect;
var
  VXY: TExtendedRect;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckRelativeRectInternal(VXY);
  CheckZoomInternal(VZoom);
  Result := RelativeRect2TileRectInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.PixelPos2TilePos(const AXY: TPoint;
  Azoom: byte): TPoint;
var
  VXY: TPoint;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckPixelPosInternal(VXY, VZoom);
  Result := PixelPos2TilePosInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.PixelRect2LonLatRect(const AXY: TRect;
  AZoom: byte): TExtendedRect;
var
  VXY: TRect;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckPixelRectInternal(VXY, VZoom);
  Result := PixelRect2LonLatRectInternal(VXY, Vzoom);
end;


function TCoordConverterAbstract.PixelRect2TileRect(const AXY: TRect;
  AZoom: byte): TRect;
var
  VXY: TRect;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckPixelRectInternal(VXY, VZoom);
  Result := PixelRect2TileRectInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.TileRect2PixelRect(const AXY: TRect;
  AZoom: byte): TRect;
var
  VXY: TRect;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckTileRectInternal(VXY, VZoom);
  Result := TileRect2PixelRectInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.PixelRect2RelativeRect(const AXY: TRect;
  AZoom: byte): TExtendedRect;
var
  VXY: TRect;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckPixelRectInternal(VXY, VZoom);
  Result := PixelRect2RelativeRectInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.TilePos2PixelPos(const AXY: TPoint;
  Azoom: byte): TPoint;
var
  VXY: TPoint;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckTilePosInternal(VXY, VZoom);
  Result := TilePos2PixelPosInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.LonLat2TilePos(const AXY: TExtendedPoint;
  Azoom: byte): Tpoint;
var
  VXY: TExtendedPoint;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckLonLatPosInternal(VXY);
  CheckZoomInternal(VZoom);
  Result := LonLat2TilePosInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.LonLat2TilePosf(const AXY: TExtendedPoint;
  Azoom: byte): TExtendedPoint;
var
  VXY: TExtendedPoint;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckLonLatPosInternal(VXY);
  CheckZoomInternal(VZoom);
  Result := LonLat2TilePosfInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.LonLat2Pos(const AXY: TExtendedPoint;
  Azoom: byte): Tpoint;
var
  VXY: TExtendedPoint;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckLonLatPosInternal(VXY);
  CheckZoomInternal(VZoom);
  Result := LonLat2PosInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.LonLat2Relative(
  const AXY: TExtendedPoint): TExtendedPoint;
var
  VXY: TExtendedPoint;
begin
  VXY := AXY;
  CheckLonLatPosInternal(VXY);
  Result := LonLat2RelativeInternal(VXY);
end;

function TCoordConverterAbstract.Pos2LonLat(const AXY: TPoint;
  Azoom: byte): TExtendedPoint;
var
  VXY: TPoint;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckPixelPosInternal(VXY, VZoom);
  Result := Pos2LonLatInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.TileRect2LonLatRect(const AXY: TRect;
  Azoom: byte): TExtendedRect;
var
  VXY: TRect;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckTileRectInternal(VXY, VZoom);
  Result := TileRect2LonLatRectInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.TileRect2RelativeRect(const AXY: TRect;
  AZoom: byte): TExtendedRect;
var
  VXY: TRect;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckTileRectInternal(VXY, VZoom);
  Result := TileRect2RelativeRectInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.LonLatRect2TileRect(const AXY: TExtendedRect;
  Azoom: byte): TRect;
var
  VXY: TExtendedRect;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckLonLatRectInternal(VXY);
  CheckZoomInternal(VZoom);
  Result := LonLatRect2TileRectInternal(VXY, Vzoom);
end;

function TCoordConverterAbstract.LonLatRect2PixelRect(const AXY: TExtendedRect;
  Azoom: byte): TRect;
var
  VXY: TExtendedRect;
  VZoom: Byte;
begin
  VXY := AXY;
  VZoom := AZoom;
  CheckLonLatRectInternal(VXY);
  CheckZoomInternal(VZoom);
  Result := LonLatRect2PixelRectInternal(VXY, Vzoom);
end;


end.
