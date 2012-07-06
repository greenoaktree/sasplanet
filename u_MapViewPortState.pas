{******************************************************************************}
{* SAS.Planet (SAS.�������)                                                   *}
{* Copyright (C) 2007-2012, SAS.Planet development team.                      *}
{* This program is free software: you can redistribute it and/or modify       *}
{* it under the terms of the GNU General Public License as published by       *}
{* the Free Software Foundation, either version 3 of the License, or          *}
{* (at your option) any later version.                                        *}
{*                                                                            *}
{* This program is distributed in the hope that it will be useful,            *}
{* but WITHOUT ANY WARRANTY; without even the implied warranty of             *}
{* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *}
{* GNU General Public License for more details.                               *}
{*                                                                            *}
{* You should have received a copy of the GNU General Public License          *}
{* along with this program.  If not, see <http://www.gnu.org/licenses/>.      *}
{*                                                                            *}
{* http://sasgis.ru                                                           *}
{* az@sasgis.ru                                                               *}
{******************************************************************************}

unit u_MapViewPortState;

interface

uses
  Types,
  i_Notifier,
  i_Listener,
  t_GeoTypes,
  i_CoordConverter,
  i_LocalCoordConverter,
  i_LocalCoordConverterChangeable,
  i_ConfigDataProvider,
  i_ConfigDataWriteProvider,
  i_InternalPerformanceCounter,
  i_ViewPortState,
  i_ActiveMapsConfig,
  i_LocalCoordConverterFactorySimpe,
  u_ConfigDataElementBase;

type
  TMapViewPortState = class(TConfigDataElementBase, IViewPortState)
  private
    FMainCoordConverter: ICoordConverter;
    FVisibleCoordConverterFactory: ILocalCoordConverterFactorySimpe;
    FMainMapConfig: IMainActiveMap;

    FPosition: ILocalCoordConverterChangeableInternal;
    FView: ILocalCoordConverterChangeableInternal;

    FBaseScale: TDoublePoint;

    FPosChangeCounter: IInternalPerformanceCounter;
    FScaleChangeCounter: IInternalPerformanceCounter;

    FMainMapChangeListener: IListener;
    function _GetActiveCoordConverter: ICoordConverter;
    function CreateVisibleCoordConverter(
      AActiveCoordConverter: ICoordConverter;
      AViewSize: TPoint;
      AVisibleMove: TDoublePoint;
      AMapScale: TDoublePoint;
      ACenterPos: TDoublePoint;
      AZoom: Byte
    ): ILocalCoordConverter;
    procedure _SetActiveCoordConverter;
    procedure OnMainMapChange;
  protected
    procedure DoChangeNotify; override;
    procedure DoReadConfig(const AConfigData: IConfigDataProvider); override;
    procedure DoWriteConfig(const AConfigData: IConfigDataWriteProvider); override;
  private
    function GetMainCoordConverter: ICoordConverter;
    procedure SetMainCoordConverter(const AValue: ICoordConverter);

    function GetCurrentCoordConverter: ICoordConverter;
    function GetCurrentZoom: Byte;

    function GetPosition: ILocalCoordConverterChangeable;
    function GetView: ILocalCoordConverterChangeable;

    procedure ChangeViewSize(const ANewSize: TPoint);
    procedure ChangeMapPixelByDelta(const ADelta: TDoublePoint);
    procedure ChangeMapPixelToVisualPoint(const AVisualPoint: TPoint);
    procedure ChangeZoomWithFreezeAtVisualPoint(
      const AZoom: Byte;
      const AFreezePoint: TPoint
    );
    procedure ChangeZoomWithFreezeAtCenter(const AZoom: Byte);

    procedure ChangeLonLat(const ALonLat: TDoublePoint);
    procedure FitRectToScreen(const ALonLatRect: TDoubleRect);

    procedure MoveTo(const Pnt: TPoint);
    procedure ScaleTo(
      const AScale: Double;
      const ACenterPoint: TPoint
    ); overload;
    procedure ScaleTo(const AScale: Double); overload;
  public
    constructor Create(
      const ACoordConverterFactory: ILocalCoordConverterFactorySimpe;
      const AMainMapConfig: IMainActiveMap;
      const APerfCounterList: IInternalPerformanceCounterList
    );
    destructor Destroy; override;
  end;

implementation

uses
  SysUtils,
  u_Notifier,
  i_MapTypes,
  u_ListenerByEvent,
  u_LocalCoordConverterChangeable,
  u_GeoFun;

{ TMapViewPortStateNew }

constructor TMapViewPortState.Create(
  const ACoordConverterFactory: ILocalCoordConverterFactorySimpe;
  const AMainMapConfig: IMainActiveMap;
  const APerfCounterList: IInternalPerformanceCounterList
);
var
  VGeoConverter: ICoordConverter;
  VLocalConverter: ILocalCoordConverter;
  VCenterPoint: TDoublePoint;
  VZoom: Byte;
begin
  inherited Create;
  FPosChangeCounter := APerfCounterList.CreateAndAddNewCounter('PosChange');
  FScaleChangeCounter := APerfCounterList.CreateAndAddNewCounter('ScaleChange');

  FVisibleCoordConverterFactory := ACoordConverterFactory;
  FMainMapConfig := AMainMapConfig;
  FMainCoordConverter := nil;

  FMainMapChangeListener := TNotifyNoMmgEventListener.Create(Self.OnMainMapChange);
  FBaseScale.X := 1;
  FBaseScale.Y := 1;

  VGeoConverter := _GetActiveCoordConverter;
  VZoom := 0;
  VGeoConverter.CheckZoom(VZoom);
  VCenterPoint := RectCenter(VGeoConverter.PixelRectAtZoom(VZoom));

  VLocalConverter :=
    CreateVisibleCoordConverter(
      VGeoConverter,
      Point(1024, 768),
      DoublePoint(0, 0),
      FBaseScale,
      VCenterPoint,
      VZoom
    );
  FPosition := TLocalCoordConverterChangeable.Create(VLocalConverter);
  FView := TLocalCoordConverterChangeable.Create(VLocalConverter);
  FMainMapConfig.GetChangeNotifier.Add(FMainMapChangeListener);
end;

destructor TMapViewPortState.Destroy;
begin
  if FMainMapConfig <> nil then begin
    FMainMapConfig.GetChangeNotifier.Remove(FMainMapChangeListener);
    FMainMapChangeListener := nil;
    FMainMapConfig := nil;
  end;
  FVisibleCoordConverterFactory := nil;
  inherited;
end;

procedure TMapViewPortState.FitRectToScreen(const ALonLatRect: TDoubleRect);
var
  VCenterLonLat: TDoublePoint;
  VLLRect: TDoubleRect;
  VGeoConverter: ICoordConverter;
  VScreenSize: TPoint;
  VRelativeRect: TDoubleRect;
  VTargetZoom: Byte;
  VZoom: Byte;
  VMarkMapRect: TRect;
  VMarkMapSize: TPoint;
  VLocalConverter: ILocalCoordConverter;
  VLocalConverterNew: ILocalCoordConverter;
begin
  if PointIsEmpty(ALonLatRect.TopLeft) or PointIsEmpty(ALonLatRect.BottomRight) then begin
    Exit;
  end;
  if DoublePointsEqual(ALonLatRect.TopLeft, ALonLatRect.BottomRight) then begin
    Exit;
  end;
  VCenterLonLat.X := (ALonLatRect.Left + ALonLatRect.Right) / 2;
  VCenterLonLat.Y := (ALonLatRect.Top + ALonLatRect.Bottom) / 2;
  VLLRect := ALonLatRect;
  LockWrite;
  try
    VLocalConverter := FPosition.GetStatic;
    VGeoConverter := VLocalConverter.GeoConverter;
    VScreenSize := VLocalConverter.GetLocalRectSize;

    VGeoConverter.CheckLonLatRect(VLLRect);
    VRelativeRect := VGeoConverter.LonLatRect2RelativeRect(VLLRect);

    VTargetZoom := 23;
    for VZoom := 1 to 23 do begin
      VMarkMapRect := VGeoConverter.RelativeRect2PixelRect(VRelativeRect, VZoom);
      VMarkMapSize.X := VMarkMapRect.Right - VMarkMapRect.Left;
      VMarkMapSize.Y := VMarkMapRect.Bottom - VMarkMapRect.Top;
      if (VMarkMapSize.X > VScreenSize.X) or (VMarkMapSize.Y > VScreenSize.Y) then begin
        VTargetZoom := VZoom - 1;
        Break;
      end;
    end;
    VGeoConverter.CheckZoom(VTargetZoom);
    VGeoConverter.CheckLonLatPos(VCenterLonLat);

    VLocalConverterNew :=
      CreateVisibleCoordConverter(
        VGeoConverter,
        VScreenSize,
        DoublePoint(0, 0),
        FBaseScale,
        VGeoConverter.LonLat2PixelPosFloat(VCenterLonLat, VTargetZoom),
        VTargetZoom
      );
    FPosition.SetConverter(VLocalConverterNew);
    FView.SetConverter(VLocalConverterNew);
  finally
    UnlockWrite;
  end;
end;

procedure TMapViewPortState.ChangeLonLat(const ALonLat: TDoublePoint);
var
  VLonLat: TDoublePoint;
  VPixelPos: TDoublePoint;
  VLocalConverter: ILocalCoordConverter;
  VGeoConverter: ICoordConverter;
  VLocalConverterNew: ILocalCoordConverter;
begin
  VLonLat := ALonLat;
  LockWrite;
  try
    VLocalConverter := FPosition.GetStatic;
    VGeoConverter := VLocalConverter.GeoConverter;
    VGeoConverter.CheckLonLatPos(VLonLat);
    VPixelPos := VGeoConverter.LonLat2PixelPosFloat(VLonLat, VLocalConverter.Zoom);
    VLocalConverter :=
      CreateVisibleCoordConverter(
        VGeoConverter,
        VLocalConverter.GetLocalRectSize,
        DoublePoint(0, 0),
        FBaseScale,
        VPixelPos,
        VLocalConverter.Zoom
      );
    FPosition.SetConverter(VLocalConverterNew);
    FView.SetConverter(VLocalConverterNew);
  finally
    UnlockWrite;
  end;
end;

procedure TMapViewPortState.ChangeMapPixelByDelta(const ADelta: TDoublePoint);
var
  VNewPos: TDoublePoint;
  VZoom: Byte;
  VLocalConverter: ILocalCoordConverter;
  VGeoConverter: ICoordConverter;
  VLocalConverterNew: ILocalCoordConverter;
  VCenterPos: TDoublePoint;
begin
  LockWrite;
  try
    VLocalConverter := FPosition.GetStatic;
    VGeoConverter := VLocalConverter.GeoConverter;

    VZoom := VLocalConverter.Zoom;
    VCenterPos := VLocalConverter.GetCenterMapPixelFloat;
    VNewPos.X := VCenterPos.X + ADelta.X / FBaseScale.X;
    VNewPos.Y := VCenterPos.Y + ADelta.Y / FBaseScale.Y;

    VGeoConverter.CheckPixelPosFloatStrict(VNewPos, VZoom, True);
    VLocalConverter :=
      CreateVisibleCoordConverter(
        VGeoConverter,
        VLocalConverter.GetLocalRectSize,
        DoublePoint(0, 0),
        FBaseScale,
        VNewPos,
        VZoom
      );
    FPosition.SetConverter(VLocalConverterNew);
    FView.SetConverter(VLocalConverterNew);
  finally
    UnlockWrite;
  end;
end;

procedure TMapViewPortState.ChangeMapPixelToVisualPoint(
  const AVisualPoint: TPoint
);
var
  VNewPos: TDoublePoint;
  VZoom: Byte;
  VLocalConverter: ILocalCoordConverter;
  VGeoConverter: ICoordConverter;
  VLocalConverterNew: ILocalCoordConverter;
begin
  LockWrite;
  try
    VLocalConverter := FPosition.GetStatic;
    VZoom := VLocalConverter.Zoom;
    VGeoConverter := VLocalConverter.GeoConverter;
    VNewPos := VLocalConverter.LocalPixel2MapPixelFloat(AVisualPoint);
    VGeoConverter.CheckPixelPosFloatStrict(VNewPos, VZoom, True);
    VLocalConverterNew :=
      CreateVisibleCoordConverter(
        VGeoConverter,
        VLocalConverter.GetLocalRectSize,
        DoublePoint(0, 0),
        FBaseScale,
        VNewPos,
        VZoom
      );
    FPosition.SetConverter(VLocalConverterNew);
    FView.SetConverter(VLocalConverterNew);
  finally
    UnlockWrite;
  end;
end;

procedure TMapViewPortState.ChangeViewSize(const ANewSize: TPoint);
var
  VLocalConverter: ILocalCoordConverter;
  VGeoConverter: ICoordConverter;
  VLocalConverterNew: ILocalCoordConverter;
begin
  if ANewSize.X <= 0 then begin
    raise Exception.Create('��������� ������ ������������ �����');
  end;
  if ANewSize.X > 4096 then begin
    raise Exception.Create('��������� ������ ������������ �����');
  end;
  if ANewSize.Y <= 0 then begin
    raise Exception.Create('��������� ������ ������������ �����');
  end;
  if ANewSize.Y > 4096 then begin
    raise Exception.Create('��������� ������ ������������ �����');
  end;
  LockWrite;
  try
    VLocalConverter := FPosition.GetStatic;
    VGeoConverter := VLocalConverter.GeoConverter;
    VLocalConverterNew :=
      CreateVisibleCoordConverter(
        VGeoConverter,
        ANewSize,
        DoublePoint(0, 0),
        FBaseScale,
        VLocalConverter.GetCenterMapPixelFloat,
        VLocalConverter.Zoom
      );
    FPosition.SetConverter(VLocalConverterNew);
    FView.SetConverter(VLocalConverterNew);
  finally
    UnlockWrite;
  end;
end;

procedure TMapViewPortState.ChangeZoomWithFreezeAtCenter(const AZoom: Byte);
var
  VRelativePoint: TDoublePoint;
  VZoom: Byte;
  VZoomOld: Byte;
  VLocalConverter: ILocalCoordConverter;
  VGeoConverter: ICoordConverter;
  VLocalConverterNew: ILocalCoordConverter;
  VCenterPos: TDoublePoint;
begin
  LockWrite;
  try
    VLocalConverter := FPosition.GetStatic;
    VGeoConverter := VLocalConverter.GeoConverter;
    VZoom := AZoom;
    VZoomOld := VLocalConverter.Zoom;
    VGeoConverter.CheckZoom(VZoom);
    VRelativePoint := VGeoConverter.PixelPosFloat2Relative(VLocalConverter.GetCenterMapPixelFloat, VZoomOld);
    VCenterPos := VGeoConverter.Relative2PixelPosFloat(VRelativePoint, VZoom);
    VLocalConverterNew :=
      CreateVisibleCoordConverter(
        VGeoConverter,
        VLocalConverter.GetLocalRectSize,
        DoublePoint(0, 0),
        FBaseScale,
        VCenterPos,
        VZoom
      );
    FPosition.SetConverter(VLocalConverterNew);
    FView.SetConverter(VLocalConverterNew);
  finally
    UnlockWrite;
  end;
end;

procedure TMapViewPortState.ChangeZoomWithFreezeAtVisualPoint(
  const AZoom: Byte;
  const AFreezePoint: TPoint
);
var
  VZoom: Byte;
  VZoomOld: Byte;
  VMapFreezePoint: TDoublePoint;
  VRelativeFreezePoint: TDoublePoint;
  VMapFreezPointAtNewZoom: TDoublePoint;
  VNewCenterPos: TDoublePoint;
  VViewCenter: TDoublePoint;
  VLocalConverter: ILocalCoordConverter;
  VGeoConverter: ICoordConverter;
  VLocalConverterNew: ILocalCoordConverter;
begin
  LockWrite;
  try
    VLocalConverter := FPosition.GetStatic;
    VGeoConverter := VLocalConverter.GeoConverter;
    VZoom := AZoom;
    VGeoConverter.CheckZoom(VZoom);
    VZoomOld := VLocalConverter.Zoom;
      VMapFreezePoint := VLocalConverter.LocalPixel2MapPixelFloat(AFreezePoint);
      VGeoConverter.CheckPixelPosFloat(VMapFreezePoint, VZoomOld, False);
      VRelativeFreezePoint := VGeoConverter.PixelPosFloat2Relative(VMapFreezePoint, VZoomOld);
      VMapFreezPointAtNewZoom := VGeoConverter.Relative2PixelPosFloat(VRelativeFreezePoint, VZoom);
      VViewCenter := RectCenter(VLocalConverter.GetLocalRect);

      VNewCenterPos.X := VMapFreezPointAtNewZoom.X - (AFreezePoint.X - VViewCenter.X) / FBaseScale.X;
      VNewCenterPos.Y := VMapFreezPointAtNewZoom.Y - (AFreezePoint.Y - VViewCenter.Y) / FBaseScale.Y;
      VGeoConverter.CheckPixelPosFloatStrict(VNewCenterPos, VZoom, False);

      VLocalConverterNew :=
        CreateVisibleCoordConverter(
          VGeoConverter,
          VLocalConverter.GetLocalRectSize,
          DoublePoint(0, 0),
          FBaseScale,
          VNewCenterPos,
          VZoom
        );
      FPosition.SetConverter(VLocalConverterNew);
      FView.SetConverter(VLocalConverterNew);
  finally
    UnlockWrite;
  end;
end;

function TMapViewPortState.CreateVisibleCoordConverter(
  AActiveCoordConverter: ICoordConverter;
  AViewSize: TPoint;
  AVisibleMove: TDoublePoint;
  AMapScale: TDoublePoint;
  ACenterPos: TDoublePoint;
  AZoom: Byte
): ILocalCoordConverter;
var
  VViewCenter: TPoint;
  VLocalTopLeftAtMap: TDoublePoint;
begin
  VViewCenter := Point(AViewSize.X div 2, AViewSize.Y div 2);
  VLocalTopLeftAtMap.X := (-VViewCenter.X + AVisibleMove.X) / AMapScale.X + ACenterPos.X;
  VLocalTopLeftAtMap.Y := (-VViewCenter.Y + AVisibleMove.Y) / AMapScale.Y + ACenterPos.Y;

  Result := FVisibleCoordConverterFactory.CreateConverter(
    Rect(0, 0, AViewSize.X, AViewSize.Y),
    AZoom,
    AActiveCoordConverter,
    AMapScale,
    VLocalTopLeftAtMap
  );
end;

procedure TMapViewPortState.DoChangeNotify;
var
  VCounterContext: TInternalPerformanceCounterContext;
begin
  VCounterContext := FPosChangeCounter.StartOperation;
  try
    inherited;
  finally
    FPosChangeCounter.FinishOperation(VCounterContext);
  end;
end;

procedure TMapViewPortState.DoReadConfig(const AConfigData: IConfigDataProvider);
var
  VLonLat: TDoublePoint;
  VZoom: Byte;
  VLocalConverter: ILocalCoordConverter;
  VGeoConverter: ICoordConverter;
  VLocalConverterNew: ILocalCoordConverter;
  VPixelPos: TDoublePoint;
begin
  inherited;
  if AConfigData <> nil then begin
    VLocalConverter := FPosition.GetStatic;
    VGeoConverter := VLocalConverter.GeoConverter;
    VZoom := AConfigData.ReadInteger('Zoom', VLocalConverter.Zoom);
    VGeoConverter.CheckZoom(VZoom);
    VLonLat := VLocalConverter.GetCenterLonLat;
    VLonLat.X := AConfigData.ReadFloat('X', VLonLat.X);
    VLonLat.Y := AConfigData.ReadFloat('Y', VLonLat.Y);
    VGeoConverter.CheckLonLatPos(VLonLat);

    VPixelPos := VGeoConverter.LonLat2PixelPosFloat(VLonLat, VLocalConverter.Zoom);
    VLocalConverterNew :=
      CreateVisibleCoordConverter(
        VGeoConverter,
        VLocalConverter.GetLocalRectSize,
        DoublePoint(0, 0),
        FBaseScale,
        VPixelPos,
        VLocalConverter.Zoom
      );
    FPosition.SetConverter(VLocalConverterNew);
    FView.SetConverter(VLocalConverterNew);
  end;
end;

procedure TMapViewPortState.DoWriteConfig(
  const AConfigData: IConfigDataWriteProvider
);
var
  VLonLat: TDoublePoint;
  VLocalConverter: ILocalCoordConverter;
begin
  inherited;
  VLocalConverter := FPosition.GetStatic;
  VLonLat := VLocalConverter.GetCenterLonLat;
  AConfigData.WriteInteger('Zoom', VLocalConverter.Zoom);
  AConfigData.WriteFloat('X', VLonLat.X);
  AConfigData.WriteFloat('Y', VLonLat.Y);
end;

function TMapViewPortState._GetActiveCoordConverter: ICoordConverter;
var
  VMap: IMapType;
begin
  Result := nil;
  if FMainCoordConverter <> nil then begin
    Result := FMainCoordConverter;
  end else begin
    VMap := FMainMapConfig.GetActiveMap.GetMapsSet.GetMapTypeByGUID(FMainMapConfig.GetActiveMap.GetSelectedGUID);
    if VMap <> nil then begin
      Result := VMap.MapType.ViewGeoConvert;
    end;
  end;
end;

function TMapViewPortState.GetCurrentCoordConverter: ICoordConverter;
begin
  LockRead;
  try
    Result := FPosition.GetStatic.GeoConverter;
  finally
    UnlockRead;
  end;
end;

function TMapViewPortState.GetCurrentZoom: Byte;
begin
  LockRead;
  try
    Result := FPosition.GetStatic.Zoom;
  finally
    UnlockRead;
  end;
end;

function TMapViewPortState.GetMainCoordConverter: ICoordConverter;
begin
  LockRead;
  try
    Result := FMainCoordConverter;
  finally
    UnlockRead;
  end;
end;

function TMapViewPortState.GetPosition: ILocalCoordConverterChangeable;
begin
  Result := FPosition;
end;

function TMapViewPortState.GetView: ILocalCoordConverterChangeable;
begin
  Result := FView;
end;

procedure TMapViewPortState.MoveTo(const Pnt: TPoint);
var
  VVisibleMove: TDoublePoint;
  VLocalConverter: ILocalCoordConverter;
  VLocalConverterNew: ILocalCoordConverter;
begin
  LockWrite;
  try
    VLocalConverter := FPosition.GetStatic;
    VVisibleMove := DoublePoint(Pnt);
    VLocalConverterNew :=
      CreateVisibleCoordConverter(
        VLocalConverter.GeoConverter,
        VLocalConverter.GetLocalRectSize,
        VVisibleMove,
        FBaseScale,
        VLocalConverter.GetCenterMapPixelFloat,
        VLocalConverter.Zoom
      );
    FView.SetConverter(VLocalConverterNew);
  finally
    UnlockWrite;
  end;
end;

procedure TMapViewPortState.OnMainMapChange;
begin
  LockWrite;
  try
    _SetActiveCoordConverter;
  finally
    UnlockWrite
  end;
end;

procedure TMapViewPortState.ScaleTo(
  const AScale: Double;
  const ACenterPoint: TPoint
);
var
  VVisiblePointFixed: TDoublePoint;
  VMapPointFixed: TDoublePoint;
  VNewVisualPoint: TDoublePoint;
  VNewMapScale: TDoublePoint;
  VNewVisibleMove: TDoublePoint;
  VViewCenter: TDoublePoint;
  VLocalConverter: ILocalCoordConverter;
  VLocalConverterNew: ILocalCoordConverter;
  VGeoConverter: ICoordConverter;
  VCenterPos: TDoublePoint;
  VZoom: Byte;
begin
  VVisiblePointFixed := DoublePoint(ACenterPoint);
  LockWrite;
  try
    VLocalConverter := FPosition.GetStatic;
    VZoom := VLocalConverter.Zoom;
    VGeoConverter := VLocalConverter.GeoConverter;
    VNewMapScale.X := FBaseScale.X * AScale;
    VNewMapScale.Y := FBaseScale.X * AScale;
    VMapPointFixed := VLocalConverter.LocalPixelFloat2MapPixelFloat(VVisiblePointFixed);
    VViewCenter := RectCenter(VLocalConverter.GetLocalRect);
    VCenterPos := VLocalConverter.GetCenterMapPixelFloat;
    VNewVisualPoint.X := (VMapPointFixed.X - VCenterPos.X) * VNewMapScale.X + VViewCenter.X;
    VNewVisualPoint.Y := (VMapPointFixed.Y - VCenterPos.Y) * VNewMapScale.Y + VViewCenter.Y;
    VGeoConverter.CheckPixelPosFloatStrict(VNewVisualPoint, VZoom, False);

    VNewVisibleMove.X := VNewVisualPoint.X - VVisiblePointFixed.X;
    VNewVisibleMove.Y := VNewVisualPoint.Y - VVisiblePointFixed.Y;
    VLocalConverterNew :=
      CreateVisibleCoordConverter(
        VGeoConverter,
        VLocalConverter.GetLocalRectSize,
        VNewVisibleMove,
        VNewMapScale,
        VNewVisualPoint,
        VZoom
      );
    FView.SetConverter(VLocalConverterNew);
  finally
    UnlockWrite;
  end;
end;

procedure TMapViewPortState.ScaleTo(const AScale: Double);
var
  VVisiblePointFixed: TDoublePoint;
  VMapPointFixed: TDoublePoint;
  VNewVisualPoint: TDoublePoint;
  VViewCenter: TDoublePoint;
  VNewMapScale: TDoublePoint;
  VNewVisibleMove: TDoublePoint;
  VLocalConverter: ILocalCoordConverter;
  VLocalConverterNew: ILocalCoordConverter;
  VGeoConverter: ICoordConverter;
  VCenterPos: TDoublePoint;
begin
  LockWrite;
  try
    VLocalConverter := FPosition.GetStatic;
    VGeoConverter := VLocalConverter.GeoConverter;
    VViewCenter := RectCenter(VLocalConverter.GetLocalRect);
    VVisiblePointFixed.X := VViewCenter.X;
    VVisiblePointFixed.Y := VViewCenter.Y;
    VCenterPos := VLocalConverter.GetCenterMapPixelFloat;
    VMapPointFixed := VLocalConverter.LocalPixelFloat2MapPixelFloat(VVisiblePointFixed);

    VNewMapScale.X := FBaseScale.X * AScale;
    VNewMapScale.Y := FBaseScale.X * AScale;

    VNewVisualPoint.X := (VMapPointFixed.X - VCenterPos.X) * VNewMapScale.X + VViewCenter.X;
    VNewVisualPoint.Y := (VMapPointFixed.Y - VCenterPos.Y) * VNewMapScale.Y + VViewCenter.Y;
    VNewVisibleMove.X := VNewVisualPoint.X - VVisiblePointFixed.X;
    VNewVisibleMove.Y := VNewVisualPoint.Y - VVisiblePointFixed.Y;
    VLocalConverterNew :=
      CreateVisibleCoordConverter(
        VGeoConverter,
        VLocalConverter.GetLocalRectSize,
        VNewVisibleMove,
        VNewMapScale,
        VNewVisualPoint,
        VLocalConverter.Zoom
      );
    FView.SetConverter(VLocalConverterNew);
  finally
    UnlockWrite;
  end;
end;

procedure TMapViewPortState._SetActiveCoordConverter;
var
  VCenterLonLat: TDoublePoint;
  VLocalConverter: ILocalCoordConverter;
  VLocalConverterNew: ILocalCoordConverter;
  VGeoConverter: ICoordConverter;
begin
  VLocalConverter := FPosition.GetStatic;
  VGeoConverter := _GetActiveCoordConverter;
  if not VLocalConverter.GeoConverter.IsSameConverter(VGeoConverter) then begin
    VCenterLonLat := VLocalConverter.GetCenterLonLat;
    VGeoConverter.CheckLonLatPos(VCenterLonLat);
    VLocalConverterNew :=
      CreateVisibleCoordConverter(
        VGeoConverter,
        VLocalConverter.GetLocalRectSize,
        DoublePoint(0, 0),
        FBaseScale,
        VGeoConverter.LonLat2PixelPosFloat(VCenterLonLat, VLocalConverter.Zoom),
        VLocalConverter.Zoom
      );
    FPosition.SetConverter(VLocalConverterNew);
    FView.SetConverter(VLocalConverterNew);
  end;
end;

procedure TMapViewPortState.SetMainCoordConverter(const AValue: ICoordConverter);
begin
  LockWrite;
  try
    if FMainCoordConverter <> AValue then begin
      FMainCoordConverter := AValue;
      _SetActiveCoordConverter;
    end;
  finally
    UnlockWrite;
  end;
end;

end.
