unit u_CoordConverterMercatorOnEllipsoid;

interface

uses
  Types,
  t_GeoTypes,
  u_CoordConverterAbstract;

type
  TCoordConverterMercatorOnEllipsoid = class(TCoordConverterAbstract)
  protected
    FExct,FRadiusa,FRadiusb : Extended;
  public
    constructor Create(AExct,Aradiusa,Aradiusb : Extended);
    function Pos2LonLat(XY : TPoint; Azoom : byte) : TExtendedPoint; override;
    function LonLat2Pos(Ll : TExtendedPoint; Azoom : byte) : Tpoint; override;
    function LonLat2Metr(Ll : TExtendedPoint) : TExtendedPoint; override;
    function CalcDist(AStart: TExtendedPoint; AFinish: TExtendedPoint): Extended; override;
  end;

implementation

uses
  Math;
  
const
  MerkElipsK=0.0000001;

{ TCoordConverterMercatorOnEllipsoid }

constructor TCoordConverterMercatorOnEllipsoid.Create(AExct,Aradiusa,Aradiusb: Extended);
begin
  inherited Create();
  FExct := AExct;
  Fradiusa:=Aradiusa;
  Fradiusb:=Aradiusb;
end;

function TCoordConverterMercatorOnEllipsoid.LonLat2Pos(Ll: TExtendedPoint;
  Azoom: byte): Tpoint;
var
  TilesAtZoom : Integer;
  z, c : Extended;
begin
  TilesAtZoom := (1 shl Azoom);
  Result.x := round(TilesAtZoom / 2 + Ll.x * (TilesAtZoom / 360));
  z := sin(Ll.y * Pi / 180);
  c := (TilesAtZoom / (2 * Pi));
  Result.y := round(TilesAtZoom / 2 - c*(ArcTanh(z)-FExct*ArcTanh(FExct*z)));
end;

function TCoordConverterMercatorOnEllipsoid.Pos2LonLat(XY: TPoint;
  Azoom: byte): TExtendedPoint;
var
  TilesAtZoom : Integer;
  zu, zum1, yy : extended;
begin
  if Azoom < 31 then begin

    TilesAtZoom := (1 shl Azoom);

    if TilesAtZoom>1 then begin
      if XY.x < 0 then XY.x := XY.x + TilesAtZoom;
      if (XY.y>TilesAtZoom/2) then begin
        yy:=(TilesAtZoom div 2) - (XY.y mod (TilesAtZoom div 2));
      end else begin
        yy:=XY.y;
      end;
      Result.X := (XY.x - TilesAtZoom / 2) / (TilesAtZoom / 360);
      Result.Y := (yy - TilesAtZoom / 2) / -(TilesAtZoom / (2*PI));
      Result.Y := (2 * arctan(exp(Result.Y)) - PI / 2) * 180 / PI;
      Zu := result.y / (180 / Pi);
      yy := (yy - TilesAtZoom / 2);
      repeat
        Zum1 := Zu;
        Zu := arcsin(1-((1+Sin(Zum1))*power(1-FExct*sin(Zum1),FExct))/(exp((2*yy)/-(TilesAtZoom/(2*Pi)))*power(1+FExct*sin(Zum1),FExct)));
      until (abs(Zum1 - Zu) < MerkElipsK) or (isNAN(Zu));
      if not(isNAN(Zu)) then begin
        if XY.y>TilesAtZoom/2 then begin
          result.Y:=-zu*180/Pi;
        end else begin
          result.Y:=zu*180/Pi;
        end;
      end;
    end;
  end else begin
    Result.X := 0;
    Result.Y := 0;
  end;
end;

function TCoordConverterMercatorOnEllipsoid.LonLat2Metr(Ll : TExtendedPoint) : TExtendedPoint;
begin
  ll.x:=ll.x*(Pi/180);
  ll.y:=ll.y*(Pi/180);
  result.x:=Fradiusa*ll.x;
  result.y:=Fradiusa*Ln(Tan(PI/4+ll.y/2));
end;

function TCoordConverterMercatorOnEllipsoid.CalcDist(AStart,
  AFinish: TExtendedPoint): Extended;
const
  D2R: Double = 0.017453292519943295769236907684886;// ��������� ��� �������������� �������� � �������
var
  fPhimean,fdLambda,fdPhi,fAlpha,fRho,fNu,fR,fz,fTemp,a,e2:Double;
  VStart, VFinish: TExtendedPoint; // ���������� � ��������
begin
  result := 0;
  if (AStart.X = AFinish.X) and (AStart.Y = AFinish.Y) then exit;
  e2 := FExct*FExct;
  a := FRadiusa;

  VStart.X := AStart.X * D2R;
  VStart.Y := AStart.Y * D2R;
  VFinish.X := AFinish.X * D2R;
  VFinish.Y := AFinish.Y * D2R;

  fdLambda := VStart.X - VFinish.X;
  fdPhi := VStart.Y - VFinish.Y;
  fPhimean := (VStart.Y + VFinish.Y) / 2.0;
  fTemp := 1 - e2 * (Power(Sin(fPhimean), 2));
  fRho := (a * (1 - e2)) / Power(fTemp, 1.5);
  fNu := a / (Sqrt(1 - e2 * (Sin(fPhimean) * Sin(fPhimean))));
  fz:=Sqrt(Power(Sin(fdPhi/2),2)+Cos(VFinish.Y)*Cos(VStart.Y)*Power(Sin(fdLambda/2),2));
  fz := 2*ArcSin(fz);
  fAlpha := Cos(VFinish.Y) * Sin(fdLambda) * 1 / Sin(fz);
  fAlpha := ArcSin(fAlpha);
  fR:=(fRho*fNu)/((fRho*Power(Sin(fAlpha),2))+(fNu*Power(Cos(fAlpha),2)));
  result := (fz * fR);
end;

end.
