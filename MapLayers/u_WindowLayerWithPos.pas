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

unit u_WindowLayerWithPos;

interface

uses
  Types,
  SysUtils,
  GR32,
  GR32_Layers,
  GR32_Image,
  i_NotifierOperation,
  i_LocalCoordConverter,
  i_LocalCoordConverterChangeable,
  i_ViewPortState,
  i_SimpleFlag,
  i_InternalPerformanceCounter,
  u_WindowLayerBasic;

type
  TWindowLayerSimpleBase = class(TWindowLayerAbstract)
  private
    FLocalConverter: ILocalCoordConverterChangeable;
    FLayer: TCustomLayer;
    FOnPaintCounter: IInternalPerformanceCounter;
    FOnMeasuringPaintCounter: IInternalPerformanceCounter;
    procedure OnViewPortPosChange;

    function GetVisible: Boolean;
    procedure SetVisible(const Value: Boolean);

    procedure OnPaintLayer(
      Sender: TObject;
      Buffer: TBitmap32
    );
  protected
    procedure PaintLayer(
      ABuffer: TBitmap32;
      const ALocalConverter: ILocalCoordConverter
    ); virtual; abstract;

    procedure SetNeedRedraw;
    procedure Show;
    procedure Hide;

    property Visible: Boolean read GetVisible write SetVisible;
  protected
    procedure StartThreads; override;
  public
    constructor Create(
      const APerfList: IInternalPerformanceCounterList;
      const AAppStartedNotifier: INotifierOneOperation;
      const AAppClosingNotifier: INotifierOneOperation;
      ALayer: TCustomLayer;
      const ALocalConverter: ILocalCoordConverterChangeable
    );
  end;

  TWindowLayerWithLocationBase = class(TWindowLayerAbstract)
  private
    FLayer: TPositionedLayer;
    FVisible: Boolean;
    FNeedUpdateLayerVisibilityFlag: ISimpleFlag;
    FNeedUpdateLayerLocationFlag: ISimpleFlag;
    FNeedFullRepaintLayerFlag: ISimpleFlag;

    FOnPaintCounter: IInternalPerformanceCounter;
    FOnMeasuringPaintCounter: IInternalPerformanceCounter;
    procedure SetVisible(const Value: Boolean);

    procedure OnPaintLayer(
      Sender: TObject;
      Buffer: TBitmap32
    );
  protected
    procedure StartThreads; override;
    procedure DoViewUpdate; override;
  protected
    procedure SetNeedUpdateLayerVisibility;
    procedure DoUpdateLayerVisibility; virtual;

    procedure SetNeedUpdateLayerLocation;
    function GetNewLayerLocation: TFloatRect; virtual; abstract;
    procedure DoUpdateLayerLocation(ALocation: TFloatRect); virtual;

    procedure SetNeedFullRepaintLayer;
    procedure DoFullRepaintLayer; virtual;

    procedure PaintLayer(ABuffer: TBitmap32); virtual; abstract;

    property Layer: TPositionedLayer read FLayer;
    property Visible: Boolean read FVisible write SetVisible;
  public
    constructor Create(
      const APerfList: IInternalPerformanceCounterList;
      const AAppStartedNotifier: INotifierOneOperation;
      const AAppClosingNotifier: INotifierOneOperation;
      ALayer: TPositionedLayer
    );
  end;

  TWindowLayerWithBitmapBase = class(TWindowLayerAbstract)
  private
    FLayer: TBitmapLayer;
    FVisible: Boolean;
    FNeedUpdateLayerVisibilityFlag: ISimpleFlag;
    FNeedUpdateBitmapDrawFlag: ISimpleFlag;
    FNeedUpdateBitmapSizeFlag: ISimpleFlag;
    FNeedUpdateLayerLocationFlag: ISimpleFlag;

    FResizeCounter: IInternalPerformanceCounter;
    FRedrawCounter: IInternalPerformanceCounter;

    procedure SetVisible(const Value: Boolean);
  protected
    procedure DoViewUpdate; override;
  protected
    procedure SetNeedUpdateLayerVisibility;
    procedure DoUpdateLayerVisibility; virtual;

    procedure SetNeedUpdateBitmapDraw;
    procedure DoUpdateBitmapDraw; virtual; abstract;

    procedure SetNeedUpdateBitmapSize;
    function GetNewBitmapSize: TPoint; virtual; abstract;
    procedure DoUpdateBitmapSize(const ASize: TPoint); virtual;

    procedure SetNeedUpdateLayerLocation;
    function GetNewLayerLocation: TFloatRect; virtual; abstract;
    procedure DoUpdateLayerLocation(ALocation: TFloatRect); virtual;

    property Layer: TBitmapLayer read FLayer;
    property Visible: Boolean read FVisible write SetVisible;
  public
    constructor Create(
      const APerfList: IInternalPerformanceCounterList;
      const AAppStartedNotifier: INotifierOneOperation;
      const AAppClosingNotifier: INotifierOneOperation;
      ALayer: TBitmapLayer
    );
  end;

  TWindowLayerWithPosBase = class(TWindowLayerAbstract)
  private
    FViewPortState: IViewPortState;

    FViewCoordConverter: ILocalCoordConverter;
    FViewCoordConverterCS: IReadWriteSync;

    FLayerCoordConverter: ILocalCoordConverter;
    FLayerCoordConverterCS: IReadWriteSync;

    FViewUpdateLockCounter: ICounter;
    procedure OnViewPortPosChange;
    procedure OnViewPortScaleChange;
    function GetLayerCoordConverter: ILocalCoordConverter;
    function GetViewCoordConverter: ILocalCoordConverter;

    procedure ScaleChange(const ANewVisualCoordConverter: ILocalCoordConverter);
  protected
    procedure StartThreads; override;
  protected
    procedure SetViewCoordConverter(const AValue: ILocalCoordConverter); virtual;
    procedure SetLayerCoordConverter(const AValue: ILocalCoordConverter); virtual;

    function GetLayerCoordConverterByViewConverter(const ANewViewCoordConverter: ILocalCoordConverter): ILocalCoordConverter; virtual;

    procedure PosChange(const ANewVisualCoordConverter: ILocalCoordConverter);

    property ViewCoordConverter: ILocalCoordConverter read GetViewCoordConverter;
    property LayerCoordConverter: ILocalCoordConverter read GetLayerCoordConverter;
  public
    constructor Create(
      const APerfList: IInternalPerformanceCounterList;
      const AAppStartedNotifier: INotifierOneOperation;
      const AAppClosingNotifier: INotifierOneOperation;
      const AViewPortState: IViewPortState;
      AListenScaleChange: Boolean
    );
    destructor Destroy; override;

  end;

  TWindowLayerBasic = class(TWindowLayerWithPosBase)
  private
    FVisible: Boolean;
    FLayer: TCustomLayer;

    FNeedRedrawFlag: ISimpleFlag;
    FRedrawCounter: IInternalPerformanceCounter;
  protected
    function GetVisible: Boolean; virtual;
    procedure SetVisible(const Value: Boolean);

    procedure SetNeedRedraw; virtual;

    procedure Show;
    procedure DoShow; virtual;
    procedure Hide;
    procedure DoHide; virtual;
    procedure DoRedraw; virtual; abstract;
    procedure RedrawIfNeed;

    property Layer: TCustomLayer read FLayer;
    property Visible: Boolean read GetVisible write SetVisible;
  protected
    procedure DoViewUpdate; override;
    procedure Redraw;
  public
    constructor Create(
      const APerfList: IInternalPerformanceCounterList;
      const AAppStartedNotifier: INotifierOneOperation;
      const AAppClosingNotifier: INotifierOneOperation;
      ALayer: TCustomLayer;
      const AViewPortState: IViewPortState;
      AListenScaleChange: Boolean
    );
    destructor Destroy; override;
  end;

  TWindowLayerWithBitmap = class(TWindowLayerBasic)
  private
    FNeedUpdateLayerSizeFlag: ISimpleFlag;
    FNeedUpdateLocationFlag: ISimpleFlag;
    FLayer: TBitmapLayer;
  protected
    property Layer: TBitmapLayer read FLayer;

    procedure SetNeedUpdateLayerSize; virtual;

    procedure UpdateLayerSize;
    procedure UpdateLayerSizeIfNeed;
    procedure DoUpdateLayerSize(const ANewSize: TPoint); virtual;
    function GetLayerSizeForView(const ANewVisualCoordConverter: ILocalCoordConverter): TPoint; virtual; abstract;
  protected
    function GetMapLayerLocationRect(const ANewVisualCoordConverter: ILocalCoordConverter): TFloatRect; virtual; abstract;
    procedure UpdateLayerLocationIfNeed;
    procedure UpdateLayerLocation;
    procedure DoUpdateLayerLocation(const ANewLocation: TFloatRect); virtual;
  protected
    procedure SetNeedUpdateLocation;
    procedure SetNeedRedraw; override;
    procedure SetViewCoordConverter(const AValue: ILocalCoordConverter); override;
    procedure DoHide; override;
    procedure DoShow; override;
    procedure DoViewUpdate; override;
  public
    constructor Create(
      const APerfList: IInternalPerformanceCounterList;
      const AAppStartedNotifier: INotifierOneOperation;
      const AAppClosingNotifier: INotifierOneOperation;
      AParentMap: TImage32;
      const AViewPortState: IViewPortState
    );
  end;

  TWindowLayerFixedSizeWithBitmap = class(TWindowLayerWithBitmap)
  protected
    function GetLayerSizeForView(const ANewVisualCoordConverter: ILocalCoordConverter): TPoint; override;
    procedure DoRedraw; override;
  end;

