unit u_MainMemCacheConfig;

interface

uses
  i_IConfigDataProvider,
  i_IConfigDataWriteProvider,
  i_IMainMemCacheConfig,
  u_ConfigDataElementBase;

type
  TMainMemCacheConfig = class(TConfigDataElementBase, IMainMemCacheConfig)
  private
    FMaxSize: Integer;
  protected
    procedure DoReadConfig(AConfigData: IConfigDataProvider); override;
    procedure DoWriteConfig(AConfigData: IConfigDataWriteProvider); override;
  protected
    function GetMaxSize: Integer;
    procedure SetMaxSize(AValue: Integer);
  public
    constructor Create;
  end;

implementation

{ TMainMemCacheConfig }

constructor TMainMemCacheConfig.Create;
begin
  FMaxSize := 150;
end;

procedure TMainMemCacheConfig.DoReadConfig(AConfigData: IConfigDataProvider);
begin
  inherited;
  if AConfigData <> nil then begin
    FMaxSize := AConfigData.ReadInteger('MainMemCacheSize', FMaxSize);
    if FMaxSize < 0 then begin
      FMaxSize := 0;
    end;
    SetChanged;
  end;
end;

procedure TMainMemCacheConfig.DoWriteConfig(
  AConfigData: IConfigDataWriteProvider);
begin
  inherited;
  AConfigData.WriteInteger('MainMemCacheSize', FMaxSize);
end;

function TMainMemCacheConfig.GetMaxSize: Integer;
begin
  LockRead;
  try
    Result := FMaxSize;
  finally
    UnlockRead;
  end;
end;

procedure TMainMemCacheConfig.SetMaxSize(AValue: Integer);
var
  VMaxSize: Integer;
begin
  LockWrite;
  try
    VMaxSize := AValue;
    if VMaxSize < 0 then begin
      VMaxSize := 0;
    end;
    if FMaxSize <> VMaxSize then begin
      FMaxSize := VMaxSize;
      SetChanged;
    end;
  finally
    UnlockWrite;
  end;
end;

end.
