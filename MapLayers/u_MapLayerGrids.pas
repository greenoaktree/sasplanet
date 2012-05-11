unit u_MapLayerGrids;

interface

uses
  Types,
  GR32,
  GR32_Image,
  t_GeoTypes,
  i_LocalCoordConverter,
  i_LocalCoordConverterFactorySimpe,
  i_InternalPerformanceCounter,
  i_ImageResamplerConfig,
  i_MapLayerGridsConfig,
  i_ViewPortState,
  i_ValueToStringConverter,
  u_MapLayerBasic;

type
  TMapLayerGrids = class(TMapLayerBasic)
  private
    FConfig: IMapLayerGridsConfig;
    FValueToStringConverterConfig: IValueToStringConverterConfig;
    procedure generate_granica;
    procedure DrawGenShBorders;
    procedure DrawDegreeBorders;
    procedure OnConfigChange;
  protected
    procedure DoRedraw; override;
    function GetVisibleForNewPos(
      const ANewVisualCoordConverter: ILocalCoordConverter
    ): Boolean; override;
  public
    procedure StartThreads; override;
  public
    constructor Create(
      const APerfList: IInternalPerformanceCounterList;
      AParentMap: TImage32;
      const AViewPortState: IViewPortState;
      const AResamplerConfig: IImageResamplerConfig;
      const AConverterFactory: ILocalCoordConverterFactorySimpe;
      const AConfig: IMapLayerGridsConfig;
      const AValueToStringConverterConfig: IValueToStringConverterConfig
    );
  end;

implementation

uses
  SysUtils,
  i_CoordConverter,
  u_GeoFun,
  u_NotifyEventListener,
  u_GeoToStr,
  StrUtils;

const
  GSHprec = 100000000;

{ TMapLayerGrids }

constructor TMapLayerGrids.Create(
  const APerfList: IInternalPerformanceCounterList;
  AParentMap: TImage32;
  const AViewPortState: IViewPortState;
  const AResamplerConfig: IImageResamplerConfig;
  const AConverterFactory: ILocalCoordConverterFactorySimpe;
  const AConfig: IMapLayerGridsConfig;
  const AValueToStringConverterConfig: IValueToStringConverterConfig
);
begin
  inherited Create(
    APerfList,
    AParentMap,
    AViewPortState,
    AResamplerConfig,
    AConverterFactory
  );
  FConfig := AConfig;
  FValueToStringConverterConfig := AValueToStringConverterConfig;
  LinksList.Add(
    TNotifyNoMmgEventListener.Create(Self.OnConfigChange),
    FConfig.GetChangeNotifier
  );
end;

procedure TMapLayerGrids.DoRedraw;
begin
  inherited;
  if FConfig.TileGrid.Visible then begin
    generate_granica;
  end;
  if FConfig.GenShtabGrid.Visible then begin
    DrawGenShBorders;
  end;
  if FConfig.DegreeGrid.Visible then begin
    DrawDegreeBorders;
  end;
end;

function FloatPoint2RectWihtClip(ASource: TDoublePoint): TPoint;
const
  CMaxClip = 1 shl 14;
begin
  if ASource.X < -CMaxClip then begin
    Result.X := -CMaxClip;
  end else if ASource.X > CMaxClip then begin
    Result.X := CMaxClip;
  end else begin
    Result.X := trunc(ASource.X);
  end;

  if ASource.Y < -CMaxClip then begin
    Result.Y := -CMaxClip;
  end else if ASource.Y > CMaxClip then begin
    Result.Y := CMaxClip;
  end else begin
    Result.Y := trunc(ASource.Y);
  end;
end;



procedure TMapLayerGrids.DrawDegreeBorders; //garl
var
  z: TDoublePoint;
  twidth, theight: integer;
  ListName: WideString;
  VZoom: Byte;
  VLoadedRect: TDoubleRect;
  VLoadedLonLatRect: TDoubleRect;
  VGridLonLatRect: TDoubleRect;
  VGridRect: TRect;
  VDrawLonLatRect: TDoubleRect;
  VDrawRectFloat: TDoubleRect;
  VDrawScreenRect: TRect;
  VCanShowText: Boolean;
  VLocalConverter: ILocalCoordConverter;
  VGeoConvert: ICoordConverter;
  VScale: Double;
  VShowText: Boolean;
  VColor: TColor32;

  VVDrawLonLatRect: TDoubleRect;
  VVDrawRectFloat: TDoubleRect;
  VVDrawScreenRect: TRect;
  VValueConverter: IValueToStringConverter;
  ss: string;
  VTextXPos: TDoublePoint;
  VTextYPos: TDoublePoint;
  VTextPos2: TRect;