implementation

uses
  u_Synchronizer,
  u_SimpleFlagWithInterlock,
  u_ListenerByEvent;

{ TWindowLayerWithPosBase }

constructor TWindowLayerWithPosBase.Create(
  const APerfList: IInternalPerformanceCounterList;
  const AAppStartedNotifier: INotifierOneOperation;
  const AAppClosingNotifier: INotifierOneOperation;
  const AViewPortState: IViewPortState;
  AListenScaleChange: Boolean
);
begin
  inherited Create(APerfList, AAppStartedNotifier, AAppClosingNotifier);
  FViewPortState := AViewPortState;

  FViewCoordConverterCS := MakeSyncRW_Var(Self);
  FLayerCoordConverterCS := MakeSyncRW_Var(Self);
  FViewUpdateLockCounter := TCounterInterlock.Create;

  LinksList.Add(
    TNotifyNoMmgEventListener.Create(Self.OnViewPortPosChange),
    FViewPortState.Position.ChangeNotifier
  );
  if AListenScaleChange then begin
    LinksList.Add(
      TNotifyNoMmgEventListener.Create(Self.OnViewPortScaleChange),
      FViewPortState.View.ChangeNotifier
    );
  end;
end;

destructor TWindowLayerWithPosBase.Destroy;
begin
  FViewCoordConverterCS := nil;
  FLayerCoordConverterCS := nil;
  FViewCoordConverter := nil;
  FLayerCoordConverter := nil;
  FViewPortState := nil;
  inherited;
