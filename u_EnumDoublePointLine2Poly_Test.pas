unit u_EnumDoublePointLine2Poly_Test;

interface

uses
  TestFramework,
  u_SASTestCase,
  t_GeoTypes,
  i_CoordConverter,
  i_ProjectionInfo,
  i_EnumDoublePoint;

type
  TestTEnumDoublePointLine2Poly = class(TSASTestCase)
  private
    FConverter: ICoordConverter;
    FZoom: Byte;
    FProjection: IProjectionInfo;
    FRadius: Double;
    function PrepareEnumByArray(AData: TArrayOfDoublePoint): IEnumLonLatPoint;
  protected
    procedure SetUp; override;
  published
    procedure TestTwoPoints;
    procedure TestFivePoints;
  end;

implementation

uses
  u_GeoFun,
  c_CoordConverter,
  i_CoordConverterFactory,
  u_CoordConverterFactorySimple,
  u_ProjectionInfo,
  u_EnumDoublePointsByArray,
  u_EnumDoublePointLine2Poly;

{ TestTEnumDoublePointLine2Poly }

function TestTEnumDoublePointLine2Poly.PrepareEnumByArray(
  AData: TArrayOfDoublePoint): IEnumLonLatPoint;
var
  VDataEnum: IEnumLonLatPoint;
begin
  VDataEnum := TEnumLonLatPointsByArray.Create(@AData[0], Length(AData));
  Result := TEnumDoublePointLine2Poly.Create(VDataEnum, FRadius, FProjection);
end;

procedure TestTEnumDoublePointLine2Poly.SetUp;
var
  VConveterFactory: ICoordConverterFactory;
begin
  inherited;
  FZoom := 18;
  FRadius := 1000;
  VConveterFactory := TCoordConverterFactorySimple.Create;
  FConverter := VConveterFactory.GetCoordConverterByCode(CGoogleProjectionEPSG, CTileSplitQuadrate256x256);
  FProjection := TProjectionInfo.Create(FConverter, FZoom);
end;

procedure TestTEnumDoublePointLine2Poly.TestFivePoints;
var
  VSource: TArrayOfDoublePoint;
  VResult: TArrayOfDoublePoint;
  i: Integer;
  VEnum: IEnumDoublePoint;
  VPoint: TDoublePoint;
begin
  SetLength(VSource, 5);
  VSource[0] := DoublePoint(10, 10);
  VSource[1] := DoublePoint(11, 11);
  VSource[2] := DoublePoint(12, 10);
  VSource[3] := DoublePoint(13, 11);
  VSource[4] := DoublePoint(14, 11);
  SetLength(VResult, 11);
  VResult[0] := DoublePoint(10.000109176, 9.9872758672);
  VResult[1] := DoublePoint(11, 10.987207936);
  VResult[2] := DoublePoint(12, 9.9871665133);
  VResult[3] := DoublePoint(13.003835966, 10.991016706);
  VResult[4] := DoublePoint(14.009151292, 10.991016706);
  VResult[5] := DoublePoint(14.009151292, 11.00898302);
  VResult[6] := DoublePoint(12.996164034, 11.00898302);
  VResult[7] := DoublePoint(12, 10.01283298);
  VResult[8] := DoublePoint(11, 11.012791509);
  VResult[9] := DoublePoint(9.9870798298, 9.9998924829);
  VResult[10] := DoublePoint(10.000109176, 9.9872758672);
  VEnum := PrepareEnumByArray(VSource);
  for i := 0 to Length(VResult) - 1 do begin
    CheckTrue(VEnum.Next(VPoint));
    CheckDoublePointsEquals(VResult[i], VPoint, 0.0000001);
  end;
  CheckFalse(VEnum.Next(VPoint));
end;

procedure TestTEnumDoublePointLine2Poly.TestTwoPoints;
var
  VSource: TArrayOfDoublePoint;
  VResult: TArrayOfDoublePoint;
  i: Integer;
  VEnum: IEnumDoublePoint;
  VPoint: TDoublePoint;
begin
  SetLength(VSource, 2);
  VSource[0] := DoublePoint(10, 10);
  VSource[1] := DoublePoint(11, 11);
  SetLength(VResult, 5);
  VResult[0] := DoublePoint(10.000109176, 9.9872758672);
  VResult[1] := DoublePoint(11.01292017, 11.00010717);
  VResult[2] := DoublePoint(10.999890824, 11.012682517);
  VResult[3] := DoublePoint(9.9870798298, 9.9998924829);
  VResult[4] := DoublePoint(10.000109176, 9.9872758672);
  VEnum := PrepareEnumByArray(VSource);
  for i := 0 to Length(VResult) - 1 do begin
    CheckTrue(VEnum.Next(VPoint));
    CheckDoublePointsEquals(VResult[i], VPoint, 0.0000001);
  end;
  CheckFalse(VEnum.Next(VPoint));
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTEnumDoublePointLine2Poly.Suite);
end.