begin
  VValueConverter := FValueToStringConverterConfig.GetStatic;
  FConfig.DegreeGrid.LockRead;
  try
    VScale := FConfig.DegreeGrid.Scale;
    VShowText := FConfig.DegreeGrid.ShowText;
    VColor := FConfig.DegreeGrid.GridColor;
  finally
    FConfig.DegreeGrid.UnlockRead;
  end;
  if VScale = 0 then begin
    exit;
  end;
  VLocalConverter := LayerCoordConverter;
  VGeoConvert := VLocalConverter.GetGeoConverter;
  VZoom := VLocalConverter.GetZoom;
  z := GetDegBordersStepByScale(VScale, VZoom);
  VLoadedRect := VLocalConverter.GetRectInMapPixelFloat;
  VGeoConvert.CheckPixelRectFloat(VLoadedRect, VZoom);
  VLoadedLonLatRect := VGeoConvert.PixelRectFloat2LonLatRect(VLoadedRect, VZoom);
  if VLoadedLonLatRect.Top > 90 then begin
    VLoadedLonLatRect.Top := 90;
  end;
  if VLoadedLonLatRect.Bottom < -90 then begin
    VLoadedLonLatRect.Bottom := -90;
  end;

  VGridLonLatRect.Left := VLoadedLonLatRect.Left - z.X;
  VGridLonLatRect.Top := VLoadedLonLatRect.Top + z.Y;
  VGridLonLatRect.Right := VLoadedLonLatRect.Right + z.X;
  VGridLonLatRect.Bottom := VLoadedLonLatRect.Bottom - z.Y;
  VGeoConvert.CheckLonLatRect(VGridLonLatRect);
  VGridRect := VGeoConvert.LonLatRect2PixelRect(VGridLonLatRect, VZoom);
  VDrawLonLatRect.TopLeft := VGridLonLatRect.TopLeft;
  VDrawLonLatRect.BottomRight := DoublePoint(VGridLonLatRect.Left + z.X, VGridLonLatRect.Bottom);
  VDrawRectFloat := VGeoConvert.LonLatRect2PixelRectFloat(VDrawLonLatRect, VZoom);

  if abs(VDrawRectFloat.Right - VDrawRectFloat.Left) < 3 then begin
    exit;
  end;

  if (abs(VDrawRectFloat.Right - VDrawRectFloat.Left) > 30) and (VShowText) then begin
    VCanShowText := true;
  end else begin
    VCanShowText := false;
  end;

  // вертикаль
  VDrawLonLatRect.TopLeft := VGridLonLatRect.TopLeft;
  VDrawLonLatRect.Right := VGridLonLatRect.Right;
  VDrawLonLatRect.Bottom := VGridLonLatRect.Bottom;
  VDrawLonLatRect.Left := trunc(VDrawLonLatRect.Left / z.x) * z.x;
  while VDrawLonLatRect.Left <= VGridLonLatRect.Right do begin
    VDrawRectFloat := VGeoConvert.LonLatRect2PixelRectFloat(VDrawLonLatRect, VZoom);
    VDrawScreenRect.TopLeft := FloatPoint2RectWihtClip(VLocalConverter.MapPixelFloat2LocalPixelFloat(VDrawRectFloat.TopLeft));
    VDrawScreenRect.BottomRight := FloatPoint2RectWihtClip(VLocalConverter.MapPixelFloat2LocalPixelFloat(VDrawRectFloat.BottomRight));
    Layer.bitmap.LineAS(
      VDrawScreenRect.Left, VDrawScreenRect.Top,
      VDrawScreenRect.left, VDrawScreenRect.Bottom, VColor
    );
    VVDrawLonLatRect.TopLeft := VGridLonLatRect.TopLeft;
    VVDrawLonLatRect.Right := VGridLonLatRect.Right;
    VVDrawLonLatRect.Bottom := VGridLonLatRect.Bottom;
    VVDrawLonLatRect.Top := trunc(VGridLonLatRect.Top / z.y) * z.y;

    while VVDrawLonLatRect.Top > VGridLonLatRect.Bottom do begin
      vVDrawRectFloat := VGeoConvert.LonLatRect2PixelRectFloat(VVDrawLonLatRect, VZoom);
      vVDrawScreenRect.TopLeft := FloatPoint2RectWihtClip(VLocalConverter.MapPixelFloat2LocalPixelFloat(vVDrawRectFloat.TopLeft));
      vVDrawScreenRect.BottomRight := FloatPoint2RectWihtClip(VLocalConverter.MapPixelFloat2LocalPixelFloat(vVDrawRectFloat.BottomRight));
      Layer.bitmap.LineAS(
        vVDrawScreenRect.Left, vVDrawScreenRect.Top,
        vVDrawScreenRect.Right, vVDrawScreenRect.top, VColor
      );

      if VCanShowText then begin
        if VDrawLonLatRect.Left + z.X / 2 < 180 then begin
          VTextYPos := VGeoConvert.LonLat2PixelPosFloat(doublepoint(VDrawLonLatRect.Left + z.X / 2, VVDrawLonLatRect.Top), Vzoom);
          VTextXPos := VGeoConvert.LonLat2PixelPosFloat(doublepoint(VDrawLonLatRect.Left, VVDrawLonLatRect.Top + z.Y / 2), Vzoom);
          VTextPos2.TopLeft := FloatPoint2RectWihtClip(VLocalConverter.MapPixelFloat2LocalPixelFloat(VTextYPos));
          VTextPos2.BottomRight := FloatPoint2RectWihtClip(VLocalConverter.MapPixelFloat2LocalPixelFloat(VTextXPos));
          // X
          ListName := VValueConverter.LatConvert(vVDrawLonLatRect.Top);
          ss := copy(ListName, length(ListName) - 5, 6);
          if copy(ListName, length(ListName) - 5, 6) = '00.00"' then begin
            ListName := ReplaceStr(ListName, '00.00"', '');
          end;
          if copy(ListName, length(ListName) - 5, 6) = '00,00"' then begin
            ListName := ReplaceStr(ListName, '00,00"', '');
          end;
          if copy(ListName, length(ListName) - 3, 4) = ',00"' then begin
            ListName := ReplaceStr(ListName, ',00"', '"');
          end;
          if copy(ListName, length(ListName) - 3, 4) = '.00"' then begin
            ListName := ReplaceStr(ListName, '.00"', '"');
          end;
          if copy(ListName, length(ListName) - 2, 3) = '00''' then begin
            ListName := ReplaceStr(ListName, '00''', '');
          end;
          twidth := Layer.bitmap.TextWidth(ListName);
          Layer.bitmap.RenderTextW(
            VTextPos2.Left - twidth div 2,
            VTextPos2.Top,
            ListName, 0, VColor);
          // Y
          ListName := VValueConverter.LonConvert(VDrawLonLatRect.Left);
          if copy(ListName, length(ListName) - 5, 6) = '00.00"' then begin
            ListName := ReplaceStr(ListName, '00.00"', '');
          end;
          if copy(ListName, length(ListName) - 5, 6) = '00,00"' then begin
            ListName := ReplaceStr(ListName, '00,00"', '');
          end;
          if copy(ListName, length(ListName) - 3, 4) = ',00"' then begin
            ListName := ReplaceStr(ListName, ',00"', '"');
          end;
          if copy(ListName, length(ListName) - 3, 4) = '.00"' then begin
            ListName := ReplaceStr(ListName, '.00"', '"');
          end;
          if copy(ListName, length(ListName) - 2, 3) = '00''' then begin
            ListName := ReplaceStr(ListName, '00''', '');
          end;
          theight := Layer.bitmap.TextHeight(ListName);
          Layer.bitmap.RenderTextW(
            VTextPos2.Right + 2,
            VTextPos2.Bottom - theight div 2,
            ListName, 0, VColor);
        end;
      end;

      VVDrawLonLatRect.Top := VVDrawLonLatRect.Top - z.Y;
    end;
    VDrawLonLatRect.Left := VDrawLonLatRect.Left + z.X;
    VDrawLonLatRect.Right := VDrawLonLatRect.Left;
  end;

