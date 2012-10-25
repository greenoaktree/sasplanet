unit u_MarkerDrawableWithDirectionByBitmapMarker;

interface
uses
  Types,
  SysUtils,
  GR32,
  t_GeoTypes,
  i_MarkerDrawable,
  i_BitmapMarker;

type
  TMarkerDrawableWithDirectionByBitmapMarker = class(TInterfacedObject, IMarkerDrawableWithDirection)
  private
    FMarker: IBitmapMarkerWithDirection;
    FCachedMarkerCS: IReadWriteSync;
    FCachedMarker: IBitmapMarkerWithDirection;

    function ModifyMarkerWithRotation(
      const ASourceMarker: IBitmapMarkerWithDirection;
      const AAngle: Double
    ): IBitmapMarkerWithDirection;
    procedure DrawToBitmap(
      const AMarker: IBitmapMarker;
      ABitmap: TCustomBitmap32;
      const APosition: TDoublePoint
    );
  private
    function DrawToBitmapWithDirection(
      ABitmap: TCustomBitmap32;
      const APosition: TDoublePoint;
      const AAngle: Double
    ): Boolean;
  public
    constructor Create(
      const AMarker: IBitmapMarkerWithDirection
    );
  end;

implementation

uses
  Math,
  GR32_Blend,
  GR32_Rasterizers,
  GR32_Resamplers,
  GR32_Transforms,
  i_Bitmap32Static,
  u_GeoFun,
  u_Bitmap32Static,
  u_BitmapMarker,
  u_Synchronizer;

const
  CAngleDelta = 1.0;


{ TMarkerDrawableWithDirectionByBitmapMarker }

constructor TMarkerDrawableWithDirectionByBitmapMarker.Create(
  const AMarker: IBitmapMarkerWithDirection);
begin
  inherited Create;
  FMarker := AMarker;
  FCachedMarkerCS := MakeSyncRW_Var(Self, False);
end;

procedure TMarkerDrawableWithDirectionByBitmapMarker.DrawToBitmap(
  const AMarker: IBitmapMarker;
  ABitmap: TCustomBitmap32;
  const APosition: TDoublePoint
);
var
  VTargetPoint: TPoint;
  VTargetPointFloat: TDoublePoint;
begin
  VTargetPointFloat :=
    DoublePoint(
      APosition.X - AMarker.AnchorPoint.X,
      APosition.Y - AMarker.AnchorPoint.Y
    );
  VTargetPoint := PointFromDoublePoint(VTargetPointFloat, prToTopLeft);
  BlockTransfer(
    ABitmap,
    VTargetPoint.X, VTargetPoint.Y,
    ABitmap.ClipRect,
    AMarker.Bitmap,
    AMarker.Bitmap.BoundsRect,
    dmBlend,
    ABitmap.CombineMode
  );
end;

function TMarkerDrawableWithDirectionByBitmapMarker.DrawToBitmapWithDirection(
  ABitmap: TCustomBitmap32;
  const APosition: TDoublePoint;
  const AAngle: Double
): Boolean;
var
  VCachedMarker: IBitmapMarkerWithDirection;
  VMarkerToDraw: IBitmapMarkerWithDirection;
  VSourceSize: TPoint;
  VAnchorPoint: TDoublePoint;
  VHalfSize: Double;
  VTargetRect: TRect;
  VTargetDoubleRect: TDoubleRect;
