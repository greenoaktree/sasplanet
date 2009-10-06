unit u_TesterCoordConvertAbstract;

interface

uses
  u_CoordConverterAbstract;

type
  TTesterCoordConverterAbstract = class
  protected
    FConverter: ICoordConverter;
    FEpsilon: Extended;
    function CheckExtended(E1, E2: Extended): Boolean;
  public
    constructor Create(AConverter: ICoordConverter);
    destructor Destroy; override;
    procedure Check_TilesAtZoom; virtual;
    procedure Check_TilePos2PixelRect; virtual;
    procedure Check_TilePos2Relative; virtual;
    procedure Check_TilePos2RelativeRect; virtual;
    procedure CheckConverter; virtual;
  end;
implementation

uses
  Types,
  SysUtils,
  t_GeoTypes;

{ TTesterCoordConverterAbstract }

procedure TTesterCoordConverterAbstract.CheckConverter;
begin
  try
    Check_TilesAtZoom;
  except
    on E: Exception do begin
      raise Exception.Create('������ ��� ������������ ������� TilesAtZoom:' + E.Message);
    end;
  end;

  try
    Check_TilePos2PixelRect;
  except
    on E: Exception do begin
      raise Exception.Create('������ ��� ������������ ������� TilePos2PixelRect:' + E.Message);
    end;
  end;

  try
    Check_TilePos2Relative;
  except
    on E: Exception do begin
      raise Exception.Create('������ ��� ������������ ������� TilePos2Relative:' + E.Message);
    end;
  end;

  try
    Check_TilePos2RelativeRect;
  except
    on E: Exception do begin
      raise Exception.Create('������ ��� ������������ ������� TilePos2RelativeRect:' + E.Message);
    end;
  end;

end;

function TTesterCoordConverterAbstract.CheckExtended(E1,
  E2: Extended): Boolean;
begin
  Result := abs(E1-E2) < FEpsilon;
end;

procedure TTesterCoordConverterAbstract.Check_TilePos2PixelRect;
var
  Res: TRect;
begin
  Res := FConverter.TilePos2PixelRect(Point(0, 0), 0);
  if Res.Left <> 0 then
    raise Exception.Create('Z = 0. ������ � Left ��������������');
  if Res.Top <> 0 then
    raise Exception.Create('Z = 0. ������ � Top ��������������');
  if Res.Right <> 255 then
    raise Exception.Create('Z = 0. ������ � Right ��������������');
  if Res.Bottom <> 255 then
    raise Exception.Create('Z = 0. ������ � Bottom ��������������');

  Res := FConverter.TilePos2PixelRect(Point(1, 0), 1);
  if Res.Left <> 256 then
    raise Exception.Create('Z = 1. ������ � Left ��������������');
  if Res.Top <> 0 then
    raise Exception.Create('Z = 1. ������ � Top ��������������');
  if Res.Right <> 511 then
    raise Exception.Create('Z = 1. ������ � Right ��������������');
  if Res.Bottom <> 255 then
    raise Exception.Create('Z = 1. ������ � Bottom ��������������');

  Res := FConverter.TilePos2PixelRect(Point(FConverter.TilesAtZoom(23) - 1, FConverter.TilesAtZoom(23) - 1), 23);
  if Res.Left <> 2147483392 then
    raise Exception.Create('Z = 23. ������ � Left ��������������');
  if Res.Top <> 2147483392 then
    raise Exception.Create('Z = 23. ������ � Top ��������������');
  if Res.Right <> 2147483647 then
    raise Exception.Create('Z = 23. ������ � Right ��������������');
  if Res.Bottom <> 2147483647 then
    raise Exception.Create('Z = 23. ������ � Bottom ��������������');
end;

procedure TTesterCoordConverterAbstract.Check_TilePos2Relative;
var
  Res: TExtendedPoint;
