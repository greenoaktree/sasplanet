unit u_TileIteratorAbstract;

interface

uses
  Types,
  t_GeoTypes,
  i_ICoordConverter;

type
  TTileIteratorAbstract = class
  protected
    function GetTilesTotal: Int64; virtual; abstract;
    function GetTilesRect: TRect; virtual; abstract;
  public
    function Next(out ATile: TPoint): Boolean; virtual; abstract;
    procedure Reset; virtual; abstract;
    property TilesTotal: Int64 read GetTilesTotal;
    property TilesRect: TRect read GetTilesRect;
  end;

  TTileIteratorByPolygonAbstract = class(TTileIteratorAbstract)
  protected
    FPolygLL: TDoublePointArray;
    FZoom: byte;
    FGeoConvert: ICoordConverter;
    FCurrent: TPoint;
  public
    constructor Create(AZoom: byte; APolygLL: TDoublePointArray; AGeoConvert: ICoordConverter); virtual;
    destructor Destroy; override;
  end;

implementation

uses
  Ugeofun;

{ TTileIteratorByPolygonAbstract }

constructor TTileIteratorByPolygonAbstract.Create(AZoom: byte;
  APolygLL: TDoublePointArray; AGeoConvert: ICoordConverter);
begin
  FZoom := AZoom;
  FPolygLL := Copy(APolygLL);
  FGeoConvert := AGeoConvert;
end;

destructor TTileIteratorByPolygonAbstract.Destroy;
begin
  FPolygLL := nil;
  FGeoConvert := nil;
  inherited;
end;

end.