end;


procedure TMapLayerGrids.DrawGenShBorders;
var
  z: TDoublePoint;
  twidth, theight: integer;
  ListName: WideString;
  VZoom: Byte;
  VLoadedRect: TDoubleRect;
  VLoadedLonLatRect: TDoubleRect;
  VGridLonLatRect: TDoubleRect;
  VGridRect: TRect;
  VDrawLonLatRect: TDoubleRect;
  VDrawRectFloat: TDoubleRect;
  VDrawScreenRect: TRect;
  VCanShowText: Boolean;
  VLocalConverter: ILocalCoordConverter;
  VGeoConvert: ICoordConverter;
  VScale: Integer;
  VShowText: Boolean;
  VColor: TColor32;
begin
  FConfig.GenShtabGrid.LockRead;
  try
    VScale := FConfig.GenShtabGrid.Scale;
    VShowText := FConfig.GenShtabGrid.ShowText;
    VColor := FConfig.GenShtabGrid.GridColor;
  finally
    FConfig.GenShtabGrid.UnlockRead;
  end;
  if VScale = 0 then begin
    exit;
  end;
  z := GetGhBordersStepByScale(VScale);
  VLocalConverter := LayerCoordConverter;
  VGeoConvert := VLocalConverter.GetGeoConverter;
  VZoom := VLocalConverter.GetZoom;
  VLoadedRect := VLocalConverter.GetRectInMapPixelFloat;

  VGeoConvert.CheckPixelRectFloat(VLoadedRect, VZoom);

  VLoadedLonLatRect := VGeoConvert.PixelRectFloat2LonLatRect(VLoadedRect, VZoom);
  if VLoadedLonLatRect.Top > 90 then begin
    VLoadedLonLatRect.Top := 90;
  end;
  if VLoadedLonLatRect.Bottom < -90 then begin
    VLoadedLonLatRect.Bottom := -90;
  end;

  VGridLonLatRect.Left := VLoadedLonLatRect.Left - z.X;
  VGridLonLatRect.Top := VLoadedLonLatRect.Top + z.Y;
  VGridLonLatRect.Right := VLoadedLonLatRect.Right + z.X;
  VGridLonLatRect.Bottom := VLoadedLonLatRect.Bottom - z.Y;
  VGeoConvert.CheckLonLatRect(VGridLonLatRect);

  VGridLonLatRect.Left := VGridLonLatRect.Left - (round(VGridLonLatRect.Left * GSHprec) mod round(z.X * GSHprec)) / GSHprec;
  VGridLonLatRect.Top := VGridLonLatRect.Top - (round(VGridLonLatRect.Top * GSHprec) mod round(z.Y * GSHprec)) / GSHprec;
  VGridLonLatRect.Bottom := VGridLonLatRect.Bottom - (round(VGridLonLatRect.Bottom * GSHprec) mod round(z.Y * GSHprec)) / GSHprec;

  VGridRect := VGeoConvert.LonLatRect2PixelRect(VGridLonLatRect, VZoom);

  VDrawLonLatRect.TopLeft := VGridLonLatRect.TopLeft;
  VDrawLonLatRect.BottomRight := DoublePoint(VGridLonLatRect.Left + z.X, VGridLonLatRect.Bottom);
  VDrawRectFloat := VGeoConvert.LonLatRect2PixelRectFloat(VDrawLonLatRect, VZoom);

  if abs(VDrawRectFloat.Right - VDrawRectFloat.Left) < 4 then begin
    exit;
  end;

  if (abs(VDrawRectFloat.Right - VDrawRectFloat.Left) > 30) and (VShowText) then begin
    VCanShowText := true;
  end else begin
    VCanShowText := false;
  end;

  VDrawLonLatRect.TopLeft := VGridLonLatRect.TopLeft;
  VDrawLonLatRect.Right := VGridLonLatRect.Left;
  VDrawLonLatRect.Bottom := VGridLonLatRect.Bottom;

  while VDrawLonLatRect.Left <= VGridLonLatRect.Right do begin
    VDrawRectFloat := VGeoConvert.LonLatRect2PixelRectFloat(VDrawLonLatRect, VZoom);

    VDrawScreenRect.TopLeft := FloatPoint2RectWihtClip(VLocalConverter.MapPixelFloat2LocalPixelFloat(VDrawRectFloat.TopLeft));
    VDrawScreenRect.BottomRight := FloatPoint2RectWihtClip(VLocalConverter.MapPixelFloat2LocalPixelFloat(VDrawRectFloat.BottomRight));

    Layer.bitmap.LineAS(
      VDrawScreenRect.Left, VDrawScreenRect.Top,
      VDrawScreenRect.Right, VDrawScreenRect.Bottom, VColor
    );

    if (z.x < 6) and (VDrawLonLatRect.Left = round(VDrawLonLatRect.Left / 6) * 6) then begin
      Layer.bitmap.LineAS(
        VDrawScreenRect.Left + 1, VDrawScreenRect.Top,
        VDrawScreenRect.Right + 1, VDrawScreenRect.Bottom, VColor
      );
      Layer.bitmap.LineAS(
        VDrawScreenRect.Left - 1, VDrawScreenRect.Top,
        VDrawScreenRect.Right - 1, VDrawScreenRect.Bottom, VColor
      );
    end;
    if (z.x < 3) and (VDrawLonLatRect.Left = round(VDrawLonLatRect.Left / 3) * 3) then begin
      Layer.bitmap.LineAS(
        VDrawScreenRect.Left + 1, VDrawScreenRect.Top,
        VDrawScreenRect.Right + 1, VDrawScreenRect.Bottom, {(((VColor and $FF000000) or $88000000) or VColor)} Vcolor
      );
    end;

    VDrawLonLatRect.Left := VDrawLonLatRect.Left + z.X;
    VDrawLonLatRect.Right := VDrawLonLatRect.Left;
  end;

  VDrawLonLatRect.TopLeft := VGridLonLatRect.TopLeft;
  VDrawLonLatRect.Right := VGridLonLatRect.Right;
  VDrawLonLatRect.Bottom := VGridLonLatRect.Top;

  while VDrawLonLatRect.Top - VGridLonLatRect.Bottom > -0.000001 do begin
    VDrawRectFloat := VGeoConvert.LonLatRect2PixelRectFloat(VDrawLonLatRect, VZoom);

    VDrawScreenRect.TopLeft := FloatPoint2RectWihtClip(VLocalConverter.MapPixelFloat2LocalPixelFloat(VDrawRectFloat.TopLeft));
    VDrawScreenRect.BottomRight := FloatPoint2RectWihtClip(VLocalConverter.MapPixelFloat2LocalPixelFloat(VDrawRectFloat.BottomRight));
    Layer.bitmap.LineAS(
      VDrawScreenRect.Left, VDrawScreenRect.Top,
      VDrawScreenRect.Right, VDrawScreenRect.Bottom, VColor
    );

    if (z.Y < 4) and (round((VDrawLonLatRect.Top + 0.000000001) * 100) = trunc((VDrawLonLatRect.Top + 0.01) / 4) * 4 * 100) then begin
      Layer.bitmap.LineAS(
        VDrawScreenRect.Left, VDrawScreenRect.Top + 1,
        VDrawScreenRect.Right, VDrawScreenRect.Bottom + 1, VColor
      );
      Layer.bitmap.LineAS(
        VDrawScreenRect.Left, VDrawScreenRect.Top - 1,
        VDrawScreenRect.Right, VDrawScreenRect.Bottom - 1, VColor
      );
    end;
    if (z.Y < 2) and (round((VDrawLonLatRect.Top + 0.000000001) * 100) = trunc((VDrawLonLatRect.Top + 0.01) / 2) * 2 * 100) then begin
      Layer.bitmap.LineAS(
        VDrawScreenRect.Left, VDrawScreenRect.Top + 1,
        VDrawScreenRect.Right, VDrawScreenRect.Bottom + 1, {((VColor and $FF000000) or $88000000) or VColor}Vcolor
      );
    end;

    VDrawLonLatRect.Top := VDrawLonLatRect.Top - z.Y;
    VDrawLonLatRect.Bottom := VDrawLonLatRect.Top;
  end;

  if not VCanShowText then begin
    exit;
  end;

  VDrawLonLatRect.TopLeft := VGridLonLatRect.TopLeft;
  VDrawLonLatRect.Right := VDrawLonLatRect.Left + z.X;
  VDrawLonLatRect.Bottom := VDrawLonLatRect.Top - z.Y;
  while VDrawLonLatRect.Top - VGridLonLatRect.Bottom > -0.000001 do begin
    while VDrawLonLatRect.Left + z.X / 2 <= VGridLonLatRect.Right do begin
      VDrawRectFloat := VGeoConvert.LonLatRect2PixelRectFloat(VDrawLonLatRect, VZoom);
      ListName := LonLat2GShListName(
        DoublePoint(VDrawLonLatRect.Left + z.X / 2, VDrawLonLatRect.Top - z.Y / 2),
        VScale, GSHprec
      );
      twidth := Layer.bitmap.TextWidth(ListName);
      theight := Layer.bitmap.TextHeight(ListName);

      VDrawScreenRect.TopLeft := FloatPoint2RectWihtClip(VLocalConverter.MapPixelFloat2LocalPixelFloat(VDrawRectFloat.TopLeft));
      VDrawScreenRect.BottomRight := FloatPoint2RectWihtClip(VLocalConverter.MapPixelFloat2LocalPixelFloat(VDrawRectFloat.BottomRight));

      Layer.bitmap.RenderTextW(
        VDrawScreenRect.Left + (VDrawScreenRect.Right - VDrawScreenRect.Left) div 2 - (twidth div 2),
        VDrawScreenRect.Top + (VDrawScreenRect.Bottom - VDrawScreenRect.Top) div 2 - (theight div 2),
        ListName, 0, VColor
      );

      VDrawLonLatRect.Left := VDrawLonLatRect.Right;
      VDrawLonLatRect.Right := VDrawLonLatRect.Right + z.X;
    end;
    VDrawLonLatRect.Left := VGridLonLatRect.Left;
    VDrawLonLatRect.Right := VDrawLonLatRect.Left + z.X;
    VDrawLonLatRect.Top := VDrawLonLatRect.Bottom;
    VDrawLonLatRect.Bottom := VDrawLonLatRect.Bottom - z.Y;
  end;