end;

procedure TWindowLayerWithPosBase.OnViewPortPosChange;
begin
  PosChange(FViewPortState.Position.GetStatic);
end;

procedure TWindowLayerWithPosBase.PosChange(
  const ANewVisualCoordConverter: ILocalCoordConverter
);
begin
  ViewUpdateLock;
  try
    SetViewCoordConverter(ANewVisualCoordConverter);
    SetLayerCoordConverter(GetLayerCoordConverterByViewConverter(ANewVisualCoordConverter));
  finally
    ViewUpdateUnlock;
  end;
end;

procedure TWindowLayerWithPosBase.OnViewPortScaleChange;
begin
  ScaleChange(FViewPortState.View.GetStatic);
end;

procedure TWindowLayerWithPosBase.ScaleChange(
  const ANewVisualCoordConverter: ILocalCoordConverter
);
begin
  ViewUpdateLock;
  try
    SetViewCoordConverter(ANewVisualCoordConverter);
  finally
    ViewUpdateUnlock;
  end;
end;

function TWindowLayerWithPosBase.GetLayerCoordConverter: ILocalCoordConverter;
begin
  FLayerCoordConverterCS.BeginRead;
  try
    Result := FLayerCoordConverter;
  finally
    FLayerCoordConverterCS.EndRead;
  end;