begin
  VSourceSize := FMarker.Size;
  VAnchorPoint := FMarker.AnchorPoint;
  VHalfSize :=
    Min(
      Min(VAnchorPoint.X + VAnchorPoint.Y, VSourceSize.X - VAnchorPoint.X + VAnchorPoint.Y),
      Min(VAnchorPoint.X + VSourceSize.Y - VAnchorPoint.Y, VSourceSize.X - VAnchorPoint.X + VSourceSize.Y - VAnchorPoint.Y)
    );
  VTargetDoubleRect.Left := APosition.X - VHalfSize;
  VTargetDoubleRect.Top := APosition.Y - VHalfSize;
  VTargetDoubleRect.Right := APosition.X + VHalfSize;
  VTargetDoubleRect.Bottom := APosition.Y + VHalfSize;
  VTargetRect := RectFromDoubleRect(VTargetDoubleRect, rrOutside);

  Types.IntersectRect(VTargetRect, ABitmap.ClipRect, VTargetRect);
  if Types.IsRectEmpty(VTargetRect) then begin
    Result := False;
    Exit;
  end;

  if ABitmap.MeasuringMode then begin
    ABitmap.Changed(VTargetRect);
  end else begin
    if Abs(CalcAngleDelta(AAngle, FMarker.Direction)) > CAngleDelta then begin
      FCachedMarkerCS.BeginRead;
      try
        VCachedMarker := FCachedMarker;
      finally
        FCachedMarkerCS.EndRead;
      end;

      if VCachedMarker <> nil then begin
        if Abs(CalcAngleDelta(AAngle, VCachedMarker.Direction)) > CAngleDelta then begin
          VMarkerToDraw := nil;
        end else begin
          VMarkerToDraw := VCachedMarker;
        end;
      end else begin
        VMarkerToDraw := nil;
      end;
      if VMarkerToDraw = nil then begin
        VMarkerToDraw := ModifyMarkerWithRotation(FMarker, AAngle);
      end;
      if (VMarkerToDraw <> nil) and (VMarkerToDraw <> VCachedMarker) then begin
        FCachedMarkerCS.BeginWrite;
        try
          FCachedMarker := VMarkerToDraw;
        finally
          FCachedMarkerCS.EndWrite;
        end;
      end;
    end else begin
      VMarkerToDraw := FMarker;
    end;
    DrawToBitmap(VMarkerToDraw, ABitmap, APosition);
  end;
  Result := True;
end;

function TMarkerDrawableWithDirectionByBitmapMarker.ModifyMarkerWithRotation(
  const ASourceMarker: IBitmapMarkerWithDirection;
  const AAngle: Double): IBitmapMarkerWithDirection;
var
  VTransform: TAffineTransformation;
  VSizeSource: TPoint;
  VTargetRect: TFloatRect;
  VSizeTarget: TPoint;
  VBitmap: TCustomBitmap32;
  VFixedOnBitmap: TFloatPoint;
  VRasterizer: TRasterizer;
  VTransformer: TTransformer;
  VCombineInfo: TCombineInfo;
  VSampler: TCustomResampler;
  VBitmapStatic: IBitmap32Static;
begin
  VTransform := TAffineTransformation.Create;
  try
    VSizeSource := ASourceMarker.Size;
    VTransform.SrcRect := FloatRect(0, 0, VSizeSource.X, VSizeSource.Y);
    VTransform.Rotate(0, 0, ASourceMarker.Direction - AAngle);
    VTargetRect := VTransform.GetTransformedBounds;
    VSizeTarget.X := Trunc(VTargetRect.Right - VTargetRect.Left) + 1;
    VSizeTarget.Y := Trunc(VTargetRect.Bottom - VTargetRect.Top) + 1;
    VTransform.Translate(-VTargetRect.Left, -VTargetRect.Top);
    VBitmap := TCustomBitmap32.Create;
    try
      VBitmap.SetSize(VSizeTarget.X, VSizeTarget.Y);
      VBitmap.Clear(0);
      VRasterizer := TRegularRasterizer.Create;
      try
        VSampler := TLinearResampler.Create;
        try
          VSampler.Bitmap := ASourceMarker.Bitmap;
          VTransformer := TTransformer.Create(VSampler, VTransform);
          try
            VRasterizer.Sampler := VTransformer;
            VCombineInfo.SrcAlpha := 255;
            VCombineInfo.DrawMode := dmOpaque;
            VCombineInfo.TransparentColor := 0;
            VRasterizer.Rasterize(VBitmap, VBitmap.BoundsRect, VCombineInfo);
          finally
            EMMS;
            VTransformer.Free;
          end;
        finally
          VSampler.Free;
        end;
      finally
        VRasterizer.Free;
      end;
      VFixedOnBitmap := VTransform.Transform(FloatPoint(ASourceMarker.AnchorPoint.X, ASourceMarker.AnchorPoint.Y));
      VBitmapStatic := TBitmap32Static.CreateWithOwn(VBitmap);
      VBitmap := nil;
    finally
      VBitmap.Free;
    end;
    Result :=
      TBitmapMarkerWithDirection.Create(
        VBitmapStatic,
        DoublePoint(VFixedOnBitmap.X, VFixedOnBitmap.Y),
        AAngle
      );
  finally
    VTransform.Free;
  end;
end;

end.