end;

procedure TMapLayerGrids.generate_granica;
var
  i, j: integer;
  VColor: TColor32;
  textoutx, textouty: string;
  Sz1, Sz2: TSize;
  VLoadedRect: TDoubleRect;
  VLoadedRelativeRect: TDoubleRect;
  VCurrentZoom: Byte;
  VTilesRect: TRect;
  VTileRelativeRect: TDoubleRect;
  VTileRect: TRect;
  VTileIndex: TPoint;
  VTileScreenRect: TRect;
  VTileCenter: TPoint;
  VTileSize: TPoint;
  VGridZoom: Byte;
  VLocalConverter: ILocalCoordConverter;
  VGeoConvert: ICoordConverter;
  VShowText: Boolean;
begin
  VLocalConverter := LayerCoordConverter;
  VGeoConvert := VLocalConverter.GetGeoConverter;
  VCurrentZoom := VLocalConverter.GetZoom;

  FConfig.TileGrid.LockRead;
  try
    VColor := FConfig.TileGrid.GridColor;
    VShowText := FConfig.TileGrid.ShowText;
    if FConfig.TileGrid.UseRelativeZoom then begin
      VGridZoom := VCurrentZoom + FConfig.TileGrid.Zoom;
    end else begin
      VGridZoom := FConfig.TileGrid.Zoom;
    end;
  finally
    FConfig.TileGrid.UnlockRead;
  end;

  if VShowText then begin
    if (VGridZoom >= VCurrentZoom - 2) and (VGridZoom <= VCurrentZoom + 3) then begin
      VLoadedRect := VLocalConverter.GetRectInMapPixelFloat;
      VGeoConvert.CheckPixelRectFloat(VLoadedRect, VCurrentZoom);

      VLoadedRelativeRect := VGeoConvert.PixelRectFloat2RelativeRect(VLoadedRect, VCurrentZoom);
      VTilesRect := VGeoConvert.RelativeRect2TileRect(VLoadedRelativeRect, VGridZoom);
      for i := VTilesRect.Top to VTilesRect.Bottom - 1 do begin
        VTileIndex.Y := i;
        for j := VTilesRect.Left to VTilesRect.Right - 1 do begin
          VTileIndex.X := j;
          VTileRelativeRect := VGeoConvert.TilePos2RelativeRect(VTileIndex, VGridZoom);
          VTileRect := VGeoConvert.RelativeRect2PixelRect(VTileRelativeRect, VCurrentZoom);
          VTileScreenRect.TopLeft := VLocalConverter.MapPixel2LocalPixel(VTileRect.TopLeft);
          VTileScreenRect.BottomRight := VLocalConverter.MapPixel2LocalPixel(VTileRect.BottomRight);

          VTileSize.X := VTileRect.Right - VTileRect.Left;
          VTileSize.Y := VTileRect.Bottom - VTileRect.Top;
          VTileCenter.X := VTileScreenRect.Left + VTileSize.X div 2;
          VTileCenter.Y := VTileScreenRect.Top + VTileSize.Y div 2;
          textoutx := 'x=' + inttostr(VTileIndex.X);
          textouty := 'y=' + inttostr(VTileIndex.Y);
          Sz1 := Layer.bitmap.TextExtent(textoutx);
          Sz2 := Layer.bitmap.TextExtent(textouty);
          if (Sz1.cx < VTileSize.X) and (Sz2.cx < VTileSize.X) then begin
            Layer.bitmap.RenderText(VTileCenter.X - (Sz1.cx div 2) + 1, VTileCenter.Y - Sz2.cy, textoutx, 0, VColor);
            Layer.bitmap.RenderText(VTileCenter.X - (Sz2.cx div 2) + 1, VTileCenter.Y, textouty, 0, VColor);
          end;
        end;
      end;
    end;
  end;