end;

function TWindowLayerWithPosBase.GetLayerCoordConverterByViewConverter(
  const ANewViewCoordConverter: ILocalCoordConverter
): ILocalCoordConverter;
begin
  Result := ANewViewCoordConverter;
end;

function TWindowLayerWithPosBase.GetViewCoordConverter: ILocalCoordConverter;
begin
  FViewCoordConverterCS.BeginRead;
  try
    Result := FViewCoordConverter;
  finally
    FViewCoordConverterCS.EndRead;
  end;
end;

procedure TWindowLayerWithPosBase.SetLayerCoordConverter(
  const AValue: ILocalCoordConverter
);
begin
  FLayerCoordConverterCS.BeginWrite;
  try
    FLayerCoordConverter := AValue;
  finally
    FLayerCoordConverterCS.EndWrite;
  end;
end;

procedure TWindowLayerWithPosBase.SetViewCoordConverter(
  const AValue: ILocalCoordConverter
);
begin
  FViewCoordConverterCS.BeginWrite;
  try
    FViewCoordConverter := AValue;
  finally
    FViewCoordConverterCS.EndWrite;
  end;
end;

procedure TWindowLayerWithPosBase.StartThreads;
begin
  inherited;
  OnViewPortPosChange;
end;

{ TWindowLayerBasic }

constructor TWindowLayerBasic.Create(
  const APerfList: IInternalPerformanceCounterList;
  const AAppStartedNotifier: INotifierOneOperation;
  const AAppClosingNotifier: INotifierOneOperation;
  ALayer: TCustomLayer;
  const AViewPortState: IViewPortState;
  AListenScaleChange: Boolean
);
begin
  inherited Create(
    APerfList,
    AAppStartedNotifier,
    AAppClosingNotifier,
    AViewPortState,
    AListenScaleChange
  );
  FLayer := ALayer;
  FRedrawCounter := PerfList.CreateAndAddNewCounter('Redraw');

  FLayer.MouseEvents := false;
  FLayer.Visible := false;
  FVisible := False;
  FNeedRedrawFlag := TSimpleFlagWithInterlock.Create;
end;

destructor TWindowLayerBasic.Destroy;
begin
  FLayer := nil;
  inherited;
end;

procedure TWindowLayerBasic.DoViewUpdate;
begin
  inherited;
  RedrawIfNeed;
end;

procedure TWindowLayerBasic.Hide;
begin
  ViewUpdateLock;
  try
    if FVisible then begin
      DoHide;
    end;
  finally
    ViewUpdateUnlock;
  end;
end;

procedure TWindowLayerBasic.DoHide;
begin
  FVisible := False;
  FLayer.Visible := False;
  SetNeedRedraw;
end;

procedure TWindowLayerBasic.Show;
begin
  ViewUpdateLock;
  try
    if not Visible then begin
      DoShow;
    end;
  finally
    ViewUpdateUnlock;
  end;
end;

procedure TWindowLayerBasic.DoShow;
begin
  FVisible := True;
  FLayer.Visible := True;
  SetNeedRedraw;
end;

function TWindowLayerBasic.GetVisible: Boolean;
begin
  Result := FVisible;
end;

procedure TWindowLayerBasic.Redraw;
var
  VCounterContext: TInternalPerformanceCounterContext;
