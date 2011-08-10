unit u_BitmapMarkerProviderSimpleCross;

interface

uses
  Types,
  GR32,
  i_BitmapMarker,
  i_BitmapMarkerProviderSimpleConfig,
  u_BitmapMarkerProviderSimpleBase;

type
  TBitmapMarkerProviderSimpleCross = class(TBitmapMarkerProviderSimpleBase)
  protected
    function CreateMarker: IBitmapMarker; override;
  end;

implementation

uses
  GR32_Polygons,
  t_GeoTypes,
  u_BitmapMarker;

{ TBitmapMarkerProviderSimpleCross }

function TBitmapMarkerProviderSimpleCross.CreateMarker: IBitmapMarker;
var
  VConfig: IBitmapMarkerProviderSimpleConfigStatic;
  VMarkerBitmap: TCustomBitmap32;
  VSize: TPoint;
  VPolygon: TPolygon32;
  VCenterPoint: TDoublePoint;
  VCrossHalfWidth: Double;
begin
  VMarkerBitmap := TCustomBitmap32.Create;
  try
    VConfig := Config.GetStatic;
    VSize := Point(VConfig.MarkerSize, VConfig.MarkerSize);

    VCenterPoint.X := VSize.X / 2;
    VCenterPoint.Y := VSize.Y / 2;

    VCrossHalfWidth := VConfig.MarkerSize / 10;

    VMarkerBitmap.SetSize(VSize.Y, VSize.Y);
    VMarkerBitmap.Clear(0);
    VPolygon := TPolygon32.Create;
    try
      VPolygon.Antialiased := true;
      VPolygon.Closed := True;
      VPolygon.AntialiasMode := am32times;
      VPolygon.Add(FixedPoint(VCenterPoint.X - VCrossHalfWidth, 0));
      VPolygon.Add(FixedPoint(VCenterPoint.X + VCrossHalfWidth, 0));
      VPolygon.Add(FixedPoint(VCenterPoint.X + VCrossHalfWidth, VCenterPoint.Y - VCrossHalfWidth));
      VPolygon.Add(FixedPoint(VSize.X - 1, VCenterPoint.Y - VCrossHalfWidth));
      VPolygon.Add(FixedPoint(VSize.X - 1, VCenterPoint.Y + VCrossHalfWidth));
      VPolygon.Add(FixedPoint(VCenterPoint.X + VCrossHalfWidth, VCenterPoint.Y + VCrossHalfWidth));
      VPolygon.Add(FixedPoint(VCenterPoint.X + VCrossHalfWidth, VSize.Y - 1));
      VPolygon.Add(FixedPoint(VCenterPoint.X - VCrossHalfWidth, VSize.Y - 1));
      VPolygon.Add(FixedPoint(VCenterPoint.X - VCrossHalfWidth, VCenterPoint.Y + VCrossHalfWidth));
      VPolygon.Add(FixedPoint(0, VCenterPoint.Y + VCrossHalfWidth));
      VPolygon.Add(FixedPoint(0, VCenterPoint.Y - VCrossHalfWidth));
      VPolygon.Add(FixedPoint(VCenterPoint.X - VCrossHalfWidth, VCenterPoint.Y - VCrossHalfWidth));
      VPolygon.DrawFill(VMarkerBitmap, VConfig.MarkerColor);
      VPolygon.DrawEdge(VMarkerBitmap, VConfig.BorderColor);
    finally
      VPolygon.Free;
    end;
    Result :=
      TBitmapMarker.Create(
        VMarkerBitmap,
        VCenterPoint,
        False,
        0
      );
  finally
    VMarkerBitmap.Free;
  end;
end;

end.
