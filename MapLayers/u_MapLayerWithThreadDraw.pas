unit u_MapLayerWithThreadDraw;

interface

uses
  Classes,
  SyncObjs,
  GR32,
  GR32_Image,
  GR32_Layers,
  i_ILocalCoordConverter,
  i_IBackgroundTaskLayerDraw,
  u_MapViewPortState,
  u_MapLayerBasic;

type
  TMapLayerWithThreadDraw = class(TMapLayerBasicNoBitmap)
  protected
    FDrawTask: IBackgroundTaskLayerDraw;
    FBitmapCoordConverter: ILocalCoordConverter;
    FLayer: TBitmapLayer;
    property DrawTask: IBackgroundTaskLayerDraw read FDrawTask;
    procedure DoRedraw; override;
    procedure DoHide; override;
    procedure DoShow; override;
    function GetMapLayerLocationRect: TFloatRect; override;
    procedure DoUpdateLayerSize(ANewSize: TPoint); override;
    procedure DoPosChange(ANewVisualCoordConverter: ILocalCoordConverter); override;
  public
    constructor Create(AParentMap: TImage32; AViewPortState: TMapViewPortState; ATaskFactory: IBackgroundTaskLayerDrawFactory);
    destructor Destroy; override;
    procedure StartThreads; override;
    procedure SendTerminateToThreads; override;
  end;

implementation

uses
  SysUtils,
  t_GeoTypes,
  Ugeofun;

{ TMapLayerWithThreadDraw }

constructor TMapLayerWithThreadDraw.Create(AParentMap: TImage32;
  AViewPortState: TMapViewPortState;  ATaskFactory: IBackgroundTaskLayerDrawFactory);
begin
  FLayer := TBitmapLayer.Create(AParentMap.Layers);
  inherited Create(FLayer, AViewPortState);
  FLayer.Bitmap.DrawMode := dmBlend;
  FLayer.Bitmap.CombineMode := cmMerge;
  FDrawTask := ATaskFactory.GetTask(FLayer.Bitmap);
end;

destructor TMapLayerWithThreadDraw.Destroy;
begin
  FDrawTask := nil;
  inherited;
end;

procedure TMapLayerWithThreadDraw.DoHide;
begin
  inherited;
  FDrawTask.StopExecute;
end;

procedure TMapLayerWithThreadDraw.DoPosChange(
  ANewVisualCoordConverter: ILocalCoordConverter);
begin
  inherited;
  FBitmapCoordConverter :=  FVisualCoordConverter;
  FDrawTask.ChangePos(FBitmapCoordConverter);
  UpdateLayerLocation(GetMapLayerLocationRect);
end;

procedure TMapLayerWithThreadDraw.DoRedraw;
begin
  inherited;
  FDrawTask.StopExecute;
  FDrawTask.StartExecute;
end;

procedure TMapLayerWithThreadDraw.DoShow;
begin
  inherited;
  FDrawTask.StartExecute;
end;

procedure TMapLayerWithThreadDraw.DoUpdateLayerSize(ANewSize: TPoint);
begin
  inherited;
  FDrawTask.StopExecute;
  try
    FDrawTask.ChangePos(FBitmapCoordConverter);
  finally
    FDrawTask.StartExecute;
  end;
end;

function TMapLayerWithThreadDraw.GetMapLayerLocationRect: TFloatRect;
var
  VBitmapOnMapRect: TDoubleRect;
  VBitmapOnVisualRect: TDoubleRect;
begin
  VBitmapOnMapRect := FBitmapCoordConverter.GetRectInMapPixelFloat;
  VBitmapOnVisualRect := FVisualCoordConverter.MapRectFloat2LocalRectFloat(VBitmapOnMapRect);
  Result := FloatRect(VBitmapOnVisualRect.Left, VBitmapOnVisualRect.Top, VBitmapOnVisualRect.Right, VBitmapOnVisualRect.Bottom);
end;

procedure TMapLayerWithThreadDraw.SendTerminateToThreads;
begin
  inherited;
  FDrawTask.Terminate;
end;

procedure TMapLayerWithThreadDraw.StartThreads;
begin
  inherited;
  FDrawTask.Start;
  FDrawTask.ChangePos(FBitmapCoordConverter);
end;

end.