begin
  if FVisible then begin
    FNeedRedrawFlag.CheckFlagAndReset;
    VCounterContext := FRedrawCounter.StartOperation;
    try
      DoRedraw;
    finally
      FRedrawCounter.FinishOperation(VCounterContext);
    end;
  end;
end;

procedure TWindowLayerBasic.RedrawIfNeed;
begin
  if FNeedRedrawFlag.CheckFlagAndReset then begin
    Redraw;
  end;
end;

procedure TWindowLayerBasic.SetNeedRedraw;
begin
  FNeedRedrawFlag.SetFlag;
end;

procedure TWindowLayerBasic.SetVisible(const Value: Boolean);
begin
  if Value then begin
    Show;
  end else begin
    Hide;
  end;
end;

{ TWindowLayerWithBitmap }

constructor TWindowLayerWithBitmap.Create(
  const APerfList: IInternalPerformanceCounterList;
  const AAppStartedNotifier: INotifierOneOperation;
  const AAppClosingNotifier: INotifierOneOperation;
  AParentMap: TImage32;
  const AViewPortState: IViewPortState
);
begin
  FLayer := TBitmapLayer.Create(AParentMap.Layers);
  inherited Create(
    APerfList,
    AAppStartedNotifier,
    AAppClosingNotifier,
    FLayer,
    AViewPortState,
    True
  );

  FNeedUpdateLayerSizeFlag := TSimpleFlagWithInterlock.Create;
  FNeedUpdateLocationFlag := TSimpleFlagWithInterlock.Create;
  FLayer.Bitmap.DrawMode := dmBlend;
end;

procedure TWindowLayerWithBitmap.DoViewUpdate;
begin
  UpdateLayerSizeIfNeed;
  inherited;
  UpdateLayerLocationIfNeed;
end;

procedure TWindowLayerWithBitmap.DoHide;
begin
  inherited;
  SetNeedUpdateLayerSize;
end;

procedure TWindowLayerWithBitmap.DoShow;
begin
  inherited;
  SetNeedUpdateLayerSize;
end;

procedure TWindowLayerWithBitmap.DoUpdateLayerLocation(
  const ANewLocation: TFloatRect
);
begin
  FLayer.Location := ANewLocation;
end;

procedure TWindowLayerWithBitmap.DoUpdateLayerSize(const ANewSize: TPoint);
var
  VNedRedraw: Boolean;
begin
  FLayer.Bitmap.Lock;
  try
    VNedRedraw := FLayer.Bitmap.SetSize(ANewSize.X, ANewSize.Y);
  finally
    FLayer.Bitmap.Unlock;
  end;
  if VNedRedraw then begin
    SetNeedRedraw;
  end;
end;

procedure TWindowLayerWithBitmap.SetNeedRedraw;
begin
  inherited;
  SetNeedUpdateLocation;
end;

procedure TWindowLayerWithBitmap.SetNeedUpdateLayerSize;
begin
  FNeedUpdateLayerSizeFlag.SetFlag;
end;

procedure TWindowLayerWithBitmap.SetNeedUpdateLocation;
begin
  FNeedUpdateLocationFlag.SetFlag;
end;

procedure TWindowLayerWithBitmap.SetViewCoordConverter(
  const AValue: ILocalCoordConverter
);
var
  VLocalConverter: ILocalCoordConverter;
begin
  VLocalConverter := ViewCoordConverter;
  if (VLocalConverter = nil) or (not VLocalConverter.GetIsSameConverter(AValue)) then begin
    SetNeedUpdateLocation;
  end;
  inherited;
end;

procedure TWindowLayerWithBitmap.UpdateLayerLocation;
begin
  if Visible then begin
    FNeedUpdateLocationFlag.CheckFlagAndReset;
    DoUpdateLayerLocation(GetMapLayerLocationRect(ViewCoordConverter));
  end;
end;

procedure TWindowLayerWithBitmap.UpdateLayerLocationIfNeed;
begin
  if FNeedUpdateLocationFlag.CheckFlagAndReset then begin
    UpdateLayerLocation;
  end;
end;

