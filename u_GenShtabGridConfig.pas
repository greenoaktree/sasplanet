unit u_GenShtabGridConfig;

interface

uses
  t_GeoTypes,
  i_ILocalCoordConverter,
  i_ConfigDataProvider,
  i_ConfigDataWriteProvider,
  i_MapLayerGridsConfig,
  u_BaseGridConfig;

type
  TGenShtabGridConfig = class(TBaseGridConfig, IGenShtabGridConfig)
  private
    FScale: Integer;
  protected
    procedure DoReadConfig(AConfigData: IConfigDataProvider); override;
    procedure DoWriteConfig(AConfigData: IConfigDataWriteProvider); override;
  protected
    function GetScale: Integer;
    procedure SetScale(AValue: Integer);
    function GetRectStickToGrid(ALocalConverter: ILocalCoordConverter; ASourceRect: TDoubleRect): TDoubleRect;
  public
    constructor Create;
  end;

implementation

uses
  Ugeofun;

const
  GSHprec=100000000;

{ TGenShtabGridConfig }

constructor TGenShtabGridConfig.Create;
begin
  inherited;
  FScale := 0;
end;

procedure TGenShtabGridConfig.DoReadConfig(AConfigData: IConfigDataProvider);
begin
  inherited;
  if AConfigData <> nil then begin
    SetScale(AConfigData.ReadInteger('Scale', FScale));
  end;
end;

procedure TGenShtabGridConfig.DoWriteConfig(
  AConfigData: IConfigDataWriteProvider);
begin
  inherited;
  AConfigData.WriteInteger('Scale', FScale);
end;

function TGenShtabGridConfig.GetRectStickToGrid(
  ALocalConverter: ILocalCoordConverter; ASourceRect: TDoubleRect): TDoubleRect;
var
  VScale: Integer;
  VVisible: Boolean;
  z: TDoublePoint;
begin
  LockRead;
  try
    VVisible := GetVisible;
    VScale := FScale;
  finally
    UnlockRead;
  end;
  Result := ASourceRect;
  if VVisible and (VScale > 0)  then begin
    z := GetGhBordersStepByScale(VScale);

    Result.Left := Result.Left-(round(Result.Left*GSHprec) mod round(z.X*GSHprec))/GSHprec;
    if Result.Left < 0 then Result.Left := Result.Left-z.X;

    Result.Top := Result.Top-(round(Result.Top*GSHprec) mod round(z.Y*GSHprec))/GSHprec;
    if Result.Top > 0 then Result.Top := Result.Top+z.Y;

    Result.Right := Result.Right-(round(Result.Right*GSHprec) mod round(z.X*GSHprec))/GSHprec;
    if Result.Right >= 0 then Result.Right := Result.Right+z.X;

    Result.Bottom := Result.Bottom-(round(Result.Bottom*GSHprec) mod round(z.Y*GSHprec))/GSHprec;
    if Result.Bottom <= 0 then Result.Bottom := Result.Bottom-z.Y;
  end;
end;

function TGenShtabGridConfig.GetScale: Integer;
begin
  LockRead;
  try
    Result := FScale;
  finally
    UnlockRead;
  end;
end;

procedure TGenShtabGridConfig.SetScale(AValue: Integer);
var
  VScale: Integer;
begin
  VScale := AValue;
  if VScale >= 1000000 then begin
    VScale := 1000000;
  end else if VScale >= 500000 then begin
    VScale := 500000;
  end else if VScale >= 200000 then begin
    VScale := 200000;
  end else if VScale >= 100000 then begin
    VScale := 100000;
  end else if VScale >= 50000 then begin
    VScale := 50000;
  end else if VScale >= 25000 then begin
    VScale := 25000;
  end else if VScale >= 10000 then begin
    VScale := 10000;
  end else begin
    VScale := 0;
  end;
  LockWrite;
  try
    if FScale <> VScale then begin
      FScale := VScale;
      if FScale = 0 then begin
        SetVisible(False);
      end;
      SetChanged;
    end;
  finally
    UnlockWrite;
  end;
end;

end.