begin
  Res := FConverter.TilePos2Relative(Point(0, 0), 0);
  if not CheckExtended(Res.X, 0) then
    raise Exception.Create('�� ���� 0 ������������� ���������� ������������� ����� ������ ���� (0;0)');
  if not CheckExtended(Res.Y, 0) then
    raise Exception.Create('�� ���� 0 ������������� ���������� ������������� ����� ������ ���� (0;0)');

  Res := FConverter.TilePos2Relative(Point(0, 0), 1);
  if not CheckExtended(Res.X, 0) then
    raise Exception.Create('�� ���� 1 ������������� ���������� ����� (0;0) ������ ���� (0;0)');
  if not CheckExtended(Res.Y, 0) then
    raise Exception.Create('�� ���� 1 ������������� ���������� ����� (0;0) ������ ���� (0;0)');

  Res := FConverter.TilePos2Relative(Point(1, 1), 1);
  if not CheckExtended(Res.X, 0.5) then
    raise Exception.Create('�� ���� 1 ������������� ���������� ����� (1;1) ������ ���� (0.5;0.5)');
  if not CheckExtended(Res.Y, 0.5) then
    raise Exception.Create('�� ���� 1 ������������� ���������� ����� (1;1) ������ ���� (0.5;0.5)');

  Res := FConverter.TilePos2Relative(Point(2, 2), 1);
  if not CheckExtended(Res.X, 1) then
    raise Exception.Create('�� ���� 1 ������������� ���������� ����� (2;2) ������ ���� (1;1)');
  if not CheckExtended(Res.Y, 1) then
    raise Exception.Create('�� ���� 1 ������������� ���������� ����� (2;2) ������ ���� (1;1)');

  Res := FConverter.TilePos2Relative(Point(0, 0), 23);
  if not CheckExtended(Res.X, 0) then
    raise Exception.Create('�� ���� 23 ������������� ���������� ����� (0;0) ������ ���� (0;0)');
  if not CheckExtended(Res.Y, 0) then
    raise Exception.Create('�� ���� 23 ������������� ���������� ����� (0;0) ������ ���� (0;0)');

  Res := FConverter.TilePos2Relative(Point(1, 1), 23);
  if not CheckExtended(Res.X, 1.1920928955e-07) then
    raise Exception.Create('�� ���� 23 ������������� ���������� ����� (1;1) ������ ���� (1.1920928955e-07;1.1920928955e-07)');
  if not CheckExtended(Res.Y, 1.1920928955e-07) then
    raise Exception.Create('�� ���� 23 ������������� ���������� ����� (1;1) ������ ���� (1.1920928955e-07;1.1920928955e-07)');

  Res := FConverter.TilePos2Relative(Point(1 shl 23, 1 shl 23), 23);
  if not CheckExtended(Res.X, 1) then
    raise Exception.Create('�� ���� 23 ������������� ���������� ����� (Max;Max) ������ ���� (1;1)');
  if not CheckExtended(Res.Y, 1) then
    raise Exception.Create('�� ���� 23 ������������� ���������� ����� (Max;Max) ������ ���� (1;1)');
end;

procedure TTesterCoordConverterAbstract.Check_TilePos2RelativeRect;
var
  Res: TExtendedRect;
begin
  Res := FConverter.TilePos2RelativeRect(Point(0,0),0);
  if not CheckExtended(Res.Left, 0) then
    raise Exception.Create('Z = 0. ������ � Left');
  if not CheckExtended(Res.Top, 0) then
    raise Exception.Create('Z = 0. ������ � Top');
  if not CheckExtended(Res.Right, 1) then
    raise Exception.Create('Z = 0. ������ � Right');
  if not CheckExtended(Res.Bottom, 1) then
    raise Exception.Create('Z = 0. ������ � Bottom');
end;

procedure TTesterCoordConverterAbstract.Check_TilesAtZoom;
var
  Res: Integer;
begin
  Res := FConverter.TilesAtZoom(0);
  if Res <> 1 then
    raise Exception.Create('�� ���� 0 ������ ���� 1 ����');

  Res := FConverter.TilesAtZoom(1);
  if Res <> 2 then
    raise Exception.Create('�� ���� 1 ������ ���� 2 �����');

  Res := FConverter.TilesAtZoom(23);
  if Res <> 8388608 then
    raise Exception.Create('�� ���� 23 ������ ���� 8388608 ������');
end;

constructor TTesterCoordConverterAbstract.Create(
  AConverter: ICoordConverter);
begin
  FConverter := AConverter;
  FEpsilon := 1/(1 shl 30 + (1 shl 30 - 1));
end;

destructor TTesterCoordConverterAbstract.Destroy;
begin
  FConverter := nil;
  inherited;
end;

end.