procedure TWindowLayerWithBitmap.UpdateLayerSize;
begin
  if FVisible then begin
    FNeedUpdateLayerSizeFlag.CheckFlagAndReset;
    DoUpdateLayerSize(GetLayerSizeForView(LayerCoordConverter));
  end;
end;

procedure TWindowLayerWithBitmap.UpdateLayerSizeIfNeed;
begin
  if FNeedUpdateLayerSizeFlag.CheckFlagAndReset then begin
    UpdateLayerSize;
  end;
end;

{ TWindowLayerFixedSizeWithBitmap }

procedure TWindowLayerFixedSizeWithBitmap.DoRedraw;
begin
  // ��-��������� ������ �� ������.
end;

function TWindowLayerFixedSizeWithBitmap.GetLayerSizeForView(
  const ANewVisualCoordConverter: ILocalCoordConverter
): TPoint;
begin
  FLayer.Bitmap.Lock;
  try
    Result := Point(FLayer.Bitmap.Width, FLayer.Bitmap.Height);
  finally
    FLayer.Bitmap.Unlock;
  end;
end;

{ TWindowLayerSimpleBase }

constructor TWindowLayerSimpleBase.Create(
  const APerfList: IInternalPerformanceCounterList;
  const AAppStartedNotifier, AAppClosingNotifier: INotifierOneOperation;
  ALayer: TCustomLayer;
  const ALocalConverter: ILocalCoordConverterChangeable
);
begin
  inherited Create(APerfList, AAppStartedNotifier, AAppClosingNotifier);
  FLocalConverter := ALocalConverter;
  FLayer := ALayer;

  FLayer.MouseEvents := false;
  FLayer.Visible := false;

  FOnPaintCounter := PerfList.CreateAndAddNewCounter('OnPaint');
  FOnMeasuringPaintCounter := PerfList.CreateAndAddNewCounter('OnMeasuringPaint');

  LinksList.Add(
    TNotifyNoMmgEventListener.Create(Self.OnViewPortPosChange),
    FLocalConverter.ChangeNotifier
  );
end;

function TWindowLayerSimpleBase.GetVisible: Boolean;
begin
  Result := FLayer.Visible;
end;

procedure TWindowLayerSimpleBase.Hide;
begin
  FLayer.Visible := False
end;

procedure TWindowLayerSimpleBase.OnPaintLayer(
  Sender: TObject;
  Buffer: TBitmap32
);
var
  VConverter: ILocalCoordConverter;
  VCounter: IInternalPerformanceCounter;
  VCounterContext: TInternalPerformanceCounterContext;
begin
  VConverter := FLocalConverter.GetStatic;
  if VConverter <> nil then begin
    if Buffer.MeasuringMode then begin
      VCounter := FOnMeasuringPaintCounter;
    end else begin
      VCounter := FOnPaintCounter;
    end;
    VCounterContext := VCounter.StartOperation;
    try
      PaintLayer(Buffer, VConverter);
    finally
      VCounter.FinishOperation(VCounterContext);
    end;
  end;
end;

procedure TWindowLayerSimpleBase.OnViewPortPosChange;
begin
  SetNeedRedraw;
end;

procedure TWindowLayerSimpleBase.SetNeedRedraw;
begin
  inherited;
  FLayer.Changed;
end;

procedure TWindowLayerSimpleBase.SetVisible(const Value: Boolean);
begin
  FLayer.Visible := Value
end;

procedure TWindowLayerSimpleBase.Show;
begin
  FLayer.Visible := True
end;

procedure TWindowLayerSimpleBase.StartThreads;
begin
  inherited;
  FLayer.OnPaint := OnPaintLayer;
end;

{ TWindowLayerWithBitmapBase }

constructor TWindowLayerWithBitmapBase.Create(
  const APerfList: IInternalPerformanceCounterList; const AAppStartedNotifier,
  AAppClosingNotifier: INotifierOneOperation; ALayer: TBitmapLayer);