end;

function TMapLayerGrids.GetVisibleForNewPos(
  const ANewVisualCoordConverter: ILocalCoordConverter
): Boolean;
var
  VConverter: ILocalCoordConverter;
  VGeoConverter: ICoordConverter;
  VZoom: Byte;
  VTileGridZoom: Byte;
begin
  Result := false;
  VConverter := ANewVisualCoordConverter;
  if VConverter <> nil then begin
    VGeoConverter := VConverter.GetGeoConverter;
    VZoom := VConverter.GetZoom;
    FConfig.LockRead;
    try
      if FConfig.TileGrid.Visible then begin
        if FConfig.TileGrid.ShowText then begin
          if FConfig.TileGrid.UseRelativeZoom then begin
            VTileGridZoom := VZoom + FConfig.TileGrid.Zoom;
          end else begin
            VTileGridZoom := FConfig.TileGrid.Zoom;
          end;
          if VGeoConverter.CheckZoom(VTileGridZoom) then begin
            Result := (VTileGridZoom >= VZoom - 2) and (VTileGridZoom <= VZoom + 3);
          end;
        end;
      end;
      if FConfig.GenShtabGrid.Visible then begin
        if FConfig.GenShtabGrid.Scale > 0 then begin
          Result := True;
        end;
      end;
      if FConfig.DegreeGrid.Visible then begin
        if FConfig.DegreeGrid.Scale <> 0 then begin
          Result := True;
        end;
      end;
    finally
      FConfig.UnlockRead;
    end;
  end;
end;

procedure TMapLayerGrids.OnConfigChange;
begin
  ViewUpdateLock;
  try
    SetNeedRedraw;
    SetVisible(GetVisibleForNewPos(ViewCoordConverter));
  finally
    ViewUpdateUnlock;
  end;
end;

procedure TMapLayerGrids.StartThreads;
begin
  inherited;
  OnConfigChange;
end;

end.