begin
  inherited Create(
    APerfList,
    AAppStartedNotifier,
    AAppClosingNotifier
  );
  FLayer := ALayer;
  FLayer.Visible := False;
  FLayer.MouseEvents := False;
  FLayer.Bitmap.DrawMode := dmBlend;

  FNeedUpdateLayerVisibilityFlag := TSimpleFlagWithInterlock.Create;
  FNeedUpdateBitmapDrawFlag := TSimpleFlagWithInterlock.Create;
  FNeedUpdateBitmapSizeFlag := TSimpleFlagWithInterlock.Create;
  FNeedUpdateLayerLocationFlag := TSimpleFlagWithInterlock.Create;

  FResizeCounter := PerfList.CreateAndAddNewCounter('Resize');
  FRedrawCounter := PerfList.CreateAndAddNewCounter('Redraw');
end;

procedure TWindowLayerWithBitmapBase.DoUpdateBitmapSize(const ASize: TPoint);
begin
  FLayer.Bitmap.SetSize(ASize.X, ASize.Y);
end;

procedure TWindowLayerWithBitmapBase.DoUpdateLayerLocation(ALocation: TFloatRect);
begin
  FLayer.Location := ALocation;
end;

procedure TWindowLayerWithBitmapBase.DoUpdateLayerVisibility;
begin
  FLayer.Visible := FVisible;
end;

procedure TWindowLayerWithBitmapBase.DoViewUpdate;
var
  VSize: TPoint;
  VLocation: TFloatRect;
  VCounterContext: TInternalPerformanceCounterContext;
begin
  inherited;
  if FNeedUpdateLayerVisibilityFlag.CheckFlagAndReset then begin
    if FVisible <> FLayer.Visible then begin
      SetNeedUpdateLayerVisibility;
      SetNeedUpdateBitmapSize;
    end;
  end;
  if FNeedUpdateBitmapSizeFlag.CheckFlagAndReset then begin
    if FVisible then begin
      VSize := GetNewBitmapSize;
    end else begin
      VSize := Point(0, 0);
    end;
    if (VSize.X <> FLayer.Bitmap.Width) or (VSize.Y <> FLayer.Bitmap.Height) then begin
      VCounterContext := FResizeCounter.StartOperation;
      try
        DoUpdateBitmapSize(VSize);
        if FVisible then begin
          SetNeedUpdateBitmapDraw;
          SetNeedUpdateLayerLocation;
        end;
      finally
        FResizeCounter.FinishOperation(VCounterContext);
      end;
    end;
  end;
  if FNeedUpdateBitmapDrawFlag.CheckFlagAndReset then begin
    if FVisible then begin
      VCounterContext := FRedrawCounter.StartOperation;
      try
        DoUpdateBitmapDraw;
      finally
        FRedrawCounter.FinishOperation(VCounterContext);
      end;
    end;
  end;
  if FNeedUpdateLayerLocationFlag.CheckFlagAndReset then begin
    VLocation := GetNewLayerLocation;
    if not EqualRect(VLocation, FLayer.Location) then begin
      DoUpdateLayerLocation(VLocation);
    end;
  end;
  if FNeedUpdateLayerVisibilityFlag.CheckFlagAndReset then begin
    if FLayer.Visible <> FVisible then begin
      DoUpdateLayerVisibility;
    end;
  end;
end;

procedure TWindowLayerWithBitmapBase.SetNeedUpdateBitmapDraw;
begin
  FNeedUpdateBitmapDrawFlag.SetFlag;
end;

procedure TWindowLayerWithBitmapBase.SetNeedUpdateBitmapSize;
begin
  FNeedUpdateBitmapSizeFlag.SetFlag;
end;

procedure TWindowLayerWithBitmapBase.SetNeedUpdateLayerLocation;
begin
  FNeedUpdateLayerLocationFlag.SetFlag;
end;

procedure TWindowLayerWithBitmapBase.SetNeedUpdateLayerVisibility;
begin
  FNeedUpdateLayerVisibilityFlag.SetFlag;
end;

procedure TWindowLayerWithBitmapBase.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
  SetNeedUpdateLayerVisibility;
end;

{ TWindowLayerWithLocationBase }

constructor TWindowLayerWithLocationBase.Create(
  const APerfList: IInternalPerformanceCounterList; const AAppStartedNotifier,
  AAppClosingNotifier: INotifierOneOperation; ALayer: TPositionedLayer);
begin
  inherited Create(
    APerfList,
    AAppStartedNotifier,
    AAppClosingNotifier
  );
  FLayer := ALayer;
  FLayer.Visible := False;
  FLayer.MouseEvents := False;

  FNeedUpdateLayerVisibilityFlag := TSimpleFlagWithInterlock.Create;
  FNeedUpdateLayerLocationFlag := TSimpleFlagWithInterlock.Create;
  FNeedFullRepaintLayerFlag := TSimpleFlagWithInterlock.Create;

  FOnPaintCounter := PerfList.CreateAndAddNewCounter('OnPaint');
  FOnMeasuringPaintCounter := PerfList.CreateAndAddNewCounter('OnMeasuringPaint');
end;

procedure TWindowLayerWithLocationBase.DoFullRepaintLayer;
begin
  FLayer.Changed;
end;

procedure TWindowLayerWithLocationBase.DoUpdateLayerLocation(
  ALocation: TFloatRect);
begin
  FLayer.Location := ALocation;
end;

procedure TWindowLayerWithLocationBase.DoUpdateLayerVisibility;
begin
  FLayer.Visible := FVisible;
end;

procedure TWindowLayerWithLocationBase.DoViewUpdate;
var
  VLocation: TFloatRect;
begin
  inherited;
  if FNeedUpdateLayerLocationFlag.CheckFlagAndReset then begin
    VLocation := GetNewLayerLocation;
    if not EqualRect(VLocation, FLayer.Location) then begin
      DoUpdateLayerLocation(VLocation);
    end;
  end;
  if FNeedUpdateLayerVisibilityFlag.CheckFlagAndReset then begin
    if FLayer.Visible <> FVisible then begin
      DoUpdateLayerVisibility;
    end;
  end;
  if FNeedFullRepaintLayerFlag.CheckFlagAndReset then begin
    DoFullRepaintLayer;
  end;
end;

procedure TWindowLayerWithLocationBase.OnPaintLayer(Sender: TObject;
  Buffer: TBitmap32);
var
  VCounter: IInternalPerformanceCounter;
  VCounterContext: TInternalPerformanceCounterContext;
  VOldClipRect: TRect;
  VNewClipRect: TRect;
begin
  if Buffer.MeasuringMode then begin
    VCounter := FOnMeasuringPaintCounter;
  end else begin
    VCounter := FOnPaintCounter;
  end;
  VCounterContext := VCounter.StartOperation;
  try
    VOldClipRect := Buffer.ClipRect;
    if IntersectRect(VNewClipRect, VOldClipRect, MakeRect(FLayer.Location, rrClosest)) then begin
      Buffer.ClipRect := VNewClipRect;
      try
        PaintLayer(Buffer);
      finally
        Buffer.ClipRect := VOldClipRect;
      end;
    end;
  finally
    VCounter.FinishOperation(VCounterContext);
  end;
end;

procedure TWindowLayerWithLocationBase.SetNeedFullRepaintLayer;
begin
  FNeedFullRepaintLayerFlag.SetFlag;
end;

procedure TWindowLayerWithLocationBase.SetNeedUpdateLayerLocation;
begin
  FNeedUpdateLayerLocationFlag.SetFlag;
end;

procedure TWindowLayerWithLocationBase.SetNeedUpdateLayerVisibility;
begin
  FNeedUpdateLayerVisibilityFlag.SetFlag;
end;

procedure TWindowLayerWithLocationBase.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
  SetNeedUpdateLayerVisibility;
end;

procedure TWindowLayerWithLocationBase.StartThreads;
begin
  inherited;
  FLayer.OnPaint := OnPaintLayer;
end;

end.
